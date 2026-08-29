import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../models/fund.dart';

class FundService {
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
  // Get Funds
  // -------------------------------------------------

  static Future<List<Fund>> getFunds() async {

    final idToken = await _getIdToken();

    final response = await http.get(
      Uri.parse('$baseUrl/get_funds.php'),
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
          .map(
            (json) => Fund.fromJson(json),
      )
          .toList();
    }

    throw Exception(
      responseData['message'] ??
          'Unable to retrieve funds.',
    );
  }

  // -------------------------------------------------
  // Add Fund
  // -------------------------------------------------

  static Future<Fund> addFund({
    required int ownerId,
    required int gardenId,
    required double fundAmount,
    required String fundDate,
  }) async {

    final idToken = await _getIdToken();

    final response = await http.post(
      Uri.parse('$baseUrl/add_fund.php'),

      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },

      body: jsonEncode({
        'owner_id': ownerId,
        'garden_id': gardenId,
        'fund_amount': fundAmount,
        'fund_date': fundDate,
      }),
    );

    print('PHP Status: ${response.statusCode}');
    print('PHP Response: ${response.body}');

    final responseData = jsonDecode(response.body);

    if ((response.statusCode == 200 ||
        response.statusCode == 201) &&
        responseData['success'] == true) {

      return Fund.fromJson(
        responseData['data'],
      );
    }

    throw Exception(
      responseData['message'] ??
          'Unable to add fund.',
    );
  }

  // -------------------------------------------------
// Update Fund
// -------------------------------------------------

  static Future<void> updateFund({
    required int fundId,
    required int ownerId,
    required int gardenId,
    required double fundAmount,
    required String fundDate,
  }) async {

    final idToken = await _getIdToken();

    final response = await http.post(
      Uri.parse('$baseUrl/update_fund.php'),

      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },

      body: jsonEncode({
        'fund_id': fundId,
        'owner_id': ownerId,
        'garden_id': gardenId,
        'fund_amount': fundAmount,
        'fund_date': fundDate,
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
          'Unable to update fund.',
    );
  }

  // -------------------------------------------------
// Delete Fund
// -------------------------------------------------

  static Future<void> deleteFund({
    required int fundId,
  }) async {

    final idToken = await _getIdToken();

    final response = await http.post(
      Uri.parse('$baseUrl/delete_fund.php'),

      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },

      body: jsonEncode({
        'fund_id': fundId,
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
          'Unable to delete fund.',
    );
  }
}