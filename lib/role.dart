import 'package:flutter/material.dart';
import 'package:mech_go/Admin/a_login.dart';
import 'package:mech_go/Mechanic/MechanicAccount/m_login.dart';
import 'package:mech_go/User/UserAccount/u_login.dart';

class Role extends StatefulWidget {
  const Role({super.key});

  @override
  State<Role> createState() => _RoleState();
}

class _RoleState extends State<Role> {
  int selectedIndex=0;

  final Color primaryRed =
      const Color.fromARGB(255, 198, 24, 11);

  final List<Widget> roles = [
    const UserLogin(),
    const MechanicLogin(),
    const AdminLogin(),
  ];

  // Role information
  final List<Map<String, dynamic>> roleDetails = [
    {
      'icon': Icons.person,
      'tagline': 'I am a User',
      'subtitle': 'Need help for my vehicle',
      
    },
    {
      'icon': Icons.settings,
      'tagline': 'I am a Mechanic',
      'subtitle': 'I want to help People',
    },
    {
      'icon': Icons.admin_panel_settings,
      'tagline': 'I am an Admin',
      'subtitle': 'Manage and Oversee',
    },
  ];

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body:Stack(
        children: [
          Positioned.fill(
            child: Opacity(opacity: 
            0.28, child: Image.asset('assets/login_cover.jpg', fit: BoxFit.cover,),)),
          Positioned.fill(child: Container(
            color: Colors.white.withOpacity(0.32),
          )),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
          
              child: Column(
                children: [
          
                  SizedBox(
                    height: size.height * 0.1,
                  ),
          
                  // Heading
                  Text(
                    'Select your Role',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: size.height * 0.032,
                    ),
                  ),
          
                  const SizedBox(height: 5),
          
                  // Subtitle
                  const Text(
                    'Choose how you want to continue',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Times New Roman',
                      fontSize: 15,
                    ),
                  ),
          
                  SizedBox(
                    height: size.height * 0.1,
                  ),
          
                  // Role List
                  Expanded(
                    child: ListView.builder(
                      itemCount: roleDetails.length,
          
                      itemBuilder: (context, index) {
                      bool isSelected=selectedIndex==index;
          
                        return GestureDetector(
                          onTap: () {
                           setState(() {
                             selectedIndex=index;
                           });
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => roles[index],
                              ),
                            );
          
                          },
          
                          child: Container(
                            width: double.infinity,
                            height: size.height * 0.09,
                          
                            margin: const EdgeInsets.only(
                              bottom: 20,
                            ),
                          
                            decoration: BoxDecoration(
                              color: isSelected ? const Color.fromARGB(255, 198, 24, 11)
                              : Colors.white,
                              borderRadius: BorderRadius.circular(11),
                          
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 15,
                                  offset: Offset(3, 7),
                                ),
                              ],
                            ),
                          
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                          
                              child: Row(
                                children: [
                          
                                  // Icon
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: isSelected ? Colors.white : Colors.black,
                          
                                    child: Icon(
                                      roleDetails[index]['icon'],
                                      color: isSelected ? Colors.black : Colors.white,
                                      size: 30,
                                    ),
                                  ),
                          
                                  const SizedBox(width: 20),
                          
                                  // Text section
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                          
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                          
                                      children: [
                          
                                        // Role title
                                        Text(
                                          roleDetails[index]['tagline'],
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                          ),
                                        ),
                          
                                        const SizedBox(height: 3),
                          
                                        // Role description
                                        Text(
                                          roleDetails[index]['subtitle'],
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.black,
                                            fontFamily: 'Times New Roman',
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          
                                  // Arrow
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: isSelected ? Colors.white : Colors.black,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]
      ),
    );
  }
}