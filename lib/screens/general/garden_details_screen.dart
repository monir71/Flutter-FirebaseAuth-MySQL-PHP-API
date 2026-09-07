import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhgarden/screens/general/profit_management_screen.dart';
import '../../models/dashboard_data.dart';

class GardenDetailsScreen extends StatelessWidget {
  final DashboardGarden garden;

  const GardenDetailsScreen({super.key, required this.garden});

  String _money(double value) {
    final formatter = NumberFormat('#,##0');
    final formattedValue = formatter.format(value);
    return '৳ $formattedValue';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),

      // ===================================================
      // APP BAR
      // ===================================================
      appBar: AppBar(
        elevation: 4,
        shadowColor: Colors.black26,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        titleSpacing: 18,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.agriculture_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'NH Garden',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '• ${garden.gardenName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),

      // ===================================================
      // BODY
      // ===================================================
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // =================================================
          // GARDEN HEADER
          // =================================================
          _buildGardenHeader(),

          const SizedBox(height: 16),

          // =================================================
          // FINANCIAL SUMMARY + PROFIT MANAGEMENT + MY FUNDS
          // =================================================
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;

              if (!isWide) {
                return Column(
                  children: [
                    // =========================================
                    // FINANCIAL SUMMARY
                    // =========================================
                    _sectionTitle(
                      'Financial Summary',
                      Icons.account_balance_wallet_rounded,
                      Colors.blue.shade700,
                    ),

                    const SizedBox(height: 10),

                    _summaryRow(
                      'Total Fund',
                      garden.fundTotal,
                      Icons.savings_rounded,
                      Colors.blue.shade700,
                    ),

                    _summaryRow(
                      'Total Expense',
                      garden.expenseTotal,
                      Icons.receipt_long_rounded,
                      Colors.deepOrange.shade600,
                    ),

                    _summaryRow(
                      'Total Income',
                      garden.incomeTotal,
                      Icons.trending_up_rounded,
                      Colors.green.shade700,
                    ),

                    _summaryRow(
                      'Total Loan Received (Paid/Not Paid)',
                      garden.loanTotal,
                      Icons.account_balance_rounded,
                      Colors.indigo.shade600,
                    ),

                    const SizedBox(height: 18),

                    // =========================================
                    // PROFIT MANAGEMENT
                    // =========================================
                    _buildProfitManagementButton(context),

                    const SizedBox(height: 22),

                    // =========================================
                    // MY FUNDS
                    // =========================================
                    _sectionTitle(
                      'MY FUNDS',
                      Icons.account_balance_wallet_rounded,
                      Colors.green.shade700,
                      subtitle: 'I have funded',
                    ),

                    const SizedBox(height: 10),

                    _summaryRow(
                      'My Total Funding',
                      garden.myFunds.fold(
                        0.0,
                        (total, fund) => total + fund.fundAmount,
                      ),
                      Icons.payments_rounded,
                      Colors.green.shade700,
                    ),

                    _builderFundingStatus(),

                    const SizedBox(height: 4),

                    ...garden.myFunds.map((fund) => _fundCard(fund)),
                  ],
                );
              }

              // =================================================
              // WIDE SCREEN — THREE CARDS IN ONE ROW
              // =================================================
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =============================================
                  // FINANCIAL SUMMARY CARD
                  // =============================================
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.shade100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.035),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle(
                            'Financial Summary',
                            Icons.account_balance_wallet_rounded,
                            Colors.blue.shade700,
                          ),

                          const SizedBox(height: 10),

                          _summaryRow(
                            'Total Fund',
                            garden.fundTotal,
                            Icons.savings_rounded,
                            Colors.blue.shade700,
                          ),

                          _summaryRow(
                            'Total Expense',
                            garden.expenseTotal,
                            Icons.receipt_long_rounded,
                            Colors.deepOrange.shade600,
                          ),

                          _summaryRow(
                            'Total Income',
                            garden.incomeTotal,
                            Icons.trending_up_rounded,
                            Colors.green.shade700,
                          ),

