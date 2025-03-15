import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          tabs: const [Tab(text: 'Upcoming'), Tab(text: 'History')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildUpcomingAppointments(), _buildAppointmentHistory()],
      ),
    );
  }

  Widget _buildUpcomingAppointments() {
    // This would normally fetch from a repository
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildAppointmentCard(
          date: DateTime.now().add(const Duration(days: 2)),
          barberName: 'John Doe',
          barbershopName: 'Classic Cuts',
          services: ['Haircut', 'Beard Trim'],
          status: 'Confirmed',
          isUpcoming: true,
        ),
      ],
    );
  }

  Widget _buildAppointmentHistory() {
    // This would normally fetch from a repository
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildAppointmentCard(
          date: DateTime.now().subtract(const Duration(days: 7)),
          barberName: 'Mike Smith',
          barbershopName: 'Modern Styles',
          services: ['Haircut'],
          status: 'Completed',
          isUpcoming: false,
        ),
      ],
    );
  }

  Widget _buildAppointmentCard({
    required DateTime date,
    required String barberName,
    required String barbershopName,
    required List<String> services,
    required String status,
    required bool isUpcoming,
  }) {
    final formattedDate = DateFormat('MMM d, y - h:mm a').format(date);
    final statusColor =
        status == 'Confirmed'
            ? Colors.green
            : status == 'Completed'
            ? Colors.blue
            : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Text(barberName[0])),
              title: Text(barberName),
              subtitle: Text(barbershopName),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  services
                      .map(
                        (service) => Chip(
                          label: Text(service),
                          backgroundColor: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                        ),
                      )
                      .toList(),
            ),
            if (isUpcoming) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      // Handle reschedule
                    },
                    child: const Text('Reschedule'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      // Handle cancel
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
