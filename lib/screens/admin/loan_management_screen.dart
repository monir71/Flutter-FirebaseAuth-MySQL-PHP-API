import 'package:flutter/material.dart';
import '../../models/financial_partner.dart';
import '../../models/garden.dart';
import '../../models/loan.dart';
import '../../services/financial_partner_service.dart';
import '../../services/garden_service.dart';
import '../../services/loan_service.dart';

class LoanManagementScreen extends StatefulWidget {
  const LoanManagementScreen({super.key});

  @override
  State<LoanManagementScreen> createState() => _LoanManagementScreenState();
}

class _LoanManagementScreenState extends State<LoanManagementScreen> {
  List<Loan> _loans = [];
  List<FinancialPartner> _partners = [];
  List<Garden> _gardens = [];

  FinancialPartner? _selectedPartner;
  Garden? _selectedGarden;

  final _purposeController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  bool _isLoading = true;
  bool _isAdding = false;

  final Color _primaryColor = Colors.indigo.shade600;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // -------------------------------------------------
  // Load Data
  // -------------------------------------------------

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        LoanService.getLoans(),
        FinancialPartnerService.getPartners(),
        GardenService.getGardens(),
      ]);

      if (!mounted) return;

      setState(() {
        _loans = results[0] as List<Loan>;
        _partners = results[1] as List<FinancialPartner>;
        _gardens = results[2] as List<Garden>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage('Unable to load data: $e');
    }
  }

  // -------------------------------------------------
  // Add Loan
  // -------------------------------------------------

  Future<void> _addLoan() async {
    if (_selectedPartner == null) {
      _showMessage('Please select a financial partner.');
      return;
    }

    if (_selectedGarden == null) {
      _showMessage('Please select a garden.');
      return;
    }

    final purpose = _purposeController.text.trim();

    if (purpose.isEmpty) {
      _showMessage('Please enter loan purpose.');
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      _showMessage('Please enter a valid loan amount.');
      return;
    }

    setState(() {
      _isAdding = true;
    });

    try {
      final date =
          '${_selectedDate.year}-'
          '${_selectedDate.month.toString().padLeft(2, '0')}-'
          '${_selectedDate.day.toString().padLeft(2, '0')}';

      final loan = await LoanService.addLoan(
        partnerId: _selectedPartner!.partnerId,
        gardenId: _selectedGarden!.gardenId,
        loanPurpose: purpose,
        loanAmount: amount,
        loanDate: date,
      );

      if (!mounted) return;

      // -------------------------------------------------
      // Add partner/garden names immediately.
      // -------------------------------------------------

      final loanWithNames = Loan(
        loanId: loan.loanId,
        partnerId: loan.partnerId,
        partnerName: _selectedPartner!.partnerName,
        partnerInstitution: _selectedPartner!.partnerInstitution,
        gardenId: loan.gardenId,
        gardenName: _selectedGarden!.gardenName,
        loanPurpose: loan.loanPurpose,
        loanAmount: loan.loanAmount,
        loanDate: loan.loanDate,
        createdAt: loan.createdAt,
      );

      setState(() {
        _loans.insert(0, loanWithNames);

        _purposeController.clear();
        _amountController.clear();

        _selectedPartner = null;
        _selectedGarden = null;

        _selectedDate = DateTime.now();
      });

      _showMessage('Loan added successfully.');
    } catch (e) {
      if (!mounted) return;

      _showMessage('Unable to add loan: $e');
    } finally {
      if (!mounted) return;

      setState(() {
        _isAdding = false;
      });
    }
  }

  // -------------------------------------------------
  // Edit Loan
  // -------------------------------------------------

  Future<void> _editLoan(Loan loan) async {
    FinancialPartner? selectedPartner;

    try {
      selectedPartner = _partners.firstWhere(
        (partner) => partner.partnerId == loan.partnerId,
      );
    } catch (_) {
      selectedPartner = null;
    }

    Garden? selectedGarden;

    try {
      selectedGarden = _gardens.firstWhere(
        (garden) => garden.gardenId == loan.gardenId,
      );
    } catch (_) {
      selectedGarden = null;
    }

    final purposeController = TextEditingController(text: loan.loanPurpose);

    final amountController = TextEditingController(
      text: loan.loanAmount.toString(),
    );

    DateTime selectedDate = DateTime.parse(loan.loanDate);

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      color: _primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Edit Loan',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Financial Partner
                    DropdownButtonFormField<FinancialPartner>(
                      value: selectedPartner,
                      decoration: _inputDecoration(
                        'Financial Partner',
                        Icons.handshake_rounded,
                      ),
                      items: _partners.map((partner) {
                        return DropdownMenuItem<FinancialPartner>(
                          value: partner,
                          child: Text(partner.partnerName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedPartner = value;
                        });
                      },
                    ),

                    const SizedBox(height: 14),

                    // Garden
                    DropdownButtonFormField<Garden>(
                      value: selectedGarden,
                      decoration: _inputDecoration(
                        'Garden',
                        Icons.agriculture_rounded,
                      ),
                      items: _gardens.map((garden) {
                        return DropdownMenuItem<Garden>(
                          value: garden,
                          child: Text(garden.gardenName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedGarden = value;
                        });
                      },
                    ),

                    const SizedBox(height: 14),

                    // Purpose
                    TextField(
                      controller: purposeController,
                      decoration: _inputDecoration(
                        'Loan Purpose',
                        Icons.description_rounded,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Amount
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _inputDecoration(
                        'Loan Amount',
                        Icons.payments_rounded,
                        prefixText: '৳ ',
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Date
                    _buildDateSelector(
                      date: selectedDate,
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );

                        if (date != null) {
                          setDialogState(() {
                            selectedDate = date;
                          });
                        }
                      },
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
                  onPressed: () async {
                    if (selectedPartner == null || selectedGarden == null) {
                      return;
                    }

                    final purpose = purposeController.text.trim();

                    final amount = double.tryParse(
                      amountController.text.trim(),
                    );

                    if (purpose.isEmpty || amount == null || amount <= 0) {
                      return;
                    }

                    final date =
                        '${selectedDate.year}-'
                        '${selectedDate.month.toString().padLeft(2, '0')}-'
                        '${selectedDate.day.toString().padLeft(2, '0')}';

                    try {
                      final updatedLoan = await LoanService.updateLoan(
                        loanId: loan.loanId,
                        partnerId: selectedPartner!.partnerId,
                        gardenId: selectedGarden!.gardenId,
                        loanPurpose: purpose,
                        loanAmount: amount,
                        loanDate: date,
                      );

                      if (!mounted) {
                        return;
                      }

                      // ---------------------------------
                      // Add names immediately
                      // ---------------------------------

                      final updatedLoanWithNames = Loan(
                        loanId: updatedLoan.loanId,
                        partnerId: updatedLoan.partnerId,
                        partnerName: selectedPartner!.partnerName,
                        partnerInstitution: selectedPartner!.partnerInstitution,
                        gardenId: updatedLoan.gardenId,
                        gardenName: selectedGarden!.gardenName,
                        loanPurpose: updatedLoan.loanPurpose,
                        loanAmount: updatedLoan.loanAmount,
                        loanDate: updatedLoan.loanDate,
                        createdAt: loan.createdAt,
                      );

                      final index = _loans.indexWhere(
                        (item) => item.loanId == loan.loanId,
                      );

                      setState(() {
                        if (index != -1) {
                          _loans[index] = updatedLoanWithNames;
                        }
                      });

                      Navigator.pop(dialogContext, true);

                      _showMessage('Loan updated successfully.');
                    } catch (e) {
                      _showMessage('Unable to update loan: $e');
                    }
                  },
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: const Text('SAVE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
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
      },
    );

    purposeController.dispose();
    amountController.dispose();
  }

  // -------------------------------------------------
  // Delete Loan
  // -------------------------------------------------

  Future<void> _deleteLoan(Loan loan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
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
                  Icons.delete_rounded,
                  color: Colors.red.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Delete Loan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Are you sure you want to delete this loan?',
                  style: TextStyle(fontSize: 15),
                ),
              ),

              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDialogInfoRow(
                      Icons.payments_rounded,
                      'Amount',
                      '৳${loan.loanAmount.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 8),
                    _buildDialogInfoRow(
                      Icons.handshake_rounded,
                      'Partner',
                      loan.partnerName,
                    ),
                    const SizedBox(height: 8),
                    _buildDialogInfoRow(
                      Icons.agriculture_rounded,
                      'Garden',
                      loan.gardenName,
                    ),
                    const SizedBox(height: 8),
                    _buildDialogInfoRow(
                      Icons.description_rounded,
                      'Purpose',
                      loan.loanPurpose,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
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
                Navigator.pop(context, true);
              },
              icon: const Icon(Icons.delete_rounded, size: 18),
              label: const Text('DELETE'),
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

    if (confirmed != true) {
      return;
    }

    try {
      await LoanService.deleteLoan(loanId: loan.loanId);

      if (!mounted) return;

      setState(() {
        _loans.removeWhere((item) => item.loanId == loan.loanId);
      });

      _showMessage('Loan deleted successfully.');
    } catch (e) {
      if (!mounted) return;

      _showMessage('Unable to delete loan: $e');
    }
  }

  // -------------------------------------------------
  // Date Picker
  // -------------------------------------------------

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
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
  // Helpers
  // -------------------------------------------------

  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    String? prefixText,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _primaryColor),
      prefixText: prefixText,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
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
        borderSide: BorderSide(color: _primaryColor, width: 1.5),
      ),
    );
  }

  Widget _buildDateSelector({
    required DateTime date,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_month_rounded, color: _primaryColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Loan Date',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatDate(date),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.edit_calendar_rounded, size: 18),
            label: const Text('CHANGE'),
            style: TextButton.styleFrom(foregroundColor: _primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.red.shade600),
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

  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _purposeController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // -------------------------------------------------
  // UI
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
                Icons.account_balance_rounded,
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
                  'Loan Management',
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
                  Icon(
                    Icons.account_balance_rounded,
                    color: _primaryColor,
                    size: 42,
                  ),
                  const SizedBox(height: 12),
                  CircularProgressIndicator(color: _primaryColor),
                  const SizedBox(height: 12),
                  Text(
                    'Loading loans...',
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
              onRefresh: _loadData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  _buildAddLoanCard(),

                  const SizedBox(height: 30),

                  _buildLoanListHeader(),

                  const SizedBox(height: 12),

                  _buildLoanList(),
                ],
              ),
            ),
    );
  }

  // -------------------------------------------------
  // Add Loan Card
  // -------------------------------------------------

  Widget _buildAddLoanCard() {
    return Card(
      elevation: 6,
      shadowColor: Colors.indigo.withOpacity(0.18),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade700, Colors.indigo.shade400],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.add_card_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add New Loan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Record a new garden loan',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Partner
                DropdownButtonFormField<FinancialPartner>(
                  value: _selectedPartner,
                  decoration: _inputDecoration(
                    'Financial Partner',
                    Icons.handshake_rounded,
                  ),
                  items: _partners.map((partner) {
                    return DropdownMenuItem<FinancialPartner>(
                      value: partner,
                      child: Text(partner.partnerName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPartner = value;
                    });
                  },
                ),

                const SizedBox(height: 14),

                // Garden
                DropdownButtonFormField<Garden>(
                  value: _selectedGarden,
                  decoration: _inputDecoration(
                    'Garden',
                    Icons.agriculture_rounded,
                  ),
                  items: _gardens.map((garden) {
                    return DropdownMenuItem<Garden>(
                      value: garden,
                      child: Text(garden.gardenName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGarden = value;
                    });
                  },
                ),

                const SizedBox(height: 14),

                // Purpose
                TextField(
                  controller: _purposeController,
                  decoration: _inputDecoration(
                    'Loan Purpose',
                    Icons.description_rounded,
                  ),
                ),

                const SizedBox(height: 14),

                // Amount
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _inputDecoration(
                    'Loan Amount',
                    Icons.payments_rounded,
                    prefixText: '৳ ',
                  ),
                ),

                const SizedBox(height: 14),

                // Date
                _buildDateSelector(date: _selectedDate, onPressed: _selectDate),

                const SizedBox(height: 18),

                // Add button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isAdding ? null : _addLoan,
                    icon: _isAdding
                        ? const SizedBox(
                            width: 19,
                            height: 19,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.add_rounded),
                    label: Text(_isAdding ? 'ADDING...' : 'ADD LOAN'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.indigo.shade300,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      ),
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
  // Loan List Header
  // -------------------------------------------------

  Widget _buildLoanListHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.account_balance_wallet_rounded,
            color: _primaryColor,
            size: 23,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Loan List',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 2),
              Text(
                'All recorded garden loans',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_loans.length}',
            style: TextStyle(
              color: _primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------
  // Loan List
  // -------------------------------------------------

  Widget _buildLoanList() {
    if (_loans.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_rounded,
                color: _primaryColor,
                size: 46,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No loans found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Add a loan to see it here.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _loans.map((loan) {
        return _buildLoanCard(loan);
      }).toList(),
    );
  }

  // -------------------------------------------------
  // Loan Card
  // -------------------------------------------------

  Widget _buildLoanCard(Loan loan) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.08),
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ID Box
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.indigo.shade700, Colors.indigo.shade400],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.account_balance_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '#${loan.loanId}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '৳${loan.loanAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: _primaryColor,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  _buildLoanInfoRow(Icons.handshake_rounded, loan.partnerName),

                  const SizedBox(height: 5),

                  _buildLoanInfoRow(
                    Icons.business_rounded,
                    loan.partnerInstitution,
                  ),

                  const SizedBox(height: 5),

                  _buildLoanInfoRow(Icons.agriculture_rounded, loan.gardenName),

                  const SizedBox(height: 5),

                  _buildLoanInfoRow(
                    Icons.description_rounded,
                    loan.loanPurpose,
                  ),

                  const SizedBox(height: 5),

                  _buildLoanInfoRow(
                    Icons.calendar_month_rounded,
                    loan.loanDate,
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 38,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _editLoan(loan);
                            },
                            icon: const Icon(Icons.edit_rounded, size: 17),
                            label: const Text('EDIT'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _primaryColor,
                              side: BorderSide(color: _primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 38,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _deleteLoan(loan);
                            },
                            icon: const Icon(Icons.delete_rounded, size: 17),
                            label: const Text('DELETE'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red.shade600,
                              side: BorderSide(color: Colors.red.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
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

  Widget _buildLoanInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
