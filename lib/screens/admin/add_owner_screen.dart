import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/garden.dart';
import '../../services/garden_service.dart';
import '../../services/owner_service.dart';
import '../../widgets/custom_avatar_picker.dart';

class AddOwnerScreen extends StatefulWidget {
  const AddOwnerScreen({super.key});

  @override
  State<AddOwnerScreen> createState() => _AddOwnerScreenState();
}

class _AddOwnerScreenState extends State<AddOwnerScreen> {
  final _ownerNameController = TextEditingController();

  List<Garden> gardens = [];
  List<int> selectedGardenIds = [];

  bool isLoading = true;
  bool isSaving = false;

  XFile? _selectedOwnerPhoto;

  final Color _primaryColor = Colors.deepPurple.shade600;

  @override
  void initState() {
    super.initState();
    loadGardens();
  }

  Future<void> loadGardens() async {
    try {
      final result = await GardenService.getGardens();

      setState(() {
        gardens = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveOwner() async {
    if (_ownerNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter owner name.')));
      return;
    }

    if (selectedGardenIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one garden.')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // ---------------------------------------------
      // 1. Create Owner
      // ---------------------------------------------

      final owner = await OwnerService.addOwner(
        ownerName: _ownerNameController.text.trim(),
        gardenIds: selectedGardenIds,
      );

      // ---------------------------------------------
      // 2. Upload Owner Photo
      // ---------------------------------------------

      if (_selectedOwnerPhoto != null) {
        final photoPath = await OwnerService.uploadOwnerPhoto(
          ownerId: owner.ownerId,
          photo: _selectedOwnerPhoto!,
        );
      }

      // ---------------------------------------------
      // 3. Return to Owner Management
      // ---------------------------------------------

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    super.dispose();
  }

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
                Icons.person_add_alt_1_rounded,
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
                  'Add Owner',
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

      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_alt_rounded,
                    color: _primaryColor,
                    size: 42,
                  ),
                  const SizedBox(height: 12),
                  CircularProgressIndicator(color: _primaryColor),
                  const SizedBox(height: 12),
                  Text(
                    'Loading gardens...',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // -----------------------------------------
                // Header Card
                // -----------------------------------------
                Card(
                  elevation: 6,
                  shadowColor: Colors.deepPurple.withOpacity(0.18),
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.deepPurple.shade700,
                              Colors.deepPurple.shade400,
                            ],
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
                                Icons.person_add_alt_1_rounded,
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
                                    'Add New Owner',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Create an owner and assign gardens',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ---------------------------------
                            // Owner Photo
                            // ---------------------------------
                            Center(
                              child: Column(
                                children: [
                                  CustomAvatarPicker(
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedOwnerPhoto = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Owner Photo',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 22),

                            // ---------------------------------
                            // Owner Name
                            // ---------------------------------
                            TextField(
                              controller: _ownerNameController,
                              decoration: _inputDecoration(
                                'Owner Name',
                                Icons.person_outline_rounded,
                              ),
                            ),

                            const SizedBox(height: 22),

                            // ---------------------------------
                            // Garden Section
                            // ---------------------------------
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.agriculture_rounded,
                                    color: _primaryColor,
                                    size: 21,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Select Gardens',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Choose one or more gardens for this owner',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${selectedGardenIds.length}',
                                    style: TextStyle(
                                      color: _primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // ---------------------------------
                            // Garden List
                            // ---------------------------------
                            if (gardens.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.orange.shade100,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.orange.shade700,
                                      size: 35,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'No gardens available',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Please create a garden first.',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: gardens.length,
                                  separatorBuilder: (context, index) {
                                    return Divider(
                                      height: 1,
                                      color: Colors.grey.shade200,
                                    );
                                  },
                                  itemBuilder: (context, index) {
                                    final garden = gardens[index];

                                    final selected = selectedGardenIds.contains(
                                      garden.gardenId,
                                    );

                                    return CheckboxListTile(
                                      value: selected,
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            selectedGardenIds.add(
                                              garden.gardenId,
                                            );
                                          } else {
                                            selectedGardenIds.remove(
                                              garden.gardenId,
                                            );
                                          }
                                        });
                                      },
                                      activeColor: _primaryColor,
                                      checkColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      secondary: Container(
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? Colors.deepPurple.shade50
                                              : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(
                                            9,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.agriculture_rounded,
                                          size: 19,
                                          color: selected
                                              ? _primaryColor
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                      title: Text(
                                        garden.gardenName,
                                        style: TextStyle(
                                          fontWeight: selected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                            const SizedBox(height: 20),

                            // ---------------------------------
                            // Save Button
                            // ---------------------------------
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: isSaving ? null : saveOwner,
                                icon: isSaving
                                    ? const SizedBox(
                                        width: 19,
                                        height: 19,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.person_add_rounded),
                                label: Text(
                                  isSaving ? 'SAVING...' : 'SAVE OWNER',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primaryColor,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      Colors.deepPurple.shade300,
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
                ),
              ],
            ),
    );
  }
}
