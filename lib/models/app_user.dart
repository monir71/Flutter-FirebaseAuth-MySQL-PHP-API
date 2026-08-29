class AppUser {
  final int id;
  final String firebaseUid;
  final String username;
  final String email;
  final String role;
  final String createdAt;

  AppUser({
    required this.id,
    required this.firebaseUid,
    required this.username,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: int.parse(json['id'].toString()),
      firebaseUid: json['firebase_uid'].toString(),
      username: json['username'].toString(),
      email: json['email'].toString(),
      role: json['role'].toString(),
      createdAt: json['created_at'].toString(),
    );
  }

  bool get isAdmin => role == 'admin';

  bool get isGeneral => role == 'general';
}