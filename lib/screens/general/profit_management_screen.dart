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

  // -------------------------------------------------
  // Money Format
  // -------------------------------------------------

  String _money(double value) {
    final formatter = NumberFormat('#,##0');

    return '৳ ${formatter.format(value)}';
  }

  // -------------------------------------------------
  // Load Data
  // -------------------------------------------------

  Future<void> _loadData() async {
    try {
      final summary = await ProfitService.getProfitSummary(
        gardenId: widget.garden.gardenId,
      );

      final allTransactions =
      await ProfitService.getMyProfits();

      print('==============================');
      print('MY PROFIT TRANSACTIONS');
      print('Count: ${allTransactions.length}');

      for (final transaction in allTransactions) {
        print(
          'ID: ${transaction.profitTransactionId} | '
              'Owner: ${transaction.ownerId} | '
              'Garden: ${transaction.gardenId} | '
              'Amount: ${transaction.profitAmount} | '
              'Status: ${transaction.status}',
        );
      }

      print('Current garden ID: ${widget.garden.gardenId}');
      print('==============================');

      if (!mounted) return;

      final gardenTransactions = allTransactions
          .where(
            (transaction) =>
        transaction.gardenId ==
            widget.garden.gardenId,
      )
          .toList();

      print(
        'Transactions for current garden: '
            '${gardenTransactions.length}',
      );

      setState(() {
        _summary = summary;
        _transactions = gardenTransactions;
        _isLoading = false;
      });

    } catch (e) {
      print('PROFIT LOAD ERROR: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to load profit information: $e',
          ),
        ),
      );
    }
  }

  // -------------------------------------------------
  // Request Profit Withdrawal
  // -------------------------------------------------

  Future<void> _requestProfit() async {
    final summary = _summary;

    if (summary == null) {
      return;
    }

    final availableProfit =
        double.tryParse(summary['my_available_profit']?.toString() ?? '0') ?? 0;

    if (availableProfit <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No profit is currently available for withdrawal.'),
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
          title: const Text('Withdraw Profit'),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Available profit: '
                '${_money(availableProfit)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Profit Amount',
                  prefixText: '৳ ',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Note (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
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
              child: const Text('Request'),
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

  // -------------------------------------------------
  // Create Profit Request
  // -------------------------------------------------

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
        const SnackBar(
          content: Text(
            'Profit withdrawal request submitted. '
            'Waiting for admin approval.',
          ),
        ),
      );

      await _loadData();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to submit request: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // -------------------------------------------------
  // Cancel Request
  // -------------------------------------------------

  Future<void> _cancelTransaction(ProfitTransaction transaction) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Request'),

          content: Text(
            'Cancel the profit withdrawal '
            'request of '
            '${_money(transaction.profitAmount)}?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('No'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
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
        const SnackBar(content: Text('Profit withdrawal request cancelled.')),
      );

      await _loadData();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to cancel request: $e')));
    }
  }

  // -------------------------------------------------
  // Status Color
  // -------------------------------------------------

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

  // -------------------------------------------------
  // Status Text
  // -------------------------------------------------

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

  // -------------------------------------------------
  // Summary Card
  // -------------------------------------------------

  Widget _buildSummaryCard() {
    final summary = _summary;

    // Safety check.
    // Never use _summary! here.
    if (summary == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 40, color: Colors.red),

              const SizedBox(height: 10),

              const Text(
                'Profit information is unavailable.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Try Again'),
              ),
            ],
          ),
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

    return Card(
      elevation: 4,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              widget.garden.gardenName,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              'Owners: $ownerCount',
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 18),

            _buildAmountRow('Total Income', totalIncome),

            _buildAmountRow('Total Expense', totalExpense),

            const Divider(),

            _buildAmountRow(
              'Available Garden Profit',
              availableProfit,
              valueColor: Colors.green,
            ),

            _buildAmountRow(
              'My Equal Profit Share',
              equalShare,
              valueColor: Colors.blue,
            ),

            _buildAmountRow(
              'My Approved Profit',
              myApprovedProfit,
              valueColor: Colors.green,
            ),

            _buildAmountRow(
              'My Pending Profit',
              myPendingProfit,
              valueColor: Colors.orange,
            ),

            const Divider(),

            _buildAmountRow(
              'My Available Profit',
              myAvailableProfit,
              valueColor: myAvailableProfit > 0 ? Colors.green : Colors.red,
              bold: true,
            ),
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),

      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),

          Text(
            _money(amount),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: valueColor,
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
    final statusColor = _statusColor(transaction.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      child: Padding(
        padding: const EdgeInsets.all(14),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _money(transaction.profitAmount),

                    style: const TextStyle(
                      fontSize: 18,
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
                    color: statusColor.withOpacity(0.12),

                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(
                    _statusText(transaction.status),

                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              'Date: '
              '${transaction.profitDate}',
              style: const TextStyle(color: Colors.grey),
            ),

            // ---------------------------------------
            // Profit Note
            // ---------------------------------------
            if (transaction.profitNote?.isNotEmpty == true) ...[
              const SizedBox(height: 6),

              Text(
                'Note: '
                '${transaction.profitNote}',
              ),
            ],

            // ---------------------------------------
            // Admin Note
            // ---------------------------------------
            if (transaction.adminNote?.isNotEmpty == true) ...[
              const SizedBox(height: 6),

              Text(
                'Admin Note: '
                '${transaction.adminNote}',

                style: TextStyle(color: statusColor),
              ),
            ],

            // ---------------------------------------
            // Approved By
            // ---------------------------------------
            if (transaction.approvedByName?.isNotEmpty == true) ...[
              const SizedBox(height: 6),

              Text(
                'Approved by: '
                '${transaction.approvedByName}',
              ),
            ],

            // ---------------------------------------
            // Approved At
            // ---------------------------------------
            if (transaction.approvedAt?.isNotEmpty == true) ...[
              const SizedBox(height: 6),

              Text(
                'Approved at: '
                '${transaction.approvedAt}',
              ),
            ],

            // ---------------------------------------
            // Cancel Pending Request
            // ---------------------------------------
            if (transaction.status.toLowerCase() == 'pending') ...[
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,

                child: TextButton.icon(
                  onPressed: () {
                    _cancelTransaction(transaction);
                  },

                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),

                  label: const Text(
                    'Cancel Request',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ],
        ),
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
          'Profit Management',
          style: TextStyle(color: Colors.white),
        ),

        backgroundColor: Colors.blue,

        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,

              child: ListView(
                padding: const EdgeInsets.all(16),

                children: [
                  _buildSummaryCard(),

                  const SizedBox(height: 20),

                  SizedBox(
                    height: 52,

                    child: ElevatedButton.icon(
                      onPressed: _summary == null || _isSubmitting
                          ? null
                          : _requestProfit,

                      icon: const Icon(Icons.account_balance_wallet),

                      label: _isSubmitting
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Request Profit Withdrawal'),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'My Profit Transactions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  if (_transactions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(30),

                      child: Center(
                        child: Text('No profit transactions found.'),
                      ),
                    )
                  else
                    ..._transactions.map(
                      (transaction) => _buildTransactionCard(transaction),
                    ),
                ],
              ),
            ),
    );
  }
}
