import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mech_go/Admin/Admin_Authentication/admin_bloc.dart';
import 'package:mech_go/Admin/Admin_Authentication/admin_event.dart';
import 'package:mech_go/Admin/Admin_Authentication/admin_repo.dart';
import 'package:mech_go/Admin/Admin_Authentication/admin_state.dart';

class AdminRequests extends StatelessWidget {
  const AdminRequests({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminBloc(
        adminRepository: AdminRepository(),
      )..add(
          const LoadAllAdminRequests(),
        ),
      child: const _AdminRequestsView(),
    );
  }
}

class _AdminRequestsView extends StatelessWidget {
  const _AdminRequestsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

        title: const Text(
          'All Requests',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Times New Roman',
          ),
        ),

        backgroundColor:
            const Color.fromARGB(
          255,
          197,
          17,
          4,
        ),

        centerTitle: true,
      ),

      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state.status ==
              AdminStatus.loading) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (state.status ==
              AdminStatus.failure) {
            return Center(
              child: Text(
                state.errorMessage ??
                    'Unable to load requests.',
              ),
            );
          }

          if (state.allRequests.isEmpty) {
            return const Center(
              child: Text(
                'No requests found.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.symmetric(
              vertical: 10,
            ),

            itemCount:
                state.allRequests.length,

            itemBuilder: (context, index) {
              final request =
                  state.allRequests[index];

              return _requestCard(
                context,
                request,
              );
            },
          );
        },
      ),
    );
  }

  Widget _requestCard(
    BuildContext context,
    Map<String, dynamic> request,
  ) {
    final String name =
        request['userName']?.toString() ??
            'Unknown User';

    final String phone =
        request['userPhone']?.toString() ??
            '';

    final String problem =
        request['problem']?.toString() ??
            'No problem specified';

    final String status =
        request['status']?.toString() ??
            'pending';

    final String mechanicName =
        request['mechanicName']?.toString() ??
            'Not assigned';

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),

      child: Card(
        elevation: 4,

        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),

        child: Padding(
          padding:
              const EdgeInsets.all(12),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // USER
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,

                    backgroundImage:
                        _getUserImage(request),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Text(
                          name,

                          style:
                              const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        if (phone.isNotEmpty)
                          Text(
                            phone,

                            style:
                                const TextStyle(
                              color:
                                  Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),

                  _statusBadge(status),
                ],
              ),

              const Divider(height: 20),

              // PROBLEM
              const Text(
                'Problem',
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                problem,
                style: const TextStyle(
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 12),

              // MECHANIC
              const Text(
                'Mechanic',
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                mechanicName,
                style: const TextStyle(
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 12),

              // REQUEST ID
              Text(
                'Request ID: '
                '${request['requestId'] ?? ''}',

                style: const TextStyle(
                  color: Colors.black45,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _statusBadge(String status) {
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
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),

      decoration: BoxDecoration(
        color: _statusColor(status)
            .withOpacity(0.15),

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Text(
        text,

        style: TextStyle(
          color: _statusColor(status),
          fontWeight:
              FontWeight.bold,
          fontSize: 12,
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