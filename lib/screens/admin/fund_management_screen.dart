import 'package:flutter/material.dart';

import '../../models/fund.dart';
import '../../models/garden.dart';
import '../../models/owner.dart';
import '../../services/fund_service.dart';
import '../../services/garden_service.dart';
import '../../services/owner_service.dart';

class FundManagementScreen extends StatefulWidget {
  const FundManagementScreen({super.key});

  @override
  State<FundManagementScreen> createState() =>
      _FundManagementScreenState();
}

class _FundManagementScreenState
    extends State<FundManagementScreen> {

  List<Fund> _funds = [];
  List<Owner> _owners = [];
  List<Garden> _gardens = [];

  Owner? _selectedOwner;
  Garden? _selectedGarden;

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

    try {

      final results = await Future.wait([
        FundService.getFunds(),
        OwnerService.getOwners(),
        GardenService.getGardens(),
      ]);

      if (!mounted) return;

      setState(() {
        _funds = results[0] as List<Fund>;
        _owners = results[1] as List<Owner>;
        _gardens = results[2] as List<Garden>;
        _isLoading = false;
      });

    } catch (e) {

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to load data: $e',
          ),
        ),
      );
    }
  }

  // -------------------------------------------------
  // Add Fund
  // -------------------------------------------------

  Future<void> _addFund() async {

    if (_selectedOwner == null) {
      _showMessage('Please select an owner.');
      return;
    }

    if (_selectedGarden == null) {
      _showMessage('Please select a garden.');
      return;
    }

    final amount =
    double.tryParse(_amountController.text.trim());

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

      final fund = await FundService.addFund(
        ownerId: _selectedOwner!.ownerId,
        gardenId: _selectedGarden!.gardenId,
        fundAmount: amount,
        fundDate: date,
      );

      if (!mounted) return;

      setState(() {
        _funds.insert(0, fund);
        _amountController.clear();
        _selectedOwner = null;
        _selectedGarden = null;
        _selectedDate = DateTime.now();
      });

      _showMessage(
        'Fund added successfully.',
      );

    } catch (e) {

      if (!mounted) return;

      _showMessage(
        'Unable to add fund: $e',
      );

    } finally {

      if (!mounted) return;

      setState(() {
        _isAdding = false;
      });
    }
  }

  // -------------------------------------------------
// Edit Fund
// -------------------------------------------------

  Future<void> _editFund(Fund fund) async {

    final amountController = TextEditingController(
      text: fund.fundAmount.toString(),
    );

    Owner? selectedOwner = _owners.firstWhere(
          (owner) => owner.ownerId == fund.ownerId,
      orElse: () => _owners.first,
    );

    Garden? selectedGarden = _gardens.firstWhere(
          (garden) => garden.gardenId == fund.gardenId,
      orElse: () => _gardens.first,
    );

    DateTime selectedDate = DateTime.tryParse(
      fund.fundDate,
    ) ??
        DateTime.now();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {

        return StatefulBuilder(
          builder: (context, setDialogState) {

            return AlertDialog(
              title: const Text('Edit Fund'),

              content: SingleChildScrollView(
                child: Column(
                  children: [

                    DropdownButtonFormField<Owner>(
                      value: selectedOwner,
                      decoration: const InputDecoration(
                        labelText: 'Owner',
                        border: OutlineInputBorder(),
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

                    DropdownButtonFormField<Garden>(
                      value: selectedGarden,
                      decoration: const InputDecoration(
                        labelText: 'Garden',
                        border: OutlineInputBorder(),
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

                    TextField(
                      controller: amountController,
                      keyboardType:
                      const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Fund Amount',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

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
                          child: const Text('DATE'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              actions: [

                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('CANCEL'),
                ),

                ElevatedButton(
                  onPressed: () async {

                    final amount = double.tryParse(
                      amountController.text.trim(),
                    );

                    if (selectedOwner == null ||
                        selectedGarden == null ||
                        amount == null ||
                        amount <= 0) {

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
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

                      await FundService.updateFund(
                        fundId: fund.fundId,
                        ownerId: selectedOwner!.ownerId,
                        gardenId: selectedGarden!.gardenId,
                        fundAmount: amount,
                        fundDate: date,
                      );

                      if (!context.mounted) return;

                      Navigator.pop(context, true);

                    } catch (e) {

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            'Update failed: $e',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('SAVE'),
                ),
              ],
            );
          },
        );
      },
    );

    amountController.dispose();

    if (result == true) {

      await _loadData();

      if (!mounted) return;

      _showMessage(
        'Fund updated successfully.',
      );
    }
  }

  // -------------------------------------------------
// Delete Fund
// -------------------------------------------------

  Future<void> _deleteFund(Fund fund) async {

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {

        return AlertDialog(
          title: const Text('Delete Fund'),

          content: Text(
            'Are you sure you want to delete this fund?',
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('CANCEL'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {

      await FundService.deleteFund(
        fundId: fund.fundId,
      );

      if (!mounted) return;

      setState(() {
        _funds.removeWhere(
              (item) => item.fundId == fund.fundId,
        );
      });

      _showMessage(
        'Fund deleted successfully.',
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
        title: const Text('Fund Management'),
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
              'Add Fund',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Owner
            DropdownButtonFormField<Owner>(
              value: _selectedOwner,
              decoration: const InputDecoration(
                labelText: 'Owner',
                border: OutlineInputBorder(),
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
                setState(() {
                  _selectedOwner = value;
                });
              },
            ),

            const SizedBox(height: 12),

            // Garden
            DropdownButtonFormField<Garden>(
              value: _selectedGarden,
              decoration: const InputDecoration(
                labelText: 'Garden',
                border: OutlineInputBorder(),
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
                setState(() {
                  _selectedGarden = value;
                });
              },
            ),

            const SizedBox(height: 12),

            // Amount
            TextField(
              controller: _amountController,
              keyboardType:
              const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Fund Amount',
                border: OutlineInputBorder(),
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
                  onPressed: _selectDate,
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
                    : _addFund,

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
                  'ADD FUND',
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Fund List',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: _buildFundList(),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------
  // Fund List
  // -------------------------------------------------

  Widget _buildFundList() {

    if (_funds.isEmpty) {

      return const Center(
        child: Text(
          'No funds found.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,

      child: ListView.builder(
        itemCount: _funds.length,

        itemBuilder: (context, index) {

          final fund = _funds[index];

          return Card(
            margin:
            const EdgeInsets.only(
              bottom: 10,
            ),

            child: ListTile(

              leading: CircleAvatar(
                child: Text(
                  fund.fundId.toString(),
                ),
              ),

              title: Text(
                '${fund.fundAmount.toStringAsFixed(2)}',
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
                    'Owner: ${fund.ownerName}',
                  ),

                  Text(
                    'Garden: ${fund.gardenName}',
                  ),

                  Text(
                    'Date: ${fund.fundDate}',
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
                      _editFund(fund);
                    },
                  ),

                  // Delete
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _deleteFund(fund);
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