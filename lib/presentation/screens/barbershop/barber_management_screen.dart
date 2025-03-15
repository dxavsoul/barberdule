import 'package:flutter/material.dart';

class BarberManagementScreen extends StatefulWidget {
  const BarberManagementScreen({Key? key}) : super(key: key);

  @override
  State<BarberManagementScreen> createState() => _BarberManagementScreenState();
}

class _BarberManagementScreenState extends State<BarberManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.people, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Barber Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'This screen is under construction',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
