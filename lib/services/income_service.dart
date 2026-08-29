import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../models/income.dart';

class IncomeService {
  static const String baseUrl =
      'http://localhost/gardenfluttermysql/api';

  // -------------------------------------------------
  // Get Firebase ID Token
  // -------------------------------------------------

  static Future<String> _getIdToken() async {

    final firebaseUser =
        FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      throw Exception(
        'Firebase user is not logged in.',
      );
    }

    final idToken =
    await firebaseUser.getIdToken();

    if (idToken == null) {
      throw Exception(
        'Firebase ID token is not available.',
      );
    }

    return idToken;
  }

  // -------------------------------------------------
  // Get Incomes
  // -------------------------------------------------

  static Future<List<Income>> getIncomes() async {

    final idToken = await _getIdToken();

    final response = await http.get(
      Uri.parse(
        '$baseUrl/get_incomes.php',
      ),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    print(
      'PHP Status: ${response.statusCode}',
    );

    print(
      'PHP Response: ${response.body}',
    );

    final responseData =
    jsonDecode(response.body);

    if (response.statusCode == 200 &&
        responseData['success'] == true) {

      final List data =
      responseData['data'];

      return data
          .map(
            (json) => Income.fromJson(json),
      )
          .toList();
    }

    throw Exception(
      responseData['message'] ??
          'Unable to retrieve incomes.',
    );
  }

  // -------------------------------------------------
  // Add Income
  // -------------------------------------------------

  static Future<Income> addIncome({
    required int ownerId,
    required int gardenId,
    required String incomeSource,
    required double incomeAmount,
    required String incomeDate,
  }) async {

    final idToken = await _getIdToken();

    final response = await http.post(
      Uri.parse(
        '$baseUrl/add_income.php',
      ),

      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },

      body: jsonEncode({
        'owner_id': ownerId,
        'garden_id': gardenId,
        'income_source': incomeSource,
        'income_amount': incomeAmount,
        'income_date': incomeDate,
      }),
    );

    print(
      'PHP Status: ${response.statusCode}',
    );

    print(
      'PHP Response: ${response.body}',
    );

    final responseData =
    jsonDecode(response.body);

    if ((response.statusCode == 200 ||
        response.statusCode == 201) &&
        responseData['success'] == true) {

      return Income.fromJson(
        responseData['data'],
      );
    }

    throw Exception(
      responseData['message'] ??
          'Unable to add income.',
    );
  }

  // -------------------------------------------------
  // Update Income
  // -------------------------------------------------

  static Future<Income> updateIncome({
    required int incomeId,
    required int ownerId,
    required int gardenId,
    required String incomeSource,
    required double incomeAmount,
    required String incomeDate,
  }) async {

    final idToken = await _getIdToken();

    final response = await http.put(
      Uri.parse(
        '$baseUrl/update_income.php',
      ),

      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },

      body: jsonEncode({
        'income_id': incomeId,
        'owner_id': ownerId,
        'garden_id': gardenId,
        'income_source': incomeSource,
        'income_amount': incomeAmount,
        'income_date': incomeDate,
      }),
    );

    print(
      'PHP Status: ${response.statusCode}',
    );

    print(
      'PHP Response: ${response.body}',
    );

    final responseData =
    jsonDecode(response.body);

    if (response.statusCode == 200 &&
        responseData['success'] == true) {

      return Income.fromJson(
        responseData['data'],
      );
    }

    throw Exception(
      responseData['message'] ??
          'Unable to update income.',
    );
  }


  // -------------------------------------------------
  // Delete Income
  // -------------------------------------------------

  static Future<void> deleteIncome({
    required int incomeId,
  }) async {

    final idToken = await _getIdToken();

    final response = await http.delete(
      Uri.parse(
        '$baseUrl/delete_income.php',
      ),

      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },

      body: jsonEncode({
        'income_id': incomeId,
      }),
    );

    print(
      'PHP Status: ${response.statusCode}',
    );

    print(
      'PHP Response: ${response.body}',
    );

    final responseData =
    jsonDecode(response.body);

    if (response.statusCode == 200 &&
        responseData['success'] == true) {

      return;
    }

    throw Exception(
      responseData['message'] ??
          'Unable to delete income.',
    );
  }
}