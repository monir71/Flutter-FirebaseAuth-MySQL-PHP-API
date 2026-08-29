import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../models/expense.dart';

class ExpenseService {
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
  // Get Expenses
  // -------------------------------------------------

  static Future<List<Expense>> getExpenses() async {

    final idToken = await _getIdToken();

    final response = await http.get(
      Uri.parse(
        '$baseUrl/get_expenses.php',
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
            (json) => Expense.fromJson(json),
      )
          .toList();
    }

    throw Exception(
      responseData['message'] ??
          'Unable to retrieve expenses.',
    );
  }

  // -------------------------------------------------
  // Add Expense
  // -------------------------------------------------

  static Future<Expense> addExpense({
    required int ownerId,
    required int gardenId,
    required String expenseDescription,
    required double expenseAmount,
    required String expenseDate,
  }) async {

    final idToken = await _getIdToken();

    final response = await http.post(
      Uri.parse(
        '$baseUrl/add_expense.php',
      ),

      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },

      body: jsonEncode({
        'owner_id': ownerId,
        'garden_id': gardenId,
        'expense_description':
        expenseDescription,
        'expense_amount': expenseAmount,
        'expense_date': expenseDate,
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

      return Expense.fromJson(
        responseData['data'],
      );
    }

    throw Exception(
      responseData['message'] ??
          'Unable to add expense.',
    );
  }

  // -------------------------------------------------
// Update Expense
// -------------------------------------------------

  static Future<void> updateExpense({
    required int expenseId,
    required int ownerId,
    required int gardenId,
    required String expenseDescription,
    required double expenseAmount,
    required String expenseDate,
  }) async {

    final idToken = await _getIdToken();

    final response = await http.put(
      Uri.parse(
        '$baseUrl/update_expense.php',
      ),

      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },

      body: jsonEncode({
        'expense_id': expenseId,
        'owner_id': ownerId,
        'garden_id': gardenId,
        'expense_description':
        expenseDescription,
        'expense_amount': expenseAmount,
        'expense_date': expenseDate,
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

      return;
    }

    throw Exception(
      responseData['message'] ??
          'Unable to update expense.',
    );
  }

  // -------------------------------------------------
// Delete Expense
// -------------------------------------------------

  static Future<void> deleteExpense({
    required int expenseId,
  }) async {

    final idToken = await _getIdToken();

    final response = await http.delete(
      Uri.parse(
        '$baseUrl/delete_expense.php',
      ),

      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },

      body: jsonEncode({
        'expense_id': expenseId,
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
          'Unable to delete expense.',
    );
  }
}