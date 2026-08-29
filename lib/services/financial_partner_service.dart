import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../models/financial_partner.dart';

class FinancialPartnerService {
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
  // Get all financial partners
  // -------------------------------------------------

  static Future<List<FinancialPartner>>
  getPartners() async {

    final idToken = await _getIdToken();

    final response = await http.get(
      Uri.parse(
        '$baseUrl/get_financial_partners.php',
      ),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    print('PHP Status: ${response.statusCode}');
    print('PHP Response: ${response.body}');

    final responseData =
    jsonDecode(response.body);

    if (response.statusCode == 200 &&
        responseData['success'] == true) {

      final List data =
      responseData['data'];

      return data
          .map(
            (json) =>
            FinancialPartner.fromJson(json),
      )
          .toList();
    }

    throw Exception(
      responseData['message'] ??
          'Unable to retrieve financial partners.',
    );
  }

  // -------------------------------------------------
  // Add financial partner
  // -------------------------------------------------

  static Future<FinancialPartner> addPartner({
    required String partnerName,
    required String partnerInstitution,
  }) async {

    final idToken = await _getIdToken();

    final response = await http.post(
      Uri.parse(
        '$baseUrl/add_financial_partner.php',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'partner_name': partnerName,
        'partner_institution':
        partnerInstitution,
      }),
    );

    print('PHP Status: ${response.statusCode}');
    print('PHP Response: ${response.body}');

    final responseData =
    jsonDecode(response.body);

    if ((response.statusCode == 200 ||
        response.statusCode == 201) &&
        responseData['success'] == true) {

      return FinancialPartner.fromJson(
        responseData['data'],
      );
    }

    throw Exception(
      responseData['message'] ??
          'Unable to add financial partner.',
    );
  }

  // -------------------------------------------------
// Update financial partner
// -------------------------------------------------

  static Future<FinancialPartner> updatePartner({
    required int partnerId,
    required String partnerName,
    required String partnerInstitution,
  }) async {

    final idToken = await _getIdToken();

    final response = await http.post(
      Uri.parse(
        '$baseUrl/update_financial_partner.php',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'partner_id': partnerId,
        'partner_name': partnerName,
        'partner_institution': partnerInstitution,
      }),
    );

    print('PHP Status: ${response.statusCode}');
    print('PHP Response: ${response.body}');

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        responseData['success'] == true) {

      return FinancialPartner.fromJson(
        responseData['data'],
      );
    }

    throw Exception(
      responseData['message'] ??
          'Unable to update financial partner.',
    );
  }


// -------------------------------------------------
// Delete financial partner
// -------------------------------------------------

  static Future<void> deletePartner({
    required int partnerId,
  }) async {

    final idToken = await _getIdToken();

    final response = await http.post(
      Uri.parse(
        '$baseUrl/delete_financial_partner.php',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'partner_id': partnerId,
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
          'Unable to delete financial partner.',
    );
  }
}