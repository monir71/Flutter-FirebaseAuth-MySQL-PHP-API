import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhgarden/config/api_config.dart';
import 'package:nhgarden/screens/admin/admin_profit_management_screen.dart';
import 'package:nhgarden/screens/admin/income_management_screen.dart';
import '../../models/dashboard_data.dart';
import '../../models/owner.dart';
import '../../services/auth_service.dart';
import '../../services/owner_service.dart';
import '../auth/login_screen.dart';
import 'expense_management_screen.dart';
import 'financial_partner_management_screen.dart';
import 'fund_management_screen.dart';
import 'garden_management_screen.dart';
import 'loan_management_screen.dart';
import 'owner_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<Owner> owners = [];
  bool isLoadingOwners = true;

  List<DashboardGarden> _gardens = [];
  bool _isLoadingGardens = true;

  @override
  void initState() {
    super.initState();

    loadOwners();
    _loadGardens();
  }

  // ============================================================
  // ADMIN MANAGEMENT FOOTER
  // ============================================================

  Widget _buildManagementFooter() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              // Garden
              _buildFooterItem(
                icon: Icons.agriculture_rounded,
                label: 'Garden',
                color: Colors.teal.shade700,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GardenManagementScreen(),
                    ),
                  ).then((_) {
                    _loadGardens();
                  });
                },
              ),

              // Owners
              _buildFooterItem(
                icon: Icons.people_alt_rounded,
                label: 'Owners',
                color: Colors.deepPurple.shade600,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OwnerManagementScreen(),
                    ),
                  ).then((_) {
                    loadOwners();
                  });
                },
              ),

              // Fund
              _buildFooterItem(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Fund',
                color: Colors.blue.shade700,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FundManagementScreen(),
                    ),
                  );
                },
              ),

              // Expense
              _buildFooterItem(
                icon: Icons.receipt_long_rounded,
                label: 'Expense',
                color: Colors.deepOrange.shade600,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ExpenseManagementScreen(),
                    ),
                  );
                },
              ),

              // Income
              _buildFooterItem(
                icon: Icons.trending_up_rounded,
                label: 'Income',
                color: Colors.green.shade700,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const IncomeManagementScreen(),
                    ),
                  );
                },
              ),

              // Loan
              _buildFooterItem(
                icon: Icons.account_balance_rounded,
                label: 'Loan',
                color: Colors.indigo.shade600,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoanManagementScreen(),
                    ),
                  );
                },
              ),

              // Partners
              _buildFooterItem(
                icon: Icons.handshake_rounded,
                label: 'Partners',
                color: Colors.cyan.shade700,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const FinancialPartnerManagementScreen(),
                    ),
                  );
                },
              ),

              // Profit
              _buildFooterItem(
                icon: Icons.pie_chart_rounded,
                label: 'Profit',
                color: Colors.amber.shade700,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const AdminProfitManagementScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 25,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LOAD OWNERS
  // ============================================================

  Future<void> loadOwners() async {
    try {
      final data = await OwnerService.getOwners();

      if (!mounted) return;

      setState(() {
        owners = data;
        isLoadingOwners = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingOwners = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load owners: $e'),
        ),
      );
    }
  }

  // ============================================================
  // LOAD GARDENS
  // ============================================================

  Future<void> _loadGardens() async {
    try {
      final gardens = await OwnerService.getAdminGardens();

      if (!mounted) return;

      setState(() {
        _gardens = gardens;
        _isLoadingGardens = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingGardens = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load gardens: $e'),
        ),
      );
    }
  }

  // ============================================================
  // MONEY FORMAT
  // ============================================================

  String _money(double value) {
    return '৳${NumberFormat('#,##0').format(value)}';
  }

  // ============================================================
  // GARDEN FINANCIAL CARD
  // ============================================================

  Widget _buildGardenFinancialCard(DashboardGarden garden) {
    final profitLoss = garden.incomeTotal - garden.expenseTotal;

    final moneyAtHand =
        garden.fundTotal +
            garden.loanTotal +
            garden.incomeTotal -
            garden.expenseTotal;

    final isProfit = profitLoss >= 0;
    final isMoneyPositive = moneyAtHand >= 0;

    return SizedBox(
      width: 380,
      child: Card(
        elevation: 8,
        shadowColor: Colors.black26,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ==================================================
            // CARD HEADER
            // ==================================================

            Container(
              padding: const EdgeInsets.fromLTRB(
                18,
                16,
                14,
                16,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0F766E),
                    Color(0xFF14B8A6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  // Garden icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.agriculture,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Garden name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          garden.gardenName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Garden #${garden.gardenId}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.80),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Owner count
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.people_alt_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${garden.ownerCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // CARD BODY
            // ==================================================

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ==================================================
                  // PROFIT / MONEY AT HAND
                  // ==================================================

                  Row(
                    children: [
                      Expanded(
                        child: _buildGardenMetric(
                          icon: isProfit
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          label: 'Profit / Loss',
                          value: _money(profitLoss),
                          color: isProfit
                              ? Colors.green.shade600
                              : Colors.red.shade600,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _buildGardenMetric(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Money at Hand',
                          value: _money(moneyAtHand),
                          color: isMoneyPositive
                              ? Colors.blue.shade600
                              : Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ==================================================
                  // FINANCIAL CHART
                  // ==================================================

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(
                      10,
                      12,
                      10,
                      5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.bar_chart_rounded,
                              color: Colors.teal.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 7),
                            const Text(
                              'Financial Overview',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '৳',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        SizedBox(
                          height: 160,
                          width: double.infinity,
                          child: _buildFinancialChart(
                            profitLoss,
                            moneyAtHand,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // SUMMARY TITLE
                  // ==================================================

                  Row(
                    children: [
                      const Text(
                        'Financial Summary',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.analytics_outlined,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ==================================================
                  // SUMMARY ROW 1
                  // ==================================================

                  Row(
                    children: [
                      Expanded(
                        child: _buildCompactSummaryItem(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Fund',
                          value: garden.fundTotal,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildCompactSummaryItem(
                          icon: Icons.receipt_long_outlined,
                          label: 'Expense',
                          value: garden.expenseTotal,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ==================================================
                  // SUMMARY ROW 2
                  // ==================================================

                  Row(
                    children: [
                      Expanded(
                        child: _buildCompactSummaryItem(
                          icon: Icons.trending_up_rounded,
                          label: 'Income',
                          value: garden.incomeTotal,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildCompactSummaryItem(
                          icon: Icons.account_balance_outlined,
                          label: 'Loan',
                          value: garden.loanTotal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // GARDEN METRIC
  // ============================================================

  Widget _buildGardenMetric({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: color,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMPACT SUMMARY ITEM
  // ============================================================

  Widget _buildCompactSummaryItem({
    required IconData icon,
    required String label,
    required double value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 17,
              color: Colors.teal.shade700,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _money(value),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
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

  // ============================================================
  // FINANCIAL CHART
  // ============================================================

  Widget _buildFinancialChart(
      double profitLoss,
      double moneyAtHand,
      ) {
    final values = [
      profitLoss,
      moneyAtHand,
    ];

    final maxValue = values
        .map((value) => value.abs())
        .reduce((a, b) => a > b ? a : b);

    final chartMax = maxValue == 0 ? 100.0 : maxValue * 1.25;

    return BarChart(
      BarChartData(
        minY: -chartMax,
        maxY: chartMax,

        alignment: BarChartAlignment.spaceAround,

        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: chartMax / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            );
          },
        ),

        borderData: FlBorderData(
          show: false,
        ),

        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 0,
              color: Colors.grey.shade500,
              strokeWidth: 1,
            ),
          ],
        ),

        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),

          rightTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),

          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                String text;

                if (value == 0) {
                  text = 'Profit/Loss';
                } else {
                  text = 'Money';
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                );
              },
            ),
          ),

          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              interval: chartMax / 4,
              getTitlesWidget: (value, meta) {
                if (value == 0) {
                  return const Text(
                    '0',
                    style: TextStyle(
                      fontSize: 9,
                    ),
                  );
                }

                String formatted;

                final absValue = value.abs();

                if (absValue >= 1000000) {
                  formatted =
                  '${(value / 1000000).toStringAsFixed(1)}M';
                } else if (absValue >= 1000) {
                  formatted =
                  '${(value / 1000).toStringAsFixed(1)}k';
                } else {
                  formatted = value.toStringAsFixed(0);
                }

                return Text(
                  formatted,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey.shade600,
                  ),
                );
              },
            ),
          ),
        ),

        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (
                group,
                groupIndex,
                rod,
                rodIndex,
                ) {
              final value = rod.toY;

              return BarTooltipItem(
                _money(value),
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),

        barGroups: [
          // Profit / Loss
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: profitLoss,
                width: 35,
                color: profitLoss >= 0
                    ? Colors.green.shade600
                    : Colors.red.shade600,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          ),

          // Money at Hand
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: moneyAtHand,
                width: 35,
                color: moneyAtHand >= 0
                    ? Colors.blue.shade600
                    : Colors.red.shade600,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Management Card Design
  // ============================================================

  Widget _buildManagementCard({
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 380,
      child: Card(
        elevation: 6,
        shadowColor: color.withOpacity(0.20),
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.12),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ================================================
              // TOP COLOR HEADER
              // ================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  18,
                  16,
                  18,
                  16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color,
                      color.withOpacity(0.75),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ================================================
              // CARD BODY
              // ================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  16,
                  18,
                  18,
                ),
                child: Column(
                  children: [
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onPressed,
                        icon: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                        label: Text(
                          buttonText,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            vertical: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        shadowColor: Colors.black26,
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        titleSpacing: 18,

        title: Row(
          children: [
            // ============================================
            // APP ICON
            // ============================================

            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.agriculture_rounded,
                color: Colors.white,
                size: 23,
              ),
            ),

            const SizedBox(width: 12),

            // ============================================
            // TITLE
            // ============================================

            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'NH Garden',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),

        actions: [
          // ============================================
          // LOGOUT BUTTON
          // ============================================

          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                ),
                tooltip: 'Log Out',
                onPressed: () async {
                  await AuthService().logout();

                  if (!context.mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                        (route) => false,
                  );
                },
              ),
            ),
          ),
        ],
      ),

    // ========================================================
      // BODY
      // ========================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [

              // ==================================================
              // GARDEN FINANCIAL STATUS
              // ==================================================

              const SizedBox(height: 15),

              _isLoadingGardens
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : _gardens.isEmpty
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No gardens found.',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              )
                  : Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _gardens
                    .map(
                      (garden) =>
                      _buildGardenFinancialCard(garden),
                )
                    .toList(),
              ),

              // ==================================================
              // GARDEN MANAGEMENT
              // ==================================================

              _buildManagementCard(
                icon: Icons.agriculture_rounded,
                title: 'Garden Management',
                description: 'Create, edit and manage your gardens.',
                buttonText: 'MANAGE GARDENS',
                color: Colors.teal.shade700,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GardenManagementScreen(),
                    ),
                  ).then((_) {
                    _loadGardens();
                  });
                },
              ),

              // ==================================================
              // OWNER MANAGEMENT
              // ==================================================

              _buildManagementCard(
                icon: Icons.people_alt_rounded,
                title: 'Owner Management',
                description: 'Manage garden owners and login accounts.',
                buttonText: 'MANAGE OWNERS',
                color: Colors.deepPurple.shade600,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OwnerManagementScreen(),
                    ),
                  ).then((_) {
                    loadOwners();
                  });
                },
              ),

              // ==================================================
              // FUND MANAGEMENT
              // ==================================================

              _buildManagementCard(
                icon: Icons.account_balance_wallet_rounded,
                title: 'Fund Management',
                description: 'Manage owner funding transactions.',
                buttonText: 'MANAGE FUNDS',
                color: Colors.blue.shade700,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FundManagementScreen(),
                    ),
                  );
                },
              ),

              // ==================================================
              // EXPENSE MANAGEMENT
              // ==================================================

              _buildManagementCard(
                icon: Icons.receipt_long_rounded,
                title: 'Expense Management',
                description: 'Manage garden expenses and transactions.',
                buttonText: 'MANAGE EXPENSES',
                color: Colors.deepOrange.shade600,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ExpenseManagementScreen(),
                    ),
                  );
                },
              ),

              // ==================================================
              // INCOME MANAGEMENT
              // ==================================================

              _buildManagementCard(
                icon: Icons.trending_up_rounded,
                title: 'Income Management',
                description: 'Manage income generated by your gardens.',
                buttonText: 'MANAGE INCOME',
                color: Colors.green.shade700,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const IncomeManagementScreen(),
                    ),
                  );
                },
              ),

              // ==================================================
              // LOAN MANAGEMENT
              // ==================================================

              _buildManagementCard(
                icon: Icons.account_balance_rounded,
                title: 'Loan Management',
                description: 'Manage loans received by your gardens.',
                buttonText: 'MANAGE LOANS',
                color: Colors.indigo.shade600,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoanManagementScreen(),
                    ),
                  );
                },
              ),

              // ==================================================
              // FINANCIAL PARTNER MANAGEMENT
              // ==================================================

              _buildManagementCard(
                icon: Icons.handshake_rounded,
                title: 'Financial Partners',
                description: 'Manage garden financial partners.',
                buttonText: 'MANAGE PARTNERS',
                color: Colors.cyan.shade700,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const FinancialPartnerManagementScreen(),
                    ),
                  );
                },
              ),

              // ==================================================
              // PROFIT MANAGEMENT
              // ==================================================

              _buildManagementCard(
                icon: Icons.pie_chart_rounded,
                title: 'Profit Management',
                description: 'Manage and distribute garden profits.',
                buttonText: 'MANAGE PROFIT',
                color: Colors.amber.shade700,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const AdminProfitManagementScreen(),
                    ),
                  );
                },
              ),

              // ==================================================
              // OWNERS LIST
              // ==================================================

              Card(
                elevation: 6,
                shadowColor: Colors.deepPurple.withOpacity(0.20),
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // =====================================================
                      // HEADER
                      // =====================================================

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(
                          18,
                          16,
                          18,
                          16,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepPurple.shade700,
                              Colors.deepPurple.shade400,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Icon
                            Container(
                              padding: const EdgeInsets.all(11),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: const Icon(
                                Icons.people_alt_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Title
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Owners',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Garden owners and their gardens',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.80),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Owner count
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${owners.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // =====================================================
                      // BODY
                      // =====================================================

                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          14,
                          16,
                          16,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isLoadingOwners)
                              const Padding(
                                padding: EdgeInsets.all(25),
                                child: CircularProgressIndicator(),
                              )
                            else
                              if (owners.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.people_outline_rounded,
                                        size: 45,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'No owners found.',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                ...owners.take(5).map(
                                      (owner) {
                                    return Container(
                                      margin: const EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          // =================================
                                          // OWNER PHOTO
                                          // =================================

                                          Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color:
                                                Colors.deepPurple.shade100,
                                                width: 2,
                                              ),
                                            ),
                                            child: CircleAvatar(
                                              radius: 25,
                                              backgroundColor:
                                              Colors.deepPurple.shade50,
                                              backgroundImage:
                                              owner.ownerPhoto != null
                                                  ? NetworkImage(
                                                '${ApiConfig.baseUrl}/${owner
                                                    .ownerPhoto}',
                                              )
                                                  : null,
                                              child: owner.ownerPhoto == null
                                                  ? Icon(
                                                Icons.person_rounded,
                                                color:
                                                Colors.deepPurple.shade400,
                                                size: 27,
                                              )
                                                  : null,
                                            ),
                                          ),

                                          const SizedBox(width: 12),

                                          // =================================
                                          // OWNER INFORMATION
                                          // =================================

                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  owner.ownerName,
                                                  maxLines: 1,
                                                  overflow:
                                                  TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),

                                                const SizedBox(height: 6),

                                                if (owner.gardens.isEmpty)
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .info_outline_rounded,
                                                        size: 15,
                                                        color:
                                                        Colors.orange.shade700,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        'No garden assigned',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors
                                                              .orange
                                                              .shade700,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                else
                                                  Wrap(
                                                    spacing: 5,
                                                    runSpacing: 5,
                                                    children: owner.gardens
                                                        .map(
                                                          (garden) {
                                                        return Container(
                                                          padding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                          decoration:
                                                          BoxDecoration(
                                                            color: Colors
                                                                .green
                                                                .withOpacity(
                                                                0.08),
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                20),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize:
                                                            MainAxisSize
                                                                .min,
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .agriculture_rounded,
                                                                size: 13,
                                                                color: Colors
                                                                    .green
                                                                    .shade700,
                                                              ),
                                                              const SizedBox(
                                                                width: 4,
                                                              ),
                                                              Text(
                                                                garden
                                                                    .gardenName,
                                                                style: TextStyle(
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                                  color: Colors
                                                                      .green
                                                                      .shade800,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    )
                                                        .toList(),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),

                            const SizedBox(height: 5),

                            // =================================================
                            // VIEW ALL BUTTON
                            // =================================================

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                      const OwnerManagementScreen(),
                                    ),
                                  ).then((_) {
                                    loadOwners();
                                  });
                                },
                                icon: const Icon(
                                  Icons.people_alt_outlined,
                                  size: 19,
                                ),
                                label: const Text(
                                  'VIEW ALL OWNERS',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  Colors.deepPurple.shade600,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ],
          ),
        ),
      ),
      bottomNavigationBar: _buildManagementFooter(),
    );
  }
}