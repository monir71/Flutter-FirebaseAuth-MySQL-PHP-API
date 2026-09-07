class Owner {
  final int ownerId;
  final String ownerName;
  final String? ownerPhoto;
  final int? userId;
  final List<OwnerGarden> gardens;

  Owner({
    required this.ownerId,
    required this.ownerName,
    required this.ownerPhoto,
    required this.userId,
    required this.gardens,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      ownerId: int.parse(json['owner_id'].toString()),

      ownerName: json['owner_name'].toString(),

      ownerPhoto: json['owner_photo'] == null
          ? null
          : json['owner_photo'].toString(),

      userId: json['user_id'] == null
          ? null
          : int.parse(json['user_id'].toString()),

      gardens: (json['gardens'] as List<dynamic>? ?? [])
          .map(
            (garden) => OwnerGarden.fromJson(
          garden as Map<String, dynamic>,
        ),
      )
          .toList(),
    );
  }
}

class OwnerGarden {
  final int gardenId;
  final String gardenName;

  OwnerGarden({
    required this.gardenId,
    required this.gardenName,
  });

  factory OwnerGarden.fromJson(Map<String, dynamic> json) {
    return OwnerGarden(
      gardenId: int.parse(json['garden_id'].toString()),
      gardenName: json['garden_name'].toString(),
    );
  }
}