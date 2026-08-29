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

class Expense {
  final int expenseId;
  final int ownerId;
  final String? ownerName;
  final int gardenId;
  final String? gardenName;
  final String expenseDescription;
  final double expenseAmount;
  final String expenseDate;

  Expense({
    required this.expenseId,
    required this.ownerId,
    this.ownerName,
    required this.gardenId,
    this.gardenName,
    required this.expenseDescription,
    required this.expenseAmount,
    required this.expenseDate,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      expenseId: _toInt(
        json['expense_id'].toString(),
      ),
      ownerId: _toInt(
        json['owner_id'].toString(),
      ),
      ownerName: json['owner_name']?.toString(),
      gardenId: _toInt(
        json['garden_id'].toString(),
      ),
      gardenName: json['garden_name']?.toString(),
      expenseDescription:
      json['expense_description'].toString(),
      expenseAmount: _toDouble(
        json['expense_amount'].toString(),
      ),
      expenseDate:
      json['expense_date'].toString(),
    );
  }
}