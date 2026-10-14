import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mech_go/Mechanic/Earnings/earning_bloc.dart';
import 'package:mech_go/Mechanic/Earnings/earning_event.dart';
import 'package:mech_go/Mechanic/Earnings/earning_repo.dart';
import 'package:mech_go/Mechanic/Earnings/m_earnings.dart';
import 'package:mech_go/Mechanic/MechanicProfile/m_profile.dart';
import 'package:mech_go/Mechanic/MechanicProfile/mech_profile_bloc.dart';
import 'package:mech_go/Mechanic/MechanicProfile/mech_profile_event.dart';
import 'package:mech_go/Mechanic/MechanicProfile/mech_profile_repo.dart';

import 'package:mech_go/Mechanic/MechanicRequests/m_requests.dart';
import 'package:mech_go/Mechanic/MechanicRequests/mech_request_bloc.dart';
import 'package:mech_go/Mechanic/MechanicRequests/mech_requests_repo.dart';
import 'package:mech_go/Mechanic/mechanic_homescreen.dart';


class MechanicMain extends StatefulWidget {
  const MechanicMain({super.key});

  @override
  State<MechanicMain> createState() => _MechanicMainState();
}

class _MechanicMainState extends State<MechanicMain> {
  final Color primaryRed =
      const Color.fromARGB(255, 198, 24, 11);

  int selectedIndex = 0;

  // --------------------------------------------------------------------------
  // SELECTED SCREEN
  // --------------------------------------------------------------------------

  Widget _buildSelectedScreenMech() {
    switch (selectedIndex) {
      case 0:
        return MechanicHomeScreen(
          onViewAllRequests: () {
            setState(() {
              selectedIndex = 1;
            });
          },
        );

      case 1:
        return const MechanicRequests();

      case 2:
        return const MechanicEarnings();

      case 3:
        return const MechanicProfile();

      default:
        return MechanicHomeScreen(
          onViewAllRequests: () {
            setState(() {
              selectedIndex = 1;
            });
          },
        );
    }
  }

  // --------------------------------------------------------------------------
  // BUILD
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
  providers: [
    BlocProvider<MechRequestsBloc>(
      create: (_) => MechRequestsBloc(
        repository: MechRequestsRepository(),
      ),
    ),

    BlocProvider<MechanicEarningsBloc>(
      create: (_) => MechanicEarningsBloc(
        repository: MechanicEarningsRepository(),
      )..add(
          const WatchMechanicEarnings(),
        ),
    ),
    BlocProvider<MechanicProfileBloc>(
  create: (_) => MechanicProfileBloc(
    repository: MechanicProfileRepository(),
  )..add(
      const FetchMechanicProfile(),
    ),
),

  ],

      child: Scaffold(
        body: _buildSelectedScreenMech(),

        // --------------------------------------------------------------------
        // BOTTOM NAVIGATION
        // --------------------------------------------------------------------

        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: primaryRed,

          currentIndex: selectedIndex,

          type: BottomNavigationBarType.fixed,

          selectedItemColor: Colors.white,

          unselectedItemColor: Colors.white54,

          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'Requests',
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.account_balance_wallet,
              ),
              label: 'Earnings',
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