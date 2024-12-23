import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // For accessing app's document directory

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  _StorageScreenState createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  String _storageUsed = "Calculating..."; // Placeholder for storage usage text

  @override
  void initState() {
    super.initState();
    _getStorageUsage();
  }

  // Method to get storage usage (real data)
  void _getStorageUsage() async {
    final directory = await getApplicationDocumentsDirectory();
    final totalSize = await _calculateDirectorySize(directory);

    setState(() {
      // Format the size to display in MB
      _storageUsed =
          "${(totalSize / (1024 * 1024)).toStringAsFixed(2)} MB used";
    });
  }

  // Method to calculate the size of a directory and its subdirectories
  Future<int> _calculateDirectorySize(Directory directory) async {
    int totalSize = 0;

    try {
      final files = directory.listSync(recursive: true, followLinks: false);
      for (var file in files) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
    } catch (e) {
      print("Error calculating directory size: $e");
    }

    return totalSize;
  }

  // Method to clear cache (same as before)
  void _clearCache() async {
    try {
      // You can clear cache with flutter_cache_manager or handle it according to your needs
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cache cleared")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error clearing cache: $e")),
      );
    }
  }

  // Method to clear data (delete all local files, reset app state)
  void _clearData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      directory.deleteSync(
          recursive: true); // Deletes all files in the directory
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("App data cleared")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error clearing data: $e")),
      );
    }
  }

  // Method to reset app settings
  void _resetApp() {
    _clearData();
    _clearCache();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("App reset to default")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Storage Usage: $_storageUsed"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _clearCache,
              child: Text("Clear Cache"),
            ),
            ElevatedButton(
              onPressed: _clearData,
              child: Text("Clear Data"),
            ),
            ElevatedButton(
              onPressed: _resetApp,
              child: Text("Reset App"),
            ),
          ],
        ),
      ),
    );
  }
}
