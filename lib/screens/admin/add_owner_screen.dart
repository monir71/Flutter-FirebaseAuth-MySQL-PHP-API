import 'package:flutter/material.dart';

import '../../models/garden.dart';
import '../../services/garden_service.dart';
import '../../services/owner_service.dart';

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
      debugPrint('Garden Error: $e');

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveOwner() async {
    if (_ownerNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter owner name.'),
        ),
      );
      return;
    }

    if (selectedGardenIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one garden.'),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final owner = await OwnerService.addOwner(
        ownerName: _ownerNameController.text.trim(),
        gardenIds: selectedGardenIds,
      );

      debugPrint('Owner Added: ${owner.ownerName}');

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      debugPrint('Owner Add Error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Owner'),
      ),

      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: _ownerNameController,
              decoration: const InputDecoration(
                labelText: 'Owner Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Gardens',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: gardens.length,
                itemBuilder: (context, index) {

                  final garden = gardens[index];

                  return CheckboxListTile(
                    title: Text(garden.gardenName),

                    value: selectedGardenIds
                        .contains(garden.gardenId),

                    onChanged: (value) {
                      setState(() {

                        if (value == true) {
                          selectedGardenIds
                              .add(garden.gardenId);
                        } else {
                          selectedGardenIds
                              .remove(garden.gardenId);
                        }

                      });
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving
                    ? null
                    : saveOwner,

                child: isSaving
                    ? const CircularProgressIndicator()
                    : const Text('SAVE OWNER'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}