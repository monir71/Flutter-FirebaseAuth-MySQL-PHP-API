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
  State<LoanManagementScreen> createState() =>
      _LoanManagementScreenState();
}

class _LoanManagementScreenState
    extends State<LoanManagementScreen> {

  List<Loan> _loans = [];
  List<FinancialPartner> _partners = [];
  List<Garden> _gardens = [];

  FinancialPartner? _selectedPartner;
  Garden? _selectedGarden;

  final _purposeController =
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

        _loans =
        results[0] as List<Loan>;

        _partners =
        results[1]
        as List<FinancialPartner>;

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
  // Add Loan
  // -------------------------------------------------

  Future<void> _addLoan() async {

    if (_selectedPartner == null) {

      _showMessage(
        'Please select a financial partner.',
      );

      return;
    }

    if (_selectedGarden == null) {

      _showMessage(
        'Please select a garden.',
      );

      return;
    }

    final purpose =
    _purposeController.text.trim();

    if (purpose.isEmpty) {

      _showMessage(
        'Please enter loan purpose.',
      );

      return;
    }

    final amount =
    double.tryParse(
      _amountController.text.trim(),
    );

    if (amount == null || amount <= 0) {

      _showMessage(
        'Please enter a valid loan amount.',
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


      final loan =
      await LoanService.addLoan(
        partnerId:
        _selectedPartner!.partnerId,

        gardenId:
        _selectedGarden!.gardenId,

        loanPurpose:
        purpose,

        loanAmount:
        amount,

        loanDate:
        date,
      );


      if (!mounted) return;


      // -------------------------------------------------
      // Add partner/garden names immediately.
      // -------------------------------------------------

      final loanWithNames =
      Loan(
        loanId:
        loan.loanId,

        partnerId:
        loan.partnerId,

        partnerName:
        _selectedPartner!
            .partnerName,

        partnerInstitution:
        _selectedPartner!
            .partnerInstitution,

        gardenId:
        loan.gardenId,

        gardenName:
        _selectedGarden!
            .gardenName,

        loanPurpose:
        loan.loanPurpose,

        loanAmount:
        loan.loanAmount,

        loanDate:
        loan.loanDate,

        createdAt:
        loan.createdAt,
      );


      setState(() {

        _loans.insert(
          0,
          loanWithNames,
        );

        _purposeController.clear();

        _amountController.clear();

        _selectedPartner = null;

        _selectedGarden = null;

        _selectedDate =
            DateTime.now();
      });


      _showMessage(
        'Loan added successfully.',
      );

    } catch (e) {

      if (!mounted) return;

      _showMessage(
        'Unable to add loan: $e',
      );

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
            (partner) =>
        partner.partnerId ==
            loan.partnerId,
      );
    } catch (_) {
      selectedPartner = null;
    }

    Garden? selectedGarden;

    try {
      selectedGarden = _gardens.firstWhere(
            (garden) =>
        garden.gardenId ==
            loan.gardenId,
      );
    } catch (_) {
      selectedGarden = null;
    }

    final purposeController =
    TextEditingController(
      text: loan.loanPurpose,
    );

    final amountController =
    TextEditingController(
      text: loan.loanAmount.toString(),
    );

    DateTime selectedDate =
    DateTime.parse(loan.loanDate);

    final result =
    await showDialog<bool>(
      context: context,

      builder: (dialogContext) {

        return StatefulBuilder(
          builder: (
              context,
              setDialogState,
              ) {

            return AlertDialog(

              title:
              const Text('Edit Loan'),

              content:
              SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                  MainAxisSize.min,

                  children: [

                    // ---------------------------------
                    // Financial Partner
                    // ---------------------------------

                    DropdownButtonFormField<
                        FinancialPartner>(
                      value:
                      selectedPartner,

                      decoration:
                      const InputDecoration(
                        labelText:
                        'Financial Partner',

                        border:
                        OutlineInputBorder(),
                      ),

                      items:
                      _partners.map(
                            (partner) {

                          return DropdownMenuItem<
                              FinancialPartner>(
                            value:
                            partner,

                            child:
                            Text(
                              partner.partnerName,
                            ),
                          );
                        },
                      ).toList(),

                      onChanged:
                          (value) {

                        setDialogState(() {
                          selectedPartner =
                              value;
                        });
                      },
                    ),

                    const SizedBox(
                      height: 12,
                    ),


                    // ---------------------------------
                    // Garden
                    // ---------------------------------

                    DropdownButtonFormField<
                        Garden>(
                      value:
                      selectedGarden,

                      decoration:
                      const InputDecoration(
                        labelText:
                        'Garden',

                        border:
                        OutlineInputBorder(),
                      ),

                      items:
                      _gardens.map(
                            (garden) {

                          return DropdownMenuItem<
                              Garden>(
                            value:
                            garden,

                            child:
                            Text(
                              garden.gardenName,
                            ),
                          );
                        },
                      ).toList(),

                      onChanged:
                          (value) {

                        setDialogState(() {
                          selectedGarden =
                              value;
                        });
                      },
                    ),

                    const SizedBox(
                      height: 12,
                    ),


                    // ---------------------------------
                    // Purpose
                    // ---------------------------------

                    TextField(
                      controller:
                      purposeController,

                      decoration:
                      const InputDecoration(
                        labelText:
                        'Loan Purpose',

                        border:
                        OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),


                    // ---------------------------------
                    // Amount
                    // ---------------------------------

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
                        'Loan Amount',

                        border:
                        OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),


                    // ---------------------------------
                    // Date
                    // ---------------------------------

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
                              context:
                              context,

                              initialDate:
                              selectedDate,

                              firstDate:
                              DateTime(2000),

                              lastDate:
                              DateTime(2100),
                            );

                            if (date !=
                                null) {

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
                  const Text(
                    'CANCEL',
                  ),
                ),

                ElevatedButton(
                  onPressed: () async {

                    if (selectedPartner ==
                        null ||
                        selectedGarden ==
                            null) {

                      return;
                    }

                    final purpose =
                    purposeController
                        .text
                        .trim();

                    final amount =
                    double.tryParse(
                      amountController
                          .text
                          .trim(),
                    );

                    if (purpose.isEmpty ||
                        amount == null ||
                        amount <= 0) {

                      return;
                    }

                    final date =
                        '${selectedDate.year}-'
                        '${selectedDate.month.toString().padLeft(2, '0')}-'
                        '${selectedDate.day.toString().padLeft(2, '0')}';

                    try {

                      final updatedLoan =
                      await LoanService
                          .updateLoan(
                        loanId:
                        loan.loanId,

                        partnerId:
                        selectedPartner!
                            .partnerId,

                        gardenId:
                        selectedGarden!
                            .gardenId,

                        loanPurpose:
                        purpose,

                        loanAmount:
                        amount,

                        loanDate:
                        date,
                      );

                      if (!mounted) {
                        return;
                      }


                      // ---------------------------------
                      // Add names immediately
                      // ---------------------------------

                      final updatedLoanWithNames =
                      Loan(
                        loanId:
                        updatedLoan
                            .loanId,

                        partnerId:
                        updatedLoan
                            .partnerId,

                        partnerName:
                        selectedPartner!
                            .partnerName,

                        partnerInstitution:
                        selectedPartner!
                            .partnerInstitution,

                        gardenId:
                        updatedLoan
                            .gardenId,

                        gardenName:
                        selectedGarden!
                            .gardenName,

                        loanPurpose:
                        updatedLoan
                            .loanPurpose,

                        loanAmount:
                        updatedLoan
                            .loanAmount,

                        loanDate:
                        updatedLoan
                            .loanDate,

                        createdAt:
                        loan.createdAt,
                      );


                      final index =
                      _loans.indexWhere(
                            (item) =>
                        item.loanId ==
                            loan.loanId,
                      );


                      setState(() {

                        if (index != -1) {

                          _loans[index] =
                              updatedLoanWithNames;
                        }
                      });


                      Navigator.pop(
                        dialogContext,
                        true,
                      );


                      _showMessage(
                        'Loan updated successfully.',
                      );

                    } catch (e) {

                      _showMessage(
                        'Unable to update loan: $e',
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

    purposeController.dispose();
    amountController.dispose();
  }

  // -------------------------------------------------
  // Delete Loan
  // -------------------------------------------------

  Future<void> _deleteLoan(
      Loan loan) async {

    final confirmed =
    await showDialog<bool>(
      context: context,

      builder: (context) {

        return AlertDialog(

          title:
          const Text('Delete Loan'),

          content: Text(
            'Are you sure you want to delete '
                'this loan of '
                '${loan.loanAmount.toStringAsFixed(2)}?',
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

      await LoanService.deleteLoan(
        loanId: loan.loanId,
      );


      if (!mounted) return;


      setState(() {

        _loans.removeWhere(
              (item) =>
          item.loanId ==
              loan.loanId,
        );
      });


      _showMessage(
        'Loan deleted successfully.',
      );

    } catch (e) {

      if (!mounted) return;

      _showMessage(
        'Unable to delete loan: $e',
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

      initialDate:
      _selectedDate,

      firstDate:
      DateTime(2000),

      lastDate:
      DateTime(2100),
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

      appBar: AppBar(
        title:
        const Text(
          'Loan Management',
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
              'Add Loan',

              style: TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 16,
            ),


            // Partner
            DropdownButtonFormField<
                FinancialPartner>(
              value:
              _selectedPartner,

              decoration:
              const InputDecoration(
                labelText:
                'Financial Partner',

                border:
                OutlineInputBorder(),
              ),

              items:
              _partners.map(
                    (partner) {

                  return DropdownMenuItem<
                      FinancialPartner>(
                    value:
                    partner,

                    child:
                    Text(
                      partner.partnerName,
                    ),
                  );
                },
              ).toList(),

              onChanged:
                  (value) {

                setState(() {
                  _selectedPartner =
                      value;
                });
              },
            ),

            const SizedBox(
              height: 12,
            ),


            // Garden
            DropdownButtonFormField<
                Garden>(
              value:
              _selectedGarden,

              decoration:
              const InputDecoration(
                labelText:
                'Garden',

                border:
                OutlineInputBorder(),
              ),

              items:
              _gardens.map(
                    (garden) {

                  return DropdownMenuItem<
                      Garden>(
                    value:
                    garden,

                    child:
                    Text(
                      garden.gardenName,
                    ),
                  );
                },
              ).toList(),

              onChanged:
                  (value) {

                setState(() {
                  _selectedGarden =
                      value;
                });
              },
            ),

            const SizedBox(
              height: 12,
            ),


            // Purpose
            TextField(
              controller:
              _purposeController,

              decoration:
              const InputDecoration(
                labelText:
                'Loan Purpose',

                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 12,
            ),


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
                'Loan Amount',

                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 12,
            ),


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

            const SizedBox(
              height: 12,
            ),


            // Add button
            SizedBox(
              width:
              double.infinity,

              child:
              ElevatedButton(
                onPressed:
                _isAdding
                    ? null
                    : _addLoan,

                child:
                _isAdding

                    ? const SizedBox(
                  height: 20,
                  width: 20,

                  child:
                  CircularProgressIndicator(
                    strokeWidth:
                    2,
                  ),
                )

                    : const Text(
                  'ADD LOAN',
                ),
              ),
            ),

            const SizedBox(
              height: 25,
            ),


            const Text(
              'Loan List',

              style: TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),


            Expanded(
              child:
              _buildLoanList(),
            ),
          ],
        ),
      ),
    );
  }


  // -------------------------------------------------
  // Loan List
  // -------------------------------------------------

  Widget _buildLoanList() {

    if (_loans.isEmpty) {

      return const Center(
        child: Text(
          'No loans found.',
        ),
      );
    }


    return RefreshIndicator(

      onRefresh:
      _loadData,

      child:
      ListView.builder(

        itemCount:
        _loans.length,

        itemBuilder:
            (context, index) {

          final loan =
          _loans[index];

          return Card(

            margin:
            const EdgeInsets.only(
              bottom: 10,
            ),

            child:
            ListTile(

              leading:
              CircleAvatar(
                child:
                Text(
                  loan.loanId
                      .toString(),
                ),
              ),

              title:
              Text(
                loan.loanAmount
                    .toStringAsFixed(2),

                style:
                const TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              subtitle:
              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Text(
                    'Partner: '
                        '${loan.partnerName}',
                  ),

                  Text(
                    'Institution: '
                        '${loan.partnerInstitution}',
                  ),

                  Text(
                    'Garden: '
                        '${loan.gardenName}',
                  ),

                  Text(
                    'Purpose: '
                        '${loan.loanPurpose}',
                  ),

                  Text(
                    'Date: '
                        '${loan.loanDate}',
                  ),
                ],
              ),

              trailing: Row(
                mainAxisSize:
                MainAxisSize.min,

                children: [

                  // Edit
                  IconButton(
                    icon:
                    const Icon(
                      Icons.edit,
                    ),

                    onPressed: () {
                      _editLoan(loan);
                    },
                  ),

                  // Delete
                  IconButton(
                    icon:
                    const Icon(
                      Icons.delete,
                    ),

                    onPressed: () {
                      _deleteLoan(loan);
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