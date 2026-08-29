int _toInt(dynamic value) {
  if (value == null) {
    return 0;
  }

  return int.tryParse(value.toString()) ?? 0;
}

double _toDouble(dynamic value) {
  if (value == null) {
    return 0.0;
  }

  return double.tryParse(value.toString()) ?? 0.0;
}

class Fund {
  final int fundId;
  final int ownerId;
  final String ownerName;
  final int gardenId;
  final String gardenName;
  final double fundAmount;
  final String fundDate;

  Fund({
    required this.fundId,
    required this.ownerId,
    required this.ownerName,
    required this.gardenId,
    required this.gardenName,
    required this.fundAmount,
    required this.fundDate,
  });

  factory Fund.fromJson(Map<String, dynamic> json) {
    return Fund(
      fundId: _toInt(json['fund_id'].toString()),
      ownerId: _toInt(json['owner_id'].toString()),
      ownerName: json['owner_name'].toString(),
      gardenId: _toInt(json['garden_id'].toString()),
      gardenName: json['garden_name'].toString(),
      fundAmount: _toDouble(json['fund_amount'].toString()),
      fundDate: json['fund_date'].toString(),
    );
  }
}