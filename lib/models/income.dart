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

class Income {
  final int incomeId;
  final int ownerId;
  final String? ownerName;
  final int gardenId;
  final String? gardenName;
  final String incomeSource;
  final double incomeAmount;
  final String incomeDate;

  Income({
    required this.incomeId,
    required this.ownerId,
    this.ownerName,
    required this.gardenId,
    this.gardenName,
    required this.incomeSource,
    required this.incomeAmount,
    required this.incomeDate,
  });

  factory Income.fromJson(
      Map<String, dynamic> json,
      ) {
    return Income(
      incomeId:
      _toInt(json['income_id'].toString()),

      ownerId:
      _toInt(json['owner_id'].toString()),

      ownerName:
      json['owner_name']?.toString(),

      gardenId:
      _toInt(json['garden_id'].toString()),

      gardenName:
      json['garden_name']?.toString(),

      incomeSource:
      json['income_source'].toString(),

      incomeAmount:
      _toDouble(
        json['income_amount'].toString(),
      ),

      incomeDate:
      json['income_date'].toString(),
    );
  }
}