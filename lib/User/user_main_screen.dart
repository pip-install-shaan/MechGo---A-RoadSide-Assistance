import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mech_go/User/UserRequests/request_model.dart';

import 'package:mech_go/User/user_home_screen.dart';
import 'package:mech_go/User/UserRequests/user_request.dart';
import 'package:mech_go/User/UserProfile/user_profile.dart';
import 'package:mech_go/User/Chat/request_chat_screen.dart';

// Request BLoC
import 'package:mech_go/User/UserRequests/request_bloc.dart';
import 'package:mech_go/User/UserRequests/request_repo.dart';

// Request events
import 'package:mech_go/User/UserRequests/request_event.dart';

// User Profile BLoC
import 'package:mech_go/User/UserProfile/user_profile_bloc.dart';
import 'package:mech_go/User/UserProfile/user_profile_repo.dart';
import 'package:mech_go/User/UserProfile/user_profile_event.dart';

class UserMain extends StatefulWidget {
  const UserMain({super.key});

  @override
  State<UserMain> createState() => _UserMainState();
}

class _UserMainState extends State<UserMain> {
  final Color primaryRed =
      const Color.fromARGB(255, 198, 24, 11);

  int selectedIndex = 0;

  RequestModel? acceptedRequest;

  Widget _buildSelectedScreen() {
    switch (selectedIndex) {
      case 0:
  return UserHomeScreen(
    onViewAllRequests: () {
      setState(() {
        selectedIndex = 1;
      });
    },
  );

      case 1:
        return const UserRequest();

      case 2:
        return RequestChatScreen(
          requestId:acceptedRequest!.requestId,
        mechanicId: acceptedRequest!.mechanicId,
        mechanicName: acceptedRequest!.mechanicName,
        mechanicPhone: acceptedRequest!.mechanicPhone,
        mechanicProfilePic: acceptedRequest!.mechanicProfilePic,
        );

      case 3:
        return const UserProfile();

      default:
        return const UserHomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ======================================================
        // USER PROFILE BLOC
        // ======================================================

        BlocProvider<UserProfileBloc>(
          create: (_) => UserProfileBloc(
            repository: UserProfileRepository(),
          )..add(
              const FetchUserProfile(),
            ),
        ),

        // ======================================================
        // REQUEST BLOC
        // ======================================================

        BlocProvider<RequestBloc>(
          create: (_) => RequestBloc(
            requestRepository: RequestRepository(),
          )..add(
              const WatchMyRequests(),
            ),
        ),
      ],

      child: Scaffold(
        body: _buildSelectedScreen(),

        bottomNavigationBar:
            BottomNavigationBar(
          backgroundColor: primaryRed,

          currentIndex: selectedIndex,

          type:
              BottomNavigationBarType.fixed,

          selectedItemColor:
              Colors.white,

          unselectedItemColor:
              Colors.white54,

          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },

          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              label: 'Home',
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.assignment,
              ),
              label: 'Requests',
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.chat_bubble_outline,
              ),
              label: 'Chat',
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.person_outline,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}