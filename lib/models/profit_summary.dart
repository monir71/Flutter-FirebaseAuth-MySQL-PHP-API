class ProfitSummary {
  final int gardenId;
  final String gardenName;

  final int ownerId;
  final String ownerName;

  final int ownerCount;

  final double totalIncome;
  final double totalExpense;
  final double availableProfit;

  final double equalProfitShare;

  final double myApprovedProfit;
  final double myPendingProfit;
  final double myAvailableProfit;

  ProfitSummary({
    required this.gardenId,
    required this.gardenName,
    required this.ownerId,
    required this.ownerName,
    required this.ownerCount,
    required this.totalIncome,
    required this.totalExpense,
    required this.availableProfit,
    required this.equalProfitShare,
    required this.myApprovedProfit,
    required this.myPendingProfit,
    required this.myAvailableProfit,
  });

  // -------------------------------------------------
  // Helpers
  // -------------------------------------------------

  static int _toInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    return int.tryParse(value.toString()) ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0.0;
    }

    return double.tryParse(value.toString()) ?? 0.0;
  }

  // -------------------------------------------------
  // From JSON
  // -------------------------------------------------

  factory ProfitSummary.fromJson(Map<String, dynamic> json) {
    return ProfitSummary(
      gardenId: _toInt(json['garden_id']),
      gardenName: json['garden_name']?.toString() ?? '',

      ownerId: _toInt(json['owner_id']),
      ownerName: json['owner_name']?.toString() ?? '',

      ownerCount: _toInt(json['owner_count']),

      totalIncome: _toDouble(json['total_income']),
      totalExpense: _toDouble(json['total_expense']),
      availableProfit: _toDouble(json['available_profit']),

      equalProfitShare: _toDouble(json['equal_profit_share']),

      myApprovedProfit: _toDouble(json['my_approved_profit']),

      myPendingProfit: _toDouble(json['my_pending_profit']),

      myAvailableProfit: _toDouble(json['my_available_profit']),
    );
  }
}
