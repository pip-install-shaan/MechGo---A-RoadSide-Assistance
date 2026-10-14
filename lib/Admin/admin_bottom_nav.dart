import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mech_go/Admin/Admin_Authentication/admin_event.dart';

import 'package:mech_go/Admin/a_mechanic.dart';
import 'package:mech_go/Admin/a_requests.dart';
import 'package:mech_go/Admin/a_users.dart';
import 'package:mech_go/Admin/admin_dashboard.dart';

import 'package:mech_go/Admin/Admin_Authentication/admin_bloc.dart';
import 'package:mech_go/Admin/Admin_Authentication/admin_repo.dart';
import 'package:mech_go/Admin/admin_drawer.dart';

class AdminBottomNav extends StatefulWidget {
  const AdminBottomNav({super.key});

  @override
  State<AdminBottomNav> createState() => _AdminBottomNavState();
}

class _AdminBottomNavState extends State<AdminBottomNav> {
  int _selectedIndex = 0;
  
  final GlobalKey<ScaffoldState> _adminScaffoldKey=GlobalKey<ScaffoldState>();

  late final List<Widget> _pages;


  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  

  void _openDrawer() {
  _adminScaffoldKey.currentState?.openDrawer();
}

  @override
  void initState(){
    super.initState();
    _pages=[
      AdminDashboard(
        onMenuPressed: _openDrawer,
      ),
      const AdminRequests(),
      const MechanicOnAdmin(),
      const UserOnAdmin()
    ];
  }
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminBloc(
        adminRepository: AdminRepository(),

      )..add(
        const LoadAdminDashboard(),
      ),
      child: Scaffold(
        key: _adminScaffoldKey,
        drawer: AdminDrawer(onNavigate: _navigateBottomBar),
        body: _pages[_selectedIndex],

        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color.fromARGB(
            255,
            197,
            17,
            4,
          ),

          currentIndex: _selectedIndex,

          onTap: _navigateBottomBar,

          type: BottomNavigationBarType.fixed,

          selectedItemColor: Colors.white,

          unselectedItemColor: Colors.grey,

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Request',
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.build_outlined),
              activeIcon: Icon(Icons.build),
              label: 'Mechanics',
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Users',
            ),
          ],
        ),
      ),
    );
  }
}