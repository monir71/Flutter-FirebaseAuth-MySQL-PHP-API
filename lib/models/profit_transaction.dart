class ProfitTransaction {
  final int profitTransactionId;

  final int ownerId;
  final String ownerName;

  final int gardenId;
  final String gardenName;

  final double profitAmount;
  final String profitDate;

  final String status;

  final String? profitNote;
  final String? adminNote;

  final int? approvedBy;
  final String? approvedByName;
  final String? approvedAt;

  final String createdAt;

  // Admin eligibility information
  final int ownerCount;

  final double totalIncome;
  final double totalExpense;
  final double availableProfit;
  final double equalProfitShare;

  final double ownerApprovedProfit;
  final double ownerPendingProfit;
  final double ownerAvailableProfit;

  final bool eligible;
  final String eligibilityMessage;

  ProfitTransaction({
    required this.profitTransactionId,
    required this.ownerId,
    required this.ownerName,
    required this.gardenId,
    required this.gardenName,
    required this.profitAmount,
    required this.profitDate,
    required this.status,
    this.profitNote,
    this.adminNote,
    this.approvedBy,
    this.approvedByName,
    this.approvedAt,
    required this.createdAt,

    required this.ownerCount,
    required this.totalIncome,
    required this.totalExpense,
    required this.availableProfit,
    required this.equalProfitShare,
    required this.ownerApprovedProfit,
    required this.ownerPendingProfit,
    required this.ownerAvailableProfit,
    required this.eligible,
    required this.eligibilityMessage,
  });

  // -------------------------------------------------
  // From JSON
  // -------------------------------------------------

  factory ProfitTransaction.fromJson(Map<String, dynamic> json) {
    return ProfitTransaction(
      profitTransactionId:
          int.tryParse(json['profit_transaction_id']?.toString() ?? '') ?? 0,

      ownerId: int.tryParse(json['owner_id']?.toString() ?? '') ?? 0,

      ownerName: json['owner_name']?.toString() ?? '',

      gardenId: int.tryParse(json['garden_id']?.toString() ?? '') ?? 0,

      gardenName: json['garden_name']?.toString() ?? '',

      profitAmount:
          double.tryParse(json['profit_amount']?.toString() ?? '') ?? 0.0,

      profitDate: json['profit_date']?.toString() ?? '',

      status: json['status']?.toString() ?? 'pending',

      profitNote: json['profit_note']?.toString(),

      adminNote: json['admin_note']?.toString(),

      approvedBy: json['approved_by'] == null
          ? null
          : int.tryParse(json['approved_by'].toString()),

      approvedByName: json['approved_by_name']?.toString(),

      approvedAt: json['approved_at']?.toString(),

      createdAt: json['created_at']?.toString() ?? '',

      // -------------------------------------------------
      // Eligibility information
      // -------------------------------------------------
      ownerCount: int.tryParse(json['owner_count']?.toString() ?? '') ?? 0,

      totalIncome:
          double.tryParse(json['total_income']?.toString() ?? '') ?? 0.0,

      totalExpense:
          double.tryParse(json['total_expense']?.toString() ?? '') ?? 0.0,

      availableProfit:
          double.tryParse(json['available_profit']?.toString() ?? '') ?? 0.0,

      equalProfitShare:
          double.tryParse(json['equal_profit_share']?.toString() ?? '') ?? 0.0,

      ownerApprovedProfit:
          double.tryParse(json['owner_approved_profit']?.toString() ?? '') ??
          0.0,

      ownerPendingProfit:
          double.tryParse(json['owner_pending_profit']?.toString() ?? '') ??
          0.0,

      ownerAvailableProfit:
          double.tryParse(json['owner_available_profit']?.toString() ?? '') ??
          0.0,

      eligible: json['eligible'] == true,

      eligibilityMessage: json['eligibility_message']?.toString() ?? '',
    );
  }

  // -------------------------------------------------
  // To JSON
  // -------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'profit_transaction_id': profitTransactionId,

      'owner_id': ownerId,

      'owner_name': ownerName,

      'garden_id': gardenId,

      'garden_name': gardenName,

      'profit_amount': profitAmount,

      'profit_date': profitDate,

      'status': status,

      'profit_note': profitNote,

      'admin_note': adminNote,

      'approved_by': approvedBy,

      'approved_by_name': approvedByName,

      'approved_at': approvedAt,

      'created_at': createdAt,

      'owner_count': ownerCount,

      'total_income': totalIncome,

      'total_expense': totalExpense,

      'available_profit': availableProfit,

      'equal_profit_share': equalProfitShare,

      'owner_approved_profit': ownerApprovedProfit,

      'owner_pending_profit': ownerPendingProfit,

      'owner_available_profit': ownerAvailableProfit,

      'eligible': eligible,

      'eligibility_message': eligibilityMessage,
    };
  }
}
