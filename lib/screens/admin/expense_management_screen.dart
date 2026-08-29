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

class _ExpenseManagementScreenState
    extends State<ExpenseManagementScreen> {

  List<Expense> _expenses = [];
  List<Owner> _owners = [];
  List<Garden> _gardens = [];

  Owner? _selectedOwner;
  Garden? _selectedGarden;

  final _descriptionController =
  TextEditingController();

  final _amountController =
  TextEditingController();

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

      _showMessage(
        'Unable to load data: $e',
      );

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
      _showMessage(
        'Please select an owner.',
      );
      return;
    }

    if (_selectedGarden == null) {
      _showMessage(
        'Please select a garden.',
      );
      return;
    }

    final description =
    _descriptionController.text.trim();

    if (description.isEmpty) {
      _showMessage(
        'Please enter expense description.',
      );
      return;
    }

    final amount = double.tryParse(
      _amountController.text.trim(),
    );

    if (amount == null || amount <= 0) {
      _showMessage(
        'Please enter a valid amount.',
      );
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

      // Reload so owner and garden names are available.
      await _loadData();

      if (!mounted) return;

      _showMessage(
        'Expense added successfully.',
      );

    } catch (e) {

      if (!mounted) return;

      _showMessage(
        'Unable to add expense: $e',
      );

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

    final descriptionController =
    TextEditingController(
      text: expense.expenseDescription,
    );

    final amountController =
    TextEditingController(
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
        DateTime.tryParse(expense.expenseDate) ??
            DateTime.now();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {

        return StatefulBuilder(
          builder: (context, setDialogState) {

            return AlertDialog(
              title: const Text('Edit Expense'),

              content: SingleChildScrollView(
                child: Column(
                  children: [

                    // Owner
                    DropdownButtonFormField<Owner>(
                      value: selectedOwner,

                      decoration:
                      const InputDecoration(
                        labelText: 'Owner',
                        border:
                        OutlineInputBorder(),
                      ),

                      items: _owners.map(
                            (owner) {
                          return DropdownMenuItem<Owner>(
                            value: owner,
                            child: Text(
                              owner.ownerName,
                            ),
                          );
                        },
                      ).toList(),

                      onChanged: (value) {
                        setDialogState(() {
                          selectedOwner = value;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    // Garden
                    DropdownButtonFormField<Garden>(
                      value: selectedGarden,

                      decoration:
                      const InputDecoration(
                        labelText: 'Garden',
                        border:
                        OutlineInputBorder(),
                      ),

                      items: _gardens.map(
                            (garden) {
                          return DropdownMenuItem<Garden>(
                            value: garden,
                            child: Text(
                              garden.gardenName,
                            ),
                          );
                        },
                      ).toList(),

                      onChanged: (value) {
                        setDialogState(() {
                          selectedGarden = value;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    // Description
                    TextField(
                      controller:
                      descriptionController,

                      decoration:
                      const InputDecoration(
                        labelText:
                        'Expense Description',
                        border:
                        OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Amount
                    TextField(
                      controller:
                      amountController,

                      keyboardType:
                      const TextInputType
                          .numberWithOptions(
                        decimal: true,
                      ),

                      decoration:
                      const InputDecoration(
                        labelText:
                        'Expense Amount',
                        border:
                        OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Date
                    Row(
                      children: [

                        Expanded(
                          child: Text(
                            'Date: '
                                '${selectedDate.year}-'
                                '${selectedDate.month.toString().padLeft(2, '0')}-'
                                '${selectedDate.day.toString().padLeft(2, '0')}',
                          ),
                        ),

                        TextButton(
                          onPressed: () async {

                            final date =
                            await showDatePicker(
                              context: context,
                              initialDate:
                              selectedDate,
                              firstDate:
                              DateTime(2000),
                              lastDate:
                              DateTime(2100),
                            );

                            if (date != null) {

                              setDialogState(() {
                                selectedDate =
                                    date;
                              });
                            }
                          },
                          child:
                          const Text('DATE'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              actions: [

                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      false,
                    );
                  },
                  child:
                  const Text('CANCEL'),
                ),

                ElevatedButton(
                  onPressed: () async {

                    final description =
                    descriptionController
                        .text
                        .trim();

                    final amount =
                    double.tryParse(
                      amountController
                          .text
                          .trim(),
                    );

                    if (selectedOwner == null ||
                        selectedGarden == null ||
                        description.isEmpty ||
                        amount == null ||
                        amount <= 0) {

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter valid information.',
                          ),
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
                        expenseId:
                        expense.expenseId,
                        ownerId:
                        selectedOwner!.ownerId,
                        gardenId:
                        selectedGarden!.gardenId,
                        expenseDescription:
                        description,
                        expenseAmount:
                        amount,
                        expenseDate:
                        date,
                      );

                      if (!context.mounted) {
                        return;
                      }

                      Navigator.pop(
                        context,
                        true,
                      );

                    } catch (e) {

                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Update failed: $e',
                          ),
                        ),
                      );
                    }
                  },

                  child:
                  const Text('SAVE'),
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

      _showMessage(
        'Expense updated successfully.',
      );
    }
  }

  // -------------------------------------------------
// Delete Expense
// -------------------------------------------------

  Future<void> _deleteExpense(
      Expense expense) async {

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {

        return AlertDialog(
          title: const Text('Delete Expense'),

          content: const Text(
            'Are you sure you want to delete this expense?',
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child:
              const Text('CANCEL'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child:
              const Text('DELETE'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {

      await ExpenseService.deleteExpense(
        expenseId: expense.expenseId,
      );

      if (!mounted) return;

      setState(() {

        _expenses.removeWhere(
              (item) =>
          item.expenseId ==
              expense.expenseId,
        );
      });

      _showMessage(
        'Expense deleted successfully.',
      );

    } catch (e) {

      if (!mounted) return;

      _showMessage(
        'Delete failed: $e',
      );
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
      ),
    );
  }

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
      appBar: AppBar(
        title: const Text(
          'Expense Management',
        ),
      ),

      body: _isLoading

          ? const Center(
        child: CircularProgressIndicator(),
      )

          : Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            const Text(
              'Add Expense',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Owner
            DropdownButtonFormField<Owner>(
              value: _selectedOwner,

              decoration:
              const InputDecoration(
                labelText: 'Owner',
                border:
                OutlineInputBorder(),
              ),

              items: _owners.map(
                    (owner) {
                  return DropdownMenuItem<
                      Owner>(
                    value: owner,
                    child: Text(
                      owner.ownerName,
                    ),
                  );
                },
              ).toList(),

              onChanged: (value) {
                setState(() {
                  _selectedOwner = value;
                });
              },
            ),

            const SizedBox(height: 12),

            // Garden
            DropdownButtonFormField<Garden>(
              value: _selectedGarden,

              decoration:
              const InputDecoration(
                labelText: 'Garden',
                border:
                OutlineInputBorder(),
              ),

              items: _gardens.map(
                    (garden) {
                  return DropdownMenuItem<
                      Garden>(
                    value: garden,
                    child: Text(
                      garden.gardenName,
                    ),
                  );
                },
              ).toList(),

              onChanged: (value) {
                setState(() {
                  _selectedGarden = value;
                });
              },
            ),

            const SizedBox(height: 12),

            // Description
            TextField(
              controller:
              _descriptionController,

              decoration:
              const InputDecoration(
                labelText:
                'Expense Description',
                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // Amount
            TextField(
              controller:
              _amountController,

              keyboardType:
              const TextInputType
                  .numberWithOptions(
                decimal: true,
              ),

              decoration:
              const InputDecoration(
                labelText:
                'Expense Amount',
                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // Date
            Row(
              children: [

                Expanded(
                  child: Text(
                    'Date: '
                        '${_selectedDate.year}-'
                        '${_selectedDate.month.toString().padLeft(2, '0')}-'
                        '${_selectedDate.day.toString().padLeft(2, '0')}',
                  ),
                ),

                ElevatedButton(
                  onPressed:
                  _selectDate,

                  child: const Text(
                    'SELECT DATE',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Add button
            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed:
                _isAdding
                    ? null
                    : _addExpense,

                child: _isAdding

                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )

                    : const Text(
                  'ADD EXPENSE',
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Expense List',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: _buildExpenseList(),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------
  // Expense List
  // -------------------------------------------------

  Widget _buildExpenseList() {

    if (_expenses.isEmpty) {

      return const Center(
        child: Text(
          'No expenses found.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,

      child: ListView.builder(

        itemCount: _expenses.length,

        itemBuilder: (context, index) {

          final expense =
          _expenses[index];

          return Card(
            margin:
            const EdgeInsets.only(
              bottom: 10,
            ),

            child: ListTile(

              leading: CircleAvatar(
                child: Text(
                  expense.expenseId
                      .toString(),
                ),
              ),

              title: Text(
                expense.expenseDescription,
                style: const TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              subtitle: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Text(
                    'Owner: '
                        '${expense.ownerName}',
                  ),

                  Text(
                    'Garden: '
                        '${expense.gardenName}',
                  ),

                  Text(
                    'Amount: '
                        '${expense.expenseAmount.toStringAsFixed(2)}',
                  ),

                  Text(
                    'Date: '
                        '${expense.expenseDate}',
                  ),
                ],
              ),

              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // Edit
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _editExpense(expense);
                    },
                  ),

                  // Delete
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _deleteExpense(expense);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}