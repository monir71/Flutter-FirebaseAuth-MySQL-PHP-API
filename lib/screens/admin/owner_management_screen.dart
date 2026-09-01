import 'package:flutter/material.dart';

import '../../models/owner.dart';
import '../../services/garden_service.dart';
import '../../services/owner_service.dart';
import 'add_owner_screen.dart';

class OwnerManagementScreen extends StatefulWidget {
  const OwnerManagementScreen({super.key});

  @override
  State<OwnerManagementScreen> createState() => _OwnerManagementScreenState();
}

class _OwnerManagementScreenState extends State<OwnerManagementScreen> {
  List<Owner> owners = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadOwners();
  }

  // -------------------------------------------------
  // Load Owners
  // -------------------------------------------------

  Future<void> loadOwners() async {
    try {
      final result = await OwnerService.getOwners();

      if (!mounted) return;

      setState(() {
        owners = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to load owners: $e')));
    }
  }

  // -------------------------------------------------
  // Manage Gardens
  // -------------------------------------------------

  Future<void> _manageGardens(Owner owner) async {
    try {
      final gardens = await GardenService.getGardens();

      final selectedGardenIds = owner.gardens
          .map((garden) => garden.gardenId)
          .toSet();

      if (!mounted) return;

      final result = await showDialog<List<int>>(
        context: context,
        builder: (context) {
          final selected = Set<int>.from(selectedGardenIds);

          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text('Gardens - ${owner.ownerName}'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView(
                    shrinkWrap: true,
                    children: gardens.map((garden) {
                      return CheckboxListTile(
                        value: selected.contains(garden.gardenId),
                        title: Text(garden.gardenName),
                        subtitle: Text('Garden ID: ${garden.gardenId}'),
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
                      Navigator.pop(context, selected.toList());
                    },
                    child: const Text('SAVE'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (result == null) return;

      await OwnerService.updateOwnerGardens(
        ownerId: owner.ownerId,
        gardenIds: result,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Owner gardens updated successfully.')),
      );

      await loadOwners();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to update gardens: $e')));
    }
  }

  // -------------------------------------------------
  // Set Login User
  // -------------------------------------------------

  Future<void> _setLoginUser(Owner owner) async {
    try {
      final users = await OwnerService.getUnlinkedUsers();

      if (!mounted) return;

      final selectedUserId = await showDialog<int>(
        context: context,
        builder: (context) {
          int? selectedId = owner.userId;

          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text('Login User - ${owner.ownerName}'),
                content: SizedBox(
                  width: 500,
                  child: users.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('No general users are available.'),
                        )
                      : ListView(
                          shrinkWrap: true,
                          children: [
                            for (final user in users)
                              RadioListTile<int>(
                                value: user.userId,
                                groupValue: selectedId,
                                title: Text(user.username),
                                subtitle: Text(user.email),
                                onChanged: (value) {
                                  setDialogState(() {
                                    selectedId = value;
                                  });
                                },
                              ),
                          ],
                        ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('CANCEL'),
                  ),
                  if (owner.userId != null)
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, -1);
                      },
                      child: const Text(
                        'REMOVE LOGIN',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: selectedId == null
                        ? null
                        : () {
                            Navigator.pop(context, selectedId);
                          },
                    child: const Text('SAVE'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (selectedUserId == null) return;

      // Remove existing login
      if (selectedUserId == -1) {
        await OwnerService.deleteOwner(ownerId: owner.ownerId);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Owner login removed successfully.')),
        );

        await loadOwners();
        return;
      }

      // Assign login user
      await OwnerService.assignOwnerUser(
        ownerId: owner.ownerId,
        userId: selectedUserId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Owner login user assigned successfully.'),
        ),
      );

      await loadOwners();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to set login user: $e')));
    }
  }

  // -------------------------------------------------
  // Edit Owner
  // -------------------------------------------------

  Future<void> _editOwner(Owner owner) async {
    final controller = TextEditingController(text: owner.ownerName);

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
                Navigator.pop(context, controller.text.trim());
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
        const SnackBar(content: Text('Owner updated successfully.')),
      );

      await loadOwners();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    }
  }

  // -------------------------------------------------
  // Delete Owner
  // -------------------------------------------------

  Future<void> _deleteOwner(Owner owner) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Owner'),
          content: Text(
            'Are you sure you want to delete '
            '${owner.ownerName}?',
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await OwnerService.deleteOwner(ownerId: owner.ownerId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Owner deleted successfully.')),
      );

      await loadOwners();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  // -------------------------------------------------
  // Login Status
  // -------------------------------------------------

  Widget _buildLoginStatus(Owner owner) {
    final linked = owner.userId != null;

    return Row(
      children: [
        Icon(
          linked ? Icons.account_circle : Icons.no_accounts,
          size: 16,
          color: linked ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 5),
        Text(
          linked ? 'Login linked' : 'Login not linked',
          style: TextStyle(
            fontSize: 12,
            color: linked ? Colors.green : Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------
  // Owner Card
  // -------------------------------------------------

  Widget _buildOwnerCard(Owner owner) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),

        title: Text(
          owner.ownerName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLoginStatus(owner),

              const SizedBox(height: 6),

              Text('Gardens: ${owner.gardens.length}'),

              const SizedBox(height: 5),

              for (final garden in owner.gardens)
                Text('• ${garden.gardenName}'),
            ],
          ),
        ),

        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'login':
                _setLoginUser(owner);
                break;

              case 'gardens':
                _manageGardens(owner);
                break;

              case 'edit':
                _editOwner(owner);
                break;

              case 'delete':
                _deleteOwner(owner);
                break;
            }
          },
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                value: 'login',
                child: Row(
                  children: [
                    Icon(
                      owner.userId != null
                          ? Icons.manage_accounts
                          : Icons.person_add,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      owner.userId != null
                          ? 'Change Login User'
                          : 'Set Login User',
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'gardens',
                child: Row(
                  children: [
                    Icon(Icons.grass),
                    SizedBox(width: 10),
                    Text('Manage Gardens'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 10),
                    Text('Edit Owner'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Delete Owner'),
                  ],
                ),
              ),
            ];
          },
        ),
      ),
    );
  }

  // -------------------------------------------------
  // Build
  // -------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Owner Management')),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : owners.isEmpty
          ? const Center(child: Text('No owners found.'))
          : RefreshIndicator(
              onRefresh: loadOwners,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: owners.length,
                itemBuilder: (context, index) {
                  return _buildOwnerCard(owners[index]);
                },
              ),
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddOwnerScreen()),
          );

          await loadOwners();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
