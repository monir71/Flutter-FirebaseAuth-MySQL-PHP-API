import 'package:flutter/material.dart';
import '../../models/expense.dart';
import '../../models/garden.dart';
import '../../models/owner.dart';
import '../../services/expense_service.dart';
import '../../services/garden_service.dart';
import '../../services/owner_service.dart';

class ExpenseManagementScreen extends StatefulWidget {
  const ExpenseManagementScreen({super.key});

  @override
  State<ExpenseManagementScreen> createState() =>
      _ExpenseManagementScreenState();
}

class _ExpenseManagementScreenState extends State<ExpenseManagementScreen> {
  List<Expense> _expenses = [];
  List<Owner> _owners = [];
  List<Garden> _gardens = [];

  Owner? _selectedOwner;
  Garden? _selectedGarden;

  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  bool _isLoading = true;
  bool _isAdding = false;

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
        ExpenseService.getExpenses(),
        OwnerService.getOwners(),
        GardenService.getGardens(),
      ]);

      if (!mounted) return;

      setState(() {
        _expenses = results[0] as List<Expense>;
        _owners = results[1] as List<Owner>;
        _gardens = results[2] as List<Garden>;
      });
    } catch (e) {
      if (!mounted) return;

      _showMessage('Unable to load data: $e');
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  // -------------------------------------------------
  // Add Expense
  // -------------------------------------------------

  Future<void> _addExpense() async {
    if (_selectedOwner == null) {
      _showMessage('Please select an owner.');
      return;
    }

    if (_selectedGarden == null) {
      _showMessage('Please select a garden.');
      return;
    }

    final description = _descriptionController.text.trim();

    if (description.isEmpty) {
      _showMessage('Please enter expense description.');
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      _showMessage('Please enter a valid amount.');
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

      await ExpenseService.addExpense(
        ownerId: _selectedOwner!.ownerId,
        gardenId: _selectedGarden!.gardenId,
        expenseDescription: description,
        expenseAmount: amount,
        expenseDate: date,
      );

      if (!mounted) return;

      _descriptionController.clear();
      _amountController.clear();

      setState(() {
        _selectedOwner = null;
        _selectedGarden = null;
        _selectedDate = DateTime.now();
      });

      await _loadData();

      if (!mounted) return;

      _showMessage('Expense added successfully.');
    } catch (e) {
      if (!mounted) return;

      _showMessage('Unable to add expense: $e');
    } finally {
      if (!mounted) return;

      setState(() {
        _isAdding = false;
      });
    }
  }

  // -------------------------------------------------
  // Edit Expense
  // -------------------------------------------------

  Future<void> _editExpense(Expense expense) async {
    final descriptionController = TextEditingController(
      text: expense.expenseDescription ?? '',
    );

    final amountController = TextEditingController(
      text: expense.expenseAmount.toString(),
    );

    Owner? selectedOwner;

    Garden? selectedGarden;

    if (_owners.isNotEmpty) {
      selectedOwner = _owners.firstWhere(
        (owner) => owner.ownerId == expense.ownerId,
        orElse: () => _owners.first,
      );
    }

    if (_gardens.isNotEmpty) {
      selectedGarden = _gardens.firstWhere(
        (garden) => garden.gardenId == expense.gardenId,
        orElse: () => _gardens.first,
      );
    }

    DateTime selectedDate =
        DateTime.tryParse(expense.expenseDate ?? '') ?? DateTime.now();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 8),
              contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
              actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      color: Colors.deepOrange.shade600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Edit Expense',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    DropdownButtonFormField<Owner>(
                      value: selectedOwner,
                      decoration: _inputDecoration(
                        label: 'Owner',
                        icon: Icons.person_rounded,
                      ),
                      items: _owners.map((owner) {
                        return DropdownMenuItem<Owner>(
                          value: owner,
                          child: Text(owner.ownerName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedOwner = value;
                        });
                      },
                    ),

                    const SizedBox(height: 14),

                    DropdownButtonFormField<Garden>(
                      value: selectedGarden,
                      decoration: _inputDecoration(
                        label: 'Garden',
                        icon: Icons.agriculture_rounded,
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

                    TextField(
                      controller: descriptionController,
                      maxLines: 2,
                      decoration: _inputDecoration(
                        label: 'Expense Description',
                        icon: Icons.description_rounded,
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _inputDecoration(
                        label: 'Expense Amount',
                        icon: Icons.payments_rounded,
                        prefixText: '৳ ',
                      ),
                    ),

                    const SizedBox(height: 14),

                    _buildDialogDateSelector(
                      selectedDate: selectedDate,
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
                    Navigator.pop(context, false);
                  },
                  child: Text(
                    'CANCEL',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final description = descriptionController.text.trim();

                    final amount = double.tryParse(
                      amountController.text.trim(),
                    );

                    if (selectedOwner == null ||
                        selectedGarden == null ||
                        description.isEmpty ||
                        amount == null ||
                        amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter valid information.'),
                        ),
                      );

                      return;
                    }

                    final date =
                        '${selectedDate.year}-'
                        '${selectedDate.month.toString().padLeft(2, '0')}-'
                        '${selectedDate.day.toString().padLeft(2, '0')}';

                    try {
                      await ExpenseService.updateExpense(
                        expenseId: expense.expenseId,
                        ownerId: selectedOwner!.ownerId,
                        gardenId: selectedGarden!.gardenId,
                        expenseDescription: description,
                        expenseAmount: amount,
                        expenseDate: date,
                      );

                      if (!context.mounted) {
                        return;
                      }

                      Navigator.pop(context, true);
                    } catch (e) {
                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Update failed: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: const Text('SAVE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange.shade600,
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

    descriptionController.dispose();
    amountController.dispose();

    if (result == true) {
      await _loadData();

      if (!mounted) return;

      _showMessage('Expense updated successfully.');
    }
  }

  // -------------------------------------------------
  // Delete Expense
  // -------------------------------------------------

  Future<void> _deleteExpense(Expense expense) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 8),
          contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
          actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.delete_rounded, color: Colors.red.shade700),
              ),
              const SizedBox(width: 12),
              const Text(
                'Delete Expense',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to delete this expense?',
                  style: TextStyle(color: Colors.grey.shade800, fontSize: 15),
                ),

                const SizedBox(height: 12),

                _buildDeleteInfoRow(
                  Icons.description_rounded,
                  'Description',
                  expense.expenseDescription ?? '',
                ),

                const SizedBox(height: 7),

                _buildDeleteInfoRow(
                  Icons.payments_rounded,
                  'Amount',
                  '৳${expense.expenseAmount.toStringAsFixed(2)}',
                ),

                const SizedBox(height: 7),

                _buildDeleteInfoRow(
                  Icons.person_rounded,
                  'Owner',
                  expense.ownerName ?? '',
                ),

                const SizedBox(height: 7),

                _buildDeleteInfoRow(
                  Icons.agriculture_rounded,
                  'Garden',
                  expense.gardenName ?? '',
                ),
              ],
            ),
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
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context, true);
              },
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
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

    if (confirm != true) {
      return;
    }

    try {
      await ExpenseService.deleteExpense(expenseId: expense.expenseId);

      if (!mounted) return;

      setState(() {
        _expenses.removeWhere((item) => item.expenseId == expense.expenseId);
      });

      _showMessage('Expense deleted successfully.');
    } catch (e) {
      if (!mounted) return;

      _showMessage('Delete failed: $e');
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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(message),
      ),
    );
  }

  // -------------------------------------------------
  // Dispose
  // -------------------------------------------------

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();

    super.dispose();
  }

  // -------------------------------------------------
  // UI
  // -------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: const Color(0xFFF6F8FB),
      body: _isLoading
          ? _buildLoadingState()
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAddExpenseCard(),

                  const SizedBox(height: 28),

                  _buildExpenseListHeader(),

                  const SizedBox(height: 12),

                  Expanded(child: _buildExpenseList()),
                ],
              ),
            ),
    );
  }

  // -------------------------------------------------
  // App Bar
  // -------------------------------------------------

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 4,
      shadowColor: Colors.black26,
      backgroundColor: Colors.deepOrange.shade600,
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
              Icons.receipt_long_rounded,
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
                'Expense Management',
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
    );
  }

  // -------------------------------------------------
  // Loading State
  // -------------------------------------------------

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.deepOrange.shade50,
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.deepOrange.shade600,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'Loading expenses...',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------
  // Add Expense Card
  // -------------------------------------------------

  Widget _buildAddExpenseCard() {
    return Card(
      elevation: 6,
      shadowColor: Colors.deepOrange.withOpacity(0.20),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepOrange.shade600,
                  Colors.deepOrange.shade400,
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
                  child: const Icon(
                    Icons.add_card_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add New Expense',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Record a new garden expense',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
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
                DropdownButtonFormField<Owner>(
                  value: _selectedOwner,
                  decoration: _inputDecoration(
                    label: 'Owner',
                    icon: Icons.person_rounded,
                  ),
                  items: _owners.map((owner) {
                    return DropdownMenuItem<Owner>(
                      value: owner,
                      child: Text(owner.ownerName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedOwner = value;
                    });
                  },
                ),

                const SizedBox(height: 14),

                DropdownButtonFormField<Garden>(
                  value: _selectedGarden,
                  decoration: _inputDecoration(
                    label: 'Garden',
                    icon: Icons.agriculture_rounded,
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

                TextField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: _inputDecoration(
                    label: 'Expense Description',
                    icon: Icons.description_rounded,
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _inputDecoration(
                    label: 'Expense Amount',
                    icon: Icons.payments_rounded,
                    prefixText: '৳ ',
                  ),
                ),

                const SizedBox(height: 14),

                _buildMainDateSelector(),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isAdding ? null : _addExpense,
                    icon: _isAdding
                        ? const SizedBox(
                            width: 19,
                            height: 19,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.add_rounded, size: 20),
                    label: Text(
                      _isAdding ? 'ADDING EXPENSE...' : 'ADD EXPENSE',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange.shade600,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.deepOrange.shade300,
                      disabledForegroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
    );
  }

  // -------------------------------------------------
  // Expense List Header
  // -------------------------------------------------

  Widget _buildExpenseListHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: Colors.deepOrange.shade50,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            Icons.receipt_long_rounded,
            color: Colors.deepOrange.shade600,
            size: 22,
          ),
        ),

        const SizedBox(width: 12),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Expense List',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 2),
              Text(
                'All recorded garden expenses',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.deepOrange.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_expenses.length}',
            style: TextStyle(
              color: Colors.deepOrange.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------
  // Expense List
  // -------------------------------------------------

  Widget _buildExpenseList() {
    if (_expenses.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: Colors.deepOrange.shade600,
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: _expenses.length,
        itemBuilder: (context, index) {
          final expense = _expenses[index];

          return _buildExpenseCard(expense);
        },
      ),
    );
  }

  // -------------------------------------------------
  // Expense Card
  // -------------------------------------------------

  Widget _buildExpenseCard(Expense expense) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepOrange.shade600,
                    Colors.deepOrange.shade400,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt_long_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '#${expense.expenseId}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.expenseDescription ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    '৳${expense.expenseAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.deepOrange.shade700,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  _buildExpenseInfoRow(
                    Icons.person_outline_rounded,
                    expense.ownerName ?? '',
                  ),

                  const SizedBox(height: 5),

                  _buildExpenseInfoRow(
                    Icons.agriculture_outlined,
                    expense.gardenName ?? '',
                  ),

                  const SizedBox(height: 5),

                  _buildExpenseInfoRow(
                    Icons.calendar_today_outlined,
                    expense.expenseDate ?? '',
                  ),
                ],
              ),
            ),

            const SizedBox(width: 6),

            Column(
              children: [
                _buildActionButton(
                  icon: Icons.edit_rounded,
                  color: Colors.deepOrange.shade600,
                  tooltip: 'Edit Expense',
                  onPressed: () {
                    _editExpense(expense);
                  },
                ),

                const SizedBox(height: 7),

                _buildActionButton(
                  icon: Icons.delete_rounded,
                  color: Colors.red.shade600,
                  tooltip: 'Delete Expense',
                  onPressed: () {
                    _deleteExpense(expense);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------
  // Expense Info Row
  // -------------------------------------------------

  Widget _buildExpenseInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),

        const SizedBox(width: 7),

        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------
  // Action Button
  // -------------------------------------------------

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Icon(icon, color: color, size: 19),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------
  // Empty State
  // -------------------------------------------------

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.deepOrange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                color: Colors.deepOrange.shade600,
                size: 40,
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              'No expenses found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              'Add an expense using the form above.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------
  // Main Date Selector
  // -------------------------------------------------

  Widget _buildMainDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_month_rounded,
            color: Colors.deepOrange.shade600,
            size: 22,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expense Date',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                ),
                Text(
                  _formatDate(_selectedDate),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          TextButton.icon(
            onPressed: _selectDate,
            icon: const Icon(Icons.edit_calendar_rounded, size: 18),
            label: const Text('CHANGE'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.deepOrange.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------
  // Dialog Date Selector
  // -------------------------------------------------

  Widget _buildDialogDateSelector({
    required DateTime selectedDate,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_month_rounded,
            color: Colors.deepOrange.shade600,
            size: 21,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              _formatDate(selectedDate),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          TextButton(
            onPressed: onPressed,
            child: Text(
              'CHANGE',
              style: TextStyle(
                color: Colors.deepOrange.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------
  // Input Decoration
  // -------------------------------------------------

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? prefixText,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.deepOrange.shade600),
      prefixText: prefixText,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.deepOrange.shade600, width: 1.8),
      ),
    );
  }

  // -------------------------------------------------
  // Delete Info Row
  // -------------------------------------------------

  Widget _buildDeleteInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 17, color: Colors.grey.shade600),

        const SizedBox(width: 8),

        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),

        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------
  // Date Format
  // -------------------------------------------------

  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
