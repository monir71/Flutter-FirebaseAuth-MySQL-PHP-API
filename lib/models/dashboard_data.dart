import 'fund.dart';
import 'expense.dart';
import 'income.dart';
import 'loan.dart';

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

// =======================================================
// DASHBOARD DATA
// =======================================================

class DashboardData {
  final int ownerId;
  final String ownerName;
  final String? ownerPhoto;
  final String createdAt;

  final List<DashboardGarden> gardens;

  DashboardData({
    required this.ownerId,
    required this.ownerName,
    this.ownerPhoto,
    required this.createdAt,
    required this.gardens,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'] as Map<String, dynamic>;

    final gardens = json['gardens'] as List<dynamic>? ?? [];

    return DashboardData(
      ownerId: _toInt(owner['owner_id']),

      ownerName: owner['owner_name'].toString(),

      ownerPhoto: owner['owner_photo']?.toString(),

      createdAt: owner['created_at'].toString(),

      gardens: gardens
          .map(
            (garden) =>
            DashboardGarden.fromJson(garden as Map<String, dynamic>),
      )
          .toList(),
    );
  }
}

// =======================================================
// DASHBOARD GARDEN
// =======================================================

class DashboardGarden {
  final int gardenId;
  final String gardenName;

  // -------------------------------------------------------
  // Garden Owners
  // -------------------------------------------------------

  final int ownerCount;

  // -------------------------------------------------------
  // Financial Summary
  // -------------------------------------------------------

  final double fundTotal;
  final double expenseTotal;
  final double incomeTotal;
  final double loanTotal;

  // -------------------------------------------------------
  // My Transactions
  // -------------------------------------------------------

  final List<Fund> myFunds;
  final List<Expense> myExpenses;
  final List<Income> myIncomes;

  // -------------------------------------------------------
  // All Transactions
  // -------------------------------------------------------

  final List<Fund> allFunds;
  final List<Expense> allExpenses;
  final List<Income> allIncomes;
  final List<Loan> allLoans;

  DashboardGarden({
    required this.gardenId,
    required this.gardenName,
    required this.ownerCount,
    required this.fundTotal,
    required this.expenseTotal,
    required this.incomeTotal,
    required this.loanTotal,
    required this.myFunds,
    required this.myExpenses,
    required this.myIncomes,
    required this.allFunds,
    required this.allExpenses,
    required this.allIncomes,
    required this.allLoans,
  });

  // -------------------------------------------------------
  // From JSON
  // -------------------------------------------------------

  factory DashboardGarden.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? {};

    return DashboardGarden(
      // ---------------------------------------------------
      // Garden Information
      // ---------------------------------------------------
      gardenId: _toInt(json['garden_id']),

      gardenName: json['garden_name'].toString(),

      ownerCount: _toInt(json['owner_count']),

      // ---------------------------------------------------
      // Financial Summary
      // ---------------------------------------------------
      fundTotal: _toDouble(summary['fund_total']),

      expenseTotal: _toDouble(summary['expense_total']),

      incomeTotal: _toDouble(summary['income_total']),

      loanTotal: _toDouble(summary['loan_total']),

      // ---------------------------------------------------
      // My Funds
      // ---------------------------------------------------
      myFunds: (json['my_funds'] as List<dynamic>? ?? [])
          .map((item) => Fund.fromJson(item as Map<String, dynamic>))
          .toList(),

      // ---------------------------------------------------
      // My Expenses
      // ---------------------------------------------------
      myExpenses: (json['my_expenses'] as List<dynamic>? ?? [])
          .map((item) => Expense.fromJson(item as Map<String, dynamic>))
          .toList(),

      // ---------------------------------------------------
      // My Income
      // ---------------------------------------------------
      myIncomes: (json['my_incomes'] as List<dynamic>? ?? [])
          .map((item) => Income.fromJson(item as Map<String, dynamic>))
          .toList(),

      // ---------------------------------------------------
      // All Funds
      // ---------------------------------------------------
      allFunds: (json['all_funds'] as List<dynamic>? ?? [])
          .map((item) => Fund.fromJson(item as Map<String, dynamic>))
          .toList(),

      // ---------------------------------------------------
      // All Expenses
      // ---------------------------------------------------
      allExpenses: (json['all_expenses'] as List<dynamic>? ?? [])
          .map((item) => Expense.fromJson(item as Map<String, dynamic>))
          .toList(),

      // ---------------------------------------------------
      // All Income
      // ---------------------------------------------------
      allIncomes: (json['all_incomes'] as List<dynamic>? ?? [])
          .map((item) => Income.fromJson(item as Map<String, dynamic>))
          .toList(),

      // ---------------------------------------------------
      // All Loans
      // ---------------------------------------------------
      allLoans: (json['all_loans'] as List<dynamic>? ?? [])
          .map((item) => Loan.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