                          _summaryRow(
                            'Total Loan Received (Paid/Not Paid)',
                            garden.loanTotal,
                            Icons.account_balance_rounded,
                            Colors.indigo.shade600,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // =============================================
                  // PROFIT MANAGEMENT CARD
                  // =============================================
                  Expanded(child: _buildProfitManagementButton(context)),

                  const SizedBox(width: 12),

                  // =============================================
                  // MY FUNDS CARD
                  // =============================================
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.shade100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.035),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle(
                            'MY FUNDS',
                            Icons.account_balance_wallet_rounded,
                            Colors.green.shade700,
                            subtitle: 'I have funded',
                          ),

                          const SizedBox(height: 10),

                          _summaryRow(
                            'My Total Funding',
                            garden.myFunds.fold(
                              0.0,
                              (total, fund) => total + fund.fundAmount,
                            ),
                            Icons.payments_rounded,
                            Colors.green.shade700,
                          ),

                          _builderFundingStatus(),

                          const SizedBox(height: 4),

                          ...garden.myFunds.map((fund) => _fundCard(fund)),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 18),

          // =================================================
          // MY EXPENSES
          // =================================================
          _sectionTitle(
            'MY EXPENSES',
            Icons.receipt_long_rounded,
            Colors.deepOrange.shade600,
            subtitle: 'By my hand',
          ),

          const SizedBox(height: 10),

          ...garden.myExpenses.map((expense) => _expenseCard(expense)),

          const SizedBox(height: 18),

          // =================================================
          // MY INCOME
          // =================================================
          _sectionTitle(
            'MY INCOME',
            Icons.trending_up_rounded,
            Colors.green.shade700,
            subtitle: 'I sold something',
          ),

          const SizedBox(height: 10),

          ...garden.myIncomes.map((income) => _incomeCard(income)),

          const SizedBox(height: 22),

          // =================================================
          // ALL FUNDS
          // =================================================
          _sectionTitle(
            'ALL FUNDS',
            Icons.account_balance_wallet_rounded,
            Colors.blue.shade700,
          ),

          const SizedBox(height: 10),

          ...garden.allFunds.map((fund) => _fundCard(fund)),

          const SizedBox(height: 18),

          // =================================================
          // ALL INCOME
          // =================================================
          _sectionTitle(
            'ALL INCOME',
            Icons.trending_up_rounded,
            Colors.green.shade700,
          ),

          const SizedBox(height: 10),

          ...garden.allIncomes.map((income) => _incomeCard(income)),

          const SizedBox(height: 18),

          // =================================================
          // ALL LOANS
          // =================================================
          _sectionTitle(
            'ALL LOANS',
            Icons.account_balance_rounded,
            Colors.indigo.shade600,
            subtitle: 'Received • Paid / Not Paid',
          ),

          const SizedBox(height: 10),

          ...garden.allLoans.map((loan) => _loanCard(loan)),

          const SizedBox(height: 18),

          // =================================================
          // ALL EXPENSES
          // =================================================
          _sectionTitle(
            'ALL EXPENSES',
            Icons.receipt_long_rounded,
            Colors.deepOrange.shade600,
          ),

          const SizedBox(height: 10),

          ...garden.allExpenses.map((expense) => _expenseCard(expense)),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // =======================================================
  // GARDEN HEADER
  // =======================================================

  Widget _buildGardenHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.lightBlue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.7),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.agriculture_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            garden.gardenName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 5),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Garden ID: ${garden.gardenId}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.92),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =======================================================
  // SECTION TITLE
  // =======================================================

  Widget _sectionTitle(
    String title,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.78)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.16),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 19),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.78),
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =======================================================
  // SUMMARY ROW
  // =======================================================

  Widget _summaryRow(String title, double amount, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.09),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 19),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Text(
            _money(amount),
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // =======================================================
  // PROFIT MANAGEMENT BUTTON
  // =======================================================

  Widget _buildProfitManagementButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade700, Colors.deepOrange.shade500],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade200.withOpacity(0.55),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfitManagementScreen(garden: garden),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.pie_chart_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Text(
                    'Profit Management',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withOpacity(0.85),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =======================================================
  // FUND
  // =======================================================

  Widget _fundCard(dynamic fund) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.blue.shade700,
              size: 20,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amount: ${_money(fund.fundAmount)}',
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Date: ${fund.fundDate}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),

                const SizedBox(height: 2),

                Text(
                  'Owner: ${fund.ownerName}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =======================================================
  // EXPENSE
  // =======================================================

  Widget _expenseCard(dynamic expense) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.deepOrange.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepOrange.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: Colors.deepOrange.shade600,
              size: 20,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.expenseDescription,
                  style: TextStyle(
                    color: Colors.grey.shade900,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Date: ${expense.expenseDate}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),

                const SizedBox(height: 2),

                Text(
                  'Owner: ${expense.ownerName ?? 'Unknown'}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),

                const SizedBox(height: 3),

                Text(
                  'Amount: ${_money(expense.expenseAmount)}',
                  style: TextStyle(
                    color: Colors.deepOrange.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =======================================================
  // INCOME
  // =======================================================

  Widget _incomeCard(dynamic income) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.trending_up_rounded,
              color: Colors.green.shade700,
              size: 20,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  income.incomeSource,
                  style: TextStyle(
                    color: Colors.grey.shade900,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Date: ${income.incomeDate}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),

                const SizedBox(height: 2),

                Text(
                  'Owner: ${income.ownerName ?? 'Unknown'}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),

                const SizedBox(height: 3),

                Text(
                  'Amount: ${_money(income.incomeAmount)}',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =======================================================
  // LOAN
  // =======================================================

  Widget _loanCard(dynamic loan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.indigo.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.account_balance_rounded,
              color: Colors.indigo.shade600,
              size: 20,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loan.loanPurpose,
                  style: TextStyle(
                    color: Colors.grey.shade900,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Date: ${loan.loanDate}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),

                const SizedBox(height: 2),

                Text(
                  'Partner: ${loan.partnerName}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),

                const SizedBox(height: 3),

                Text(
                  'Amount: ${_money(loan.loanAmount)}',
                  style: TextStyle(
                    color: Colors.indigo.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =======================================================
  // FUNDING STATUS
  // =======================================================

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

    final expectedFunding = totalFunding / ownerCount;

    // -------------------------------------------------
    // Funding Percentage
    // -------------------------------------------------

    final percentage = (myFunding / expectedFunding) * 100;

    // -------------------------------------------------
    // Difference
    // -------------------------------------------------

    final difference = expectedFunding - myFunding;

    // -------------------------------------------------
    // Display
    // -------------------------------------------------

    final bool isComplete = difference == 0;
    final bool hasExtra = difference < 0;

    final Color statusColor = isComplete
        ? Colors.green.shade700
        : hasExtra
        ? Colors.blue.shade700
        : Colors.orange.shade700;

    final IconData statusIcon = isComplete
        ? Icons.check_circle_rounded
        : hasExtra
        ? Icons.trending_up_rounded
        : Icons.warning_amber_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.95),
            statusColor.withOpacity(0.78),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.20),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Funding percentage
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(statusIcon, color: Colors.white, size: 20),
              ),

              const SizedBox(width: 9),

              const Expanded(
                child: Text(
                  'My Funding Status',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 11),

          // Expected + actual
          Row(
            children: [
              Expanded(
                child: _fundingInfo('Expected', _money(expectedFunding)),
              ),

              const SizedBox(width: 8),

              Expanded(child: _fundingInfo('Funded', _money(myFunding))),
            ],
          ),

          const SizedBox(height: 8),

          // Difference
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.13),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              difference > 0
                  ? 'Less: ${_money(difference)}'
                  : difference < 0
                  ? 'Extra: ${_money(difference.abs())}'
                  : 'Funding Complete',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =======================================================
  // FUNDING INFO
  // =======================================================

  Widget _fundingInfo(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 10,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
