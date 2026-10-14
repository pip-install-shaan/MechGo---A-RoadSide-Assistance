import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mech_go/Admin/Admin_Authentication/admin_bloc.dart';
import 'package:mech_go/Admin/Admin_Authentication/admin_state.dart';
import 'package:mech_go/Admin/Notifications/admin_notify.dart';
import 'package:mech_go/Admin/a_login.dart';
import 'package:mech_go/Admin/a_requests.dart';
import 'package:mech_go/OTP/auth_bloc.dart';
import 'package:mech_go/OTP/auth_state.dart';

class AdminDashboard extends StatelessWidget {
  final VoidCallback onMenuPressed;
  const AdminDashboard({required this.onMenuPressed, super.key});
  
  

  @override
  Widget build(BuildContext context) {
    return  _AdminDashboardView(
        onMenuPressed: onMenuPressed
      );
  }
}

class _AdminDashboardView extends StatelessWidget {
  final VoidCallback onMenuPressed;

  const _AdminDashboardView(
    {required this.onMenuPressed,}
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current)=>previous.status!=current.status,
      listener: (context, state){
        if(state.status==AuthStatus.loggedOut){
          Navigator.pushAndRemoveUntil(context, 
          MaterialPageRoute(builder: (context)=>const AdminLogin()), 
          (route)=>false);
        }
      },
      child: Scaffold(
        // drawer: AdminDrawer(),
      
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
      
          title: Text(
            'Admin Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Times New Roman',
              fontSize: size.height * 0.02,
            ),
          ),
      
          backgroundColor: const Color.fromARGB(
            255,
            197,
            17,
            4,
          ),
      
          centerTitle: true,
          leading: IconButton(onPressed: onMenuPressed, 
          icon: Icon(Icons.menu)),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(context, 
                MaterialPageRoute(builder: (context)=>
                AdminNotification()));
              },
              icon: const Icon(
                Icons.notifications,
                color: Colors.white,
              ),
            ),
          ],
        ),
      
        body: BlocBuilder<AdminBloc, AdminState>(
          builder: (context, state) {
            if (state.status == AdminStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
      
            if (state.status == AdminStatus.failure) {
              return Center(
                child: Text(
                  state.errorMessage ??
                      'Unable to load dashboard.',
                ),
              );
            }
      
            return _buildDashboard(
              context,
              size,
              state,
            );
          },
        ),
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    Size size,
    AdminState state,
  ) {
    final List<Map<String, dynamic>> record = [
      {
        'title': 'Total Users',
        'number': state.totalUsers,
        'icon': Icons.person_add,
      },
      {
        'title': 'Total Mechanics',
        'number': state.totalMechanics,
        'icon': Icons.manage_accounts,
      },
      {
        'title': 'Active Requests',
        'number': state.activeRequests,
        'icon': Icons.request_page,
      },
      {
        'title': 'Completed',
        'number': state.completedRequests,
        'icon': Icons.done_outline_outlined,
      },
      {
        'title': 'Pending Mechanics',
        'number': state.pendingMechanics,
        'icon': Icons.pending_outlined,
      },
      {
        'title': 'Total Earnings',
        'number': state.totalEarnings,
        'icon': Icons.monetization_on,
      },
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: size.height * 0.02,
          ),

          // =====================================
          // DASHBOARD CARDS
          // =====================================

          SizedBox(
            height: size.height * 0.42,

            child: GridView.builder(
              physics:
                  const NeverScrollableScrollPhysics(),

              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                childAspectRatio: 1.90,
              ),

              itemCount: record.length,

              itemBuilder: (context, index) {
                return Container(
                  margin:
                      const EdgeInsets.all(5),

                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(12),

                    color: Colors.white,

                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15,
                        offset: Offset(3, 7),
                      ),
                    ],
                  ),

                  child: Padding(
                    padding:
                        const EdgeInsets.all(12),

                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Text(
                          record[index]['title']
                              .toString(),

                          style:
                              const TextStyle(
                            color: Colors.black,
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,

                          children: [
                            Text(
                              record[index]['number']
                                  .toString(),

                              style:
                                  const TextStyle(
                                color: Colors.black,
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),

                            Icon(
                              record[index]['icon'],
                              size: 30,
                              color:
                                  const Color
                                      .fromARGB(
                                255,
                                194,
                                17,
                                4,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // =====================================
          // RECENT REQUEST HEADER
          // =====================================

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 8,
            ),

            child: Row(
              children: [
                const Text(
                  'Recent Request',

                  style: TextStyle(
                    color: Colors.black,
                    fontFamily:
                        'Times New Roman',
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const Spacer(),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const AdminRequests(),
                      ),
                    );
                  },

                  child: const Text(
                    'View All',

                    style: TextStyle(
                      color: Color.fromARGB(
                        255,
                        224,
                        19,
                        4,
                      ),
                      fontFamily:
                          'Times New Roman',
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // =====================================
          // RECENT REQUESTS
          // =====================================

          if (state.recentRequests.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'No requests found.',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 15,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,

              physics:
                  const NeverScrollableScrollPhysics(),

              itemCount:
                  state.recentRequests.length,

              itemBuilder: (context, index) {
                final request =
                    state.recentRequests[index];

                return _requestCard(
                  context,
                  size,
                  request,
                );
              },
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ==========================================
  // REQUEST CARD
  // ==========================================

  Widget _requestCard(
    BuildContext context,
    Size size,
    Map<String, dynamic> request,
  ) {
    final String name =
        request['userName']?.toString() ??
            'Unknown User';

    final String problem =
        request['problem']?.toString() ??
            'No problem specified';

    final String status =
        request['status']?.toString() ??
            'pending';

    final String phone =
        request['userPhone']?.toString() ??
            '';

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
              BorderRadius.circular(12),

          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(2, 4),
            ),
          ],
        ),

        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),

          leading: CircleAvatar(
            radius: 30,

            backgroundImage:
                _getUserImage(request),
          ),

          title: Text(
            name,

            style: const TextStyle(
              color: Colors.black,
              fontWeight:
                  FontWeight.bold,
              fontSize: 18,
            ),
          ),

          subtitle: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                problem,

                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),

              if (phone.isNotEmpty)
                Text(
                  phone,

                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 12,
                  ),
                ),
            ],
          ),

          trailing:
              _statusContainer(
            size,
            status,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // USER IMAGE
  // ==========================================

  ImageProvider _getUserImage(
    Map<String, dynamic> request,
  ) {
    final image =
        request['userImage'];

    if (image != null &&
        image.toString().isNotEmpty) {
      return NetworkImage(
        image.toString(),
      );
    }

    return const AssetImage(
      'assets/login_cover.jpg',
    );
  }

  // ==========================================
  // STATUS
  // ==========================================

  Widget _statusContainer(
    Size size,
    String status,
  ) {
    String text;

    switch (status) {
      case 'accepted':
        text = 'Accepted';
        break;

      case 'on_the_way':
        text = 'On the way';
        break;

      case 'completed':
        text = 'Completed';
        break;

      case 'pending':
      default:
        text = 'Pending';
    }

    return Container(
      width: size.width * 0.22,
      height: size.height * 0.04,

      decoration: BoxDecoration(
        color: _statusColor(status)
            .withOpacity(0.15),

        borderRadius:
            BorderRadius.circular(15),
      ),

      child: Center(
        child: Text(
          text,

          style: TextStyle(
            color: _statusColor(status),
            fontSize: 12,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;

      case 'on_the_way':
        return Colors.blue;

      case 'completed':
        return Colors.grey;

      case 'pending':
      default:
        return Colors.orange;
    }
  }
}