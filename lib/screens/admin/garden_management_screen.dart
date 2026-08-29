import 'package:flutter/material.dart';
import 'package:nhgarden/models/garden.dart';
import 'package:nhgarden/services/garden_service.dart';

class GardenManagementScreen extends StatefulWidget {
  const GardenManagementScreen({super.key});

  @override
  State<GardenManagementScreen> createState() =>
      _GardenManagementScreenState();
}

class _GardenManagementScreenState
    extends State<GardenManagementScreen> {

  final _gardenNameController = TextEditingController();

  List<Garden> _gardens = [];

  bool _isLoading = true;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _loadGardens();
  }

  // -------------------------------------------------
  // Load Gardens
  // -------------------------------------------------

  Future<void> _loadGardens() async {

    setState(() {
      _isLoading = true;
    });

    try {

      final gardens = await GardenService.getGardens();

      if (!mounted) return;

      setState(() {
        _gardens = gardens;
      });

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load gardens: $e'),
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
  // Add Garden
  // -------------------------------------------------

  Future<void> _addGarden() async {

    final gardenName =
    _gardenNameController.text.trim();

    if (gardenName.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter garden name.'),
        ),
      );

      return;
    }

    setState(() {
      _isAdding = true;
    });

    try {

      final garden = await GardenService.addGarden(
        gardenName: gardenName,
      );

      if (!mounted) return;

      _gardenNameController.clear();

      setState(() {
        _gardens.add(garden);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Garden added successfully.'),
        ),
      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to add garden: $e'),
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

    _gardenNameController.dispose();

    super.dispose();
  }

  // -------------------------------------------------
// Edit Garden
// -------------------------------------------------

  Future<void> _editGarden(Garden garden) async {

    final controller = TextEditingController(
      text: garden.gardenName,
    );

    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Garden'),

          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Garden Name',
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

      final updatedGarden =
      await GardenService.updateGarden(
        gardenId: garden.gardenId,
        gardenName: newName,
      );

      if (!mounted) return;

      setState(() {

        final index = _gardens.indexWhere(
              (item) =>
          item.gardenId == garden.gardenId,
        );

        if (index != -1) {
          _gardens[index] = updatedGarden;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Garden updated successfully.',
          ),
        ),
      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to update garden: $e',
          ),
        ),
      );
    }
  }


// -------------------------------------------------
// Delete Garden
// -------------------------------------------------

  Future<void> _deleteGarden(Garden garden) async {

    try {

      await GardenService.deleteGarden(
        gardenId: garden.gardenId,
      );

      if (!mounted) return;

      setState(() {
        _gardens.removeWhere(
              (item) =>
          item.gardenId == garden.gardenId,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Garden deleted successfully.',
          ),
        ),
      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to delete garden: $e',
          ),
        ),
      );
    }
  }

  // -------------------------------------------------
  // UI
  // -------------------------------------------------

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Garden Management'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            // -----------------------------------------
            // Add Garden
            // -----------------------------------------

            const Text(
              'Add Garden',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _gardenNameController,

              decoration: const InputDecoration(
                labelText: 'Garden Name',
                hintText:
                'Enter garden name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed:
                _isAdding
                    ? null
                    : _addGarden,

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
                  'ADD GARDEN',
                ),
              ),
            ),

            const SizedBox(height: 30),

            // -----------------------------------------
            // Garden List
            // -----------------------------------------

            const Text(
              'Garden List',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: _buildGardenList(),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------
  // Garden List Widget
  // -------------------------------------------------

  Widget _buildGardenList() {

    if (_isLoading) {

      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_gardens.isEmpty) {

      return const Center(
        child: Text(
          'No gardens found.',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGardens,

      child: ListView.builder(

        itemCount: _gardens.length,

        itemBuilder: (context, index) {

          final garden = _gardens[index];

          return Card(
            margin:
            const EdgeInsets.only(
              bottom: 10,
            ),

            child: ListTile(

              leading: CircleAvatar(
                child: Text(
                  garden.gardenId.toString(),
                ),
              ),

              title: Text(
                garden.gardenName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: Text(
                'Garden ID: ${garden.gardenId}',
              ),

              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // Edit
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _editGarden(garden);
                    },
                  ),

                  // Delete
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _deleteGarden(garden);
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