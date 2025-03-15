import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:barberdule/routes.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppointmentsList('upcoming'),
          _buildAppointmentsList('completed'),
          _buildAppointmentsList('cancelled'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to book appointment screen
          Navigator.pushNamed(context, AppRoutes.bookAppointment);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAppointmentsList(String type) {
    // This would normally fetch appointments from a repository
    // For now, we'll use mock data
    final List<Map<String, dynamic>> appointments = _getMockAppointments(type);

    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'upcoming'
                  ? Icons.calendar_today
                  : type == 'completed'
                  ? Icons.check_circle
                  : Icons.cancel,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No ${type.capitalize()} Appointments',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              type == 'upcoming'
                  ? 'Book an appointment with your favorite barber'
                  : 'Your ${type.capitalize()} appointments will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            if (type == 'upcoming')
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.bookAppointment);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Book Appointment'),
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(appointment['barberImage']),
              radius: 30,
            ),
            title: Text(
              appointment['barberName'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  appointment['service'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('MMM dd, yyyy').format(appointment['date'])} at ${DateFormat('hh:mm a').format(appointment['date'])}',
                ),
                const SizedBox(height: 4),
                Text(
                  appointment['barbershopName'],
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            trailing:
                type == 'upcoming'
                    ? IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        _showAppointmentOptions(appointment);
                      },
                    )
                    : null,
            onTap: () {
              // Show appointment details
            },
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getMockAppointments(String type) {
    if (type == 'upcoming') {
      return [
        {
          'id': '1',
          'barberName': 'John Smith',
          'barberImage': 'https://randomuser.me/api/portraits/men/32.jpg',
          'service': 'Haircut & Beard Trim',
          'date': DateTime.now().add(const Duration(days: 2)),
          'barbershopName': 'Classic Cuts',
          'status': 'confirmed',
        },
        {
          'id': '2',
          'barberName': 'Michael Johnson',
          'barberImage': 'https://randomuser.me/api/portraits/men/44.jpg',
          'service': 'Hair Styling',
          'date': DateTime.now().add(const Duration(days: 5)),
          'barbershopName': 'Modern Styles',
          'status': 'pending',
        },
      ];
    } else if (type == 'completed') {
      return [
        {
          'id': '3',
          'barberName': 'Robert Davis',
          'barberImage': 'https://randomuser.me/api/portraits/men/22.jpg',
          'service': 'Haircut',
          'date': DateTime.now().subtract(const Duration(days: 10)),
          'barbershopName': 'Elite Barbers',
          'status': 'completed',
        },
      ];
    } else {
      return []; // No cancelled appointments for demo
    }
  }

  void _showAppointmentOptions(Map<String, dynamic> appointment) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Reschedule'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to reschedule screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text(
                  'Cancel Appointment',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showCancelConfirmation(appointment);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCancelConfirmation(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Appointment'),
          content: const Text(
            'Are you sure you want to cancel this appointment?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Cancel appointment logic would go here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Appointment cancelled'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text('Yes', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
