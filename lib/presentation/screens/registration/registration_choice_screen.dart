import 'package:flutter/material.dart';
import '../../../routes.dart';

class RegistrationChoiceScreen extends StatelessWidget {
  const RegistrationChoiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choose Registration Type',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildOptionCard(
              context,
              title: 'Register as a Customer',
              description:
                  'Register as a customer to book appointments with barbers.',
              icon: Icons.person,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.registerCustomer);
              },
            ),
            const SizedBox(height: 24),
            _buildOptionCard(
              context,
              title: 'Register a Barbershop',
              description:
                  'Register your barbershop to attract customers and manage your barbers.',
              icon: Icons.store,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.registerBarbershop);
              },
            ),
            const SizedBox(height: 24),
            _buildOptionCard(
              context,
              title: 'Register as a Barber',
              description:
                  'Register as a barber to manage your appointments and services.',
              icon: Icons.content_cut,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.registerBarber);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(icon, size: 60, color: Theme.of(context).primaryColor),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
