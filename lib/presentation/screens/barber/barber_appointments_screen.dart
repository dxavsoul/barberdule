import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../logic/blocs/barber_appointments/barber_appointments_bloc.dart';
import '../../../logic/blocs/barber_appointments/barber_appointments_event.dart';

class BarberAppointmentsScreen extends StatefulWidget {
  const BarberAppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<BarberAppointmentsScreen> createState() =>
      _BarberAppointmentsScreenState();
}

class _BarberAppointmentsScreenState extends State<BarberAppointmentsScreen> {
  DateTime _selectedDate = DateTime.now();
  late BarberAppointmentsBloc _appointmentsBloc;

  @override
  void initState() {
    super.initState();
    _appointmentsBloc = BlocProvider.of<BarberAppointmentsBloc>(context);
    _appointmentsBloc.add(const BarberAppointmentsLoadRequested());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildDateSelector(),
          _buildDailyStats(),
          Expanded(child: _buildAppointmentsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle adding manual appointment
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              });
            },
          ),
          GestureDetector(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2024),
                lastDate: DateTime(2025),
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                });
              }
            },
            child: Column(
              children: [
                Text(
                  DateFormat('MMMM d, y').format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _isToday(_selectedDate)
                      ? 'Today'
                      : DateFormat('EEEE').format(_selectedDate),
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.add(const Duration(days: 1));
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDailyStats() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard('Total', '5', Icons.calendar_today),
          _buildStatCard('Completed', '2', Icons.check_circle),
          _buildStatCard('Upcoming', '3', Icons.schedule),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    // This would normally fetch from a repository based on selected date
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 5,
      itemBuilder: (context, index) {
        final time = DateTime.now().add(Duration(hours: index + 1));
        final isCompleted = index < 2;

        return _buildAppointmentCard(
          time: time,
          customerName: 'Customer ${index + 1}',
          services: ['Haircut', if (index % 2 == 0) 'Beard Trim'],
          isCompleted: isCompleted,
        );
      },
    );
  }

  Widget _buildAppointmentCard({
    required DateTime time,
    required String customerName,
    required List<String> services,
    required bool isCompleted,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              isCompleted ? Colors.green : Theme.of(context).primaryColor,
          child: Icon(
            isCompleted ? Icons.check : Icons.schedule,
            color: Colors.white,
          ),
        ),
        title: Text(customerName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('h:mm a').format(time)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children:
                  services
                      .map(
                        (service) => Chip(
                          label: Text(
                            service,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
        trailing:
            isCompleted
                ? null
                : PopupMenuButton(
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'complete',
                          child: Text('Mark Complete'),
                        ),
                        const PopupMenuItem(
                          value: 'reschedule',
                          child: Text('Reschedule'),
                        ),
                        const PopupMenuItem(
                          value: 'cancel',
                          child: Text('Cancel'),
                        ),
                      ],
                  onSelected: (value) {
                    // Handle menu item selection
                  },
                ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
