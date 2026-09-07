import 'package:flutter/material.dart';
import 'package:nhgarden/models/garden.dart';
import 'package:nhgarden/services/garden_service.dart';

class GardenManagementScreen extends StatefulWidget {
  const GardenManagementScreen({super.key});

  @override
  State<GardenManagementScreen> createState() => _GardenManagementScreenState();
}

class _GardenManagementScreenState extends State<GardenManagementScreen> {
  final _gardenNameController = TextEditingController();

  List<Garden> _gardens = [];

  bool _isLoading = true;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _loadGardens();
  }

  // ============================================================
  // LOAD GARDENS
  // ============================================================

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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to load gardens: $e')));
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // ADD GARDEN
  // ============================================================

  Future<void> _addGarden() async {
    final gardenName = _gardenNameController.text.trim();

    if (gardenName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter garden name.')),
      );

      return;
    }

    setState(() {
      _isAdding = true;
    });

    try {
      final garden = await GardenService.addGarden(gardenName: gardenName);

      if (!mounted) return;

      _gardenNameController.clear();

      setState(() {
        _gardens.add(garden);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Garden added successfully.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to add garden: $e')));
    } finally {
      if (!mounted) return;

      setState(() {
        _isAdding = false;
      });
    }
  }

  // ============================================================
  // EDIT GARDEN
  // ============================================================

  Future<void> _editGarden(Garden garden) async {
    final controller = TextEditingController(text: garden.gardenName);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.edit_rounded, color: Colors.teal.shade700),
              ),

              const SizedBox(width: 10),

              const Text(
                'Edit Garden',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Garden Name',
              hintText: 'Enter garden name',
              prefixIcon: const Icon(Icons.agriculture_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
              ),
            ),
          ),

          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),

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
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('SAVE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                foregroundColor: Colors.white,
                elevation: 0,
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
      final updatedGarden = await GardenService.updateGarden(
        gardenId: garden.gardenId,
        gardenName: newName,
      );

      if (!mounted) return;

      setState(() {
        final index = _gardens.indexWhere(
          (item) => item.gardenId == garden.gardenId,
        );

        if (index != -1) {
          _gardens[index] = updatedGarden;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Garden updated successfully.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to update garden: $e')));
    }
  }

  // ============================================================
  // DELETE GARDEN
  // ============================================================

  Future<void> _deleteGarden(Garden garden) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red.shade600,
                ),
              ),

              const SizedBox(width: 10),

              const Text(
                'Delete Garden',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          content: Text(
            'Are you sure you want to delete '
            '"${garden.gardenName}"?\n\n'
            'This action cannot be undone.',
            style: const TextStyle(height: 1.5),
          ),

          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),

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
              icon: const Icon(Icons.delete_forever_rounded, size: 18),
              label: const Text('DELETE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await GardenService.deleteGarden(gardenId: garden.gardenId);

      if (!mounted) return;

      setState(() {
        _gardens.removeWhere((item) => item.gardenId == garden.gardenId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Garden deleted successfully.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to delete garden: $e')));
    }
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 4,
      shadowColor: Colors.black26,
      backgroundColor: Colors.teal.shade700,
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
              Icons.agriculture_rounded,
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
                'Garden Management',
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

  // ============================================================
  // ADD GARDEN SECTION
  // ============================================================

  Widget _buildAddGardenSection() {
    return Card(
      elevation: 6,
      shadowColor: Colors.teal.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade700, Colors.teal.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add_business_rounded,
                    color: Colors.white,
                    size: 25,
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add New Garden',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Create a new garden for NH Garden',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                TextField(
                  controller: _gardenNameController,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    if (!_isAdding) {
                      _addGarden();
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Garden Name',
                    hintText: 'Enter garden name',
                    prefixIcon: const Icon(Icons.agriculture_rounded),
                    filled: true,
                    fillColor: Colors.grey.shade50,
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
                      borderSide: BorderSide(
                        color: Colors.teal.shade600,
                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isAdding ? null : _addGarden,
                    icon: _isAdding
                        ? const SizedBox(
                            height: 19,
                            width: 19,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.add_rounded, size: 20),
                    label: Text(_isAdding ? 'ADDING GARDEN...' : 'ADD GARDEN'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.teal.shade300,
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

  // ============================================================
  // GARDEN LIST HEADER
  // ============================================================

  Widget _buildGardenListHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.10),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            Icons.format_list_bulleted_rounded,
            color: Colors.teal.shade700,
            size: 22,
          ),
        ),

        const SizedBox(width: 10),

        const Expanded(
          child: Text(
            'Garden List',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),

        if (!_isLoading && _gardens.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_gardens.length}',
              style: TextStyle(
                color: Colors.teal.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // GARDEN LIST
  // ============================================================

  Widget _buildGardenList() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.teal.shade600),
            const SizedBox(height: 12),
            Text(
              'Loading gardens...',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    if (_gardens.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.agriculture_outlined,
                size: 45,
                color: Colors.teal.shade400,
              ),
            ),

            const SizedBox(height: 14),

            const Text(
              'No gardens found.',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 5),

            Text(
              'Add your first garden above.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.teal.shade700,
      onRefresh: _loadGardens,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 20),
        itemCount: _gardens.length,
        itemBuilder: (context, index) {
          final garden = _gardens[index];

          return _buildGardenListCard(garden);
        },
      ),
    );
  }

  // ============================================================
  // GARDEN LIST CARD
  // ============================================================

  Widget _buildGardenListCard(Garden garden) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // ==============================================
            // GARDEN ICON / ID
            // ==============================================
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade700, Colors.teal.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.agriculture_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${garden.gardenId}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ==============================================
            // GARDEN INFORMATION
            // ==============================================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    garden.gardenName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      Icon(
                        Icons.tag_rounded,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Garden ID: ${garden.gardenId}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ==============================================
            // EDIT BUTTON
            // ==============================================
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                tooltip: 'Edit Garden',
                icon: Icon(
                  Icons.edit_rounded,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
                onPressed: () {
                  _editGarden(garden);
                },
              ),
            ),

            const SizedBox(width: 5),

            // ==============================================
            // DELETE BUTTON
            // ==============================================
            Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                tooltip: 'Delete Garden',
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red.shade600,
                  size: 20,
                ),
                onPressed: () {
                  _deleteGarden(garden);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ==============================================
            // ADD GARDEN
            // ==============================================
            _buildAddGardenSection(),

            const SizedBox(height: 28),

            // ==============================================
            // GARDEN LIST TITLE
            // ==============================================
            _buildGardenListHeader(),

            const SizedBox(height: 10),

            // ==============================================
            // GARDEN LIST
            // ==============================================
            Expanded(child: _buildGardenList()),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _gardenNameController.dispose();
    super.dispose();
  }
}
