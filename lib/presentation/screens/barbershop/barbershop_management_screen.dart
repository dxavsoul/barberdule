import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repository/barbershop_repository.dart';
import '../../../logic/blocs/profile/profile_bloc.dart';
import '../../../logic/blocs/profile/profile_state.dart';
import '../../../routes.dart';

class BarbershopManagementScreen extends StatefulWidget {
  const BarbershopManagementScreen({Key? key}) : super(key: key);

  @override
  State<BarbershopManagementScreen> createState() =>
      _BarbershopManagementScreenState();
}

class _BarbershopManagementScreenState
    extends State<BarbershopManagementScreen> {
  final BarbershopRepository _barbershopRepository = BarbershopRepository();
  bool _isLoading = true;
  String? _barbershopId;
  String? _barbershopName;

  @override
  void initState() {
    super.initState();
    _loadBarbershopData();
  }

  Future<void> _loadBarbershopData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final state = context.read<ProfileBloc>().state;
      if (state is ProfileLoaded) {
        final userId = state.user.uid;
        final barbershop = await _barbershopRepository.getBarbershopByOwnerId(
          userId,
        );

        if (barbershop != null) {
          setState(() {
            _barbershopId = barbershop.id;
            _barbershopName = barbershop.name;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading barbershop: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_barbershopId == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.store, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No Barbershop Found',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'You need to register a barbershop first',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.registerBarbershop);
                },
                child: const Text('Register Barbershop'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_barbershopName ?? 'My Barbershop')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Barbershop Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildManagementCard(
              title: 'Manage Barbers',
              description: 'Approve or reject barber applications',
              icon: Icons.people,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.barberApproval);
              },
            ),
            const SizedBox(height: 16),
            _buildManagementCard(
              title: 'Manage Services',
              description:
                  'Add, edit, or remove services offered by your barbershop',
              icon: Icons.content_cut,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.manageServices,
                  arguments: {'barbershopId': _barbershopId},
                );
              },
            ),
            const SizedBox(height: 16),
            _buildManagementCard(
              title: 'Barbershop Profile',
              description: 'Edit your barbershop information',
              icon: Icons.store,
              onTap: () {
                // Navigate to barbershop profile edit screen
              },
            ),
            const SizedBox(height: 16),
            _buildManagementCard(
              title: 'Working Hours',
              description: 'Set your barbershop working hours',
              icon: Icons.access_time,
              onTap: () {
                // Navigate to working hours screen
              },
            ),
            const SizedBox(height: 16),
            _buildManagementCard(
              title: 'Analytics',
              description: 'View appointments and revenue statistics',
              icon: Icons.analytics,
              onTap: () {
                // Navigate to analytics screen
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
