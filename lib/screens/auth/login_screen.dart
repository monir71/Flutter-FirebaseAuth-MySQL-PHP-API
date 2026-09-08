import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nhgarden/services/auth_service.dart';
import '../../services/owner_service.dart';
import '../../services/user_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _forgotPassword() async {
    final emailController = TextEditingController(
      text: _emailController.text.trim(),
    );

    final email = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.lock_reset_rounded),
              SizedBox(width: 10),
              Text('Forgot Password?'),
            ],
          ),
          content: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              prefixIcon: Icon(Icons.email_rounded),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                final email = emailController.text.trim();

                if (email.isEmpty || !email.contains('@')) {
                  return;
                }

                Navigator.pop(context, email);
              },
              child: const Text('SEND LINK'),
            ),
          ],
        );
      },
    );

    emailController.dispose();

    if (email == null || email.isEmpty) {
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;

      _showMessage(
        'Password reset link has been sent to your email.',
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      _showMessage(
        e.message ?? 'Unable to send password reset email.',
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Unable to send password reset email: $e',
        isError: true,
      );
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // -------------------------------------------------
      // 1. Firebase Login
      // -------------------------------------------------

      final credential = await _authService.loginUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw Exception('Firebase user was not found.');
      }

      //debugPrint('Login Successful');
      //debugPrint('Firebase UID: ${firebaseUser.uid}');
      //debugPrint('Email: ${firebaseUser.email}');

      // -------------------------------------------------
      // 2. Get MySQL User
      // -------------------------------------------------

      final appUser = await UserService.getCurrentUser();

      //debugPrint('--------------------------');
      //debugPrint('MySQL User ID: ${appUser.id}');
      //debugPrint('Username: ${appUser.username}');
      //debugPrint('Email: ${appUser.email}');
      //debugPrint('Role: ${appUser.role}');
      //debugPrint('Is Admin: ${appUser.isAdmin}');
      //debugPrint('Is General: ${appUser.isGeneral}');
      //debugPrint('--------------------------');

      // -------------------------------------------------
      // 3. Check User Role
      // -------------------------------------------------

      if (appUser.isAdmin) {
        //debugPrint('Admin user detected.');

        if (!mounted) return;

        Navigator.pushReplacementNamed(
          context,
          '/admin',
        );

        return;
      }

      // -------------------------------------------------
      // 4. General User
      // -------------------------------------------------

      if (appUser.isGeneral) {
        //debugPrint('General user detected.');

        // Get the owner belonging to this user.
        final owner = await OwnerService.getCurrentOwner();

        //debugPrint('--------------------------');
        //debugPrint('Current Owner ID: ${owner.ownerId}');
        //debugPrint('Current Owner Name: ${owner.ownerName}');
        //debugPrint('Number of Gardens: ${owner.gardens.length}');
        //debugPrint('--------------------------');

        for (final garden in owner.gardens) {
          //debugPrint(
            //'Garden ID: ${garden.gardenId}, '
                //'Garden Name: ${garden.gardenName}',
          //);
        }

        if (!mounted) return;

        Navigator.pushReplacementNamed(
          context,
          '/general',
          arguments: owner,
        );

        return;
      }

      // -------------------------------------------------
      // 5. Unknown Role
      // -------------------------------------------------

      throw Exception(
        'Unknown user role: ${appUser.role}',
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      _showMessage(
        e.message ?? 'Login failed.',
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Login failed: $e',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(
      String message, {
        bool isError = false,
      }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor:
        isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: Colors.blue.shade700,
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.blue.shade700,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.red.shade400,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.red.shade600,
          width: 2,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        elevation: 4,
        shadowColor: Colors.black26,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        titleSpacing: 18,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.lock_person_rounded,
                color: Colors.white,
                size: 23,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'North Hunter Garden',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Secure Login',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 430,
              ),
              child: Card(
                elevation: 8,
                shadowColor: Colors.black26,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // ---------------------------------------
                    // Header
                    // ---------------------------------------
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(
                        24,
                        30,
                        24,
                        28,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade800,
                            Colors.blue.shade600,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.login_rounded,
                              color: Colors.white,
                              size: 42,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Welcome Back',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Sign in to continue to NH Garden',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ---------------------------------------
                    // Login Form
                    // ---------------------------------------
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.account_circle_rounded,
                                  color: Colors.blue.shade700,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Account Login',
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Email
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: _inputDecoration(
                                label: 'Email',
                                hint: 'Enter your email',
                                icon: Icons.email_rounded,
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty) {
                                  return 'Please enter your email';
                                }

                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Password
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) {
                                if (!_isLoading) {
                                  _login();
                                }
                              },
                              decoration: _inputDecoration(
                                label: 'Password',
                                hint: 'Enter your password',
                                icon: Icons.lock_rounded,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  tooltip: _obscurePassword
                                      ? 'Show password'
                                      : 'Hide password',
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_rounded
                                        : Icons.visibility_off_rounded,
                                    color: Colors.grey.shade600,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword =
                                      !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }

                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 8),

                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: _isLoading ? null : _forgotPassword,
                                icon: const Icon(
                                  Icons.lock_reset_rounded,
                                  size: 18,
                                ),
                                label: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.blue.shade700,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 4,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),
                            // Login button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : _login,
                                icon: _isLoading
                                    ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                                    : const Icon(
                                  Icons.login_rounded,
                                ),
                                label: Text(
                                  _isLoading
                                      ? 'SIGNING IN...'
                                      : 'LOGIN',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  Colors.blue.shade700,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                  Colors.blue.shade300,
                                  disabledForegroundColor:
                                  Colors.white,
                                  elevation: 4,
                                  shadowColor: Colors.blue.shade200,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // Security note
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius:
                                BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue.shade100,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.security_rounded,
                                    color: Colors.blue.shade700,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Your account is securely authenticated '
                                          'using Firebase.',
                                      style: TextStyle(
                                        color: Colors.blue.shade800,
                                        fontSize: 12,
                                        height: 1.4,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}