import 'package:flutter/material.dart';

import '../../models/financial_partner.dart';
import '../../services/financial_partner_service.dart';

class FinancialPartnerManagementScreen
    extends StatefulWidget {
  const FinancialPartnerManagementScreen({
    super.key,
  });

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

      final partners =
      await FinancialPartnerService.getPartners();

      if (!mounted) return;

      setState(() {
        _partners = partners;
      });

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to load partners: $e',
          ),
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

    final name =
    _nameController.text.trim();

    final institution =
    _institutionController.text.trim();

    if (name.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter partner name.',
          ),
        ),
      );

      return;
    }

    if (institution.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter institution name.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isAdding = true;
    });

    try {

      final partner =
      await FinancialPartnerService.addPartner(
        partnerName: name,
        partnerInstitution: institution,
      );

      if (!mounted) return;

      _nameController.clear();
      _institutionController.clear();

      setState(() {
        _partners.insert(0, partner);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Financial partner added successfully.',
          ),
        ),
      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to add partner: $e',
          ),
        ),
      );

    } finally {

      if (!mounted) return;

      setState(() {
        _isAdding = false;
      });
    }
  }

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
      appBar: AppBar(
        title: const Text(
          'Financial Partner Management',
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            // -----------------------------------------
            // Add Partner
            // -----------------------------------------

            const Text(
              'Add Financial Partner',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _nameController,

              decoration: const InputDecoration(
                labelText: 'Partner Name',
                hintText: 'Enter partner name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _institutionController,

              decoration: const InputDecoration(
                labelText: 'Institution',
                hintText: 'Enter institution name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed:
                _isAdding ? null : _addPartner,

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
                  'ADD PARTNER',
                ),
              ),
            ),

            const SizedBox(height: 30),

            // -----------------------------------------
            // Partner List
            // -----------------------------------------

            const Text(
              'Financial Partner List',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: _buildPartnerList(),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------
  // Partner List
  // -------------------------------------------------

  Widget _buildPartnerList() {

    if (_isLoading) {

      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_partners.isEmpty) {

      return const Center(
        child: Text(
          'No financial partners found.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPartners,

      child: ListView.builder(
        itemCount: _partners.length,

        itemBuilder: (context, index) {

          final partner = _partners[index];

          return Card(
            margin: const EdgeInsets.only(
              bottom: 10,
            ),

            child: ListTile(
              leading: CircleAvatar(
                child: Text(
                  partner.partnerId.toString(),
                ),
              ),

              title: Text(
                partner.partnerName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: Text(
                partner.partnerInstitution,
              ),

              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // Edit
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {

                      final nameController =
                      TextEditingController(
                        text: partner.partnerName,
                      );

                      final institutionController =
                      TextEditingController(
                        text: partner.partnerInstitution,
                      );

                      final result =
                      await showDialog<List<String>>(
                        context: context,
                        builder: (context) {

                          return AlertDialog(
                            title: const Text(
                              'Edit Financial Partner',
                            ),

                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [

                                TextField(
                                  controller: nameController,
                                  decoration:
                                  const InputDecoration(
                                    labelText: 'Partner Name',
                                    border:
                                    OutlineInputBorder(),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                TextField(
                                  controller:
                                  institutionController,
                                  decoration:
                                  const InputDecoration(
                                    labelText: 'Institution',
                                    border:
                                    OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),

                            actions: [

                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('CANCEL'),
                              ),

                              ElevatedButton(
                                onPressed: () {

                                  Navigator.pop(
                                    context,
                                    [
                                      nameController.text.trim(),
                                      institutionController.text
                                          .trim(),
                                    ],
                                  );
                                },
                                child: const Text('SAVE'),
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

                      if (newName.isEmpty ||
                          newInstitution.isEmpty) {
                        return;
                      }

                      try {

                        final updatedPartner =
                        await FinancialPartnerService
                            .updatePartner(
                          partnerId: partner.partnerId,
                          partnerName: newName,
                          partnerInstitution:
                          newInstitution,
                        );

                        if (!mounted) return;

                        setState(() {
                          _partners[index] = updatedPartner;
                        });

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Financial partner updated successfully.',
                            ),
                          ),
                        );

                      } catch (e) {

                        if (!mounted) return;

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
                  ),

                  // Delete
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {

                      try {

                        await FinancialPartnerService
                            .deletePartner(
                          partnerId: partner.partnerId,
                        );

                        if (!mounted) return;

                        setState(() {
                          _partners.removeAt(index);
                        });

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Financial partner deleted successfully.',
                            ),
                          ),
                        );

                      } catch (e) {

                        if (!mounted) return;

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              'Delete failed: $e',
                            ),
                          ),
                        );
                      }
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