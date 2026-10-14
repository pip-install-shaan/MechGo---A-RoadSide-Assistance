import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mech_go/Admin/Notifications/admin_notify.dart';
import 'package:mech_go/OTP/auth_bloc.dart';
import 'package:mech_go/OTP/auth_event.dart';
import 'package:mech_go/Services/theme_controller.dart';

class AdminDrawer extends StatelessWidget {
  final Function(int) onNavigate;

  const AdminDrawer({
    super.key,
    required this.onNavigate,
  });

final Color primaryRed =
      const Color.fromARGB(255, 198, 24, 11);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Drawer(
      backgroundColor: Colors.white,

      child: SafeArea(
        child: Column(
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 25,
                horizontal: 20,
              ),
              child: Column(
                children: [

                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black,
                        width: 3,
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.admin_panel_settings,
                        size: 65,
                        color: Color.fromARGB(255, 208, 21, 7),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Admin',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Times New Roman',
                      fontWeight: FontWeight.bold,
                      fontSize: size.height * 0.027,
                    ),
                  ),

                  const SizedBox(height: 3),

                  const Text(
                    'Mech Go Administration',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(
              color: Colors.black,
              thickness: 1.5,
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [

                  // DASHBOARD
                  _drawerItem(
                    context: context,
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    onTap: () {
                      Navigator.pop(context);
                      onNavigate(0);
                    },
                  ),

                  // USERS
                  _drawerItem(
                    context: context,
                    icon: Icons.people,
                    title: 'Users',
                    onTap: () {
                      Navigator.pop(context);
                      onNavigate(3);
                    },
                  ),

                  // MECHANICS
                  _drawerItem(
                    context: context,
                    icon: Icons.build,
                    title: 'Mechanics',
                    onTap: () {
                      Navigator.pop(context);
                      onNavigate(2);
                    },
                  ),

                  // REQUESTS
                  _drawerItem(
                    context: context,
                    icon: Icons.assignment,
                    title: 'Requests',
                    onTap: () {
                      Navigator.pop(context);
                      onNavigate(1);
                    },
                  ),

                  const Divider(
                    color: Colors.black26,
                  ),

                  // NOTIFICATIONS
                  _drawerItem(
                    context: context,
                    icon: Icons.notifications,
                    title: 'Notifications',
                    onTap: () {
                      Navigator.push(context, 
                      MaterialPageRoute(builder: 
                      (context)=>AdminNotification()));

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Here is new Notification for you.',
                          ),
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(
                    width: size.width*0.4,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                      ),
                      onPressed: (){
                      ThemeController.instance.toggleTheme();
                    }, 
                    child: Text('Dark Mode',style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Times New Roman',
                      fontSize: size.height*0.02,
                      fontWeight: FontWeight.bold,
                    ),)),
                  )
                ],
              ),
            ),

            // =========================================
            // LOGOUT
            // =========================================

            const Divider(
              color: Colors.black,
              thickness: 1.5,
            ),

            _drawerItem(
              context: context,
              icon: Icons.logout,
              title: 'Logout',
              iconColor: Colors.red,
              textColor: Colors.red,
              onTap: () {
                _showLogoutDialog(context);
              },
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // =========================================
  // DRAWER ITEM
  // =========================================

  Widget _drawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.black,
    Color textColor = Colors.black,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),

      leading: Icon(
        icon,
        color: iconColor,
        size: 28,
      ),

      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Times New Roman',
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),

      onTap: onTap,
    );
  }


  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Logout',
          ),

          content: const Text(
            'Are you sure you want to logout?',
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
context.read<AuthBloc>().add(
    const LogoutRequested(),
  );

              },
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}