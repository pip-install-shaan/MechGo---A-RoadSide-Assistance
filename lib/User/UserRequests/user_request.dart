import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'request_bloc.dart';
import 'request_event.dart';
import 'request_model.dart';
import 'request_state.dart';

class UserRequest extends StatefulWidget {
  const UserRequest({super.key});

  @override
  State<UserRequest> createState() => _UserRequestState();
}

class _UserRequestState extends State<UserRequest> {
  final Color primaryRed =
      const Color.fromARGB(255, 198, 24, 11);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryRed,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          'My Requests',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Times New Roman',
            fontWeight: FontWeight.bold,
            fontSize: size.height * 0.03,
          ),
        ),
      ),

      body: BlocBuilder<RequestBloc, RequestState>(
        builder: (context, state) {
          if (state.status == RequestStatus.loading &&
              state.requests.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.status == RequestStatus.failure &&
              state.requests.isEmpty) {
            return _ErrorView(
              message:
                  state.errorMessage ??
                      'Something went wrong.',
              onRetry: () {
                context.read<RequestBloc>().add(
                      const WatchMyRequests(),
                    );
              },
            );
          }

          final requests = state.requests;

          final acceptedRequests = requests
              .where(
                (request) =>
                    request.status == 'accepted',
              )
              .toList();

          final pendingRequests = requests
              .where(
                (request) =>
                    request.status == 'pending',
              )
              .toList();

          final rejectedMechanics = <_RejectedItem>[];

          for (final request in requests) {
            for (final mechanic
                in request.rejectedMechanics) {
              rejectedMechanics.add(
                _RejectedItem(
                  request: request,
                  mechanic: mechanic,
                ),
              );
            }
          }

          if (requests.isEmpty) {
            return const _EmptyRequestsView();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<RequestBloc>().add(
                    const WatchMyRequests(),
                  );

              await Future.delayed(
                const Duration(milliseconds: 500),
              );
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (acceptedRequests.isNotEmpty) ...[
                  const _SectionTitle(
                    icon: Icons.directions_car,
                    title: 'Mechanic On The Way',
                  ),

                  const SizedBox(height: 10),

                  ...acceptedRequests.map(
                    (request) =>
                        _AcceptedRequestCard(
                      request: request,
                      primaryRed: primaryRed,
                    ),
                  ),

                  const SizedBox(height: 24),
                ],

                if (pendingRequests.isNotEmpty) ...[
                  const _SectionTitle(
                    icon: Icons.hourglass_top,
                    title: 'Pending Requests',
                  ),

                  const SizedBox(height: 10),

                  ...pendingRequests.map(
                    (request) =>
                        _PendingRequestCard(
                      request: request,
                      primaryRed: primaryRed,
                    ),
                  ),

                  const SizedBox(height: 24),
                ],

                if (rejectedMechanics.isNotEmpty) ...[
                  const _SectionTitle(
                    icon: Icons.person_off,
                    title: 'Rejected Mechanics',
                  ),

                  const SizedBox(height: 10),

                  ...rejectedMechanics.map(
                    (item) =>
                        _RejectedMechanicCard(
                      item: item,
                    ),
                  ),
                ],

                if (acceptedRequests.isEmpty &&
                    pendingRequests.isEmpty &&
                    rejectedMechanics.isEmpty)
                  const _EmptyRequestsView(),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// SECTION TITLE
// ============================================================

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color.fromARGB(
            255,
            198,
            24,
            11,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// ACCEPTED REQUEST
// ============================================================

class _AcceptedRequestCard extends StatelessWidget {
  final RequestModel request;
  final Color primaryRed;

  const _AcceptedRequestCard({
    required this.request,
    required this.primaryRed,
  });

  @override
  Widget build(BuildContext context) {
    final mechanicName =
        request.mechanicName;

    final mechanicPhone =
        request.mechanicPhone;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _MechanicImage(
                  imageUrl:
                      request.mechanicProfilePic,
                  size: 58,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        mechanicName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 10,
                            color: Colors.green,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'On the way',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 25),

            _InfoRow(
              icon: Icons.directions_car,
              title: 'Vehicle',
              value: request.vehicleType,
            ),

            _InfoRow(
              icon: Icons.build,
              title: 'Problem',
              value: request.problemType,
            ),

            _InfoRow(
              icon: Icons.location_on,
              title: 'Location',
              value: request.location,
            ),

            _InfoRow(
              icon: Icons.payments,
              title: 'Estimated Amount',
              value:
                  'Rs. ${request.amount.toStringAsFixed(0)}',
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Connect this with your
                      // existing RequestTrackMechanic.
                    },
                    icon: const Icon(
                      Icons.location_on,
                    ),
                    label: const Text(
                      'Track',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryRed,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _callMechanic(
                        context,
                        mechanicPhone,
                      );
                    },
                    icon: const Icon(
                      Icons.call,
                    ),
                    label: const Text(
                      'Call',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Connect this with your
                  // RequestChatScreen.
                },
                icon: const Icon(
                  Icons.chat,
                ),
                label: const Text(
                  'Chat With Mechanic',
                ),
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  _confirmRejectMechanic(
                    context,
                    request,
                  );
                },
                child: const Text(
                  'Reject This Mechanic',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _callMechanic(
    BuildContext context,
    String phone,
  ) async {
    if (phone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mechanic phone number is not available.',
          ),
        ),
      );
      return;
    }

    final uri = Uri(
      scheme: 'tel',
      path: phone,
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to open phone dialer.',
          ),
        ),
      );
    }
  }

  void _confirmRejectMechanic(
    BuildContext context,
    RequestModel request,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Reject Mechanic?',
          ),
          content: Text(
            'Are you sure you want to reject '
            '${request.mechanicName}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('No'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                context.read<RequestBloc>().add(
                      RejectMechanic(
                        request.requestId,
                      ),
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// PENDING REQUEST CARD
// ============================================================

class _PendingRequestCard extends StatelessWidget {
  final RequestModel request;
  final Color primaryRed;

  const _PendingRequestCard({
    required this.request,
    required this.primaryRed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      primaryRed.withOpacity(0.1),
                  child: Icon(
                    Icons.hourglass_top,
                    color: primaryRed,
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Text(
                    'Finding a Mechanic...',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 25),

            _InfoRow(
              icon: Icons.directions_car,
              title: 'Vehicle',
              value: request.vehicleType,
            ),

            _InfoRow(
              icon: Icons.build,
              title: 'Problem',
              value: request.problemType,
            ),

            _InfoRow(
              icon: Icons.location_on,
              title: 'Location',
              value: request.location,
            ),

            _InfoRow(
              icon: Icons.payments,
              title: 'Amount',
              value:
                  'Rs. ${request.amount.toStringAsFixed(0)}',
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _confirmCancel(
                    context,
                    request,
                  );
                },
                icon: const Icon(
                  Icons.cancel_outlined,
                ),
                label: const Text(
                  'Cancel Request',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCancel(
    BuildContext context,
    RequestModel request,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Cancel Request?',
          ),
          content: const Text(
            'Are you sure you want to cancel '
            'this service request?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                context.read<RequestBloc>().add(
                      CancelRequest(
                        request.requestId,
                      ),
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cancel Request'),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// REJECTED MECHANIC ITEM
// ============================================================

class _RejectedItem {
  final RequestModel request;
  final dynamic mechanic;

  const _RejectedItem({
    required this.request,
    required this.mechanic,
  });
}

// ============================================================
// REJECTED MECHANIC CARD
// ============================================================

class _RejectedMechanicCard extends StatelessWidget {
  final _RejectedItem item;

  const _RejectedMechanicCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final mechanic = item.mechanic;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: _MechanicImage(
          imageUrl:
              mechanic.mechanicProfilePic,
          size: 50,
        ),
        title: Text(
          mechanic.mechanicName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            if (mechanic
                .mechanicPhone
                .toString()
                .isNotEmpty)
              Text(
                mechanic.mechanicPhone,
              ),

            Text(
              'Request: ${item.request.problemType}',
            ),

            if (mechanic.rejectedAt != null)
              Text(
                'Rejected: ${_formatDate(mechanic.rejectedAt)}',
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}

// ============================================================
// INFO ROW
// ============================================================

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 9,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color.fromARGB(
              255,
              198,
              24,
              11,
            ),
          ),

          const SizedBox(width: 10),

          SizedBox(
            width: 115,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MECHANIC IMAGE
// ============================================================

class _MechanicImage extends StatelessWidget {
  final String imageUrl;
  final double size;

  const _MechanicImage({
    required this.imageUrl,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isEmpty) {
      return CircleAvatar(
        radius: size / 2,
        child: const Icon(
          Icons.person,
        ),
      );
    }

    return ClipOval(
      child: Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) {
          return CircleAvatar(
            radius: size / 2,
            child: const Icon(
              Icons.person,
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// EMPTY VIEW
// ============================================================

class _EmptyRequestsView
    extends StatelessWidget {
  const _EmptyRequestsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 20),

            const Text(
              'No Requests Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Your pending and accepted '
              'requests will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ERROR VIEW
// ============================================================

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),

            const SizedBox(height: 15),

            Text(
              message,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: onRetry,
              child: const Text(
                'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }
}