import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../models/app_user.dart';

class UserService {
  static const String baseUrl =
      'http://localhost/gardenfluttermysql/api';

  static Future<AppUser> syncUser({
    required String username,
  }) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      throw Exception('Firebase user is not logged in.');
    }

    final idToken = await firebaseUser.getIdToken();

    if (idToken == null) {
      throw Exception('Firebase ID token is not available.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/firebase_sync_user.php'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'username': username,
      }),
    );

    print('PHP Status: ${response.statusCode}');
    print('PHP Response: ${response.body}');
    print('ID Token: Bearer $idToken');

    final responseData = jsonDecode(response.body);

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        responseData['success'] == true) {
      return AppUser.fromJson(
        responseData['data'],
      );
    }

    throw Exception(
      responseData['message'] ?? 'Unable to synchronize user.',
    );
  }

  static Future<AppUser> getCurrentUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      throw Exception('Firebase user is not logged in.');
    }

    final idToken = await firebaseUser.getIdToken();

    if (idToken == null) {
      throw Exception('Firebase ID token is not available.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/get_current_user.php'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    print('PHP Status: ${response.statusCode}');
    print('PHP Response: ${response.body}');
    print('ID Token: Bearer $idToken');

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        responseData['success'] == true) {
      return AppUser.fromJson(
        responseData['data'],
      );
    }

    throw Exception(
      responseData['message'] ??
          'Unable to retrieve user information.',
    );
  }
}