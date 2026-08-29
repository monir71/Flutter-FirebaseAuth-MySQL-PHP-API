import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../models/garden.dart';

class GardenService {
  static const String baseUrl =
      'http://localhost/gardenfluttermysql/api';

  // -------------------------------------------------
  // Get Firebase ID Token
  // -------------------------------------------------

  static Future<String> _getIdToken() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      throw Exception('Firebase user is not logged in.');
    }

    final idToken = await firebaseUser.getIdToken();

    if (idToken == null) {
      throw Exception('Firebase ID token is not available.');
    }

    return idToken;
  }

  // -------------------------------------------------
  // Get all gardens
  // -------------------------------------------------

  static Future<List<Garden>> getGardens() async {

    final idToken = await _getIdToken();

    final response = await http.get(
      Uri.parse('$baseUrl/get_gardens.php'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    print('PHP Status: ${response.statusCode}');
    print('PHP Response: ${response.body}');

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        responseData['success'] == true) {

      final List data = responseData['data'];

      return data
          .map((json) => Garden.fromJson(json))
          .toList();
    }

    throw Exception(
      responseData['message'] ??
          'Unable to retrieve gardens.',
    );
  }

  // -------------------------------------------------
  // Add garden
  // -------------------------------------------------

  static Future<Garden> addGarden({
    required String gardenName,
  }) async {

    final idToken = await _getIdToken();

    final response = await http.post(
      Uri.parse('$baseUrl/add_garden.php'),

      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },

      body: jsonEncode({
        'garden_name': gardenName,
      }),
    );

    print('PHP Status: ${response.statusCode}');
    print('PHP Response: ${response.body}');

    final responseData = jsonDecode(response.body);

    if ((response.statusCode == 200 ||
        response.statusCode == 201) &&
        responseData['success'] == true) {

      return Garden.fromJson(
        responseData['data'],
      );
    }

    throw Exception(
      responseData['message'] ??
          'Unable to add garden.',
    );
  }

  // -------------------------------------------------
// Update garden
// -------------------------------------------------

  static Future<Garden> updateGarden({
    required int gardenId,
    required String gardenName,
  }) async {

    final idToken = await _getIdToken();

    final response = await http.put(
      Uri.parse('$baseUrl/update_garden.php'),

      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },

      body: jsonEncode({
        'garden_id': gardenId,
        'garden_name': gardenName,
      }),
    );

    print('PHP Status: ${response.statusCode}');
    print('PHP Response: ${response.body}');

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        responseData['success'] == true) {

      return Garden.fromJson(
        responseData['data'],
      );
    }

    throw Exception(
      responseData['message'] ??
          'Unable to update garden.',
    );
  }

  // -------------------------------------------------
// Delete garden
// -------------------------------------------------

  static Future<void> deleteGarden({
    required int gardenId,
  }) async {

    final idToken = await _getIdToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/delete_garden.php'),

      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },

      body: jsonEncode({
        'garden_id': gardenId,
      }),
    );

    print('PHP Status: ${response.statusCode}');
    print('PHP Response: ${response.body}');

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        responseData['success'] == true) {

      return;
    }

    throw Exception(
      responseData['message'] ??
          'Unable to delete garden.',
    );
  }
}