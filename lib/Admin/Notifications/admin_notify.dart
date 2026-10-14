import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mech_go/Admin/Notifications/admin_notify_bloc.dart';
import 'package:mech_go/Admin/Notifications/admin_notify_event.dart';
import 'package:mech_go/Admin/Notifications/admin_notify_repo.dart';
import 'package:mech_go/Admin/Notifications/admin_notify_state.dart';


class AdminNotification extends StatelessWidget {
  const AdminNotification({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminNotifyBloc(
        repository: AdminNotifyRepository(),
      )..add(
          const WatchAdminNotifications(),
        ),
      child: const _AdminNotificationView(),
    );
  }
}

class _AdminNotificationView extends StatelessWidget {
  const _AdminNotificationView();

  final Color primaryRed =
      const Color.fromARGB(255, 198, 24, 11);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Times New Roman',
            fontSize: size.height * 0.02,
          ),
        ),
        backgroundColor: primaryRed,
        centerTitle: true,
        actions: [
          BlocBuilder<AdminNotifyBloc, AdminNotifyState>(
            builder: (context, state) {
              if (state.unreadCount == 0) {
                return const SizedBox();
              }

              return IconButton(
                tooltip: 'Mark all as read',
                onPressed: () {
                  context.read<AdminNotifyBloc>().add(
                        const MarkAllAdminNotificationsAsRead(),
                      );
                },
                icon: const Icon(
                  Icons.done_all,
                  color: Colors.white,
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AdminNotifyBloc, AdminNotifyState>(
        builder: (context, state) {
          if (state.status ==
              AdminNotifyStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.status ==
              AdminNotifyStatus.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  state.errorMessage ??
                      'Unable to load notifications.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (state.notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No notifications yet.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: state.notifications.length,
            itemBuilder: (context, index) {
              final notification =
                  state.notifications[index];

              return _notificationCard(
                context,
                notification,
              );
            },
          );
        },
      ),
    );
  }

  Widget _notificationCard(
    BuildContext context,
    AdminNotificationModel notification,
  ) {
    IconData icon = Icons.notifications;

    switch (notification.type) {
      case 'new_user':
        icon = Icons.person_add;

        break;

      case 'new_mechanic':
        icon = Icons.engineering;

        break;

      case 'new_request':
        icon = Icons.car_repair;

        break;

      case 'request_accepted':
        icon = Icons.check_circle;

        break;

      case 'request_cancelled':
        icon = Icons.cancel;

        break;

      case 'payment_completed':
        icon = Icons.payment;

        break;
    }

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) {
        context.read<AdminNotifyBloc>().add(
              DeleteAdminNotification(
                notificationId: notification.id,
              ),
            );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        elevation: notification.isRead ? 1 : 4,
        color: notification.isRead
            ? Colors.white
            : Colors.red.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            if (!notification.isRead) {
              context.read<AdminNotifyBloc>().add(
                    MarkAdminNotificationAsRead(
                      notificationId:
                          notification.id,
                    ),
                  );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor:
                      primaryRed.withOpacity(0.1),
                  child: Icon(
                    icon,
                    color: primaryRed,
                  ),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight:
                                    notification.isRead
                                        ? FontWeight.w600
                                        : FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),

                          if (!notification.isRead)
                            Container(
                              width: 9,
                              height: 9,
                              decoration:
                                  const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      Text(
                        notification.message,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 7),

                      if (notification.createdAt != null)
                        Text(
                          _formatDate(
                            notification.createdAt!,
                          ),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final hour = date.hour > 12
        ? date.hour - 12
        : date.hour == 0
            ? 12
            : date.hour;

    final minute =
        date.minute.toString().padLeft(2, '0');

    final period =
        date.hour >= 12 ? 'PM' : 'AM';

    return '${date.day}/${date.month}/${date.year} '
        '$hour:$minute $period';
  }
}