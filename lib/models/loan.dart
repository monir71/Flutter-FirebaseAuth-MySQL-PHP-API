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

class Loan {
  final int loanId;

  final int partnerId;
  final String partnerName;
  final String partnerInstitution;

  final int gardenId;
  final String gardenName;

  final String loanPurpose;
  final double loanAmount;
  final String loanDate;

  final String createdAt;

  Loan({
    required this.loanId,
    required this.partnerId,
    required this.partnerName,
    required this.partnerInstitution,
    required this.gardenId,
    required this.gardenName,
    required this.loanPurpose,
    required this.loanAmount,
    required this.loanDate,
    required this.createdAt,
  });

  factory Loan.fromJson(
      Map<String, dynamic> json) {

    return Loan(
      loanId:
      _toInt(
        json['loan_id'].toString(),
      ),

      partnerId:
      _toInt(
        json['partner_id'].toString(),
      ),

      partnerName:
      json['partner_name'] ?? '',

      partnerInstitution:
      json['partner_institution'] ?? '',

      gardenId:
      _toInt(
        json['garden_id'].toString(),
      ),

      gardenName:
      json['garden_name'] ?? '',

      loanPurpose:
      json['loan_purpose'] ?? '',

      loanAmount:
      _toDouble(
        json['loan_amount'].toString(),
      ),

      loanDate:
      json['loan_date'] ?? '',

      createdAt:
      json['created_at'] ?? '',
    );
  }
}