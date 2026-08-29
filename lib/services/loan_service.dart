import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../models/loan.dart';

class LoanService {

  static const String baseUrl =
      'http://localhost/gardenfluttermysql/api';


  // -------------------------------------------------
  // Get Firebase ID Token
  // -------------------------------------------------

  static Future<String> _getIdToken() async {

    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    final token =
    await user.getIdToken();

    if (token == null) {
      throw Exception(
        'Unable to get Firebase ID token.',
      );
    }

    return token;
  }


  // -------------------------------------------------
  // Add Loan
  // -------------------------------------------------

  static Future<Loan> addLoan({
    required int partnerId,
    required int gardenId,
    required String loanPurpose,
    required double loanAmount,
    required String loanDate,
  }) async {

    final idToken =
    await _getIdToken();

    final response =
    await http.post(
      Uri.parse(
        '$baseUrl/add_loan.php',
      ),

      headers: {
        'Content-Type':
        'application/json',

        'Authorization':
        'Bearer $idToken',
      },

      body: jsonEncode({
        'partner_id':
        partnerId,

        'garden_id':
        gardenId,

        'loan_purpose':
        loanPurpose,

        'loan_amount':
        loanAmount,

        'loan_date':
        loanDate,
      }),
    );

    print(
      'PHP Status: '
          '${response.statusCode}',
    );

    print(
      'PHP Response: '
          '${response.body}',
    );

    final data =
    jsonDecode(response.body);

    if (response.statusCode == 200 &&
        data['success'] == true) {

      return Loan.fromJson(
        data['data'],
      );
    }

    throw Exception(
      data['message'] ??
          'Unable to add loan.',
    );
  }


  // -------------------------------------------------
  // Get Loans
  // -------------------------------------------------

  static Future<List<Loan>> getLoans() async {

    final idToken =
    await _getIdToken();

    final response =
    await http.get(
      Uri.parse(
        '$baseUrl/get_loans.php',
      ),

      headers: {
        'Authorization':
        'Bearer $idToken',
      },
    );

    print(
      'PHP Status: '
          '${response.statusCode}',
    );

    print(
      'PHP Response: '
          '${response.body}',
    );

    final data =
    jsonDecode(response.body);

    if (response.statusCode == 200 &&
        data['success'] == true) {

      final List<dynamic> items =
      data['data'];

      return items
          .map(
            (item) =>
            Loan.fromJson(item),
      )
          .toList();
    }

    throw Exception(
      data['message'] ??
          'Unable to load loans.',
    );
  }

  // -------------------------------------------------
  // Update Loan
  // -------------------------------------------------

  static Future<Loan> updateLoan({
    required int loanId,
    required int partnerId,
    required int gardenId,
    required String loanPurpose,
    required double loanAmount,
    required String loanDate,
  }) async {

    final idToken =
    await _getIdToken();

    final response =
    await http.put(
      Uri.parse(
        '$baseUrl/update_loan.php',
      ),

      headers: {
        'Content-Type':
        'application/json',

        'Authorization':
        'Bearer $idToken',
      },

      body: jsonEncode({
        'loan_id':
        loanId,

        'partner_id':
        partnerId,

        'garden_id':
        gardenId,

        'loan_purpose':
        loanPurpose,

        'loan_amount':
        loanAmount,

        'loan_date':
        loanDate,
      }),
    );

    print(
      'PHP Status: '
          '${response.statusCode}',
    );

    print(
      'PHP Response: '
          '${response.body}',
    );

    final data =
    jsonDecode(response.body);

    if (response.statusCode == 200 &&
        data['success'] == true) {

      return Loan.fromJson(
        data['data'],
      );
    }

    throw Exception(
      data['message'] ??
          'Unable to update loan.',
    );
  }


  // -------------------------------------------------
  // Delete Loan
  // -------------------------------------------------

  static Future<void> deleteLoan({
    required int loanId,
  }) async {

    final idToken =
    await _getIdToken();

    final response =
    await http.delete(
      Uri.parse(
        '$baseUrl/delete_loan.php',
      ),

      headers: {
        'Content-Type':
        'application/json',

        'Authorization':
        'Bearer $idToken',
      },

      body: jsonEncode({
        'loan_id':
        loanId,
      }),
    );

    print(
      'PHP Status: '
          '${response.statusCode}',
    );

    print(
      'PHP Response: '
          '${response.body}',
    );

    final data =
    jsonDecode(response.body);

    if (response.statusCode == 200 &&
        data['success'] == true) {

      return;
    }

    throw Exception(
      data['message'] ??
          'Unable to delete loan.',
    );
  }


}