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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load profit requests: $e')),
      );
    }
  }

  // -------------------------------------------------
  // Approve Transaction
  // -------------------------------------------------

  Future<void> _approveTransaction(ProfitTransaction transaction) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Approve Profit Request'),
          content: Text(
            'Approve ${_money(transaction.profitAmount)} '
            'for ${transaction.ownerName}?\n\n'
            'Garden: ${transaction.gardenName}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Approve'),
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profit request approved successfully.')),
      );

      await _loadRequests();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to approve request: $e')));
    }
  }

  // -------------------------------------------------
  // Reject Transaction
  // -------------------------------------------------

  Future<void> _rejectTransaction(ProfitTransaction transaction) async {
    final noteController = TextEditingController();

    final note = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reject Profit Request'),
          content: TextField(
            controller: noteController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Reason',
              hintText: 'Enter rejection reason',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, noteController.text.trim());
              },
              child: const Text('Reject'),
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profit request rejected successfully.')),
      );

      await _loadRequests();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to reject request: $e')));
    }
  }

  // -------------------------------------------------
  // View Owner Earlier Transactions
  // -------------------------------------------------

  Future<void> _viewOwnerHistory(ProfitTransaction transaction) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
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
        builder: (context) {
          return AlertDialog(
            title: Text('${transaction.ownerName} - Profit History'),
            content: SizedBox(
              width: 500,
              height: 450,
              child: history.isEmpty
                  ? const Center(
                      child: Text('No previous profit transactions found.'),
                    )
                  : ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final item = history[index];

                        final status = item.status.toLowerCase();

                        Color statusColor;

                        if (status == 'approved') {
                          statusColor = Colors.green;
                        } else if (status == 'rejected') {
                          statusColor = Colors.red;
                        } else {
                          statusColor = Colors.orange;
                        }

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _money(item.profitAmount),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Text(
                                        item.status.toUpperCase(),
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  'Date: '
                                  '${item.profitDate}',
                                  style: const TextStyle(color: Colors.grey),
                                ),

                                if (item.profitNote != null &&
                                    item.profitNote!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Owner Note: '
                                    '${item.profitNote}',
                                  ),
                                ],

                                if (item.adminNote != null &&
                                    item.adminNote!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Admin Note: '
                                    '${item.adminNote}',
                                    style: TextStyle(color: statusColor),
                                  ),
                                ],

                                if (item.approvedByName != null &&
                                    item.approvedByName!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Approved by: '
                                    '${item.approvedByName}',
                                  ),
                                ],

                                if (item.approvedAt != null &&
                                    item.approvedAt!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Approved at: '
                                    '${item.approvedAt}',
                                    style: const TextStyle(color: Colors.grey),
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
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load owner history: $e')),
      );
    }
  }

  // -------------------------------------------------
  // Eligibility Section
  // -------------------------------------------------

  Widget _buildEligibility(ProfitTransaction transaction) {
    final json = transaction.toJson();

    final eligible = json['eligible'] == true;

    final eligibilityMessage = json['eligibility_message']?.toString() ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: eligible
            ? Colors.green.withOpacity(0.08)
            : Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            eligible ? Icons.check_circle : Icons.error,
            color: eligible ? Colors.green : Colors.red,
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
                    color: eligible ? Colors.green : Colors.red,
                  ),
                ),

                if (eligibilityMessage.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(eligibilityMessage),
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
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -----------------------------------------
            // Owner + Status
            // -----------------------------------------
            Row(
              children: [
                Expanded(
                  child: Text(
                    transaction.ownerName,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'PENDING',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              'Garden: ${transaction.gardenName}',
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 14),

            // -----------------------------------------
            // Requested
            // -----------------------------------------
            _buildAmountRow(
              'Requested',
              transaction.profitAmount,
              valueColor: Colors.blue,
              bold: true,
            ),

            const Divider(),

            // -----------------------------------------
            // Garden Information
            // -----------------------------------------
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
              valueColor: Colors.green,
            ),

            const Divider(),

            // -----------------------------------------
            // Owner Profit Information
            // -----------------------------------------
            _buildAmountRow(
              'Owner Equal Share',
              equalShare,
              valueColor: Colors.blue,
            ),

            _buildAmountRow(
              'Already Approved',
              ownerApprovedProfit,
              valueColor: Colors.green,
            ),

            _buildAmountRow(
              'All Pending',
              ownerPendingProfit,
              valueColor: Colors.orange,
            ),

            _buildAmountRow(
              'Other Pending',
              ownerOtherPendingProfit,
              valueColor: Colors.orange,
            ),

            _buildAmountRow(
              'Owner Available',
              ownerAvailableProfit,
              valueColor: ownerAvailableProfit > 0 ? Colors.green : Colors.red,
              bold: true,
            ),

            // -----------------------------------------
            // Eligibility
            // -----------------------------------------
            _buildEligibility(transaction),

            // -----------------------------------------
            // Owner History
            // -----------------------------------------
            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _viewOwnerHistory(transaction);
                },
                icon: const Icon(Icons.history),
                label: const Text("View Owner's Earlier Transactions"),
              ),
            ),

            // -----------------------------------------
            // Admin Actions
            // -----------------------------------------
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: eligible
                        ? () {
                            _approveTransaction(transaction);
                          }
                        : null,
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _rejectTransaction(transaction);
                    },
                    icon: const Icon(Icons.close, color: Colors.red),
                    label: const Text(
                      'Reject',
                      style: TextStyle(color: Colors.red),
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
              const SizedBox(height: 12),
              Text(
                'Owner Note: '
                '${transaction.profitNote}',
              ),
            ],
          ],
        ),
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
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),

          Text(
            displayAsMoney ? _money(amount) : amount.toInt().toString(),
            style: TextStyle(fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------
  // Build
  // -------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profit Requests',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRequests,
              child: _transactions.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 180),
                        Center(child: Text('No pending profit requests.')),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        const Text(
                          'Pending Profit Requests',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          '${_transactions.length} '
                          'pending request(s)',
                          style: const TextStyle(color: Colors.grey),
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
