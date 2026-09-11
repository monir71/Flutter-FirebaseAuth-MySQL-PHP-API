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
  State<FundManagementScreen> createState() => _FundManagementScreenState();
}

class _FundManagementScreenState extends State<FundManagementScreen> {
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

      _showMessage('Unable to load data: $e');
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

      _showMessage('Fund added successfully.');
    } catch (e) {
      if (!mounted) return;

      _showMessage('Unable to add fund: $e');
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

    Owner? selectedOwner;

    if (_owners.isNotEmpty) {
      final matchingOwners = _owners.where(
        (owner) => owner.ownerId == fund.ownerId,
      );

      selectedOwner = matchingOwners.isNotEmpty
          ? matchingOwners.first
          : _owners.first;
    }

    Garden? selectedGarden;

    if (_gardens.isNotEmpty) {
      final matchingGardens = _gardens.where(
        (garden) => garden.gardenId == fund.gardenId,
      );

      selectedGarden = matchingGardens.isNotEmpty
          ? matchingGardens.first
          : _gardens.first;
    }

    DateTime selectedDate = DateTime.tryParse(fund.fundDate) ?? DateTime.now();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
              actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 16),

              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Edit Fund',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              content: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 500,
                  maxHeight: 430,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      DropdownButtonFormField<Owner>(
                        value: selectedOwner,
                        isExpanded: true,
                        decoration: _inputDecoration(
                          label: 'Owner',
                          icon: Icons.person_rounded,
                        ),
                        items: _owners.map((owner) {
                          return DropdownMenuItem<Owner>(
                            value: owner,
                            child: Text(
                              owner.ownerName,
                              overflow: TextOverflow.ellipsis,
                            ),
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
                        isExpanded: true,
                        decoration: _inputDecoration(
                          label: 'Garden',
                          icon: Icons.agriculture_rounded,
                        ),
                        items: _gardens.map((garden) {
                          return DropdownMenuItem<Garden>(
                            value: garden,
                            child: Text(
                              garden.gardenName,
                              overflow: TextOverflow.ellipsis,
                            ),
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
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: _inputDecoration(
                          label: 'Fund Amount',
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
                    final amount = double.tryParse(
                      amountController.text.trim(),
                    );

                    if (selectedOwner == null ||
                        selectedGarden == null ||
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

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Update failed: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: const Text('SAVE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
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

    amountController.dispose();

    if (result == true) {
      await _loadData();

      if (!mounted) return;

      _showMessage('Fund updated successfully.');
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
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
          actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 16),

          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.delete_rounded, color: Colors.red.shade700),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Delete Fund',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          content: Container(
            constraints: const BoxConstraints(maxWidth: 500),
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
                  'Are you sure you want to delete this fund?',
                  style: TextStyle(color: Colors.grey.shade800, fontSize: 15),
                ),

                const SizedBox(height: 12),

                _buildDeleteInfoRow(
                  Icons.payments_rounded,
                  'Amount',
                  '৳${fund.fundAmount.toStringAsFixed(2)}',
                ),

                const SizedBox(height: 6),

                _buildDeleteInfoRow(
                  Icons.person_rounded,
                  'Owner',
                  fund.ownerName,
                ),

                const SizedBox(height: 6),

                _buildDeleteInfoRow(
                  Icons.agriculture_rounded,
                  'Garden',
                  fund.gardenName,
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
      await FundService.deleteFund(fundId: fund.fundId);

      if (!mounted) return;

      setState(() {
        _funds.removeWhere((item) => item.fundId == fund.fundId);
      });

      _showMessage('Fund deleted successfully.');
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
    if (!mounted) return;

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
          : LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 700;

                if (isSmallScreen) {
                  return _buildSmallScreenLayout();
                }

                return _buildDesktopLayout();
              },
            ),
    );
  }

  // -------------------------------------------------
  // Desktop / Web Layout
  // -------------------------------------------------

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAddFundCard(),

          const SizedBox(height: 24),

          _buildFundListHeader(),

          const SizedBox(height: 12),

          Expanded(child: _buildFundList()),
        ],
      ),
    );
  }

  // -------------------------------------------------
  // Small Screen Layout
  // -------------------------------------------------

  Widget _buildSmallScreenLayout() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAddFundCard(),

          const SizedBox(height: 22),

          _buildFundListHeader(),

          const SizedBox(height: 12),

          _buildSmallScreenFundList(),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // -------------------------------------------------
  // Small Screen Fund List
  // -------------------------------------------------

  Widget _buildSmallScreenFundList() {
    if (_funds.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: _funds.map((fund) {
        return _buildFundCard(fund);
      }).toList(),
    );
  }

  // -------------------------------------------------
  // App Bar
  // -------------------------------------------------

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
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
                'Fund Management',
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
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.blue.shade700,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'Loading funds...',
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
  // Add Fund Card
  // -------------------------------------------------

  Widget _buildAddFundCard() {
    return Card(
      elevation: 6,
      shadowColor: Colors.blue.withOpacity(0.20),
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
                colors: [Colors.blue.shade700, Colors.blue.shade500],
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
                        'Add New Fund',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Record a new garden fund contribution',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                  isExpanded: true,
                  decoration: _inputDecoration(
                    label: 'Owner',
                    icon: Icons.person_rounded,
                  ),
                  items: _owners.map((owner) {
                    return DropdownMenuItem<Owner>(
                      value: owner,
                      child: Text(
                        owner.ownerName,
                        overflow: TextOverflow.ellipsis,
                      ),
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
                  isExpanded: true,
                  decoration: _inputDecoration(
                    label: 'Garden',
                    icon: Icons.agriculture_rounded,
                  ),
                  items: _gardens.map((garden) {
                    return DropdownMenuItem<Garden>(
                      value: garden,
                      child: Text(
                        garden.gardenName,
                        overflow: TextOverflow.ellipsis,
                      ),
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
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _inputDecoration(
                    label: 'Fund Amount',
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
                    onPressed: _isAdding ? null : _addFund,
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
                      _isAdding ? 'ADDING FUND...' : 'ADD FUND',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.blue.shade300,
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
  // Fund List Header
  // -------------------------------------------------

  Widget _buildFundListHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            Icons.receipt_long_rounded,
            color: Colors.blue.shade700,
            size: 22,
          ),
        ),

        const SizedBox(width: 12),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fund List',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 2),
              Text(
                'All recorded garden fund contributions',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        Container(
          constraints: const BoxConstraints(minWidth: 38),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_funds.length}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------
  // Desktop Fund List
  // -------------------------------------------------

  Widget _buildFundList() {
    if (_funds.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: Colors.blue.shade700,
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: _funds.length,
        itemBuilder: (context, index) {
          return _buildFundCard(_funds[index]);
        },
      ),
    );
  }

  // -------------------------------------------------
  // Fund Card
  // -------------------------------------------------

  Widget _buildFundCard(Fund fund) {
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
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '#${fund.fundId}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 11),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '৳${fund.fundAmount.toStringAsFixed(2)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 7),

                  _buildFundInfoRow(
                    Icons.person_outline_rounded,
                    fund.ownerName,
                  ),

                  const SizedBox(height: 5),

                  _buildFundInfoRow(
                    Icons.agriculture_outlined,
                    fund.gardenName,
                  ),

                  const SizedBox(height: 5),

                  _buildFundInfoRow(
                    Icons.calendar_today_outlined,
                    fund.fundDate,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 5),

            Column(
              children: [
                _buildActionButton(
                  icon: Icons.edit_rounded,
                  color: Colors.blue.shade700,
                  tooltip: 'Edit Fund',
                  onPressed: () {
                    _editFund(fund);
                  },
                ),

                const SizedBox(height: 7),

                _buildActionButton(
                  icon: Icons.delete_rounded,
                  color: Colors.red.shade600,
                  tooltip: 'Delete Fund',
                  onPressed: () {
                    _deleteFund(fund);
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
  // Fund Info Row
  // -------------------------------------------------

  Widget _buildFundInfoRow(IconData icon, String text) {
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
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: color, size: 18),
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
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.blue.shade700,
                size: 40,
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              'No funds found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              'Add a fund contribution using the form above.',
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
            color: Colors.blue.shade700,
            size: 22,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fund Date',
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
            style: TextButton.styleFrom(foregroundColor: Colors.blue.shade700),
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
            color: Colors.blue.shade700,
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
                color: Colors.blue.shade700,
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
      prefixIcon: Icon(icon, color: Colors.blue.shade700),
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
        borderSide: BorderSide(color: Colors.blue.shade600, width: 1.8),
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
            maxLines: 1,
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
