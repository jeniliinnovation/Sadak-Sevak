import 'package:flutter/material.dart';
import 'package:sadak_sevak_citizen/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SavedLocationsScreen extends StatefulWidget {
  const SavedLocationsScreen({super.key});

  @override
  State<SavedLocationsScreen> createState() => _SavedLocationsScreenState();
}

class _SavedLocationsScreenState extends State<SavedLocationsScreen> {
  List<Map<String, dynamic>> _locations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedStr = prefs.getString('saved_locations');
    if (savedStr != null) {
      try {
        final List<dynamic> decoded = jsonDecode(savedStr);
        setState(() {
          _locations = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
          _isLoading = false;
        });
        return;
      } catch (e) {
        // Fallback to default seeding
      }
    }

    // Default seeded locations for demo
    _locations = [
      {
        'id': '1',
        'name': 'Home',
        'address': 'Flat 402, Block C, Park Avenue, Zone 1',
        'lat': 22.3120,
        'lng': 70.8050,
      },
      {
        'id': '2',
        'name': 'Office',
        'address': 'Tech Hub Building, MG Road, Zone 2',
        'lat': 22.3039,
        'lng': 70.8022,
      }
    ];
    await _saveLocationsToPrefs();
    setState(() => _isLoading = false);
  }

  Future<void> _saveLocationsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_locations', jsonEncode(_locations));
  }

  void _addLocation() {
    final nameCtrl = TextEditingController();
    final addrCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Location', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Label (e.g. Home, Work)',
                hintText: 'Enter name',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addrCtrl,
              decoration: const InputDecoration(
                labelText: 'Address',
                hintText: 'Enter street address',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty || addrCtrl.text.trim().isEmpty) return;
              setState(() {
                _locations.add({
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'name': nameCtrl.text.trim(),
                  'address': addrCtrl.text.trim(),
                  'lat': 22.3039,
                  'lng': 70.8022,
                });
              });
              _saveLocationsToPrefs();
              Navigator.pop(context);
            },
            child: const Text('Add'),
          )
        ],
      ),
    );
  }

  void _deleteLocation(String id) {
    setState(() {
      _locations.removeWhere((loc) => loc['id'] == id);
    });
    _saveLocationsToPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppTheme.secondaryColor),
        ),
        title: const Text('Saved Locations',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryColor, fontSize: 18)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : _locations.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _locations.length,
                  itemBuilder: (context, index) {
                    final loc = _locations[index];
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade100),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            loc['name'].toString().toLowerCase() == 'home'
                                ? Icons.home_rounded
                                : loc['name'].toString().toLowerCase() == 'office' || loc['name'].toString().toLowerCase() == 'work'
                                    ? Icons.work_rounded
                                    : Icons.location_on_rounded,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                        title: Text(loc['name'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryColor, fontSize: 15)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(loc['address'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                          onPressed: () => _deleteLocation(loc['id']),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addLocation,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_rounded, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          const Text('No saved locations', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Add locations to quickly report issues near them.', style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}
