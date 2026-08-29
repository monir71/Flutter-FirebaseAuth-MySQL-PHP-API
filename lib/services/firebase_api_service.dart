import 'dart:convert';

import 'package:http/http.dart' as http;

class FirebaseApiService {
  //Change this to your actual PHP API URL
  static const String baseUrl = "http://localhost/gardenfluttermysql/api";

  Future<void> syncUser({
    required String idToken,
    required String username,
    required String email,
  }) async {
    final url = Uri.parse("$baseUrl/firebase_user.php");
    final response = await http.post(
      url,
      headers: {
        'Content-Type' : 'application/json',
        'Authorization' : 'Bearer $idToken',
      },
      body: jsonEncode({
        'username' : username,
        'email' : email,
      }),
    );

    print("HTTP Status: ${response.statusCode}");
    print("API Response: ${response.body}");

    if(response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to sync Firebase user: ${response.body}',
      );
    }
  }

}