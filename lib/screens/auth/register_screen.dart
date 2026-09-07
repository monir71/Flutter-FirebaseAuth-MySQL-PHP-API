import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nhgarden/services/auth_service.dart';
import '../../services/user_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ---------------------------------------------
      // 1. Create Firebase Authentication account
      // ---------------------------------------------

      final credential = await _authService.registerUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      //debugPrint("Firebase Registration Successful");
      //debugPrint("Firebase UID: ${credential.user!.uid}");

      // ---------------------------------------------
      // 2. Synchronize Firebase user with MySQL
      // ---------------------------------------------

      final appUser = await UserService.syncUser(
        username: _usernameController.text.trim(),
      );

      //debugPrint("MySQL User Created");
      //debugPrint("MySQL ID: ${appUser.id}");
      //debugPrint("Username: ${appUser.username}");
      //debugPrint("Email: ${appUser.email}");
      //debugPrint("Role: ${appUser.role}");

      // ---------------------------------------------
      // 3. Show success
      // ---------------------------------------------

      if (!mounted) return;

      _showMessage(
        "Registration Successful. Role: ${appUser.role}",
        isSuccess: true,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      _showMessage(
        e.message ?? "Registration Failed",
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        "Unexpected Error: $e",
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
        bool isSuccess = false,
      }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : isSuccess
                  ? Icons.check_circle_outline_rounded
                  : Icons.info_outline_rounded,
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
        backgroundColor: isError
            ? Colors.red.shade700
            : isSuccess
            ? Colors.green.shade700
            : Colors.blue.shade700,
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
    _usernameController.dispose();

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
                Icons.person_add_alt_1_rounded,
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
                  'NH Garden',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Create Account',
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
                              Icons.person_add_alt_1_rounded,
                              color: Colors.white,
                              size: 42,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Create Your Account',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Register to get started with NH Garden',
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
                    // Registration Form
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
                                  'Account Information',
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Username
                            TextFormField(
                              controller: _usernameController,
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                              decoration: _inputDecoration(
                                label: 'Username',
                                hint: 'Enter your username',
                                icon: Icons.person_rounded,
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty) {
                                  return 'Please enter your username';
                                }

                                if (value.trim().length < 3) {
                                  return 'Username must be at least 3 characters';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

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
                                  _register();
                                }
                              },
                              decoration: _inputDecoration(
                                label: 'Password',
                                hint: 'Create a password',
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

                            const SizedBox(height: 26),

                            // Register button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed:
                                _isLoading ? null : _register,
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
                                  Icons.person_add_rounded,
                                ),
                                label: Text(
                                  _isLoading
                                      ? 'CREATING ACCOUNT...'
                                      : 'REGISTER',
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

                            // Security information
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
                                      'Your account will be securely '
                                          'authenticated using Firebase.',
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