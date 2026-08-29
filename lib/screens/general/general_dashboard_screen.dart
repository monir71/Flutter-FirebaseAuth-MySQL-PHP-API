import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/dashboard_data.dart';
import '../../services/auth_service.dart';
import '../../services/owner_service.dart';
import '../auth/login_screen.dart';
import 'garden_details_screen.dart';

class GeneralDashboardScreen extends StatefulWidget {
  const GeneralDashboardScreen({super.key});

  @override
  State<GeneralDashboardScreen> createState() => _GeneralDashboardScreenState();
}

class _GeneralDashboardScreenState extends State<GeneralDashboardScreen> {
  DashboardData? _dashboardData;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadDashboard();
  }

  void _showGardenDetails(DashboardGarden garden) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GardenDetailsScreen(
          garden: garden,
        ),
      ),
    );
  }

  // -------------------------------------------------
  // Load Dashboard
  // -------------------------------------------------

  Future<void> _loadDashboard() async {
    try {
      final dashboardData = await OwnerService.getMyDashboard();
      if (!mounted) return;

      setState(() {
        _dashboardData = dashboardData;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to load dashboard: $e')));
    }
  }

  // -------------------------------------------------
  // Logout
  // -------------------------------------------------

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // -------------------------------------------------
  // Money Format
  // -------------------------------------------------

  String _money(double amount) {
    return '৳${amount.toStringAsFixed(2)}';
  }

  // -------------------------------------------------
  // Build
  // -------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dashboardData == null
          ? const Center(child: Text('Dashboard information not found.'))
          : _buildDashboard(),
    );
  }

  // -------------------------------------------------
  // Main Dashboard
  // -------------------------------------------------

  Widget _buildDashboard() {
    final dashboard = _dashboardData!;
    return RefreshIndicator(
      onRefresh: _loadDashboard,

      child: ListView(
        padding: const EdgeInsets.all(20),

        children: [
          // -----------------------------------------
          // Welcome
          // -----------------------------------------
          Text(
            'Welcome, ${dashboard.ownerName}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          Text(
            'Owner ID: ${dashboard.ownerId}',
            style: const TextStyle(fontSize: 15, color: Colors.grey),
          ),

          const SizedBox(height: 25),

          // -----------------------------------------
          // My Gardens
          // -----------------------------------------
          const Text(
            'My Gardens',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          if (dashboard.gardens.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(child: Text('No gardens found.')),
            )
          else
            ...dashboard.gardens.map((garden) => _buildGardenCard(garden)),
        ],
      ),
    );
  }

  // -------------------------------------------------
  // Garden Card
  // -------------------------------------------------

  Widget _buildGardenCard(DashboardGarden garden) {
    // ---------------------------------------------
    // Financial Calculations
    // ---------------------------------------------

    final profitLoss =
        garden.incomeTotal -
            (garden.fundTotal + garden.loanTotal);

    final moneyAtHand =
        (garden.fundTotal +
            garden.loanTotal +
            garden.incomeTotal) -
            garden.expenseTotal;

    return Card(
      elevation: 4,

      margin: const EdgeInsets.only(bottom: 25),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(16),

        // -------------------------------------------
        // Garden Details
        // -------------------------------------------

        onTap: () {
          _showGardenDetails(garden);
        },

        child: Padding(
          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              // ---------------------------------------
              // Garden Name
              // ---------------------------------------

              Row(
                children: [

                  const Icon(
                    Icons.agriculture,
                    size: 28,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      garden.gardenName,

                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),

                  // Small indication that card is clickable
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),

              const SizedBox(height: 5),

              Text(
                'Garden ID: ${garden.gardenId}',

                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),

              // ---------------------------------------
              // Financial Status
              // ---------------------------------------

              const Text(
                'Financial Status',

                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              // ---------------------------------------
              // Chart
              // ---------------------------------------

              SizedBox(
                height: 230,

                child: _buildFinancialChart(
                  profitLoss,
                  moneyAtHand,
                ),
              ),

              const SizedBox(height: 15),

              // ---------------------------------------
              // Profit / Loss
              // ---------------------------------------

              _buildFinancialRow(
                icon: profitLoss >= 0
                    ? Icons.trending_up
                    : Icons.trending_down,

                label: 'Profit / Loss',

                value: _money(profitLoss),

                valueColor:
                profitLoss >= 0
                    ? Colors.green
                    : Colors.red,
              ),

              const SizedBox(height: 8),

              // ---------------------------------------
              // Money At Hand
              // ---------------------------------------

              _buildFinancialRow(
                icon:
                Icons.account_balance_wallet,

                label: 'Money at Hand',

                value: _money(moneyAtHand),

                valueColor:
                moneyAtHand >= 0
                    ? Colors.green
                    : Colors.red,
              ),

              const SizedBox(height: 20),

              const Divider(),

              const SizedBox(height: 10),

              // ---------------------------------------
              // Summary
              // ---------------------------------------

              const Text(
                'Summary',

                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              _buildSummaryRow(
                'Total Fund',
                garden.fundTotal,
              ),

              _buildSummaryRow(
                'Total Expense',
                garden.expenseTotal,
              ),

              _buildSummaryRow(
                'Total Income',
                garden.incomeTotal,
              ),

              _buildSummaryRow(
                'Total Loan',
                garden.loanTotal,
              ),
            ],
          ),
        ),
      ),
    );
  }
  // -------------------------------------------------
  // Financial Chart
  // -------------------------------------------------

  Widget _buildFinancialChart(double profitLoss, double moneyAtHand) {
    final values = [profitLoss, moneyAtHand];

    double maxValue = 0;

    for (final value in values) {
      if (value.abs() > maxValue) {
        maxValue = value.abs();
      }
    }

    if (maxValue == 0) {
      maxValue = 100;
    }

    // Add some space above the largest bar.
    final chartMax = maxValue * 1.25;

    return BarChart(
      BarChartData(
        minY: -chartMax,
        maxY: chartMax,

        alignment: BarChartAlignment.spaceAround,

        gridData: FlGridData(show: true, drawVerticalLine: false),

        borderData: FlBorderData(show: false),

        extraLinesData: ExtraLinesData(
          horizontalLines: [HorizontalLine(y: 0, strokeWidth: 2)],
        ),

        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 55,

              getTitlesWidget: (value, meta) {
                if (value == 0) {
                  return const Text('0', style: TextStyle(fontSize: 11));
                }

                final text = value.abs() >= 1000
                    ? '${(value / 1000).toStringAsFixed(0)}k'
                    : value.toStringAsFixed(0);

                return Text(
                  value < 0 ? '-$text' : text,
                  style: const TextStyle(fontSize: 11),
                );
              },
            ),
          ),

          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,

              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 0:
                    return const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Profit / Loss',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );

                  case 1:
                    return const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Money at Hand',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );

                  default:
                    return const SizedBox();
                }
              },
            ),
          ),
        ),

        barGroups: [
          // ---------------------------------------
          // Profit / Loss
          // ---------------------------------------
          BarChartGroupData(
            x: 0,

            barRods: [
              BarChartRodData(
                toY: profitLoss,

                width: 45,

                color: profitLoss >= 0 ? Colors.green : Colors.red,

                borderRadius: BorderRadius.circular(5),
              ),
            ],
          ),

          // ---------------------------------------
          // Money At Hand
          // ---------------------------------------
          BarChartGroupData(
            x: 1,

            barRods: [
              BarChartRodData(
                toY: moneyAtHand,

                width: 45,

                color: moneyAtHand >= 0 ? Colors.green : Colors.red,

                borderRadius: BorderRadius.circular(5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------
  // Financial Row
  // -------------------------------------------------

  Widget _buildFinancialRow({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),

        color: valueColor.withOpacity(0.08),
      ),

      child: Row(
        children: [
          Icon(icon, color: valueColor),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),

          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------
  // Summary Row
  // -------------------------------------------------

  Widget _buildSummaryRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),

      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),

          Text(
            _money(amount),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
