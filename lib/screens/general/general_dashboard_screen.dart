import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhgarden/config/api_config.dart';
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
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  // -------------------------------------------------
  // Garden Details
  // -------------------------------------------------

  void _showGardenDetails(DashboardGarden garden) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GardenDetailsScreen(garden: garden),
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

      _showMessage('Unable to load dashboard: $e', isError: true);
    }
  }

  // -------------------------------------------------
  // Refresh Dashboard
  // -------------------------------------------------

  Future<void> _refreshDashboard() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      final dashboardData = await OwnerService.getMyDashboard();

      if (!mounted) return;

      setState(() {
        _dashboardData = dashboardData;
      });

      _showMessage('Dashboard refreshed successfully.', isError: false);
    } catch (e) {
      if (!mounted) return;

      _showMessage('Unable to refresh dashboard: $e', isError: true);
    } finally {
      if (!mounted) return;

      setState(() {
        _isRefreshing = false;
      });
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

  String _money(double value) {
    final formatter = NumberFormat('#,##0');
    return '৳ ${formatter.format(value)}';
  }

  // -------------------------------------------------
  // Message
  // -------------------------------------------------

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // -------------------------------------------------
  // Build
  // -------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: _buildAppBar(),
      body: _isLoading
          ? _buildLoadingState()
          : _dashboardData == null
          ? _buildEmptyDashboard()
          : _buildDashboard(),
    );
  }

  // -------------------------------------------------
  // Responsive AppBar
  // -------------------------------------------------

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 4,
      shadowColor: Colors.black26,
      backgroundColor: Colors.teal.shade700,
      foregroundColor: Colors.white,
      automaticallyImplyLeading: false,
      titleSpacing: 12,

      title: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 400;

          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.agriculture_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'North Hunter Garden',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmall ? 15 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'My Dashboard',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),

      actions: [
        // -------------------------------------------
        // Refresh Button
        // -------------------------------------------
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: _buildAppBarButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 19,
                    height: 19,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.3,
                    ),
                  )
                : const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh Dashboard',
            onPressed: _isRefreshing ? null : _refreshDashboard,
          ),
        ),

        // -------------------------------------------
        // Logout Button
        // -------------------------------------------
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _buildAppBarButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Log Out',
            onPressed: _logout,
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------
  // AppBar Button
  // -------------------------------------------------

  Widget _buildAppBarButton({
    required Widget icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Material(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(11),
        child: IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          icon: icon,
          tooltip: tooltip,
          onPressed: onPressed,
        ),
      ),
    );
  }

  // -------------------------------------------------
  // Loading State
  // -------------------------------------------------

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.dashboard_rounded,
                color: Colors.teal.shade700,
                size: 42,
              ),
            ),
            const SizedBox(height: 18),
            CircularProgressIndicator(
              color: Colors.teal.shade700,
              strokeWidth: 3,
            ),
            const SizedBox(height: 12),
            Text(
              'Loading dashboard...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------
  // Empty Dashboard
  // -------------------------------------------------

  Widget _buildEmptyDashboard() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.dashboard_outlined,
                size: 55,
                color: Colors.teal.shade700,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Dashboard Information Not Found',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to find your dashboard information.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------
  // Main Dashboard
  // -------------------------------------------------

  Widget _buildDashboard() {
    final dashboard = _dashboardData!;

    return RefreshIndicator(
      color: Colors.teal.shade700,
      onRefresh: _refreshDashboard,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 30),
        children: [
          _buildWelcomeCard(dashboard),

          const SizedBox(height: 20),

          // -----------------------------------------
          // Garden Header
          // -----------------------------------------
          _buildGardenSectionHeader(dashboard),

          const SizedBox(height: 14),

          if (dashboard.gardens.isEmpty)
            _buildNoGardens()
          else
            ...dashboard.gardens.map((garden) => _buildGardenCard(garden)),
        ],
      ),
    );
  }

  // -------------------------------------------------
  // Garden Section Header
  // -------------------------------------------------

  Widget _buildGardenSectionHeader(DashboardData dashboard) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            Icons.agriculture_rounded,
            color: Colors.teal.shade700,
            size: 23,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Gardens',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Your gardens and financial overview',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        Container(
          constraints: const BoxConstraints(minWidth: 34),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.teal.shade700,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${dashboard.gardens.length}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------
  // Welcome Card
  // -------------------------------------------------

  Widget _buildWelcomeCard(DashboardData dashboard) {
    final String? photoUrl = dashboard.ownerPhoto?.isNotEmpty == true
        ? '${ApiConfig.baseUrl}/${dashboard.ownerPhoto}'
        : null;

    return Card(
      elevation: 7,
      shadowColor: Colors.black26,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade800, Colors.teal.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isVeryNarrow = constraints.maxWidth < 320;

            if (isVeryNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOwnerPhoto(photoUrl),
                  const SizedBox(height: 12),
                  _buildWelcomeText(dashboard),
                ],
              );
            }

            return Row(
              children: [
                _buildOwnerPhoto(photoUrl),
                const SizedBox(width: 14),
                Expanded(child: _buildWelcomeText(dashboard)),
              ],
            );
          },
        ),
      ),
    );
  }

  // -------------------------------------------------
  // Owner Photo
  // -------------------------------------------------

  Widget _buildOwnerPhoto(String? photoUrl) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
      ),
      child: ClipOval(
        child: photoUrl != null
            ? Image.network(
                photoUrl,
                width: 62,
                height: 62,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultOwnerPhoto();
                },
              )
            : _buildDefaultOwnerPhoto(),
      ),
    );
  }

  Widget _buildDefaultOwnerPhoto() {
    return Container(
      color: Colors.white.withOpacity(0.15),
      child: const Icon(Icons.person_rounded, color: Colors.white, size: 34),
    );
  }

  // -------------------------------------------------
  // Welcome Text
  // -------------------------------------------------

  Widget _buildWelcomeText(DashboardData dashboard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome Back',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          dashboard.ownerName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5),

        Row(
          children: [
            const Icon(Icons.badge_rounded, color: Colors.white70, size: 15),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                'Owner ID: ${dashboard.ownerId}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // -------------------------------------------------
  // No Gardens
  // -------------------------------------------------

  Widget _buildNoGardens() {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.agriculture_outlined,
                size: 42,
                color: Colors.teal.shade700,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'No Gardens Found',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'No gardens are currently assigned to you.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------
  // Garden Card
  // -------------------------------------------------

  Widget _buildGardenCard(DashboardGarden garden) {
    final profitLoss = garden.incomeTotal - garden.expenseTotal;

    final moneyAtHand =
        (garden.fundTotal + garden.loanTotal + garden.incomeTotal) -
        garden.expenseTotal;

    final isProfit = profitLoss >= 0;
    final isMoneyPositive = moneyAtHand >= 0;

    return Card(
      elevation: 5,
      shadowColor: Colors.black26,
      margin: const EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // -----------------------------------------
          // Garden Header
          // -----------------------------------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade700, Colors.teal.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.agriculture_rounded,
                    color: Colors.white,
                    size: 25,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        garden.gardenName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Garden ID: ${garden.gardenId}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                SizedBox(
                  width: 40,
                  height: 40,
                  child: Material(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                      onPressed: () {
                        _showGardenDetails(garden);
                      },
                      tooltip: 'Show Details',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // -----------------------------------------
          // Dashboard Content
          // -----------------------------------------
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // -----------------------------------
                // Financial Cards
                // -----------------------------------
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 700;

                    if (wide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildFinancialStatusCard(
                              profitLoss,
                              moneyAtHand,
                              isProfit,
                              isMoneyPositive,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: _buildFinancialSummaryCard(garden)),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        _buildFinancialStatusCard(
                          profitLoss,
                          moneyAtHand,
                          isProfit,
                          isMoneyPositive,
                        ),
                        const SizedBox(height: 12),
                        _buildFinancialSummaryCard(garden),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),

                // -----------------------------------
                // Owners Heading
                // -----------------------------------
                _buildGardenOwnersHeading(garden),

                const SizedBox(height: 12),

                // -----------------------------------
                // Owners
                // -----------------------------------
                _buildGardenOwners(garden),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------
  // Financial Status Card
  // -------------------------------------------------

  Widget _buildFinancialStatusCard(
    double profitLoss,
    double moneyAtHand,
    bool isProfit,
    bool isMoneyPositive,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.indigo.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: Colors.blue.shade700,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Financial Status',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Container(
            height: 190,
            padding: const EdgeInsets.fromLTRB(3, 8, 8, 0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.78),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: _buildFinancialChart(profitLoss, moneyAtHand),
          ),

          const SizedBox(height: 10),

          _buildFinancialRow(
            icon: isProfit
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            label: 'Profit / Loss',
            value: _money(profitLoss),
            valueColor: isProfit ? Colors.green.shade700 : Colors.red.shade700,
          ),

          const SizedBox(height: 7),

          _buildFinancialRow(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Money at Hand',
            value: _money(moneyAtHand),
            valueColor: isMoneyPositive
                ? Colors.green.shade700
                : Colors.red.shade700,
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------
  // Financial Summary Card
  // -------------------------------------------------

  Widget _buildFinancialSummaryCard(DashboardGarden garden) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade50, Colors.orange.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade100.withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.summarize_rounded,
                  color: Colors.orange.shade800,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Financial Summary',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.orange.shade900,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          _buildSummaryRow(
            Icons.account_balance_wallet_rounded,
            'Total Fund',
            garden.fundTotal,
          ),

          _buildSummaryRow(
            Icons.receipt_long_rounded,
            'Total Expense',
            garden.expenseTotal,
          ),

          _buildSummaryRow(
            Icons.trending_up_rounded,
            'Total Income',
            garden.incomeTotal,
          ),

          _buildSummaryRow(
            Icons.account_balance_rounded,
            'Total Loan Received (Paid/Not Paid)',
            garden.loanTotal,
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------
  // Garden Owners Heading
  // -------------------------------------------------

  Widget _buildGardenOwnersHeading(DashboardGarden garden) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade300, Colors.cyan.shade300],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.shade100.withOpacity(0.45),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.people_alt_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),

          const SizedBox(width: 9),

          const Expanded(
            child: Text(
              'Garden Owners',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Container(
            constraints: const BoxConstraints(minWidth: 30),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${garden.owners.length}',
              textAlign: TextAlign.center,
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

    final chartMax = maxValue * 1.25;

    return BarChart(
      BarChartData(
        minY: -chartMax,
        maxY: chartMax,
        alignment: BarChartAlignment.spaceAround,

        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: chartMax > 1000 ? chartMax / 4 : null,
        ),

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
              reservedSize: 38,
              getTitlesWidget: (value, meta) {
                if (value == 0) {
                  return const Text('0', style: TextStyle(fontSize: 9));
                }

                final text = value.abs() >= 1000
                    ? '${(value / 1000).toStringAsFixed(0)}k'
                    : value.toStringAsFixed(0);

                return Text(
                  value < 0 ? '-$text' : text,
                  style: const TextStyle(fontSize: 9),
                );
              },
            ),
          ),

          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 0:
                    return const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        'Profit / Loss',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );

                  case 1:
                    return const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        'Money at Hand',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
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
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: profitLoss,
                width: 35,
                color: isPositive(profitLoss)
                    ? Colors.green.shade600
                    : Colors.red.shade600,
                borderRadius: BorderRadius.circular(5),
              ),
            ],
          ),

          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: moneyAtHand,
                width: 35,
                color: isPositive(moneyAtHand)
                    ? Colors.green.shade600
                    : Colors.red.shade600,
                borderRadius: BorderRadius.circular(5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool isPositive(double value) {
    return value >= 0;
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        color: valueColor.withOpacity(0.08),
        border: Border.all(color: valueColor.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: valueColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: valueColor, size: 18),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),

          const SizedBox(width: 6),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------
  // Summary Row
  // -------------------------------------------------

  Widget _buildSummaryRow(IconData icon, String label, double amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, color: Colors.orange.shade800, size: 16),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 6),

          Flexible(
            child: Text(
              _money(amount),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey.shade900,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------
  // Garden Owners
  // -------------------------------------------------

  Widget _buildGardenOwners(DashboardGarden garden) {
    if (garden.owners.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.person_off_rounded,
              color: Colors.grey.shade500,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'No owners found.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // ---------------------------------------------
        // Very narrow phone
        // ---------------------------------------------
        if (width < 430) {
          return Column(
            children: garden.owners.map((owner) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: _buildOwnerCard(
                    garden,
                    owner,
                  ),
                ),
              );
            }).toList(),
          );
        }

        // ---------------------------------------------
        // Phone / small tablet
        // ---------------------------------------------
        if (width < 720) {
          final cardWidth = (width - 10) / 2;

          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: garden.owners.map((owner) {
              return SizedBox(
                width: cardWidth,
                child: _buildOwnerCard(
                  garden,
                  owner,
                ),
              );
            }).toList(),
          );
        }

        // ---------------------------------------------
        // Tablet
        // ---------------------------------------------
        if (width < 1050) {
          final cardWidth = (width - 20) / 3;

          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: garden.owners.map((owner) {
              return SizedBox(
                width: cardWidth,
                child: _buildOwnerCard(
                  garden,
                  owner,
                ),
              );
            }).toList(),
          );
        }

        // ---------------------------------------------
        // Desktop / Wide screen
        // ---------------------------------------------
        final cardWidth = (width - 30) / 4;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: garden.owners.map((owner) {
            return SizedBox(
              width: cardWidth,
              child: _buildOwnerCard(
                garden,
                owner,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // -------------------------------------------------
  // Owner Card
  // -------------------------------------------------

  Widget _buildOwnerCard(DashboardGarden garden, DashboardOwner owner) {
    final ownerFund = _getOwnerFund(garden, owner);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.teal.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.teal.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.shade100.withOpacity(0.28),
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -----------------------------------------
          // Photo + Status
          // -----------------------------------------
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade200, Colors.cyan.shade100],
                  ),
                  border: Border.all(color: Colors.teal.shade300, width: 2),
                ),
                child: ClipOval(
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.teal.shade50,
                    backgroundImage: owner.ownerPhoto != null
                        ? NetworkImage(
                            '${ApiConfig.baseUrl}/${owner.ownerPhoto}',
                          )
                        : null,
                    child: owner.ownerPhoto == null
                        ? Icon(
                            Icons.person_rounded,
                            color: Colors.teal.shade700,
                            size: 30,
                          )
                        : null,
                  ),
                ),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_rounded,
                  color: Colors.teal.shade600,
                  size: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          // -----------------------------------------
          // Owner Name
          // -----------------------------------------
          Text(
            owner.ownerName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade900,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 2),

          // -----------------------------------------
          // Owner ID
          // -----------------------------------------
          Row(
            children: [
              Icon(Icons.badge_rounded, color: Colors.grey.shade500, size: 12),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  'ID: ${owner.ownerId}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // -----------------------------------------
          // Fund
          // -----------------------------------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.teal.shade100),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.teal.shade700,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Funded',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.teal.shade700,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    _money(ownerFund),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.teal.shade800,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------
  // Owner Fund
  // -------------------------------------------------

  double _getOwnerFund(DashboardGarden garden, DashboardOwner owner) {
    return garden.allFunds
        .where((fund) => fund.ownerId == owner.ownerId)
        .fold<double>(0.0, (total, fund) => total + fund.fundAmount);
  }

  // -------------------------------------------------
  // Owner Photo URL
  // -------------------------------------------------

  String _getOwnerPhotoUrl(String? photo) {
    if (photo == null || photo.isEmpty) {
      return '';
    }

    return '${ApiConfig.baseUrl}${photo.replaceFirst('/..', '')}';
  }
}
