import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nhgarden/services/auth_service.dart';

import '../../models/app_user.dart';
import '../../services/owner_service.dart';
import '../../services/user_service.dart';
import '../admin/admin_dashboard.dart';
import '../general/general_dashboard.dart';

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

      debugPrint('Login Successful');
      debugPrint('Firebase UID: ${firebaseUser.uid}');
      debugPrint('Email: ${firebaseUser.email}');

      // -------------------------------------------------
      // 2. Get MySQL User
      // -------------------------------------------------

      final appUser = await UserService.getCurrentUser();

      debugPrint('--------------------------');
      debugPrint('MySQL User ID: ${appUser.id}');
      debugPrint('Username: ${appUser.username}');
      debugPrint('Email: ${appUser.email}');
      debugPrint('Role: ${appUser.role}');
      debugPrint('Is Admin: ${appUser.isAdmin}');
      debugPrint('Is General: ${appUser.isGeneral}');
      debugPrint('--------------------------');


      // -------------------------------------------------
      // 3. Check User Role
      // -------------------------------------------------

      if (appUser.isAdmin) {
        debugPrint('Admin user detected.');

        // We will create AdminDashboardScreen next.
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
        debugPrint('General user detected.');

        // Get the owner belonging to this user.
        final owner = await OwnerService.getCurrentOwner();

        debugPrint('--------------------------');
        debugPrint('Current Owner ID: ${owner.ownerId}');
        debugPrint('Current Owner Name: ${owner.ownerName}');
        debugPrint('Number of Gardens: ${owner.gardens.length}');
        debugPrint('--------------------------');

        for (final garden in owner.gardens) {
          debugPrint(
            'Garden ID: ${garden.gardenId}, '
                'Garden Name: ${garden.gardenName}',
          );
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'Login failed.',
          ),
        ),
      );

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Login failed: $e',
          ),
        ),
      );

    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter your email";
                  }

                  if (!value.contains("@")) {
                    return "Please enter a valid email";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your password";
                  }

                  if (value.length < 6) {
                    return "Password must be at least 6 characters";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Text('LOGIN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}