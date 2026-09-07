import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/dashboard_data.dart';
import '../models/general_user.dart';
import '../models/owner.dart';

class OwnerService {
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
  // Get Owners
  // -------------------------------------------------

  static Future<List<Owner>> getOwners() async {
    final idToken = await _getIdToken();

    final response = await http.get(
      Uri.parse('$baseUrl/get_owners.php'),
      headers: {'Authorization': 'Bearer $idToken'},
    );

    //print('PHP Status: ${response.statusCode}');
    //print('PHP Response: ${response.body}');

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      final List<dynamic> data = responseData['data'] ?? [];

      return data
          .map((json) => Owner.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    throw Exception(responseData['message'] ?? 'Unable to retrieve owners.');
  }

  // -------------------------------------------------
  // Add Owner
  // -------------------------------------------------

  static Future<Owner> addOwner({
    required String ownerName,
    required List<int> gardenIds,
  }) async {
    final idToken = await _getIdToken();

    final response = await http.post(
      Uri.parse('$baseUrl/add_owner.php'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({'owner_name': ownerName, 'garden_ids': gardenIds}),
    );

    //print('PHP Status: ${response.statusCode}');
    //print('PHP Response: ${response.body}');

    final responseData = jsonDecode(response.body);

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        responseData['success'] == true) {
      return Owner.fromJson(responseData['data']);
    }

    throw Exception(responseData['message'] ?? 'Unable to add owner.');
  }

  // -------------------------------------------------
  // Get Current Owner ID
  // -------------------------------------------------

  static Future<int> getCurrentOwnerId() async {
    final idToken = await _getIdToken();

    final response = await http.get(
      Uri.parse('$baseUrl/get_current_owner.php'),
      headers: {'Authorization': 'Bearer $idToken'},
    );

    //print('PHP Status: ${response.statusCode}');
    //print('PHP Response: ${response.body}');

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      return int.parse(responseData['data']['owner_id'].toString());
    }

    throw Exception(
      responseData['message'] ?? 'Unable to retrieve current owner.',
    );
  }

  // -------------------------------------------------
  // Get Current Owner
  // -------------------------------------------------

  static Future<Owner> getCurrentOwner() async {
    final currentOwnerId = await getCurrentOwnerId();

    final owners = await getOwners();

    try {
      return owners.firstWhere((owner) => owner.ownerId == currentOwnerId);
    } catch (e) {
      throw Exception('Current owner was not found in the owners list.');
    }
  }

  // -------------------------------------------------
  // Delete Owner
  // -------------------------------------------------

  static Future<void> deleteOwner({required int ownerId}) async {
    final idToken = await _getIdToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/delete_owner.php'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({'owner_id': ownerId}),
    );

