import 'package:barberdule/logic/blocs/profile/profile_bloc.dart';
import 'package:barberdule/logic/blocs/profile/profile_state.dart';
import 'package:barberdule/presentation/widgets/book_appointment_button.dart';
import 'package:barberdule/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          final userType = state.userType;

          switch (userType) {
            case 'customer':
              return _buildCustomerHome(context);
            case 'barber':
              return _buildBarberHome(context);
            case 'barbershop_owner':
              return _buildBarbershopOwnerHome(context);
            default:
              return _buildDefaultHome(context);
          }
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildCustomerHome(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50,),
              const Text(
                'Welcome back!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              // Quick Actions Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildQuickActionButton(
                            context,
                            Icons.calendar_today,
                            'Book\nAppointment',
                            () => Navigator.pushNamed(
                              context,
                              AppRoutes.bookAppointment,
                            ),
                          ),
                          _buildQuickActionButton(
                            context,
                            Icons.map,
                            'Find\nBarbershop',
                            () => Navigator.pushNamed(context, AppRoutes.exploreBarbers),
                          ),
                          _buildQuickActionButton(
                            context,
                            Icons.history,
                            'View\nHistory',
                            () => Navigator.pushNamed(
                              context,
                              AppRoutes.appointmentHistory,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Upcoming Appointments Section
              const Text(
                'Upcoming Appointments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.event_available),
                  title: const Text('No upcoming appointments'),
                  subtitle: const Text('Book your next appointment now'),
                  trailing: TextButton(
                    onPressed:
                        () => Navigator.pushNamed(
                          context,
                          AppRoutes.bookAppointment,
                        ),
                    child: const Text('Book'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarberHome(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome back, Barber!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              // Today's Overview Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Today\'s Overview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard(
                            'Appointments',
                            '0',
                            Icons.calendar_today,
                          ),
                          _buildStatCard(
                            'Available Slots',
                            '8',
                            Icons.access_time,
                          ),
                          _buildStatCard('Completed', '0', Icons.check_circle),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Next Appointment Section
              const Text(
                'Next Appointment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                child: const ListTile(
                  leading: Icon(Icons.event_available),
                  title: Text('No upcoming appointments'),
                  subtitle: Text('Your schedule is clear'),
                ),
              ),
              const SizedBox(height: 24),
              // Quick Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickActionButton(
                    context,
                    Icons.schedule,
                    'Update\nSchedule',
                    () {},
                  ),
                  _buildQuickActionButton(
                    context,
                    Icons.calendar_today,
                    'View All\nAppointments',
                    () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarbershopOwnerHome(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome back, Owner!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              // Business Overview Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Business Overview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard(
                            'Today\'s\nAppointments',
                            '0',
                            Icons.calendar_today,
                          ),
                          _buildStatCard('Active\nBarbers', '0', Icons.people),
                          _buildStatCard(
                            'Total\nRevenue',
                            '\$0',
                            Icons.attach_money,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickActionButton(
                    context,
                    Icons.person_add,
                    'Add\nBarber',
                    () {},
                  ),
                  _buildQuickActionButton(
                    context,
                    Icons.analytics,
                    'View\nAnalytics',
                    () {},
                  ),
                  _buildQuickActionButton(
                    context,
                    Icons.settings,
                    'Manage\nBarbershop',
                    () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultHome(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Welcome to Barberdule!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your one-stop solution for barber appointments',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          const BookAppointmentButton(),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.store),
            label: const Text('Register Barbershop or Barber'),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.registrationChoice);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(icon: Icon(icon), onPressed: onPressed, iconSize: 32),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

// Simple search delegate for barbershops
class BarbershopSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // This would normally search barbershops from a repository
    return Center(child: Text('Search results for: $query'));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // This would normally show suggestions based on the query
    return const Center(child: Text('Type to search barbershops'));
  }
}
