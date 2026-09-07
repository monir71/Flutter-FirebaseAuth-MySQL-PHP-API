import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/profit_transaction.dart';
import '../../services/profit_service.dart';

class AdminProfitManagementScreen extends StatefulWidget {
  const AdminProfitManagementScreen({super.key});

  @override
  State<AdminProfitManagementScreen> createState() =>
      _AdminProfitManagementScreenState();
}

class _AdminProfitManagementScreenState
    extends State<AdminProfitManagementScreen> {
  bool _isLoading = true;

  List<ProfitTransaction> _transactions = [];

  final Color _primaryColor = Colors.amber.shade700;

  @override
  void initState() {
    super.initState();

    _loadRequests();
  }

  // -------------------------------------------------
  // Money Format
  // -------------------------------------------------

  String _money(double value) {
    final formatter = NumberFormat('#,##0.00');

    return '৳ ${formatter.format(value)}';
  }

  // -------------------------------------------------
  // Load Pending Profit Requests
  // -------------------------------------------------

  Future<void> _loadRequests() async {
    try {
      final transactions = await ProfitService.getProfitRequests();

      if (!mounted) return;

      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage('Unable to load profit requests: $e');
    }
  }

  // -------------------------------------------------
  // Approve Transaction
  // -------------------------------------------------

  Future<void> _approveTransaction(ProfitTransaction transaction) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 10),
          contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green.shade600,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Approve Profit Request',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.green.shade100),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDialogInfoRow(
                  Icons.person_outline_rounded,
                  'Owner',
                  transaction.ownerName,
                  Colors.green.shade600,
                ),
                const SizedBox(height: 10),
                _buildDialogInfoRow(
                  Icons.agriculture_rounded,
                  'Garden',
                  transaction.gardenName,
                  Colors.green.shade600,
                ),
                const SizedBox(height: 10),
                _buildDialogInfoRow(
                  Icons.payments_rounded,
                  'Amount',
                  _money(transaction.profitAmount),
                  Colors.green.shade600,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(
                'CANCEL',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('APPROVE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
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

    if (confirm != true) return;

    try {
      await ProfitService.approveProfit(
        profitTransactionId: transaction.profitTransactionId,
      );

      if (!mounted) return;

      _showMessage('Profit request approved successfully.');

      await _loadRequests();
    } catch (e) {
      if (!mounted) return;

      _showMessage('Unable to approve request: $e');
    }
  }

  // -------------------------------------------------
  // Reject Transaction
  // -------------------------------------------------

  Future<void> _rejectTransaction(ProfitTransaction transaction) async {
    final noteController = TextEditingController();

    final note = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 10),
          contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.cancel_rounded,
                  color: Colors.red.shade600,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Reject Profit Request',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 19,
                      color: Colors.red.shade600,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.ownerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            transaction.gardenName,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _money(transaction.profitAmount),
                            style: TextStyle(
                              color: Colors.red.shade600,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Rejection Reason',
                  hintText: 'Enter rejection reason',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 42),
                    child: Icon(
                      Icons.edit_note_rounded,
                      color: Colors.red.shade600,
                    ),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 15,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.red.shade600,
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
                'CANCEL',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext, noteController.text.trim());
              },
              icon: const Icon(Icons.close_rounded, size: 18),
              label: const Text('REJECT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
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

    noteController.dispose();

    if (note == null) return;

    try {
      await ProfitService.rejectProfit(
        profitTransactionId: transaction.profitTransactionId,
        adminNote: note.isEmpty ? null : note,
      );

      if (!mounted) return;

      _showMessage('Profit request rejected successfully.');

      await _loadRequests();
    } catch (e) {
      if (!mounted) return;

      _showMessage('Unable to reject request: $e');
    }
  }

  // -------------------------------------------------
  // View Owner Earlier Transactions
  // -------------------------------------------------

  Future<void> _viewOwnerHistory(ProfitTransaction transaction) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history_rounded, color: _primaryColor, size: 42),
                const SizedBox(height: 12),
                CircularProgressIndicator(color: _primaryColor),
                const SizedBox(height: 12),
                const Text(
                  'Loading profit history...',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      final history = await ProfitService.getOwnerProfitTransactions(
        ownerId: transaction.ownerId,
        gardenId: transaction.gardenId,
      );

      if (!mounted) return;

      Navigator.pop(context);

      await showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 10),
            contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.history_rounded,
                    color: _primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Profit History',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        transaction.ownerName,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 520,
              height: 450,
              child: history.isEmpty
                  ? _buildEmptyHistory()
                  : ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final item = history[index];

                        final status = item.status.toLowerCase();

                        Color statusColor;

                        if (status == 'approved') {
                          statusColor = Colors.green.shade600;
                        } else if (status == 'rejected') {
                          statusColor = Colors.red.shade600;
                        } else {
                          statusColor = Colors.orange.shade700;
                        }

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          elevation: 2,
                          shadowColor: Colors.black12,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(13),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _money(item.profitAmount),
                                        style: TextStyle(
                                          color: _primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.10),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        item.status.toUpperCase(),
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildHistoryInfoRow(
                                  Icons.calendar_today_rounded,
                                  'Date',
                                  item.profitDate,
                                ),
                                if (item.profitNote != null &&
                                    item.profitNote!.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  _buildHistoryInfoRow(
                                    Icons.person_outline_rounded,
                                    'Owner Note',
                                    item.profitNote!,
                                  ),
                                ],
                                if (item.adminNote != null &&
                                    item.adminNote!.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  _buildHistoryInfoRow(
                                    Icons.admin_panel_settings_rounded,
                                    'Admin Note',
                                    item.adminNote!,
                                    statusColor,
                                  ),
                                ],
                                if (item.approvedByName != null &&
                                    item.approvedByName!.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  _buildHistoryInfoRow(
                                    Icons.person_rounded,
                                    'Approved By',
                                    item.approvedByName!,
                                  ),
                                ],
                                if (item.approvedAt != null &&
                                    item.approvedAt!.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  _buildHistoryInfoRow(
                                    Icons.access_time_rounded,
                                    'Approved At',
                                    item.approvedAt!,
                                    Colors.grey,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('CLOSE'),
                style: TextButton.styleFrom(foregroundColor: _primaryColor),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context);

      _showMessage('Unable to load owner history: $e');
    }
  }

  // -------------------------------------------------
  // Eligibility Section
  // -------------------------------------------------

  Widget _buildEligibility(ProfitTransaction transaction) {
    final json = transaction.toJson();

    final eligible = json['eligible'] == true;

    final eligibilityMessage = json['eligibility_message']?.toString() ?? '';

    final color = eligible ? Colors.green.shade600 : Colors.red.shade600;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              eligible ? Icons.check_rounded : Icons.priority_high_rounded,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eligible ? 'Eligible for Approval' : 'Not Eligible',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                if (eligibilityMessage.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    eligibilityMessage,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------
  // Transaction Card
  // -------------------------------------------------

  Widget _buildTransactionCard(ProfitTransaction transaction) {
    final json = transaction.toJson();

    final ownerCount =
        int.tryParse(json['owner_count']?.toString() ?? '0') ?? 0;

    final totalIncome =
        double.tryParse(json['total_income']?.toString() ?? '0') ?? 0;

    final totalExpense =
        double.tryParse(json['total_expense']?.toString() ?? '0') ?? 0;

    final availableProfit =
        double.tryParse(json['available_profit']?.toString() ?? '0') ?? 0;

    final equalShare =
        double.tryParse(json['equal_profit_share']?.toString() ?? '0') ?? 0;

    final ownerApprovedProfit =
        double.tryParse(json['owner_approved_profit']?.toString() ?? '0') ?? 0;

    final ownerPendingProfit =
        double.tryParse(json['owner_pending_profit']?.toString() ?? '0') ?? 0;

    final ownerOtherPendingProfit =
        double.tryParse(
          json['owner_other_pending_profit']?.toString() ?? '0',
        ) ??
        0;

    final ownerAvailableProfit =
        double.tryParse(json['owner_available_profit']?.toString() ?? '0') ?? 0;

    final eligible = json['eligible'] == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -----------------------------------------
          // Header
          // -----------------------------------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.amber.shade700, Colors.amber.shade500],
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.ownerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.agriculture_rounded,
                            color: Colors.white70,
                            size: 15,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              transaction.gardenName,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: const Text(
                    'PENDING',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -----------------------------------------
                // Requested Amount
                // -----------------------------------------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.amber.shade100),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(
                          Icons.payments_rounded,
                          color: _primaryColor,
                          size: 23,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Requested Profit',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _money(transaction.profitAmount),
                              style: TextStyle(
                                color: _primaryColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                _buildSectionTitle(
                  Icons.account_balance_rounded,
                  'Garden Financial Information',
                ),

                const SizedBox(height: 8),

                _buildAmountRow(
                  'Owners',
                  ownerCount.toDouble(),
                  displayAsMoney: false,
                ),

                _buildAmountRow('Total Income', totalIncome),

                _buildAmountRow('Total Expense', totalExpense),

                _buildAmountRow(
                  'Available Garden Profit',
                  availableProfit,
                  valueColor: Colors.green.shade600,
                  bold: true,
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 7),
                  child: Divider(height: 1),
                ),

                _buildSectionTitle(
                  Icons.person_rounded,
                  'Owner Profit Information',
                ),

                const SizedBox(height: 8),

                _buildAmountRow(
                  'Owner Equal Share',
                  equalShare,
                  valueColor: Colors.blue.shade600,
                ),

                _buildAmountRow(
                  'Already Approved',
                  ownerApprovedProfit,
                  valueColor: Colors.green.shade600,
                ),

                _buildAmountRow(
                  'All Pending',
                  ownerPendingProfit,
                  valueColor: Colors.orange.shade700,
                ),

                _buildAmountRow(
                  'Other Pending',
                  ownerOtherPendingProfit,
                  valueColor: Colors.orange.shade700,
                ),

                _buildAmountRow(
                  'Owner Available',
                  ownerAvailableProfit,
                  valueColor: ownerAvailableProfit > 0
                      ? Colors.green.shade600
                      : Colors.red.shade600,
                  bold: true,
                ),

                // -----------------------------------------
                // Eligibility
                // -----------------------------------------
                _buildEligibility(transaction),

                const SizedBox(height: 14),

                // -----------------------------------------
                // Owner History
                // -----------------------------------------
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _viewOwnerHistory(transaction);
                    },
                    icon: Icon(
                      Icons.history_rounded,
                      color: _primaryColor,
                      size: 19,
                    ),
                    label: const Text("VIEW OWNER'S EARLIER TRANSACTIONS"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primaryColor,
                      side: BorderSide(color: _primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // -----------------------------------------
                // Admin Actions
                // -----------------------------------------
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 45,
                        child: ElevatedButton.icon(
                          onPressed: eligible
                              ? () {
                                  _approveTransaction(transaction);
                                }
                              : null,
                          icon: const Icon(Icons.check_rounded, size: 19),
                          label: const Text('APPROVE'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            disabledForegroundColor: Colors.grey.shade500,
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 45,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _rejectTransaction(transaction);
                          },
                          icon: Icon(
                            Icons.close_rounded,
                            color: Colors.red.shade600,
                            size: 19,
                          ),
                          label: Text(
                            'REJECT',
                            style: TextStyle(
                              color: Colors.red.shade600,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.red.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // -----------------------------------------
                // Owner Note
                // -----------------------------------------
                if (transaction.profitNote != null &&
                    transaction.profitNote!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.sticky_note_2_rounded,
                          color: Colors.blue.shade600,
                          size: 19,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Owner Note',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                transaction.profitNote!,
                                style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  // -------------------------------------------------
  // Amount Row
  // -------------------------------------------------

  Widget _buildAmountRow(
    String label,
    double amount, {
    Color? valueColor,
    bool bold = false,
    bool displayAsMoney = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          Text(
            displayAsMoney ? _money(amount) : amount.toInt().toString(),
            style: TextStyle(
              color: valueColor ?? Colors.grey.shade900,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------
  // Section Title
  // -------------------------------------------------

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: _primaryColor, size: 18),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // -------------------------------------------------
  // Dialog Info Row
  // -------------------------------------------------

  Widget _buildDialogInfoRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------
  // History Info Row
  // -------------------------------------------------

  Widget _buildHistoryInfoRow(
    IconData icon,
    String label,
    String value, [
    Color? iconColor,
  ]) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: iconColor ?? Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------
  // Empty History
  // -------------------------------------------------

  Widget _buildEmptyHistory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history_rounded, color: _primaryColor, size: 42),
          ),
          const SizedBox(height: 14),
          const Text(
            'No Previous Transactions',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            'No previous profit transactions found.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------
  // Message
  // -------------------------------------------------

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
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

      appBar: AppBar(
        elevation: 4,
        shadowColor: Colors.black26,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        titleSpacing: 18,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
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
            const SizedBox(width: 12),
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
                  'Profit Management',
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
      ),

      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pie_chart_rounded, color: _primaryColor, size: 42),
                  const SizedBox(height: 12),
                  CircularProgressIndicator(color: _primaryColor),
                  const SizedBox(height: 12),
                  Text(
                    'Loading profit requests...',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: _primaryColor,
              onRefresh: _loadRequests,
              child: _transactions.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 150),
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  color: _primaryColor,
                                  size: 48,
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'No Pending Profit Requests',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'All profit requests have been processed.',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      children: [
                        // ---------------------------------
                        // Page Header
                        // ---------------------------------
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.pending_actions_rounded,
                                color: _primaryColor,
                                size: 23,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Pending Profit Requests',
                                    style: TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Review and manage owner profit requests',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_transactions.length}',
                                style: TextStyle(
                                  color: _primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        ..._transactions.map(
                          (transaction) => _buildTransactionCard(transaction),
                        ),
                      ],
                    ),
            ),
    );
  }
}
