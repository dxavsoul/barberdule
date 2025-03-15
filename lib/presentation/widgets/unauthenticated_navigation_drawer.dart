import 'package:flutter/material.dart';
import '../../routes.dart';

class UnauthenticatedNavigationDrawer extends StatelessWidget {
  const UnauthenticatedNavigationDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text(
                  'Barberdule',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Find and book your next haircut',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Find Barbershops'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to main screen with map tab selected
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.main,
                (route) => false,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('Login'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.login);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Register'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.registrationChoice);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              // Show about dialog
              showAboutDialog(
                context: context,
                applicationName: 'Barberdule',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.content_cut),
                applicationLegalese: '© 2023 Barberdule',
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Barberdule is a platform that connects customers with barbershops and barbers for easy appointment booking.',
                  ),
                ],
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to help screen or show help dialog
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Help & Support'),
                      content: const Text(
                        'For any questions or issues, please contact us at support@barberdule.com',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
    );
  }
}
