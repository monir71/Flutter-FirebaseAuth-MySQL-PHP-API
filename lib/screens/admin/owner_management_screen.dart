import 'package:flutter/material.dart';

import '../../models/owner.dart';
import '../../services/garden_service.dart';
import '../../services/owner_service.dart';
import 'add_owner_screen.dart';

class OwnerManagementScreen extends StatefulWidget {
  const OwnerManagementScreen({super.key});

  @override
  State<OwnerManagementScreen> createState() =>
      _OwnerManagementScreenState();
}

class _OwnerManagementScreenState
    extends State<OwnerManagementScreen> {

  List<Owner> owners = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadOwners();
  }

  Future<void> loadOwners() async {
    try {
      final result = await OwnerService.getOwners();

      setState(() {
        owners = result;
      });

    } catch (e) {
      debugPrint('Owner Error: $e');

    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _manageGardens(Owner owner) async {
    try {
      final gardens = await GardenService.getGardens();

      final selectedGardenIds =
      owner.gardens.map((garden) => garden.gardenId).toSet();

      if (!mounted) return;

      final result = await showDialog<List<int>>(
        context: context,
        builder: (context) {
          final selected = Set<int>.from(selectedGardenIds);

          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text(
                  'Gardens - ${owner.ownerName}',
                ),

                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView(
                    shrinkWrap: true,
                    children: gardens.map((garden) {
                      return CheckboxListTile(
                        value: selected.contains(garden.gardenId),

                        title: Text(garden.gardenName),

                        subtitle: Text(
                          'Garden ID: ${garden.gardenId}',
                        ),

                        onChanged: (checked) {
                          setDialogState(() {
                            if (checked == true) {
                              selected.add(garden.gardenId);
                            } else {
                              selected.remove(garden.gardenId);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
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
                        selected.toList(),
                      );
                    },
                    child: const Text('SAVE'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (result == null) {
        return;
      }

      await OwnerService.updateOwnerGardens(
        ownerId: owner.ownerId,
        gardenIds: result,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Owner gardens updated successfully.',
          ),
        ),
      );

      loadOwners();

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to update gardens: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Management'),
      ),

      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: owners.length,
        itemBuilder: (context, index) {
          final owner = owners[index];

          return Card(
            child: ListTile(
              title: Text(owner.ownerName),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gardens: ${owner.gardens.length}',
                  ),

                  const SizedBox(height: 5),

                  for (final garden in owner.gardens)
                    Text(
                      '• ${garden.gardenName}',
                    ),
                ],
              ),

              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // Manage Gardens
                  IconButton(
                    icon: const Icon(Icons.grass),
                    onPressed: () {
                      _manageGardens(owner);
                    },
                  ),

                  // Edit
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {

                      final controller = TextEditingController(
                        text: owner.ownerName,
                      );

                      final newName = await showDialog<String>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Edit Owner'),

                            content: TextField(
                              controller: controller,
                              decoration: const InputDecoration(
                                labelText: 'Owner Name',
                                border: OutlineInputBorder(),
                              ),
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
                                    controller.text.trim(),
                                  );
                                },
                                child: const Text('SAVE'),
                              ),
                            ],
                          );
                        },
                      );

                      controller.dispose();

                      if (newName == null || newName.isEmpty) {
                        return;
                      }

                      try {

                        await OwnerService.updateOwner(
                          ownerId: owner.ownerId,
                          ownerName: newName,
                        );

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Owner updated successfully.',
                            ),
                          ),
                        );

                        loadOwners();

                      } catch (e) {

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
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

                        await OwnerService.deleteOwner(
                          ownerId: owner.ownerId,
                        );

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Owner deleted successfully.',
                            ),
                          ),
                        );

                        loadOwners();

                      } catch (e) {

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
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

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddOwnerScreen(),
            ),
          );

          loadOwners();
        },

        child: const Icon(Icons.add),
      ),
    );
  }
}