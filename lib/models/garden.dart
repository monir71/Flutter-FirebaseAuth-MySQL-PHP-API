class Garden {
  final int gardenId;
  final String gardenName;

  Garden({
    required this.gardenId,
    required this.gardenName,
  });

  factory Garden.fromJson(Map<String, dynamic> json) {
    return Garden(
      gardenId: json['id'],
      gardenName: json['garden_name'],
    );
  }
}