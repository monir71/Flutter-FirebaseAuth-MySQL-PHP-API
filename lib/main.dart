import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nhgarden/firebase_options.dart';
import 'package:nhgarden/screens/admin/admin_dashboard.dart';
import 'package:nhgarden/screens/admin/admin_dashboard_screen.dart';
import 'package:nhgarden/screens/admin/owner_management_screen.dart';
import 'package:nhgarden/screens/auth/login_screen.dart';
import 'package:nhgarden/screens/auth/register_screen.dart';
import 'package:nhgarden/screens/general/general_dashboard_screen.dart';
import 'package:nhgarden/screens/start_screen.dart';

import 'models/owner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NH Garden',
      debugShowCheckedModeBanner: false,
      routes: {
        '/admin': (context) {
          return const AdminDashboardScreen();
        },

        '/owner_manage': (context) {
          return const OwnerManagementScreen();
        },

        '/general': (context) {
          return const GeneralDashboardScreen();
        },
      },
      home: const StartScreen(),
    );
  }
}
