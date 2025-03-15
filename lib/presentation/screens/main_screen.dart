import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/custom_navigation_drawer.dart';
import '../widgets/custom_bottom_navigation.dart';
import '../../logic/blocs/profile/profile_bloc.dart';
import '../../logic/blocs/profile/profile_state.dart';
import '../../logic/blocs/profile/profile_event.dart';
import '../../logic/blocs/auth/auth_bloc.dart';
import '../../logic/blocs/auth/auth_state.dart';
import '../../routes.dart';
import 'map/barbershop_map_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'appointments/appointments_screen.dart';
import 'barber/barber_appointments_screen.dart';
import 'barber/barber_schedule_screen.dart';
import 'barbershop/barbershop_management_screen.dart';
import 'barbershop/barber_management_screen.dart';
import 'barbershop/analytics_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Ensure profile is loaded when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.read<ProfileBloc>().add(const ProfileLoadRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        // If not authenticated, show map screen with login option
        if (authState is! AuthAuthenticated) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Find Barbershops'),
              elevation: 0,
              actions: [
                TextButton.icon(
                  icon: const Icon(Icons.login, color: Colors.white),
                  label: const Text(
                    'Login',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed:
                      () => Navigator.pushNamed(context, AppRoutes.login),
                ),
              ],
            ),
            body: const BarbershopMapScreen(),
          );
        }

        // If authenticated, check profile state
        return BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            // Show loading while profile is being fetched
            if (profileState is ProfileInitial ||
                profileState is ProfileLoading) {
              return const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading your profile...'),
                    ],
                  ),
                ),
              );
            }

            // If profile is loaded, show appropriate screens based on user type
            if (profileState is ProfileLoaded) {
              final userType = profileState.userType;
              final List<Widget> screens = _getScreensForUserType(userType);

              // Ensure the selected index is valid for the current screens list
              if (_selectedIndex >= screens.length) {
                _selectedIndex = 0;
              }

              return Scaffold(
                appBar: AppBar(
                  title: _getTitleForIndex(_selectedIndex, userType),
                  elevation: 0,
                ),
                drawer: const CustomNavigationDrawer(),
                body: screens[_selectedIndex],
                bottomNavigationBar: CustomBottomNavigation(
                  currentIndex: _selectedIndex,
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
              );
            }

            // Show error state
            return const Scaffold(
              body: Center(
                child: Text('Failed to load profile. Please try again.'),
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _getScreensForUserType(String? userType) {
    // Customer screens
    if (userType == 'customer') {
      return [
        const HomeScreen(),
        const BarbershopMapScreen(),
        const AppointmentsScreen(),
        const ProfileScreen(),
      ];
    }
    // Barber screens
    else if (userType == 'barber') {
      return [
        const HomeScreen(),
        const BarberAppointmentsScreen(),
        const BarberScheduleScreen(),
        const ProfileScreen(),
      ];
    }
    // Barbershop owner screens
    else if (userType == 'barbershop_owner') {
      return [
        const HomeScreen(),
        const BarbershopManagementScreen(),
        const BarberManagementScreen(),
        const AnalyticsScreen(),
        const ProfileScreen(),
      ];
    }

    // Default screens if user type is not recognized
    return [const HomeScreen(), const ProfileScreen()];
  }

  Widget _getTitleForIndex(int index, String? userType) {
    // Customer titles
    if (userType == 'customer') {
      switch (index) {
        case 0:
          return const Text('Home');
        case 1:
          return const Text('Explore');
        case 2:
          return const Text('Appointments');
        case 3:
          return const Text('Profile');
        default:
          return const Text('Barberdule');
      }
    }
    // Barber titles
    else if (userType == 'barber') {
      switch (index) {
        case 0:
          return const Text('Home');
        case 1:
          return const Text('My Appointments');
        case 2:
          return const Text('My Schedule');
        case 3:
          return const Text('Profile');
        default:
          return const Text('Barberdule');
      }
    }
    // Barbershop owner titles
    else if (userType == 'barbershop_owner') {
      switch (index) {
        case 0:
          return const Text('Home');
        case 1:
          return const Text('My Barbershop');
        case 2:
          return const Text('Manage Barbers');
        case 3:
          return const Text('Analytics');
        case 4:
          return const Text('Profile');
        default:
          return const Text('Barberdule');
      }
    }

    // Default titles
    switch (index) {
      case 0:
        return const Text('Home');
      case 1:
        return const Text('Profile');
      default:
        return const Text('Barberdule');
    }
  }
}