    //print('PHP Status: ${response.statusCode}');
    //print('PHP Response: ${response.body}');

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      return;
    }

    throw Exception(responseData['message'] ?? 'Unable to delete owner.');
  }

  // -------------------------------------------------
  // Update Owner
  // -------------------------------------------------

  static Future<Owner> updateOwner({
    required int ownerId,
    required String ownerName,
  }) async {
    final idToken = await _getIdToken();

    final response = await http.post(
      Uri.parse('$baseUrl/update_owner.php'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({'owner_id': ownerId, 'owner_name': ownerName}),
    );

    //print('PHP Status: ${response.statusCode}');
    //print('PHP Response: ${response.body}');

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      return Owner.fromJson({...responseData['data'], 'gardens': []});
    }

    throw Exception(responseData['message'] ?? 'Unable to update owner.');
  }

  // -------------------------------------------------
  // Update Owner Gardens
  // -------------------------------------------------

  static Future<void> updateOwnerGardens({
    required int ownerId,
    required List<int> gardenIds,
  }) async {
    final idToken = await _getIdToken();

    final response = await http.post(
      Uri.parse('$baseUrl/update_owner_gardens.php'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({'owner_id': ownerId, 'garden_ids': gardenIds}),
    );

    //print('PHP Status: ${response.statusCode}');
    //print('PHP Response: ${response.body}');

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      return;
    }

    throw Exception(
      responseData['message'] ?? 'Unable to update owner gardens.',
    );
  }

  // -------------------------------------------------
  // Get My Dashboard
  // -------------------------------------------------

  static Future<DashboardData> getMyDashboard() async {
    final idToken = await _getIdToken();

    final response = await http.get(
      Uri.parse('$baseUrl/get_my_dashboard.php'),
      headers: {'Authorization': 'Bearer $idToken'},
    );

    //print('PHP Status: ${response.statusCode}');
    //print('PHP Response: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return DashboardData.fromJson(data['data']);
    }

    throw Exception(data['message'] ?? 'Unable to load dashboard.');
  }

  // -------------------------------------------------
  // Get Available General Users
  // -------------------------------------------------

  static Future<List<GeneralUser>> getUnlinkedUsers() async {
    final idToken = await _getIdToken();

    final response = await http.get(
      Uri.parse('$baseUrl/get_unlinked_users.php'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    //print('PHP Status: ${response.statusCode}');
    //print('PHP Response: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        data['success'] == true) {

      final List<dynamic> users =
          data['data'] ?? [];

      return users
          .map(
            (user) => GeneralUser.fromJson(
          user as Map<String, dynamic>,
        ),
      )
          .toList();
    }

    throw Exception(
      data['message'] ??
          'Unable to retrieve available users.',
    );
  }

  // -------------------------------------------------
  // Assign User to Owner
  // -------------------------------------------------

  static Future<Map<String, dynamic>> assignOwnerUser({
    required int ownerId,
    required int userId,
  }) async {
    final idToken = await _getIdToken();

    final response = await http.post(
      Uri.parse('$baseUrl/link_owner_user.php'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({'owner_id': ownerId, 'user_id': userId}),
    );

    //print('PHP Status: ${response.statusCode}');
    //print('PHP Response: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return Map<String, dynamic>.from(data['data']);
    }

    throw Exception(data['message'] ?? 'Unable to assign user to owner.');
  }

  // -------------------------------------------------
  // Unlink User from Owner
  // -------------------------------------------------

  static Future<void> unlinkOwnerUser({required int ownerId}) async {
    final idToken = await _getIdToken();

    final response = await http.post(
      Uri.parse('$baseUrl/unlink_owner_user.php'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({'owner_id': ownerId}),
    );

    //print('PHP Status: ${response.statusCode}');
    //print('PHP Response: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return;
    }

    throw Exception(data['message'] ?? 'Unable to unlink user from owner.');
  }

  // -------------------------------------------------
  // Upload Owner Photo
  // -------------------------------------------------

  static Future<String> uploadOwnerPhoto({
    required int ownerId,
    required XFile photo,
  }) async {
    final idToken = await _getIdToken();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload_owner_photo.php'),
    );

    request.headers['Authorization'] = 'Bearer $idToken';

    request.fields['owner_id'] = ownerId.toString();

    request.files.add(
      await http.MultipartFile.fromPath(
        'photo',
        photo.path,
      ),
    );

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(streamedResponse);

    //print('PHP Status: ${response.statusCode}');
    //print('PHP Response: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return data['data']['owner_photo'].toString();
    }

    throw Exception(
      data['message'] ?? 'Unable to upload owner photo.',
    );
  }

  // -------------------------------------------------
  // Admin Dashboard Garden Details
  // -------------------------------------------------

  static Future<List<DashboardGarden>> getAdminGardens() async {
    final idToken = await _getIdToken();

    final response = await http.get(
      Uri.parse('$baseUrl/get_admin_gardens.php'),
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    //print('PHP Status: ${response.statusCode}');
    //print('PHP Response: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final List<dynamic> gardens = data['data'] ?? [];

      return gardens
          .map(
            (garden) => DashboardGarden.fromJson(
          garden as Map<String, dynamic>,
        ),
      )
          .toList();
    }

    throw Exception(
      data['message'] ?? 'Unable to load admin gardens.',
    );
  }
}
