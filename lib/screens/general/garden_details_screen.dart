import 'package:flutter/material.dart';

import '../../models/dashboard_data.dart';

class GardenDetailsScreen extends StatelessWidget {
  final DashboardGarden garden;

  const GardenDetailsScreen({
    super.key,
    required this.garden,
  });

  String _money(double value) {
    return '৳${value.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(garden.gardenName),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [

          // -------------------------------------------------
          // Garden
          // -------------------------------------------------

          Text(
            '🌱 ${garden.gardenName}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Garden ID: ${garden.gardenId}',
          ),

          const SizedBox(height: 20),

          // -------------------------------------------------
          // SUMMARY
          // -------------------------------------------------

          const Text(
            'SUMMARY',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Divider(),

          _summaryRow(
            'Total Fund',
            garden.fundTotal,
          ),

          _summaryRow(
            'Total Expense',
            garden.expenseTotal,
          ),

          _summaryRow(
            'Total Income',
            garden.incomeTotal,
          ),

          _summaryRow(
            'Total Loan',
            garden.loanTotal,
          ),

          const SizedBox(height: 25),

          // -------------------------------------------------
          // MY FUNDS
          // -------------------------------------------------

          _sectionTitle('MY FUNDS'),

          ...garden.myFunds.map(
                (fund) => _fundCard(fund),
          ),

          const SizedBox(height: 20),

          // -------------------------------------------------
          // MY EXPENSES
          // -------------------------------------------------

          _sectionTitle('MY EXPENSES'),

          ...garden.myExpenses.map(
                (expense) => _expenseCard(expense),
          ),

          const SizedBox(height: 20),

          // -------------------------------------------------
          // MY INCOME
          // -------------------------------------------------

          _sectionTitle('MY INCOME'),

          ...garden.myIncomes.map(
                (income) => _incomeCard(income),
          ),

          const SizedBox(height: 30),

          // -------------------------------------------------
          // ALL FUNDS
          // -------------------------------------------------

          _sectionTitle('ALL FUNDS'),

          ...garden.allFunds.map(
                (fund) => _fundCard(fund),
          ),

          const SizedBox(height: 20),

          // -------------------------------------------------
          // ALL EXPENSES
          // -------------------------------------------------

          _sectionTitle('ALL EXPENSES'),

          ...garden.allExpenses.map(
                (expense) => _expenseCard(expense),
          ),

          const SizedBox(height: 20),

          // -------------------------------------------------
          // ALL INCOME
          // -------------------------------------------------

          _sectionTitle('ALL INCOME'),

          ...garden.allIncomes.map(
                (income) => _incomeCard(income),
          ),

          const SizedBox(height: 20),

          // -------------------------------------------------
          // ALL LOANS
          // -------------------------------------------------

          _sectionTitle('ALL LOANS'),

          ...garden.allLoans.map(
                (loan) => _loanCard(loan),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // =======================================================
  // SECTION TITLE
  // =======================================================

  Widget _sectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),

        const Divider(),
      ],
    );
  }

  // =======================================================
  // SUMMARY ROW
  // =======================================================

  Widget _summaryRow(
      String title,
      double amount,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),

      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,

        children: [

          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),

          Text(
            _money(amount),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // =======================================================
  // FUND
  // =======================================================

  Widget _fundCard(dynamic fund) {
    return Card(
      child: ListTile(
        title: Text(
          'Amount: ${_money(fund.fundAmount)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(
          'Date: ${fund.fundDate}\n'
              'Owner: ${fund.ownerName}',
        ),
      ),
    );
  }

  // =======================================================
  // EXPENSE
  // =======================================================

  Widget _expenseCard(dynamic expense) {
    return Card(
      child: ListTile(
        title: Text(
          expense.expenseDescription,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(
          'Date: ${expense.expenseDate}\n'
              'Owner: ${expense.ownerName ?? 'Unknown'}\n'
              'Amount: ${_money(expense.expenseAmount)}',
        ),
      ),
    );
  }

  // =======================================================
  // INCOME
  // =======================================================

  Widget _incomeCard(dynamic income) {
    return Card(
      child: ListTile(
        title: Text(
          income.incomeSource,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(
          'Date: ${income.incomeDate}\n'
              'Owner: ${income.ownerName ?? 'Unknown'}\n'
              'Amount: ${_money(income.incomeAmount)}',
        ),
      ),
    );
  }

  // =======================================================
  // LOAN
  // =======================================================

  Widget _loanCard(dynamic loan) {
    return Card(
      child: ListTile(
        title: Text(
          loan.loanPurpose,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(
          'Date: ${loan.loanDate}\n'
              'Partner: ${loan.partnerName}\n'
              'Amount: ${_money(loan.loanAmount)}',
        ),
      ),
    );
  }
}