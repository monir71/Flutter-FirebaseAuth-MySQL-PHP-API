import 'package:flutter/material.dart';
import '../../models/financial_partner.dart';
import '../../services/financial_partner_service.dart';

class FinancialPartnerManagementScreen extends StatefulWidget {
  const FinancialPartnerManagementScreen({super.key});

  @override
  State<FinancialPartnerManagementScreen> createState() =>
      _FinancialPartnerManagementScreenState();
}

class _FinancialPartnerManagementScreenState
    extends State<FinancialPartnerManagementScreen> {
  final _nameController = TextEditingController();
  final _institutionController = TextEditingController();

  List<FinancialPartner> _partners = [];

  bool _isLoading = true;
  bool _isAdding = false;

  final Color _primaryColor = Colors.cyan.shade700;

  @override
  void initState() {
    super.initState();
    _loadPartners();
  }

  // -------------------------------------------------
  // Load Partners
  // -------------------------------------------------

  Future<void> _loadPartners() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final partners = await FinancialPartnerService.getPartners();

      if (!mounted) return;

      setState(() {
        _partners = partners;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load partners: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  // -------------------------------------------------
  // Add Partner
  // -------------------------------------------------

  Future<void> _addPartner() async {
    final name = _nameController.text.trim();

    final institution = _institutionController.text.trim();

    if (name.isEmpty) {
      _showMessage('Please enter partner name.');
      return;
    }

    if (institution.isEmpty) {
      _showMessage('Please enter institution name.');
      return;
    }

    setState(() {
      _isAdding = true;
    });

    try {
      final partner = await FinancialPartnerService.addPartner(
        partnerName: name,
        partnerInstitution: institution,
      );

      if (!mounted) return;

      _nameController.clear();
      _institutionController.clear();

      setState(() {
        _partners.insert(0, partner);
      });

      _showMessage('Financial partner added successfully.');
    } catch (e) {
      if (!mounted) return;

      _showMessage('Unable to add partner: $e');
    } finally {
      if (!mounted) return;

      setState(() {
        _isAdding = false;
      });
    }
  }

  // -------------------------------------------------
  // Edit Partner
  // -------------------------------------------------

  Future<void> _editPartner(FinancialPartner partner, int index) async {
    final nameController = TextEditingController(text: partner.partnerName);

    final institutionController = TextEditingController(
      text: partner.partnerInstitution,
    );

    final result = await showDialog<List<String>>(
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
                  color: Colors.cyan.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.edit_rounded, color: _primaryColor, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Edit Financial Partner',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: _inputDecoration(
                    'Partner Name',
                    Icons.person_outline_rounded,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: institutionController,
                  decoration: _inputDecoration(
                    'Institution',
                    Icons.business_rounded,
                  ),
                ),
              ],
            ),
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
                Navigator.pop(dialogContext, [
                  nameController.text.trim(),
                  institutionController.text.trim(),
                ]);
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

    nameController.dispose();
    institutionController.dispose();

    if (result == null) {
      return;
    }

    final newName = result[0];
    final newInstitution = result[1];

    if (newName.isEmpty || newInstitution.isEmpty) {
      return;
    }

    try {
      final updatedPartner = await FinancialPartnerService.updatePartner(
        partnerId: partner.partnerId,
        partnerName: newName,
        partnerInstitution: newInstitution,
      );

      if (!mounted) return;

      setState(() {
        _partners[index] = updatedPartner;
      });

      _showMessage('Financial partner updated successfully.');
    } catch (e) {
      if (!mounted) return;

      _showMessage('Update failed: $e');
    }
  }

  // -------------------------------------------------
  // Delete Partner
  // -------------------------------------------------

  Future<void> _deletePartner(
      FinancialPartner partner,
      int index,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(
            24,
            22,
            24,
            10,
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            24,
            8,
            24,
            8,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            16,
          ),
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
              const Expanded(
                child: Text(
                  'Delete Partner',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // Compact content
          content: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.red.shade100,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 18,
                      color: Colors.red.shade600,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        partner.partnerName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.business_rounded,
                      size: 18,
                      color: Colors.red.shade600,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        partner.partnerInstitution,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Are you sure you want to delete this financial partner?',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
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
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              icon: const Icon(
                Icons.delete_rounded,
                size: 18,
              ),
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
      await FinancialPartnerService.deletePartner(
        partnerId: partner.partnerId,
      );

      if (!mounted) return;

      setState(() {
        _partners.removeAt(index);
      });

      _showMessage(
        'Financial partner deleted successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Delete failed: $e',
      );
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

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: 'Enter $label',
      prefixIcon: Icon(icon, color: _primaryColor),
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

  // -------------------------------------------------
  // Dispose
  // -------------------------------------------------

  @override
  void dispose() {
    _nameController.dispose();
    _institutionController.dispose();

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
                Icons.handshake_rounded,
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
                  'Financial Partner Management',
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
                  Icon(Icons.handshake_rounded, color: _primaryColor, size: 42),
                  const SizedBox(height: 12),
                  CircularProgressIndicator(color: _primaryColor),
                  const SizedBox(height: 12),
                  Text(
                    'Loading financial partners...',
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
              onRefresh: _loadPartners,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  _buildAddPartnerCard(),

                  const SizedBox(height: 30),

                  _buildPartnerListHeader(),

                  const SizedBox(height: 12),

                  _buildPartnerList(),
                ],
              ),
            ),
    );
  }

  // -------------------------------------------------
  // Add Partner Card
  // -------------------------------------------------

  Widget _buildAddPartnerCard() {
    return Card(
      elevation: 6,
      shadowColor: Colors.cyan.withOpacity(0.18),
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
                colors: [Colors.cyan.shade700, Colors.cyan.shade400],
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
                    Icons.handshake_rounded,
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
                        'Add New Financial Partner',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Record a new financial partner',
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
                TextField(
                  controller: _nameController,
                  decoration: _inputDecoration(
                    'Partner Name',
                    Icons.person_outline_rounded,
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: _institutionController,
                  decoration: _inputDecoration(
                    'Institution',
                    Icons.business_rounded,
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isAdding ? null : _addPartner,
                    icon: _isAdding
                        ? const SizedBox(
                            width: 19,
                            height: 19,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.person_add_rounded),
                    label: Text(_isAdding ? 'ADDING...' : 'ADD PARTNER'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.cyan.shade300,
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
  // Partner List Header
  // -------------------------------------------------

  Widget _buildPartnerListHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: Colors.cyan.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.account_balance_rounded,
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
                'Financial Partner List',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 2),
              Text(
                'Banks and institutions connected to NH Garden',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.cyan.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_partners.length}',
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
  // Partner List
  // -------------------------------------------------

  Widget _buildPartnerList() {
    if (_partners.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.cyan.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.handshake_rounded,
                color: _primaryColor,
                size: 46,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No financial partners found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Add a financial partner to see it here.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Column(
      children: List.generate(_partners.length, (index) {
        final partner = _partners[index];

        return _buildPartnerCard(partner, index);
      }),
    );
  }

  // -------------------------------------------------
  // Partner Card
  // -------------------------------------------------

  Widget _buildPartnerCard(FinancialPartner partner, int index) {
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
            // ID box
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.cyan.shade700, Colors.cyan.shade400],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.handshake_rounded,
                    color: Colors.white,
                    size: 25,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '#${partner.partnerId}',
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
                  Text(
                    partner.partnerName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.business_rounded,
                        size: 17,
                        color: _primaryColor,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          partner.partnerInstitution,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 38,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _editPartner(partner, index);
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
                              _deletePartner(partner, index);
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
}
