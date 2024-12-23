import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification Settings"),
      ),
      body: Center(
        child: Text(
          'Here you can manage your notification preferences.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
