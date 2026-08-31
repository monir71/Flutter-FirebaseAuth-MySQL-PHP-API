import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/dashboard_data.dart';

class GardenDetailsScreen extends StatelessWidget {
  final DashboardGarden garden;

  const GardenDetailsScreen({
    super.key,
    required this.garden,
  });

  String _money(double value) {
    final formatter = NumberFormat('#,##0');
    final formattedValue = formatter.format(value);
    return '৳ $formattedValue';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details - ${garden.gardenName}',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // -------------------------------------------------
          // Garden
          // -------------------------------------------------
          Container(
            color: Colors.lightBlue,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  garden.gardenName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Garden ID: ${garden.gardenId}',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),

          // -------------------------------------------------
          // SUMMARY
          // -------------------------------------------------
          const SizedBox(height: 20),
          const Text(
            'SUMMARY',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.tealAccent,
            ),
          ),

          const Divider(color: Colors.tealAccent,),

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

          //_sectionTitle('MY FUNDS'),
          const Text(
            'MY FUNDS (I HAVE FUNDED)',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),

          const Divider(color: Colors.green,),

          // Total funding by me
          _summaryRow(
            'My Total Funding',
            garden.myFunds.fold(
              0.0,
                  (total, fund) => total + fund.fundAmount,
            ),
          ),

          // My funding percentage
          _builderFundingStatus(),
          // Individual fund records
          ...garden.myFunds.map(
                (fund) => _fundCard(fund),
          ),

          const SizedBox(height: 20),

          // -------------------------------------------------
          // MY EXPENSES
          // -------------------------------------------------

          //_sectionTitle('MY EXPENSES'),
          const Text(
            'MY EXPENSES (BY MY HAND)',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),

          const Divider(color: Colors.green,),

          ...garden.myExpenses.map(
                (expense) => _expenseCard(expense),
          ),

          const SizedBox(height: 20),

          // -------------------------------------------------
          // MY INCOME
          // -------------------------------------------------

          //_sectionTitle('MY INCOME'),
          const Text(
            'MY INCOME (I SOLD SOMETHING)',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),

          const Divider(color: Colors.green,),

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

          // -------------------------------------------------
          // ALL EXPENSES
          // -------------------------------------------------

          _sectionTitle('ALL EXPENSES'),

          ...garden.allExpenses.map(
                (expense) => _expenseCard(expense),
          ),

          const SizedBox(height: 20),
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
            color: Colors.tealAccent,
          ),
        ),

        const Divider(color: Colors.tealAccent,),
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

      child: Container(
        color: Colors.blue,
        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,

          children: [

            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),

            Text(
              _money(amount),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
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

  Widget _builderFundingStatus() {
    // -------------------------------------------------
    // My Total Funding
    // -------------------------------------------------

    final myFunding = garden.myFunds.fold(
      0.0,
          (total, fund) => total + fund.fundAmount,
    );

    // -------------------------------------------------
    // Total Garden Funding
    // -------------------------------------------------

    final totalFunding = garden.fundTotal;

    // -------------------------------------------------
    // Number of Owners
    // -------------------------------------------------

    final ownerCount = garden.ownerCount;

    // -------------------------------------------------
    // Prevent Division by Zero
    // -------------------------------------------------

    if (ownerCount == 0 || totalFunding == 0) {
      return const SizedBox.shrink();
    }

    // -------------------------------------------------
    // Expected Funding
    // -------------------------------------------------

    final expectedFunding =
        totalFunding / ownerCount;

    // -------------------------------------------------
    // Funding Percentage
    // -------------------------------------------------

    final percentage =
        (myFunding / expectedFunding) * 100;

    // -------------------------------------------------
    // Difference
    // -------------------------------------------------

    final difference =
        expectedFunding - myFunding;

    // -------------------------------------------------
    // Display
    // -------------------------------------------------

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),

      child: Container(
        padding: const EdgeInsets.all(16),

        color: Colors.orange,

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            // -----------------------------------------
            // Funding Percentage
            // -----------------------------------------

            Text(
              'My Funding: ${percentage.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            // -----------------------------------------
            // Expected Funding
            // -----------------------------------------

            Text(
              'Expected: ${_money(expectedFunding)}',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),

            // -----------------------------------------
            // Actual Funding
            // -----------------------------------------

            Text(
              'Funded: ${_money(myFunding)}',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),

            // -----------------------------------------
            // Difference
            // -----------------------------------------

            Text(
              difference > 0
                  ? 'Less: ${_money(difference)}'
                  : difference < 0
                  ? 'Extra: ${_money(difference.abs())}'
                  : 'Funding Complete',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}