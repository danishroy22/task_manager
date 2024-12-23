import 'package:flutter/material.dart';
import 'theme_screen.dart';
import 'notifications_screen.dart';
import 'storage_screen.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal, // Adding a custom color
        elevation: 4,
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          _buildSettingsItem(
            context,
            icon: Icons.color_lens,
            title: "Theme",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ThemeScreen()),
              );
            },
          ),
          const Divider(),
          _buildSettingsItem(
            context,
            icon: Icons.notifications,
            title: "Notifications",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NotificationsScreen()),
              );
            },
          ),
          const Divider(),
          _buildSettingsItem(
            context,
            icon: Icons.storage,
            title: "Storage",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => StorageScreen()),
              );
            },
          ),
          const Divider(),
          _buildSettingsItem(
            context,
            icon: Icons.info,
            title: "About",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        leading: Icon(
          icon,
          color: Colors.teal, // Match icon color with theme
          size: 30,
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
      ),
    );
  }
}
