class GeneralUser {
  final int userId;
  final String username;
  final String email;

  GeneralUser({
    required this.userId,
    required this.username,
    required this.email,
  });

  factory GeneralUser.fromJson(Map<String, dynamic> json) {
    return GeneralUser(
      userId: int.parse(json['user_id'].toString()),
      username: json['username'].toString(),
      email: json['email'].toString(),
    );
  }
}
