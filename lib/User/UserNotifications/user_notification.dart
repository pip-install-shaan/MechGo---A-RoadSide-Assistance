import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mech_go/User/UserNotifications/user_notify_bloc.dart';
import 'package:mech_go/User/UserNotifications/user_notify_event.dart';
import 'package:mech_go/User/UserNotifications/user_notify_model.dart';
import 'package:mech_go/User/UserNotifications/user_notify_repo.dart';
import 'package:mech_go/User/UserNotifications/user_notify_state.dart';



class UserNotification extends StatelessWidget {
  const UserNotification({super.key});

  final Color primaryRed =
      const Color.fromARGB(255, 198, 24, 11);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserNotificationBloc(
        userNotificationRepository:
            UserNotificationRepository(),
      )..add(
          const WatchUserNotifications(),
        ),
      child: _UserNotificationView(
        primaryRed: primaryRed,
      ),
    );
  }
}

class _UserNotificationView extends StatelessWidget {
  final Color primaryRed;

  const _UserNotificationView({
    required this.primaryRed,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FA),
      appBar: AppBar(
        backgroundColor: primaryRed,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Times New Roman',
            fontSize: size.height * 0.026,
          ),
        ),
        actions: [
          BlocBuilder<
              UserNotificationBloc,
              UserNotificationState>(
            builder: (context, state) {
              if (state.unreadCount == 0) {
                return const SizedBox.shrink();
              }

              return IconButton(
                tooltip: 'Mark all as read',
                icon: const Icon(
                  Icons.done_all,
                  color: Colors.white,
                ),
                onPressed: () {
                  context
                      .read<UserNotificationBloc>()
                      .add(
                        const MarkAllNotificationsRead(),
                      );
                },
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<
          UserNotificationBloc,
          UserNotificationState>(
        listener: (context, state) {
          if (state.status ==
                  UserNotificationStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(
              SnackBar(
                content:
                    Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status ==
              UserNotificationStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.status ==
                  UserNotificationStatus.failure &&
              state.notifications.isEmpty) {
            return _ErrorView(
              message:
                  state.errorMessage ??
                      'Something went wrong.',
              onRetry: () {
                context
                    .read<UserNotificationBloc>()
                    .add(
                      const WatchUserNotifications(),
                    );
              },
            );
          }

          if (state.notifications.isEmpty) {
            return const _EmptyNotificationView();
          }

          return RefreshIndicator(
            color: primaryRed,
            onRefresh: () async {
              context
                  .read<UserNotificationBloc>()
                  .add(
                    const WatchUserNotifications(),
                  );
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                12,
                12,
                12,
                30,
              ),
              itemCount:
                  state.notifications.length,
              itemBuilder: (context, index) {
                final notification =
                    state.notifications[index];

                return _NotificationCard(
                  notification: notification,
                  primaryRed: primaryRed,
                  onTap: () {
                    if (!notification.isRead &&
                        !notification.isAppUpdate) {
                      context
                          .read<
                              UserNotificationBloc>()
                          .add(
                            MarkNotificationRead(
                              notification.id,
                            ),
                          );
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final UserNotificationModel notification;
  final Color primaryRed;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.primaryRed,
    required this.onTap,
  });

  IconData _getIcon() {
    switch (notification.type) {
      case 'request_accepted':
        return Icons.check_circle;

      case 'mechanic_declined':
        return Icons.cancel;

      case 'request_cancelled':
        return Icons.block;

      case 'mechanic_arrived':
        return Icons.location_on;

      case 'request_completed':
        return Icons.task_alt;

      case 'payment_pending':
        return Icons.payment;

      case 'app_update':
        return Icons.system_update;

      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor() {
    switch (notification.type) {
      case 'request_accepted':
        return Colors.green;

      case 'mechanic_declined':
      case 'request_cancelled':
        return Colors.red;

      case 'mechanic_arrived':
        return Colors.blue;

      case 'request_completed':
        return Colors.green;

      case 'payment_pending':
        return Colors.orange;

      case 'app_update':
        return primaryRed;

      default:
        return primaryRed;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '';
    }

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 10,
        ),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.white
              : const Color(0xFFFFF3F1),
          borderRadius:
              BorderRadius.circular(14),
          border: Border.all(
            color: notification.isRead
                ? Colors.grey.shade200
                : primaryRed.withOpacity(0.25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getIconColor()
                      .withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIcon(),
                  color: _getIconColor(),
                  size: 27,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  notification.isRead
                                      ? FontWeight.w600
                                      : FontWeight.bold,
                              color:
                                  Colors.black87,
                            ),
                          ),
                        ),

                        if (!notification.isRead &&
                            !notification.isAppUpdate)
                          Container(
                            width: 9,
                            height: 9,
                            margin:
                                const EdgeInsets.only(
                              top: 5,
                              left: 5,
                            ),
                            decoration:
                                BoxDecoration(
                              color: primaryRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color:
                            Colors.grey.shade700,
                      ),
                    ),

                    if (notification
                            .mechanicName
                            .isNotEmpty &&
                        !notification.isAppUpdate)
                      Padding(
                        padding:
                            const EdgeInsets.only(
                          top: 8,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              notification
                                  .mechanicName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (notification
                            .appVersion
                            .isNotEmpty &&
                        notification.isAppUpdate)
                      Padding(
                        padding:
                            const EdgeInsets.only(
                          top: 8,
                        ),
                        child: Text(
                          'Version ${notification.appVersion}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w600,
                            color: primaryRed,
                          ),
                        ),
                      ),

                    const SizedBox(height: 7),

                    Text(
                      _formatDate(
                        notification.createdAt,
                      ),
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyNotificationView
    extends StatelessWidget {
  const _EmptyNotificationView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 85,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 18),
            const Text(
              'No Notifications',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You will see request updates and '
              'important MechGo updates here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
              color: Colors.red,
              size: 65,
            ),
            const SizedBox(height: 15),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}