import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/dashboard_data.dart';
import '../../models/profit_transaction.dart';
import '../../services/profit_service.dart';

class ProfitManagementScreen extends StatefulWidget {
  final DashboardGarden garden;

  const ProfitManagementScreen({super.key, required this.garden});

  @override
  State<ProfitManagementScreen> createState() => _ProfitManagementScreenState();
}

class _ProfitManagementScreenState extends State<ProfitManagementScreen> {
  bool _isLoading = true;
  bool _isSubmitting = false;

  Map<String, dynamic>? _summary;

  List<ProfitTransaction> _transactions = [];

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  // =====================================================
  // MONEY FORMAT
  // =====================================================

  String _money(double value) {
    final formatter = NumberFormat('#,##0');

    return '৳ ${formatter.format(value)}';
  }

  // =====================================================
  // LOAD DATA
  // =====================================================

  Future<void> _loadData() async {
    try {
      final summary = await ProfitService.getProfitSummary(
        gardenId: widget.garden.gardenId,
      );

      final allTransactions = await ProfitService.getMyProfits();

      //print('==============================');
      //print('MY PROFIT TRANSACTIONS');
      //print('Count: ${allTransactions.length}');

      for (final transaction in allTransactions) {
        //print(
          //'ID: ${transaction.profitTransactionId} | '
          //'Owner: ${transaction.ownerId} | '
          //'Garden: ${transaction.gardenId} | '
          //'Amount: ${transaction.profitAmount} | '
          //'Status: ${transaction.status}',
        //);
      }

      //print('Current garden ID: ${widget.garden.gardenId}');
      //print('==============================');

      if (!mounted) return;

      final gardenTransactions = allTransactions
          .where(
            (transaction) => transaction.gardenId == widget.garden.gardenId,
          )
          .toList();

      //print(
        //'Transactions for current garden: '
        //'${gardenTransactions.length}',
      //);

      setState(() {
        _summary = summary;
        _transactions = gardenTransactions;
        _isLoading = false;
      });
    } catch (e) {
      //print('PROFIT LOAD ERROR: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          backgroundColor: Colors.red.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text('Unable to load profit information: $e'),
        ),
      );
    }
  }

  // =====================================================
  // REQUEST PROFIT WITHDRAWAL
  // =====================================================

  Future<void> _requestProfit() async {
    final summary = _summary;

    if (summary == null) {
      return;
    }

    final availableProfit =
        double.tryParse(summary['my_available_profit']?.toString() ?? '0') ?? 0;

    if (availableProfit <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.orange.shade700,
          content: const Text(
            'No profit is currently available for withdrawal.',
          ),
        ),
      );

      return;
    }

    final amountController = TextEditingController();

    final noteController = TextEditingController();

    final amount = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          titlePadding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
          contentPadding: const EdgeInsets.fromLTRB(22, 8, 22, 4),
          actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.green.shade700,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Withdraw Profit',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Available profit
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade100),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.savings_rounded,
                      color: Colors.green.shade700,
                      size: 21,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Available Profit',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      _money(availableProfit),
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Profit Amount',
                  prefixText: '৳ ',
                  prefixIcon: const Icon(Icons.payments_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.green.shade600,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Note (Optional)',
                  prefixIcon: const Icon(Icons.notes_rounded),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.green.shade600,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final enteredAmount = double.tryParse(
                  amountController.text.trim(),
                );

                if (enteredAmount == null || enteredAmount <= 0) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Enter a valid amount.')),
                  );

                  return;
                }

                if (enteredAmount > availableProfit) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Amount cannot exceed '
                        '${_money(availableProfit)}.',
                      ),
                    ),
                  );

                  return;
                }

                Navigator.pop(dialogContext, enteredAmount);
              },
              icon: const Icon(Icons.send_rounded, size: 17),
              label: const Text('Request'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        );
      },
    );

    final note = noteController.text.trim();

    amountController.dispose();
    noteController.dispose();

    if (amount == null) {
      return;
    }

    await _createProfitRequest(
      amount: amount,
      note: note.isEmpty ? null : note,
    );
  }

  // =====================================================
  // CREATE PROFIT REQUEST
  // =====================================================

  Future<void> _createProfitRequest({
    required double amount,
    String? note,
  }) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      await ProfitService.createProfit(
        gardenId: widget.garden.gardenId,
        profitAmount: amount,
        profitDate: today,
        profitNote: note,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.green.shade700,
          content: const Text(
            'Profit withdrawal request submitted. '
            'Waiting for admin approval.',
          ),
        ),
      );

      await _loadData();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.red.shade700,
          content: Text('Unable to submit request: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // =====================================================
  // CANCEL REQUEST
  // =====================================================

  Future<void> _cancelTransaction(ProfitTransaction transaction) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red.shade700,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Cancel Request',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            'Cancel the profit withdrawal request of '
            '${_money(transaction.profitAmount)}?',
            style: TextStyle(color: Colors.grey.shade700, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(
                'No',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {
      await ProfitService.cancelProfit(
        profitTransactionId: transaction.profitTransactionId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.green.shade700,
          content: const Text('Profit withdrawal request cancelled.'),
        ),
      );

      await _loadData();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.red.shade700,
          content: Text('Unable to cancel request: $e'),
        ),
      );
    }
  }

  // =====================================================
  // STATUS COLOR
  // =====================================================

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;

      case 'rejected':
        return Colors.red;

      case 'pending':
        return Colors.orange;

      default:
        return Colors.grey;
    }
  }

  // =====================================================
  // STATUS ICON
  // =====================================================

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle_rounded;

      case 'rejected':
        return Icons.cancel_rounded;

      case 'pending':
        return Icons.hourglass_top_rounded;

      default:
        return Icons.info_rounded;
    }
  }

  // =====================================================
  // STATUS TEXT
  // =====================================================

  String _statusText(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Approved';

      case 'rejected':
        return 'Rejected';

      case 'pending':
        return 'Waiting for Admin Approval';

      default:
        return status;
    }
  }

  // =====================================================
  // SUMMARY CARD
  // =====================================================

  Widget _buildSummaryCard() {
    final summary = _summary;

    if (summary == null) {
      return Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.red.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.035),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 34,
                color: Colors.red.shade600,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Profit information is unavailable.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 14),

            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final ownerCount =
        int.tryParse(summary['owner_count']?.toString() ?? '0') ?? 0;

    final totalIncome =
        double.tryParse(summary['total_income']?.toString() ?? '0') ?? 0;

    final totalExpense =
        double.tryParse(summary['total_expense']?.toString() ?? '0') ?? 0;

    final availableProfit =
        double.tryParse(summary['available_profit']?.toString() ?? '0') ?? 0;

    final equalShare =
        double.tryParse(summary['equal_profit_share']?.toString() ?? '0') ?? 0;

    final myApprovedProfit =
        double.tryParse(summary['my_approved_profit']?.toString() ?? '0') ?? 0;

    final myPendingProfit =
        double.tryParse(summary['my_pending_profit']?.toString() ?? '0') ?? 0;

    final myAvailableProfit =
        double.tryParse(summary['my_available_profit']?.toString() ?? '0') ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blue.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // -------------------------------------------------
          // HEADER
          // -------------------------------------------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.lightBlue.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.pie_chart_rounded,
                    color: Colors.white,
                    size: 23,
                  ),
                ),

                const SizedBox(width: 11),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.garden.gardenName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        'Profit Overview • $ownerCount Owners',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.78),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // -------------------------------------------------
          // FINANCIAL FIGURES
          // -------------------------------------------------
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _buildAmountTile(
                  'Total Income',
                  totalIncome,
                  Icons.trending_up_rounded,
                  Colors.green.shade700,
                ),

                _buildAmountTile(
                  'Total Expense',
                  totalExpense,
                  Icons.receipt_long_rounded,
                  Colors.deepOrange.shade600,
                ),

                const SizedBox(height: 4),

                _buildAmountTile(
                  'Available Garden Profit',
                  availableProfit,
                  Icons.account_balance_wallet_rounded,
                  Colors.green.shade700,
                  highlighted: true,
                ),

                _buildAmountTile(
                  'My Equal Profit Share',
                  equalShare,
                  Icons.pie_chart_rounded,
                  Colors.blue.shade700,
                ),

                _buildAmountTile(
                  'My Withdrawal Profit',
                  myApprovedProfit,
                  Icons.check_circle_rounded,
                  Colors.green.shade700,
                ),

                _buildAmountTile(
                  'My Approval Pending Profit',
                  myPendingProfit,
                  Icons.hourglass_top_rounded,
                  Colors.orange.shade700,
                ),

                const SizedBox(height: 4),

                _buildAmountTile(
                  'My Available Profit',
                  myAvailableProfit,
                  Icons.payments_rounded,
                  myAvailableProfit > 0
                      ? Colors.green.shade700
                      : Colors.red.shade600,
                  highlighted: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // AMOUNT TILE
  // =====================================================

  Widget _buildAmountTile(
    String label,
    double amount,
    IconData icon,
    Color color, {
    bool highlighted = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: highlighted ? color.withOpacity(0.07) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlighted ? color.withOpacity(0.16) : Colors.grey.shade200,
        ),
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
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                fontWeight: highlighted ? FontWeight.bold : FontWeight.w600,
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

  // =====================================================
  // TRANSACTION CARD
  // =====================================================

  Widget _buildTransactionCard(ProfitTransaction transaction) {
    final statusColor = _statusColor(transaction.status);
    final statusIcon = _statusIcon(transaction.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: statusColor.withOpacity(0.16)),
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
          // -------------------------------------------------
          // AMOUNT + STATUS
          // -------------------------------------------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(statusIcon, color: statusColor, size: 21),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _money(transaction.profitAmount),
                      style: TextStyle(
                        color: Colors.grey.shade900,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      'Profit Withdrawal',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusText(transaction.status),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // -------------------------------------------------
          // DATE
          // -------------------------------------------------
          _buildTransactionInfo(
            Icons.calendar_today_rounded,
            'Date',
            transaction.profitDate,
          ),

          // -------------------------------------------------
          // PROFIT NOTE
          // -------------------------------------------------
          if (transaction.profitNote?.isNotEmpty == true)
            _buildTransactionInfo(
              Icons.notes_rounded,
              'Note',
              transaction.profitNote!,
            ),

          // -------------------------------------------------
          // ADMIN NOTE
          // -------------------------------------------------
          if (transaction.adminNote?.isNotEmpty == true)
            _buildTransactionInfo(
              Icons.admin_panel_settings_rounded,
              'Admin Note',
              transaction.adminNote!,
              valueColor: statusColor,
            ),

          // -------------------------------------------------
          // APPROVED BY
          // -------------------------------------------------
          if (transaction.approvedByName?.isNotEmpty == true)
            _buildTransactionInfo(
              Icons.person_rounded,
              'Approved by',
              transaction.approvedByName!,
            ),

          // -------------------------------------------------
          // APPROVED AT
          // -------------------------------------------------
          if (transaction.approvedAt?.isNotEmpty == true)
            _buildTransactionInfo(
              Icons.access_time_rounded,
              'Approved at',
              transaction.approvedAt!,
            ),

          // -------------------------------------------------
          // CANCEL
          // -------------------------------------------------
          if (transaction.status.toLowerCase() == 'pending') ...[
            const SizedBox(height: 5),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  _cancelTransaction(transaction);
                },
                icon: Icon(
                  Icons.cancel_outlined,
                  color: Colors.red.shade600,
                  size: 18,
                ),
                label: Text(
                  'Cancel Request',
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =====================================================
  // TRANSACTION INFO
  // =====================================================

  Widget _buildTransactionInfo(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade500, size: 15),

          const SizedBox(width: 7),

          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.grey.shade700,
                fontSize: 11,
                fontWeight: valueColor != null
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // LOADING VIEW
  // =====================================================

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.pie_chart_rounded,
              color: Colors.blue.shade700,
              size: 32,
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.blue.shade700,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Loading profit information...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),

      // =================================================
      // APP BAR
      // =================================================
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
                Icons.pie_chart_rounded,
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
                '• Profit Management',
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

      // =================================================
      // BODY
      // =================================================
      body: _isLoading
          ? _buildLoadingView()
          : RefreshIndicator(
              onRefresh: _loadData,
              color: Colors.blue.shade700,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  // ---------------------------------------
                  // SUMMARY
                  // ---------------------------------------
                  _buildSummaryCard(),

                  const SizedBox(height: 16),

                  // ---------------------------------------
                  // REQUEST BUTTON
                  // ---------------------------------------
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade700, Colors.teal.shade600],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.shade200.withOpacity(0.55),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: _summary == null || _isSubmitting
                            ? null
                            : _requestProfit,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 13,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: Colors.white,
                                  size: 21,
                                ),
                              ),

                              const SizedBox(width: 10),

                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Request Profit Withdrawal',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Submit your available profit for approval',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              if (_isSubmitting)
                                const SizedBox(
                                  width: 23,
                                  height: 23,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              else
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
                  ),

                  const SizedBox(height: 24),

                  // ---------------------------------------
                  // TRANSACTIONS HEADER
                  // ---------------------------------------
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.indigo.shade600, Colors.blue.shade500],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.indigo.shade100.withOpacity(0.7),
                          blurRadius: 7,
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
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: Colors.white,
                            size: 19,
                          ),
                        ),

                        const SizedBox(width: 9),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My Profit Transactions',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 1),
                              Text(
                                'Withdrawal requests and approval history',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_transactions.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ---------------------------------------
                  // TRANSACTIONS
                  // ---------------------------------------
                  if (_transactions.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.receipt_long_outlined,
                              size: 30,
                              color: Colors.grey.shade500,
                            ),
                          ),

                          const SizedBox(height: 11),

                          Text(
                            'No profit transactions found.',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            'Your withdrawal requests will appear here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._transactions.map(
                      (transaction) => _buildTransactionCard(transaction),
                    ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
    );
  }
}
