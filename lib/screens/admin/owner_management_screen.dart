import 'package:flutter/material.dart';
import 'package:nhgarden/config/api_config.dart';
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load owners: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 10),
                contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.grass_rounded,
                        color: Colors.teal.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Manage Gardens',
                        style: TextStyle(
                          color: Colors.grey.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                content: SizedBox(
                  width: 500,
                  child: gardens.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(25),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.grass_outlined,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No gardens available.',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          shrinkWrap: true,
                          children: gardens.map((garden) {
                            final checked = selected.contains(garden.gardenId);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: checked
                                    ? Colors.teal.withOpacity(0.07)
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: checked
                                      ? Colors.teal.withOpacity(0.25)
                                      : Colors.grey.shade200,
                                ),
                              ),
                              child: CheckboxListTile(
                                value: checked,
                                activeColor: Colors.teal.shade700,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                title: Text(
                                  garden.gardenName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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
                              ),
                            );
                          }).toList(),
                        ),
                ),
                actionsPadding: const EdgeInsets.fromLTRB(20, 5, 20, 16),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('CANCEL'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context, selected.toList());
                    },
                    icon: const Icon(Icons.save_rounded, size: 18),
                    label: const Text('SAVE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      foregroundColor: Colors.white,
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

      if (result == null) return;

      await OwnerService.updateOwnerGardens(
        ownerId: owner.ownerId,
        gardenIds: result,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Owner gardens updated successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      await loadOwners();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to update gardens: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 10),
                contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        owner.userId != null
                            ? Icons.manage_accounts_rounded
                            : Icons.person_add_alt_1_rounded,
                        color: Colors.deepPurple.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Login User',
                        style: TextStyle(
                          color: Colors.grey.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                content: SizedBox(
                  width: 500,
                  child: users.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(25),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_off_rounded,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No general users are available.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          shrinkWrap: true,
                          children: [
                            for (final user in users)
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: selectedId == user.userId
                                      ? Colors.deepPurple.withOpacity(0.07)
                                      : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selectedId == user.userId
                                        ? Colors.deepPurple.withOpacity(0.25)
                                        : Colors.grey.shade200,
                                  ),
                                ),
                                child: RadioListTile<int>(
                                  value: user.userId,
                                  groupValue: selectedId,
                                  activeColor: Colors.deepPurple.shade600,
                                  title: Text(
                                    user.username,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(user.email),
                                  onChanged: (value) {
                                    setDialogState(() {
                                      selectedId = value;
                                    });
                                  },
                                ),
                              ),
                          ],
                        ),
                ),
                actionsPadding: const EdgeInsets.fromLTRB(20, 5, 20, 16),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('CANCEL'),
                  ),
                  if (owner.userId != null)
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context, -1);
                      },
                      icon: const Icon(
                        Icons.link_off_rounded,
                        size: 17,
                        color: Colors.red,
                      ),
                      label: const Text(
                        'REMOVE LOGIN',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ElevatedButton.icon(
                    onPressed: selectedId == null
                        ? null
                        : () {
                            Navigator.pop(context, selectedId);
                          },
                    icon: const Icon(Icons.save_rounded, size: 18),
                    label: const Text('SAVE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade600,
                      foregroundColor: Colors.white,
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

      if (selectedUserId == null) return;

      // Remove existing login
      if (selectedUserId == -1) {
        await OwnerService.deleteOwner(ownerId: owner.ownerId);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Owner login removed successfully.'),
            behavior: SnackBarBehavior.floating,
          ),
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
          behavior: SnackBarBehavior.floating,
        ),
      );

      await loadOwners();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to set login user: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 10),
          contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 10),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.edit_rounded, color: Colors.blue.shade700),
              ),
              const SizedBox(width: 12),
              const Text(
                'Edit Owner',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Owner Name',
              hintText: 'Enter owner name',
              prefixIcon: const Icon(Icons.person_rounded),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 5, 20, 16),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text('SAVE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
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
          content: Text('Owner updated successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      await loadOwners();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Update failed: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 10),
          contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 10),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Delete Owner',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete ${owner.ownerName}?\n\n'
            'This action cannot be undone.',
            style: TextStyle(color: Colors.grey.shade700, height: 1.4),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 5, 20, 16),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context, true);
              },
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text('DELETE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
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

    if (confirm != true) return;

    try {
      await OwnerService.deleteOwner(ownerId: owner.ownerId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Owner deleted successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      await loadOwners();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failed: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // -------------------------------------------------
  // Login Status
  // -------------------------------------------------

  Widget _buildLoginStatus(Owner owner) {
    final linked = owner.userId != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: linked
            ? Colors.green.withOpacity(0.09)
            : Colors.red.withOpacity(0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            linked ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 15,
            color: linked ? Colors.green.shade700 : Colors.red.shade700,
          ),
          const SizedBox(width: 5),
          Text(
            linked ? 'Login linked' : 'Login not linked',
            style: TextStyle(
              fontSize: 12,
              color: linked ? Colors.green.shade700 : Colors.red.shade700,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------
  // Garden Chip
  // -------------------------------------------------

  Widget _buildGardenChip(OwnerGarden garden) {
    return Container(
      margin: const EdgeInsets.only(right: 6, bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.teal.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.grass_rounded, size: 14, color: Colors.teal.shade700),
          const SizedBox(width: 5),
          Text(
            garden.gardenName,
            style: TextStyle(
              fontSize: 12,
              color: Colors.teal.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------
  // Owner Card
  // -------------------------------------------------

  Widget _buildOwnerCard(Owner owner) {
    final hasPhoto = owner.ownerPhoto != null && owner.ownerPhoto!.isNotEmpty;

    return Card(
      elevation: 4,
      shadowColor: Colors.deepPurple.withOpacity(0.12),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Owner Photo
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(17),
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade600,
                      Colors.deepPurple.shade400,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(3),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: hasPhoto
                      ? Image.network(
                          '${ApiConfig.baseUrl}/${owner.ownerPhoto}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 34,
                            );
                          },
                        )
                      : const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                ),
              ),

              const SizedBox(width: 14),

              // Owner Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            owner.ownerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        _buildPopupMenu(owner),
                      ],
                    ),

                    const SizedBox(height: 8),

                    _buildLoginStatus(owner),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Icon(
                          Icons.grass_rounded,
                          size: 17,
                          color: Colors.teal.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${owner.gardens.length} '
                          '${owner.gardens.length == 1 ? 'Garden' : 'Gardens'}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    if (owner.gardens.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        children: owner.gardens.map(_buildGardenChip).toList(),
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      Text(
                        'No garden assigned',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------
  // Popup Menu
  // -------------------------------------------------

  Widget _buildPopupMenu(Owner owner) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: PopupMenuButton<String>(
        tooltip: 'Owner actions',
        icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                        ? Icons.manage_accounts_rounded
                        : Icons.person_add_alt_1_rounded,
                    color: Colors.deepPurple.shade600,
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
            PopupMenuItem(
              value: 'gardens',
              child: Row(
                children: [
                  Icon(Icons.grass_rounded, color: Colors.teal.shade700),
                  const SizedBox(width: 10),
                  const Text('Manage Gardens'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_rounded, color: Colors.blue.shade700),
                  const SizedBox(width: 10),
                  const Text('Edit Owner'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline_rounded, color: Colors.red),
                  SizedBox(width: 10),
                  Text('Delete Owner'),
                ],
              ),
            ),
          ];
        },
      ),
    );
  }

  // -------------------------------------------------
  // AppBar
  // -------------------------------------------------

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 4,
      shadowColor: Colors.black26,
      backgroundColor: Colors.deepPurple.shade600,
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
              Icons.people_alt_rounded,
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
                'Owner Management',
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
  // Header
  // -------------------------------------------------

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.people_alt_rounded,
              color: Colors.deepPurple.shade600,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Garden Owners',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(
                  'Manage owners, gardens and login access',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (!isLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.09),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${owners.length}',
                style: TextStyle(
                  color: Colors.deepPurple.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
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
          SizedBox(
            width: 38,
            height: 38,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.teal.shade700,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Loading owners...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------
  // Empty State
  // -------------------------------------------------

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: loadOwners,
      color: Colors.teal.shade700,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.people_outline_rounded,
                      size: 55,
                      color: Colors.deepPurple.shade300,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'No owners found.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Add your first garden owner to get started.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------
  // Build
  // -------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),

      body: Column(
        children: [
          _buildHeader(),

          Expanded(
            child: isLoading
                ? _buildLoadingState()
                : owners.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: loadOwners,
                    color: Colors.teal.shade700,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 90),
                      itemCount: owners.length,
                      itemBuilder: (context, index) {
                        return _buildOwnerCard(owners[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddOwnerScreen()),
          );

          await loadOwners();
        },
        backgroundColor: Colors.deepPurple.shade600,
        foregroundColor: Colors.white,
        elevation: 6,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text(
          'ADD OWNER',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
