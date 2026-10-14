import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mech_go/Mechanic/MechanicAccount/m_login.dart';
import 'package:mech_go/Services/theme_controller.dart';

import 'package:mech_go/User/UserProfile/user_profile.state.dart';
import 'package:mech_go/User/UserProfile/user_profile_bloc.dart';
import 'package:mech_go/User/UserProfile/user_profile_event.dart';

import 'package:mech_go/User/Support/help_support_user.dart';
import 'package:mech_go/User/UserAccount/u_login.dart';
import 'package:mech_go/User/UserNotifications/user_notification.dart';
import 'package:mech_go/User/Payment/user_payment_method.dart';
import 'package:mech_go/about_mech_go.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final Color primaryRed =
      const Color.fromARGB(255, 198, 24, 11);


bool darkClicked=false;

void toggleDarkMode(){
                                setState(() {
                                darkClicked=!darkClicked;
                              });
                              }

  final List<Map<String, dynamic>> menuItems = [
    {
      'icon': Icons.edit,
      'title': 'Edit Profile',
    },
    {
      'icon': Icons.credit_card,
      'title': 'Payment Methods',
    },
    {
      'icon': Icons.notifications_none,
      'title': 'Notifications',
    },
    {
      'icon': Icons.help_outline,
      'title': 'Help & Support',
    },
    {
      'icon': Icons.info_outline,
      'title': 'About MechGo',
    },
  ];

  // ==========================================================
  // EDIT PROFILE
  // ==========================================================

  void updateProfile() {
    final user =
        context.read<UserProfileBloc>().state.user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'User profile is still loading.',
          ),
        ),
      );
      return;
    }

    final nameController =
        TextEditingController(text: user.name);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Center(
            child: Text(
              'Update Profile',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                      user.profilePic.trim().isNotEmpty
                          ? NetworkImage(user.profilePic)
                          : null,
                  child:
                      user.profilePic.trim().isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 45,
                            )
                          : null,
                ),

                const SizedBox(height: 25),

                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter Profile Name',
                    prefixIcon:
                        const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryRed,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      final newName =
                          nameController.text.trim();

                      if (newName.isEmpty) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Name cannot be empty.',
                            ),
                          ),
                        );
                        return;
                      }

                      context
                          .read<UserProfileBloc>()
                          .add(
                            UpdateUserProfile(
                              name: newName,
                              profilePic:
                                  user.profilePic,
                            ),
                          );

                      Navigator.pop(dialogContext);
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  // ==========================================================
  // PAYMENT CONFIRMATION
  // ==========================================================

  void _confirmCompleteTask() {
    final paymentRequest = context.read<UserProfileBloc>()
        .state
        .completedPaymentRequest;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Center(
            child: Text(
              'Confirm Deal',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Does mechanic have completed his work?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontFamily: 'Times New Roman',
                    fontSize:
                        MediaQuery.of(context)
                                .size
                                .height *
                            0.02,
                  ),
                ),

                const SizedBox(height: 25),

                Row(
                  children: [
                    // NO
                    Expanded(
                      child: SizedBox(
                        height: 45,
                        child: ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                primaryRed,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                      12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(
                                dialogContext);

                            ScaffoldMessenger.of(
                                    context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Without work done, payment cannot proceed.',
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'No',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // YES
                    Expanded(
                      child: SizedBox(
                        height: 45,
                        child: ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                primaryRed,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                      12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(
                                dialogContext);

                            if (paymentRequest ==
                                null) {
                              ScaffoldMessenger.of(
                                      context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'No completed task found.',
                                  ),
                                ),
                              );
                              return;
                            }

                            if (paymentRequest
                                .mechanicId
                                .isEmpty) {
                              ScaffoldMessenger.of(
                                      context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Mechanic information is missing.',
                                  ),
                                ),
                              );
                              return;
                            }

                            if (paymentRequest
                                    .amount <=
                                0) {
                              ScaffoldMessenger.of(
                                      context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Payment amount is not available.',
                                  ),
                                ),
                              );
                              return;
                            }
                            
                           
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    UserPaymentMethod(
                                  requestId:
                                      paymentRequest
                                          .requestId,
                                  mechanicId:
                                      paymentRequest
                                          .mechanicId,
                                  mechanicName:
                                      paymentRequest
                                          .mechanicName,
                                  amount:
                                      paymentRequest
                                          .amount,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'Yes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================

  void _logout() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                try {
                  await FirebaseAuth.instance
                      .signOut();

                  if (!mounted) return;

                  Navigator.of(context)
                      .pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) =>
                          const UserLogin(),
                    ),
                    (route) => false,
                  );
                } catch (e) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    SnackBar(
                      content:
                          Text('Logout failed: $e'),
                    ),
                  );
                }
              },
              child: Text(
                'Logout',
                style: TextStyle(
                  color: primaryRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkClicked ? Colors.black : Colors.white,
      body: Container(
        decoration: BoxDecoration(
          color: darkClicked ? Colors.black : Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            BlocBuilder<UserProfileBloc,
                UserProfileState>(
              builder: (context, state) {
                final user = state.user;

                if (state.status ==
                    UserProfileStatus.loading) {
                  return Container(
                    height: 130,
                    color: primaryRed,
                    child: const Center(
                      child:
                          CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  );
                }

                if (user == null) {
                  return Container(
                    height: 130,
                    color: primaryRed,
                    child: const Center(
                      child: Text(
                        'Unable to load profile',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }

                return Container(
                  color: primaryRed,
                  padding: const EdgeInsets.only(
                    left: 10,
                    top: 17,
                    right: 5,
                    bottom: 15,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor:
                            Colors.white,
                        backgroundImage:
                            user.profilePic
                                    .trim()
                                    .isNotEmpty
                                ? NetworkImage(
                                    user.profilePic,
                                  )
                                : null,
                        child: user.profilePic
                                .trim()
                                .isEmpty
                            ? Icon(
                                Icons.person,
                                size: 35,
                                color: primaryRed,
                              )
                            : null,
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name.isEmpty
                                  ? 'User'
                                  : user.name,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              user.phone,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              user.email,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                        ),
                        onSelected: (value) {
                          if (value == 'logout') {
                            _logout();
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.logout,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 8),
                                Text('Logout'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: menuItems.length,
                      itemBuilder:
                          (context, index) {
                        return _buildMenuItem(
                          context,
                          index,
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(
                      left: 18,
                      right: 18,
                      bottom: 15,
                      top: 8,
                    ),
                    child: Column(
                      children: [
                        const Divider(
                          color: Colors.black12,
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: TextButton.icon(
                            onPressed: _logout,
                            icon: Icon(
                              Icons.logout,
                              color: primaryRed,
                              size: 21,
                            ),
                            label: Text(
                              'Logout',
                              style: TextStyle(
                                color: primaryRed,
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            style:
                                TextButton.styleFrom(
                              side: BorderSide(
                                color: primaryRed
                                    .withOpacity(0.2),
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                        8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),           
                   Padding(
                    padding: const EdgeInsets.only(
                      left: 18,
                      right: 18,
                      bottom: 15,
                      top: 8,
                    ),
                    child: Column(
                      children: [
                        const Divider(
                          color: Colors.black12,
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: TextButton.icon(
                            onPressed: (){
                               _switchToMechanicMode(context);
                            },
                            icon: Icon(
                              Icons.lightbulb,
                              color: Colors.white,
                              size: 29,
                            ),
                            label: Text(
                              'Mechanic Mode',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            style:
                                TextButton.styleFrom(
                                  backgroundColor: primaryRed,
                              side: BorderSide(
                                color: primaryRed
                                    .withOpacity(0.2),
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                        8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            Padding(
                    padding: const EdgeInsets.only(
                      left: 18,
                      right: 18,
                      bottom: 15,
                      top: 8,
                    ),
                    child: Column(
                      children: [
                        const Divider(
                          color: Colors.black12,
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: TextButton.icon(
                            onPressed: () {
                              toggleDarkMode();
  ThemeController.instance.toggleTheme();
},
icon: ValueListenableBuilder<ThemeMode>(
  valueListenable:
      ThemeController.instance.themeMode,
  builder: (context, mode, child) {
    return Icon(
      mode == ThemeMode.dark
          ? Icons.light_mode
          : Icons.dark_mode,
      color: primaryRed,
      size: 29,
    );
  },
),
label: ValueListenableBuilder<ThemeMode>(
  valueListenable:
      ThemeController.instance.themeMode,
  builder: (context, mode, child) {
    return Text(
      mode == ThemeMode.dark
          ? 'Light Mode'
          : 'Dark Mode',
      style: TextStyle(
        color: primaryRed,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  },
),
                         
                            style:
                                TextButton.styleFrom(
                              side: BorderSide(
                                color: primaryRed
                                    .withOpacity(0.2),
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                        8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // MENU ITEM
  // ==========================================================
  

void _switchToMechanicMode(BuildContext context) {
  context.read<UserProfileBloc>().add(
        const LogoutUser(),
      );

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) => const MechanicLogin(),
    ),
    (route) => false,
  );
}

  Widget _buildMenuItem(
    BuildContext context,
    int index,
  ) {
    final item = menuItems[index];
    
    final textColor=darkClicked ? Colors.white : Colors.black87;
    final iconColor= darkClicked ? Colors.white70 : Colors.black54;

    return InkWell(
      onTap: () {
        switch (index) {
          case 0:
            updateProfile();
            break;

          case 1:
           _confirmCompleteTask();
            break;

          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const UserNotification(),
              ),
            );
            break;

          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const HelpSupportUser(),
              ),
            );
            break;

          case 4:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const AboutMechGo(),
              ),
            );
            break;
        }
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 11,
            ),
            child: Row(
              children: [
                Icon(
                  item['icon'],
                  color: iconColor,
                  size: 21,
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Text(
                    item['title'],
                    style:  TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),

                 Icon(
                  Icons.chevron_right,
                  color: iconColor,
                  size: 23,
                ),
              ],
            ),
          ),

           Divider(
            height: 1,
            thickness: 0.5,
            color: darkClicked ? Colors.white24 : Colors.black12,
          ),
        ],
      ),
    );
  }
}