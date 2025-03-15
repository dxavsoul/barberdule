import 'package:flutter/material.dart';

class AppointmentHistoryScreen extends StatelessWidget {
  const AppointmentHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appointment History')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Placeholder for appointment history
          Card(
            child: ListTile(
              leading: const Icon(Icons.history),
              title: const Text('No past appointments'),
              subtitle: const Text('Your appointment history will appear here'),
            ),
          ),
        ],
      ),
    );
  }
}
