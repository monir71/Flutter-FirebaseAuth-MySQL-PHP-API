import 'package:flutter/material.dart';

import 'auth/login_screen.dart';
import 'auth/register_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('North Hunter Database',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
        ),
        backgroundColor: Colors.blue,
        leading: Image(image: AssetImage('assets/images/logo.png')),
      ),

      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.lightBlue,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [

                const CircleAvatar(
                  backgroundImage: AssetImage('assets/images/logo.png'),
                  radius: 100,
                ),

                const Text(
                  'Welcome to North Hunter Database',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text('LOGIN'),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text('REGISTER'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}