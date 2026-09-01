import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../models/profit_transaction.dart';

class ProfitService {
  static const String baseUrl = 'http://localhost/gardenfluttermysql/api';

  // -------------------------------------------------
  // Get Firebase ID Token
  // -------------------------------------------------

  static Future<String> _getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final token = await user.getIdToken();

    if (token == null) {
      throw Exception('Unable to get Firebase ID token.');
    }

    return token;
  }

  // -------------------------------------------------
  // Create Profit Withdrawal Request
  // -------------------------------------------------

  static Future<ProfitTransaction> createProfit({
    required int gardenId,
    required double profitAmount,
    required String profitDate,
    String? profitNote,
  }) async {
    final idToken = await _getIdToken();

    final response = await http.post(
      Uri.parse('$baseUrl/create_profit.php'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'garden_id': gardenId,
        'profit_amount': profitAmount,
        'profit_date': profitDate,
        'profit_note': profitNote,
      }),
    );

    print('PHP Status: ${response.statusCode}');

    print('PHP Response: ${response.body}');

    final responseData = jsonDecode(response.body);

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        responseData['success'] == true) {
      return ProfitTransaction.fromJson(responseData['data']);
    }

    throw Exception(
      responseData['message'] ?? 'Unable to create profit transaction.',
    );
  }

  // -------------------------------------------------
  // Get Profit Transactions
  // -------------------------------------------------

  static Future<List<ProfitTransaction>> getProfits() async {
    final idToken = await _getIdToken();

    final response = await http.get(
      Uri.parse('$baseUrl/get_profits.php'),
      headers: {'Authorization': 'Bearer $idToken'},
    );

    print('PHP Status: ${response.statusCode}');

    print('PHP Response: ${response.body}');

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      final List<dynamic> data = responseData['data'] ?? [];

      return data
          .map(
            (item) => ProfitTransaction.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }

    throw Exception(
      responseData['message'] ?? 'Unable to retrieve profit transactions.',
    );
  }

  // -------------------------------------------------
  // Cancel Profit Withdrawal
  // -------------------------------------------------

  static Future<ProfitTransaction> cancelProfit({
    required int profitTransactionId,
  }) async {
    final idToken = await _getIdToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/delete_profit.php'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({'profit_transaction_id': profitTransactionId}),
    );

    print('PHP Status: ${response.statusCode}');

    print('PHP Response: ${response.body}');

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      return ProfitTransaction.fromJson(responseData['data']);
    }

    throw Exception(
      responseData['message'] ?? 'Unable to cancel profit transaction.',
    );
  }

  // -------------------------------------------------
  // Approve Profit Transaction
  // -------------------------------------------------

  static Future<ProfitTransaction> approveProfit({
    required int profitTransactionId,
  }) async {
    final idToken = await _getIdToken();

    final response = await http.post(
      Uri.parse('$baseUrl/approve_profit.php'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({'profit_transaction_id': profitTransactionId}),
    );

    print('PHP Status: ${response.statusCode}');

    print('PHP Response: ${response.body}');

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      return ProfitTransaction.fromJson(responseData['data']);
    }

    throw Exception(
      responseData['message'] ?? 'Unable to approve profit transaction.',
    );
  }

  // -------------------------------------------------
  // Reject Profit Transaction
  // -------------------------------------------------

  static Future<ProfitTransaction> rejectProfit({
    required int profitTransactionId,
    String? adminNote,
  }) async {
    final idToken = await _getIdToken();

    final response = await http.post(
      Uri.parse('$baseUrl/reject_profit.php'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'profit_transaction_id': profitTransactionId,
        'admin_note': adminNote,
      }),
    );

    print('PHP Status: ${response.statusCode}');

    print('PHP Response: ${response.body}');

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      return ProfitTransaction.fromJson(responseData['data']);
    }

    throw Exception(
      responseData['message'] ?? 'Unable to reject profit transaction.',
    );
  }

  // -------------------------------------------------
  // Get Profit Summary
  // -------------------------------------------------

  static Future<Map<String, dynamic>> getProfitSummary({
    required int gardenId,
  }) async {
    final idToken = await _getIdToken();

    final response = await http.get(
      Uri.parse(
        '$baseUrl/get_profit_summary.php'
        '?garden_id=$gardenId',
      ),
      headers: {'Authorization': 'Bearer $idToken'},
    );

    print('PHP Status: ${response.statusCode}');

    print('PHP Response: ${response.body}');

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      return Map<String, dynamic>.from(responseData['data']);
    }

    throw Exception(
      responseData['message'] ?? 'Unable to retrieve profit summary.',
    );
  }

  // -------------------------------------------------
// Get My Profit Transactions
// -------------------------------------------------

  static Future<List<ProfitTransaction>> getMyProfits() async {
    final idToken = await _getIdToken();

    final response = await http.get(
      Uri.parse('$baseUrl/get_my_profits.php'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    print('PHP Status: ${response.statusCode}');
    print('PHP Response: ${response.body}');

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        responseData['success'] == true) {

      final List<dynamic> data =
          responseData['data'] as List<dynamic>? ?? [];

      return data
          .map(
            (item) => ProfitTransaction.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList();
    }

    throw Exception(
      responseData['message'] ??
          'Unable to retrieve my profit transactions.',
    );
  }

  // -------------------------------------------------
  // Get Profit Requests - Admin
  // -------------------------------------------------

  static Future<List<ProfitTransaction>> getProfitRequests() async {
    final idToken = await _getIdToken();

    final response = await http.get(
      Uri.parse('$baseUrl/get_profit_requests.php'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    print('PHP Status: ${response.statusCode}');
    print('PHP Response: ${response.body}');

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        responseData['success'] == true) {
      final List<dynamic> data =
          responseData['data'] as List<dynamic>? ?? [];

      return data
          .map(
            (item) => ProfitTransaction.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList();
    }

    throw Exception(
      responseData['message'] ??
          'Unable to retrieve profit requests.',
    );
  }

  // -------------------------------------------------
// Get Owner's Profit Transactions
// -------------------------------------------------

  static Future<List<ProfitTransaction>> getOwnerProfitTransactions({
    required int ownerId,
    required int gardenId,
  }) async {
    final idToken = await _getIdToken();

    final response = await http.get(
      Uri.parse(
        '$baseUrl/get_owner_profit_transactions.php'
            '?owner_id=$ownerId&garden_id=$gardenId',
      ),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    print('PHP Status: ${response.statusCode}');
    print('PHP Response: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        data['success'] == true) {
      final List<dynamic> transactions = data['data'] ?? [];

      return transactions
          .map(
            (json) => ProfitTransaction.fromJson(
          json as Map<String, dynamic>,
        ),
      )
          .toList();
    }

    throw Exception(
      data['message'] ??
          'Unable to retrieve owner profit transactions.',
    );
  }
}
