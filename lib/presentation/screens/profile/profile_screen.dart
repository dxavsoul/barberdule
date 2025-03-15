import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:barberdule/data/repository/auth_repository.dart';
import 'package:barberdule/data/repository/user_repository.dart';
import 'package:barberdule/logic/blocs/profile/profile_bloc.dart';
import 'package:barberdule/logic/blocs/profile/profile_event.dart';
import 'package:barberdule/logic/blocs/profile/profile_state.dart';
import 'package:barberdule/routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => ProfileBloc(
            authRepository: RepositoryProvider.of<AuthRepository>(context),
            userRepository: RepositoryProvider.of<UserRepository>(context),
          )..add(const ProfileLoadRequested()),
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ProfileUpdateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to update profile: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ProfileSignOutSuccess) {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          } else if (state is ProfileSignOutFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to sign out: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is ProfileLoaded) {
            final user = state.user;
            return Scaffold(
              appBar: AppBar(title: const Text('My Profile')),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // Profile Image
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage:
                          user.photoURL != null
                              ? NetworkImage(user.photoURL!)
                              : null,
                      child:
                          user.photoURL == null
                              ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey,
                              )
                              : null,
                    ),

                    const SizedBox(height: 20),

                    // User Name
                    Text(
                      user.displayName ?? 'Guest User',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // User Email
                    Text(
                      user.email ?? 'No email',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    if (state.phoneNumber != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        state.phoneNumber!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],

                    if (state.bio != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          state.bio!,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],

                    const SizedBox(height: 30),

                    // Profile Options
                    _buildProfileOption(
                      icon: Icons.person,
                      title: 'Edit Profile',
                      onTap: () {
                        _showEditProfileDialog(context, state);
                      },
                    ),

                    // Add option for barbers to manage appointments
                    if (state.userType == 'barber')
                      _buildProfileOption(
                        icon: Icons.calendar_today,
                        title: 'Manage Appointments',
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.barberAppointments,
                          );
                        },
                      ),

                    _buildProfileOption(
                      icon: Icons.history,
                      title: 'Appointment History',
                      onTap: () {
                        // Navigate to appointment history screen
                      },
                    ),

                    _buildProfileOption(
                      icon: Icons.favorite,
                      title: 'Favorite Barbers',
                      onTap: () {
                        // Navigate to favorite barbers screen
                      },
                    ),

                    _buildProfileOption(
                      icon: Icons.settings,
                      title: 'Settings',
                      onTap: () {
                        // Navigate to settings screen
                      },
                    ),

                    const SizedBox(height: 20),

                    // Logout Button
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<ProfileBloc>().add(
                          const ProfileSignOutRequested(),
                        );
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Default or error state
          return Scaffold(
            appBar: AppBar(title: const Text('My Profile')),
            body: const Center(
              child: Text('Failed to load profile. Please try again.'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showEditProfileDialog(BuildContext context, ProfileLoaded state) {
    final nameController = TextEditingController(text: state.user.displayName);
    final phoneController = TextEditingController(text: state.phoneNumber);
    final bioController = TextEditingController(text: state.bio);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: bioController,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<ProfileBloc>().add(
                  ProfileUpdateRequested(
                    displayName: nameController.text,
                    phoneNumber: phoneController.text,
                    bio: bioController.text,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
