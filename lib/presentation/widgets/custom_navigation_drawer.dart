import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/blocs/profile/profile_bloc.dart';
import '../../logic/blocs/profile/profile_state.dart';
import '../../logic/blocs/profile/profile_event.dart';
import '../../routes.dart';

class CustomNavigationDrawer extends StatelessWidget {
  const CustomNavigationDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          final userType = state.userType;
          final user = state.user;

          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Drawer header with user info
                UserAccountsDrawerHeader(
                  accountName: Text(user.displayName ?? 'User'),
                  accountEmail: Text(user.email ?? ''),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage:
                        user.photoURL != null
                            ? NetworkImage(user.photoURL!)
                            : null,
                    child:
                        user.photoURL == null
                            ? Icon(Icons.person, size: 40, color: Colors.white)
                            : null,
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                ),

                // Common navigation items for all users
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.main);
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('My Profile'),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    // Profile is typically accessed from the main screen
                  },
                ),

                // Customer-specific navigation items
                if (userType == 'customer') ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('My Appointments'),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to customer appointments screen
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.content_cut),
                    title: const Text('Book Appointment'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.bookAppointment);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.favorite),
                    title: const Text('Favorite Barbers'),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to favorite barbers screen
                    },
                  ),
                ],

                // Barber-specific navigation items
                if (userType == 'barber') ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Manage Appointments'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        AppRoutes.barberAppointments,
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.schedule),
                    title: const Text('My Schedule'),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to barber schedule screen
                    },
                  ),
                ],

                // Barbershop owner-specific navigation items
                if (userType == 'barbershop_owner') ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.store),
                    title: const Text('My Barbershop'),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to barbershop management screen
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text('Manage Barbers'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.barberApproval);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.content_cut),
                    title: const Text('Manage Services'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        AppRoutes.manageServices,
                        arguments: {
                          'barbershopId': 'current_barbershop_id',
                        }, // Replace with actual ID
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.analytics),
                    title: const Text('Analytics'),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to analytics screen
                    },
                  ),
                ],

                const Divider(),

                // Settings for all users
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to settings screen
                  },
                ),

                // Help & Support for all users
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Help & Support'),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to help screen
                  },
                ),

                const Divider(),

                // Logout for all users
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // Show logout confirmation dialog
                    _showLogoutConfirmationDialog(context);
                  },
                ),
              ],
            ),
          );
        }

        // Show a loading indicator if the profile is not loaded yet
        return const Drawer(child: Center(child: CircularProgressIndicator()));
      },
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Dispatch logout event to both blocs
                  BlocProvider.of<ProfileBloc>(
                    context,
                  ).add(const ProfileSignOutRequested());

                  // Navigate to welcome screen
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.welcome,
                    (route) => false,
                  );
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
