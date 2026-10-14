import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mech_go/Mechanic/MechanicNotification/mech_notify_repo.dart';

import 'mech_notify_bloc.dart';
import 'mech_notify_event.dart';
import 'mech_notify_state.dart';

class MechanicNotifications extends StatefulWidget {
  const MechanicNotifications({
    super.key,
  });

  @override
  State<MechanicNotifications> createState() =>
      _MechanicNotificationsState();
}

class _MechanicNotificationsState
    extends State<MechanicNotifications> {
  final Color primaryRed =
      const Color.fromARGB(255, 198, 24, 11);

  @override
  void initState() {
    super.initState();

    _loadMechanicLocation();
  }

  // --------------------------------------------------------------------------
  // LOAD MECHANIC LOCATION
  // --------------------------------------------------------------------------

  Future<void> _loadMechanicLocation() async {
    try {
      // ------------------------------------------------------------
      // 1. Check whether location service is enabled
      // ------------------------------------------------------------

      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;

        _showLocationError(
          'Location services are disabled. '
          'Please enable location services.',
        );

        return;
      }

      // ------------------------------------------------------------
      // 2. Check location permission
      // ------------------------------------------------------------

      LocationPermission permission =
          await Geolocator.checkPermission();

      // ------------------------------------------------------------
      // 3. Request permission if denied
      // ------------------------------------------------------------

      if (permission == LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          if (!mounted) return;

          _showLocationError(
            'Location permission was denied.',
          );

          return;
        }
      }

      // ------------------------------------------------------------
      // 4. Handle permanently denied permission
      // ------------------------------------------------------------

      if (permission ==
          LocationPermission.deniedForever) {
        if (!mounted) return;

        _showLocationError(
          'Location permission is permanently denied. '
          'Please enable it from app settings.',
        );

        return;
      }

      // ------------------------------------------------------------
      // 5. Get mechanic current location
      // ------------------------------------------------------------

      final Position position =
          await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      // ------------------------------------------------------------
      // 6. Send location to MechanicNotificationBloc
      // ------------------------------------------------------------

      context
          .read<MechanicNotificationBloc>()
          .add(
            WatchMechanicNotifications(
              mechanicLatitude:
                  position.latitude,
              mechanicLongitude:
                  position.longitude,
            ),
          );
    } catch (e) {
      if (!mounted) return;

      _showLocationError(
        'Unable to get your current location.\n$e',
      );
    }
  }

  // --------------------------------------------------------------------------
  // LOCATION ERROR
  // --------------------------------------------------------------------------

  void _showLocationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // BUILD
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MechanicNotificationBloc>(
      create: (context) =>
          MechanicNotificationBloc(
        repository:
            MechanicNotificationRepository(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Notifications',
          ),
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,

          actions: [
            BlocBuilder<
                MechanicNotificationBloc,
                MechanicNotificationState>(
              builder: (context, state) {
                if (state.unreadCount == 0) {
                  return const SizedBox();
                }

                return IconButton(
                  tooltip: 'Mark all as read',
                  onPressed: () {
                    context
                        .read<
                            MechanicNotificationBloc>()
                        .add(
                          const MarkAllNotificationsAsRead(),
                        );
                  },
                  icon: const Icon(
                    Icons.done_all,
                  ),
                );
              },
            ),
          ],
        ),

        body: BlocBuilder<
            MechanicNotificationBloc,
            MechanicNotificationState>(
          builder: (context, state) {
            // --------------------------------------------------------
            // LOADING
            // --------------------------------------------------------

            if (state.status ==
                MechanicNotificationStatus.loading) {
              return const Center(
                child:
                    CircularProgressIndicator(),
              );
            }

            // --------------------------------------------------------
            // FAILURE
            // --------------------------------------------------------

            if (state.status ==
                MechanicNotificationStatus.failure) {
              return Center(
                child: Padding(
                  padding:
                      const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        'Unable to load notifications',
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        state.errorMessage ??
                            'Something went wrong.',
                        textAlign:
                            TextAlign.center,
                      ),

                      const SizedBox(height: 20),

                      ElevatedButton.icon(
                        onPressed:
                            _loadMechanicLocation,
                        icon: const Icon(
                          Icons.refresh,
                        ),
                        label:
                            const Text('Retry'),
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              primaryRed,
                          foregroundColor:
                              Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // --------------------------------------------------------
            // NO NOTIFICATIONS
            // --------------------------------------------------------

            if (state.notifications.isEmpty) {
              return RefreshIndicator(
                onRefresh:
                    _loadMechanicLocation,
                child: ListView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 180),

                    Icon(
                      Icons.notifications_none,
                      size: 70,
                      color: Colors.grey,
                    ),

                    SizedBox(height: 15),

                    Center(
                      child: Text(
                        'No notifications',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: 5),

                    Center(
                      child: Text(
                        'You are all caught up.',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // --------------------------------------------------------
            // NOTIFICATIONS LIST
            // --------------------------------------------------------

            return RefreshIndicator(
              onRefresh:
                  _loadMechanicLocation,
              child: ListView.builder(
                padding:
                    const EdgeInsets.all(12),
                itemCount:
                    state.notifications.length,
                itemBuilder:
                    (context, index) {
                  final notification =
                      state.notifications[index];

                  return _notificationCard(
                    context,
                    notification,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // NOTIFICATION CARD
  // --------------------------------------------------------------------------

  Widget _notificationCard(
    BuildContext context,
    MechanicNotification notification,
  ) {
    IconData icon;

    switch (notification.type) {
      case 'nearby_request':
        icon = Icons.car_repair;
        break;

      case 'active_request':
        icon = Icons.build_circle;
        break;

      case 'app_update':
        icon = Icons.campaign;
        break;

      default:
        icon = Icons.notifications;
    }

    return Card(
      margin:
          const EdgeInsets.only(bottom: 12),
      elevation:
          notification.isRead ? 1 : 4,
      child: ListTile(
        contentPadding:
            const EdgeInsets.all(14),

        // ----------------------------------------------------------
        // ICON
        // ----------------------------------------------------------

        leading: CircleAvatar(
          backgroundColor:
              notification.isRead
                  ? Colors.grey.shade300
                  : primaryRed,
          child: Icon(
            icon,
            color: notification.isRead
                ? Colors.grey.shade700
                : Colors.white,
          ),
        ),

        // ----------------------------------------------------------
        // TITLE
        // ----------------------------------------------------------

        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight:
                notification.isRead
                    ? FontWeight.normal
                    : FontWeight.bold,
          ),
        ),

        // ----------------------------------------------------------
        // MESSAGE
        // ----------------------------------------------------------

        subtitle: Padding(
          padding:
              const EdgeInsets.only(top: 5),
          child: Text(
            notification.message,
          ),
        ),

        // ----------------------------------------------------------
        // UNREAD DOT
        // ----------------------------------------------------------

        trailing:
            notification.isRead
                ? null
                : Container(
                    width: 10,
                    height: 10,
                    decoration:
                        const BoxDecoration(
                      color: Colors.red,
                      shape:
                          BoxShape.circle,
                    ),
                  ),

        // ----------------------------------------------------------
        // TAP
        // ----------------------------------------------------------

        onTap: () {
          if (!notification.isRead) {
            context
                .read<
                    MechanicNotificationBloc>()
                .add(
                  MarkNotificationAsRead(
                    notificationId:
                        notification.id,
                  ),
                );
          }

          // --------------------------------------------------------
          // Later:
          // Navigate to request details using:
          //
          // notification.requestId
          //
          // for nearby_request / active_request.
          // --------------------------------------------------------
        },
      ),
    );
  }
}