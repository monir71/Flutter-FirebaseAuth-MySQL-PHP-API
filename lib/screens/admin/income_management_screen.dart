import 'package:flutter/material.dart';

import '../../models/income.dart';
import '../../models/garden.dart';
import '../../models/owner.dart';
import '../../services/income_service.dart';
import '../../services/garden_service.dart';
import '../../services/owner_service.dart';

class IncomeManagementScreen extends StatefulWidget {
  const IncomeManagementScreen({super.key});

  @override
  State<IncomeManagementScreen> createState() =>
      _IncomeManagementScreenState();
}

class _IncomeManagementScreenState
    extends State<IncomeManagementScreen> {

  List<Income> _incomes = [];
  List<Owner> _owners = [];
  List<Garden> _gardens = [];

  Owner? _selectedOwner;
  Garden? _selectedGarden;

  final _sourceController =
  TextEditingController();

  final _amountController =
  TextEditingController();

  DateTime _selectedDate =
  DateTime.now();

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

    try {

      final results = await Future.wait([
        IncomeService.getIncomes(),
        OwnerService.getOwners(),
        GardenService.getGardens(),
      ]);

      if (!mounted) return;

      setState(() {
        _incomes =
        results[0] as List<Income>;

        _owners =
        results[1] as List<Owner>;

        _gardens =
        results[2] as List<Garden>;

        _isLoading = false;
      });

    } catch (e) {

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Unable to load data: $e',
      );
    }
  }

  // -------------------------------------------------
  // Add Income
  // -------------------------------------------------

  Future<void> _addIncome() async {

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

    final source =
    _sourceController.text.trim();

    if (source.isEmpty) {
      _showMessage(
        'Please enter income source.',
      );
      return;
    }

    final amount =
    double.tryParse(
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

      final income =
      await IncomeService.addIncome(
        ownerId:
        _selectedOwner!.ownerId,

        gardenId:
        _selectedGarden!.gardenId,

        incomeSource:
        source,

        incomeAmount:
        amount,

        incomeDate:
        date,
      );

      if (!mounted) return;

      // The Add API doesn't return owner/garden names,
      // so fill them from the selected objects.

      final updatedIncome = Income(
        incomeId: income.incomeId,
        ownerId: income.ownerId,
        ownerName:
        _selectedOwner!.ownerName,
        gardenId: income.gardenId,
        gardenName:
        _selectedGarden!.gardenName,
        incomeSource:
        income.incomeSource,
        incomeAmount:
        income.incomeAmount,
        incomeDate:
        income.incomeDate,
      );

      setState(() {

        _incomes.insert(
          0,
          updatedIncome,
        );

        _sourceController.clear();
        _amountController.clear();

        _selectedOwner = null;
        _selectedGarden = null;

        _selectedDate =
            DateTime.now();
      });

      _showMessage(
        'Income added successfully.',
      );

    } catch (e) {

      if (!mounted) return;

      _showMessage(
        'Unable to add income: $e',
      );

    } finally {

      if (!mounted) return;

      setState(() {
        _isAdding = false;
      });
    }
  }

  // -------------------------------------------------
  // Edit Income
  // -------------------------------------------------

  Future<void> _editIncome(Income income) async {

    Owner? selectedOwner = _owners.firstWhere(
          (owner) => owner.ownerId == income.ownerId,
      orElse: () => _owners.first,
    );

    Garden? selectedGarden = _gardens.firstWhere(
          (garden) => garden.gardenId == income.gardenId,
      orElse: () => _gardens.first,
    );

    final sourceController = TextEditingController(
      text: income.incomeSource,
    );

    final amountController = TextEditingController(
      text: income.incomeAmount.toString(),
    );

    DateTime selectedDate =
    DateTime.parse(income.incomeDate);

    final result = await showDialog<bool>(
      context: context,

      builder: (dialogContext) {

        return StatefulBuilder(
          builder: (context, setDialogState) {

            return AlertDialog(
              title: const Text('Edit Income'),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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

                    // Source
                    TextField(
                      controller:
                      sourceController,

                      decoration:
                      const InputDecoration(
                        labelText:
                        'Income Source',
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
                        'Income Amount',
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

                        ElevatedButton(
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
                          const Text(
                            'SELECT DATE',
                          ),
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
                      dialogContext,
                      false,
                    );
                  },

                  child:
                  const Text('CANCEL'),
                ),

                ElevatedButton(
                  onPressed: () async {

                    if (selectedOwner == null ||
                        selectedGarden == null) {

                      return;
                    }

                    final source =
                    sourceController.text
                        .trim();

                    final amount =
                    double.tryParse(
                      amountController.text
                          .trim(),
                    );

                    if (source.isEmpty ||
                        amount == null ||
                        amount <= 0) {

                      return;
                    }

                    final date =
                        '${selectedDate.year}-'
                        '${selectedDate.month.toString().padLeft(2, '0')}-'
                        '${selectedDate.day.toString().padLeft(2, '0')}';

                    try {

                      final updatedIncome =
                      await IncomeService
                          .updateIncome(
                        incomeId:
                        income.incomeId,

                        ownerId:
                        selectedOwner!
                            .ownerId,

                        gardenId:
                        selectedGarden!
                            .gardenId,

                        incomeSource:
                        source,

                        incomeAmount:
                        amount,

                        incomeDate:
                        date,
                      );

                      if (!mounted) return;

                      final updatedIncomeWithNames =
                      Income(
                        incomeId:
                        updatedIncome
                            .incomeId,

                        ownerId:
                        updatedIncome
                            .ownerId,

                        ownerName:
                        selectedOwner!
                            .ownerName,

                        gardenId:
                        updatedIncome
                            .gardenId,

                        gardenName:
                        selectedGarden!
                            .gardenName,

                        incomeSource:
                        updatedIncome
                            .incomeSource,

                        incomeAmount:
                        updatedIncome
                            .incomeAmount,

                        incomeDate:
                        updatedIncome
                            .incomeDate,
                      );

                      final index =
                      _incomes.indexWhere(
                            (item) =>
                        item.incomeId ==
                            income.incomeId,
                      );

                      setState(() {

                        if (index != -1) {
                          _incomes[index] =
                              updatedIncomeWithNames;
                        }
                      });

                      Navigator.pop(
                        dialogContext,
                        true,
                      );

                      _showMessage(
                        'Income updated successfully.',
                      );

                    } catch (e) {

                      _showMessage(
                        'Unable to update income: $e',
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

    sourceController.dispose();
    amountController.dispose();
  }

  // -------------------------------------------------
  // Delete Income
  // -------------------------------------------------

  Future<void> _deleteIncome(
      Income income) async {

    final confirmed =
    await showDialog<bool>(
      context: context,

      builder: (context) {

        return AlertDialog(
          title:
          const Text('Delete Income'),

          content: Text(
            'Are you sure you want to delete '
                'this income of '
                '${income.incomeAmount.toStringAsFixed(2)}?',
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

    if (confirmed != true) {
      return;
    }

    try {

      await IncomeService.deleteIncome(
        incomeId: income.incomeId,
      );

      if (!mounted) return;

      setState(() {
        _incomes.removeWhere(
              (item) =>
          item.incomeId ==
              income.incomeId,
        );
      });

      _showMessage(
        'Income deleted successfully.',
      );

    } catch (e) {

      if (!mounted) return;

      _showMessage(
        'Unable to delete income: $e',
      );
    }
  }

  // -------------------------------------------------
  // Date Picker
  // -------------------------------------------------

  Future<void> _selectDate() async {

    final date =
    await showDatePicker(
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

  void _showMessage(
      String message) {

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {

    _sourceController.dispose();
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
          'Income Management',
        ),
      ),

      body: _isLoading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : Padding(
        padding:
        const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            const Text(
              'Add Income',
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

              items:
              _owners.map(
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
                  _selectedOwner =
                      value;
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

              items:
              _gardens.map(
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
                  _selectedGarden =
                      value;
                });
              },
            ),

            const SizedBox(height: 12),

            // Income Source
            TextField(
              controller:
              _sourceController,

              decoration:
              const InputDecoration(
                labelText:
                'Income Source',
                hintText:
                'e.g. Guava sale',
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
                'Income Amount',
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

                  child:
                  const Text(
                    'SELECT DATE',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Add button
            SizedBox(
              width:
              double.infinity,

              child:
              ElevatedButton(
                onPressed:
                _isAdding
                    ? null
                    : _addIncome,

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
                  'ADD INCOME',
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Income List',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child:
              _buildIncomeList(),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------
  // Income List
  // -------------------------------------------------

  Widget _buildIncomeList() {

    if (_incomes.isEmpty) {

      return const Center(
        child: Text(
          'No incomes found.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,

      child: ListView.builder(

        itemCount:
        _incomes.length,

        itemBuilder:
            (context, index) {

          final income =
          _incomes[index];

          return Card(
            margin:
            const EdgeInsets.only(
              bottom: 10,
            ),

            child: ListTile(

              leading: CircleAvatar(
                child: Text(
                  income.incomeId
                      .toString(),
                ),
              ),

              title: Text(
                income.incomeAmount
                    .toStringAsFixed(2),

                style:
                const TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              subtitle: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,

                children: [

                  Text(
                    'Source: '
                        '${income.incomeSource}',
                  ),

                  Text(
                    'Owner: '
                        '${income.ownerName ?? 'Unknown'}',
                  ),

                  Text(
                    'Garden: '
                        '${income.gardenName ?? 'Unknown'}',
                  ),

                  Text(
                    'Date: '
                        '${income.incomeDate}',
                  ),
                ],
              ),

              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // Edit
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                    ),

                    onPressed: () {
                      _editIncome(income);
                    },
                  ),

                  // Delete
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                    ),

                    onPressed: () {
                      _deleteIncome(income);
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