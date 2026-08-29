class FinancialPartner {
  final int partnerId;
  final String partnerName;
  final String partnerInstitution;
  final String? partnerPhoto;

  FinancialPartner({
    required this.partnerId,
    required this.partnerName,
    required this.partnerInstitution,
    this.partnerPhoto,
  });

  factory FinancialPartner.fromJson(
      Map<String, dynamic> json,
      ) {
    return FinancialPartner(
      partnerId: int.parse(
        json['partner_id'].toString(),
      ),
      partnerName: json['partner_name'].toString(),
      partnerInstitution:
      json['partner_institution'].toString(),
      partnerPhoto: json['partner_photo'],
    );
  }
}