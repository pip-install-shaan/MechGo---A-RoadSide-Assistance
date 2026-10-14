import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mech_go/Mechanic/MechanicProfile/mech_profile_bloc.dart';
import 'package:mech_go/Mechanic/MechanicProfile/mech_profile_event.dart';
import 'package:mech_go/Mechanic/MechanicProfile/mech_profile_state.dart';
import 'package:mech_go/Services/theme_controller.dart';
import 'package:mech_go/User/Support/help_support_user.dart';
import 'package:mech_go/User/UserAccount/u_login.dart';


class MechanicProfile extends StatelessWidget {
  const MechanicProfile({super.key});

  final Color primaryRed =
      const Color.fromARGB(255, 198, 24, 11);

  @override
  Widget build(BuildContext context) {
    return BlocListener<MechanicProfileBloc,
        MechanicProfileState>(
      listener: (context, state) {
        if (state.status ==
            MechanicProfileStatus.updateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Profile updated successfully',
              ),
            ),
          );
        }

        if (state.status ==
            MechanicProfileStatus.logoutSuccess) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const UserLogin(),
            ),
            (route) => false,
          );
        }

        if (state.status ==
            MechanicProfileStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ??
                    'Something went wrong.',
              ),
            ),
          );
        }
      },
      child: BlocBuilder<MechanicProfileBloc,
          MechanicProfileState>(
        builder: (context, state) {
          if (state.status ==
              MechanicProfileStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.status ==
                  MechanicProfileStatus.failure &&
              state.name.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Unable to load profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage ??
                        'Unable to load profile.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<MechanicProfileBloc>()
                          .add(
                            const FetchMechanicProfile(),
                          );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryRed,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return _profileContent(
            context,
            state,
          );
        },
      ),
    );
  }

  Widget _profileContent(
    BuildContext context,
    MechanicProfileState state,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 30),

          _profileHeader(state),

          const SizedBox(height: 30),

          _menuItem(
            icon: Icons.edit,
            title: 'Edit Profile',
            onTap: () {
              _showEditProfileDialog(
                context,
                state,
              );
            },
          ),

          _menuItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HelpSupportUser(),
                ),
              );
            },
          ),

          _menuItem(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            onTap: () {
              ThemeController.instance.toggleTheme();
            },
          ),

          _menuItem(
            icon: Icons.person,
            title: 'User Mode',
            onTap: () {
              _switchToUserMode(context);
            },
          ),

          _menuItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _profileHeader(
    MechanicProfileState state,
  ) {
    ImageProvider imageProvider;

    if (state.profilePic.isNotEmpty) {
      imageProvider =
          NetworkImage(state.profilePic);
    } else {
      imageProvider = const AssetImage(
        'assets/login_cover.jpg',
      );
    }

    final ratingText = state.reviewCount > 0
        ? '${state.rating.toStringAsFixed(1)} - '
            '${state.reviewCount} Reviews'
        : 'No reviews yet';

    return Column(
      children: [
        CircleAvatar(
          radius: 55,
          backgroundImage: imageProvider,
        ),

        const SizedBox(height: 15),

        Text(
          state.workshopName.isNotEmpty
              ? state.workshopName
              : state.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          state.specialization.isNotEmpty
              ? state.specialization
              : 'Mechanic',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          ratingText,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          state.email,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: primaryRed,
      ),
      title: Text(title),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  void _switchToUserMode(
    BuildContext context,
  ) {
    context
        .read<MechanicProfileBloc>()
        .add(
          const LogoutMechanic(),
        );
  }
 

 Future<void> _showEditProfileDialog(
  BuildContext context,
  MechanicProfileState state,
) async {
  final nameController =
      TextEditingController(text: state.name);

  final workshopController =
      TextEditingController(
    text: state.workshopName,
  );

  final specializationController =
      TextEditingController(
    text: state.specialization,
  );

  File? selectedImage;

  final picker = ImagePicker();

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          ImageProvider imageProvider;

          if (selectedImage != null) {
            imageProvider =
                FileImage(selectedImage!);
          } else if (state.profilePic.isNotEmpty) {
            imageProvider =
                NetworkImage(state.profilePic);
          } else {
            imageProvider = const AssetImage(
              'assets/login_cover.jpg',
            );
          }

          return AlertDialog(
            title: const Text('Edit Profile'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: imageProvider,
                  ),

                  const SizedBox(height: 10),

                  TextButton.icon(
                    onPressed: () async {
                      final image =
                          await picker.pickImage(
                        source: ImageSource.gallery,
                      );

                      if (image != null) {
                        setDialogState(() {
                          selectedImage =
                              File(image.path);
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.camera_alt,
                    ),
                    label: const Text(
                      'Change Photo',
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(
                      labelText: 'Name',
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: workshopController,
                    decoration:
                        const InputDecoration(
                      labelText: 'Workshop Name',
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller:
                        specializationController,
                    decoration:
                        const InputDecoration(
                      labelText: 'Specialization',
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    enabled: false,
                    controller: TextEditingController(
                      text: state.email,
                    ),
                    decoration:
                        const InputDecoration(
                      labelText: 'Email',
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    enabled: false,
                    controller: TextEditingController(
                      text: state.phone,
                    ),
                    decoration:
                        const InputDecoration(
                      labelText: 'Phone',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Cancel'),
              ),

              ElevatedButton(
                onPressed: () {
                  if (nameController.text
                      .trim()
                      .isEmpty) {
                    return;
                  }

                  context
                      .read<MechanicProfileBloc>()
                      .add(
                        UpdateMechanicProfile(
                          name:
                              nameController.text,
                          workshopName:
                              workshopController
                                  .text,
                          specialization:
                              specializationController
                                  .text,
                          profileImage:
                              selectedImage,
                        ),
                      );

                  Navigator.pop(dialogContext);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );

  nameController.dispose();
  workshopController.dispose();
  specializationController.dispose();
}
  void _showLogoutDialog(
    BuildContext context,
  ) {
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
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                context
                    .read<MechanicProfileBloc>()
                    .add(
                      const LogoutMechanic(),
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}