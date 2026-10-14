import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'mech_notify_state.dart';

class MechanicNotificationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  MechanicNotificationRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore =
            firestore ?? FirebaseFirestore.instance,
        _auth =
            auth ?? FirebaseAuth.instance;

  // ---------------------------------------------------------------------------
  // CURRENT MECHANIC
  // ---------------------------------------------------------------------------

  String get mechanicId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'Mechanic is not logged in.',
      );
    }

    return user.uid;
  }

  // ---------------------------------------------------------------------------
  // WATCH ALL MECHANIC NOTIFICATIONS
  // ---------------------------------------------------------------------------

  Stream<List<MechanicNotification>>
      watchNotifications({
    required double mechanicLatitude,
    required double mechanicLongitude,
  }) {
    final controller =
        StreamController<List<MechanicNotification>>();

    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
        pendingSubscription;

    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
        activeSubscription;

    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
        updatesSubscription;

    List<MechanicNotification>
        pendingNotifications = [];

    List<MechanicNotification>
        activeNotifications = [];

    List<MechanicNotification>
        updateNotifications = [];

    void emitNotifications() {
      final all = [
        ...pendingNotifications,
        ...activeNotifications,
        ...updateNotifications,
      ];

      // Remove duplicate notification IDs.
      final unique =
          <String, MechanicNotification>{};

      for (final notification in all) {
        unique[notification.id] =
            notification;
      }

      final result = unique.values.toList();

      result.sort((a, b) {
        final aDate = a.createdAt ??
            DateTime.fromMillisecondsSinceEpoch(
              0,
            );

        final bDate = b.createdAt ??
            DateTime.fromMillisecondsSinceEpoch(
              0,
            );

        return bDate.compareTo(aDate);
      });

      if (!controller.isClosed) {
        controller.add(result);
      }
    }

    // -------------------------------------------------------------------------
    // NEW PENDING REQUESTS
    // -------------------------------------------------------------------------

    pendingSubscription = _firestore
        .collection('requests')
        .where(
          'status',
          isEqualTo: 'pending',
        )
        .snapshots()
        .listen(
      (snapshot) {
        pendingNotifications = [];

        for (final document
            in snapshot.docs) {
          final data = document.data();

          final latitude =
              _toDouble(data['latitude']);

          final longitude =
              _toDouble(data['longitude']);

          final distance = _calculateDistanceKm(
            mechanicLatitude,
            mechanicLongitude,
            latitude,
            longitude,
          );

          // Only notify for requests within 5 KM.
          if (distance <= 5) {
            final userName =
                data['userName'] ??
                    'A user';

            final problemType =
                data['problemType'] ??
                    'Vehicle problem';

            pendingNotifications.add(
              MechanicNotification(
                id:
                    'nearby_${document.id}',
                title:
                    'New Nearby Request',
                message:
                    '$userName sent a $problemType request '
                    '${distance.toStringAsFixed(1)} km away.',
                type:
                    'nearby_request',
                requestId:
                    document.id,
                userId:
                    data['userId'],
                userName:
                    userName,
                problemType:
                    problemType,
                distanceKm:
                    distance,
                createdAt:
                    _toDateTime(
                  data['createdAt'],
                ),
              ),
            );
          }
        }

        emitNotifications();
      },
      onError: (error) {
        if (!controller.isClosed) {
          controller.addError(error);
        }
      },
    );

    // -------------------------------------------------------------------------
    // ACCEPTED / ACTIVE REQUESTS
    // -------------------------------------------------------------------------

    activeSubscription = _firestore
        .collection('requests')
        .where(
          'mechanicId',
          isEqualTo: mechanicId,
        )
        .where(
          'status',
          whereIn: [
            'accepted',
            'in_progress',
          ],
        )
        .snapshots()
        .listen(
      (snapshot) {
        activeNotifications = [];

        for (final document
            in snapshot.docs) {
          final data = document.data();

          final userName =
              data['userName'] ??
                  'Customer';

          final problemType =
              data['problemType'] ??
                  'Vehicle problem';

          activeNotifications.add(
            MechanicNotification(
              id:
                  'active_${document.id}',
              title:
                  'Active Service',
              message:
                  'You are currently working '
                  'with $userName on '
                  '$problemType.',
              type:
                  'active_request',
              requestId:
                  document.id,
              userId:
                  data['userId'],
              userName:
                  userName,
              problemType:
                  problemType,
              createdAt:
                  _toDateTime(
                data['acceptedAt'],
              ) ??
                      _toDateTime(
                        data['updatedAt'],
                      ) ??
                      _toDateTime(
                        data['createdAt'],
                      ),
            ),
          );
        }

        emitNotifications();
      },
      onError: (error) {
        if (!controller.isClosed) {
          controller.addError(error);
        }
      },
    );

    // -------------------------------------------------------------------------
    // APP UPDATES
    // -------------------------------------------------------------------------

    updatesSubscription = _firestore
        .collection('app_updates')
        .where(
          'isActive',
          isEqualTo: true,
        )
        .snapshots()
        .listen(
      (snapshot) {
        updateNotifications = [];

        for (final document
            in snapshot.docs) {
          final data = document.data();

          updateNotifications.add(
            MechanicNotification(
              id:
                  'update_${document.id}',
              title:
                  data['title'] ??
                      'App Update',
              message:
                  data['message'] ??
                      '',
              type:
                  'app_update',
              createdAt:
                  _toDateTime(
                data['createdAt'],
              ),
            ),
          );
        }

        emitNotifications();
      },
      onError: (error) {
        if (!controller.isClosed) {
          controller.addError(error);
        }
      },
    );

    controller.onCancel = () async {
      await pendingSubscription?.cancel();
      await activeSubscription?.cancel();
      await updatesSubscription?.cancel();
    };

    return controller.stream;
  }

  // ---------------------------------------------------------------------------
  // MARK READ
  // ---------------------------------------------------------------------------

  Future<void> markAsRead(
    MechanicNotification notification,
  ) async {
    final mechanicNotificationReference =
        _firestore
            .collection('mechanic_notifications')
            .doc(mechanicId)
            .collection('notifications')
            .doc(notification.id);

    await mechanicNotificationReference.set(
      {
        'notificationId':
            notification.id,
        'isRead': true,
        'readAt':
            FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // ---------------------------------------------------------------------------
  // MARK ALL READ
  // ---------------------------------------------------------------------------

  Future<void> markAllAsRead(
    List<MechanicNotification>
        notifications,
  ) async {
    final batch = _firestore.batch();

    for (final notification
        in notifications) {
      final reference = _firestore
          .collection(
            'mechanic_notifications',
          )
          .doc(mechanicId)
          .collection('notifications')
          .doc(notification.id);

      batch.set(
        reference,
        {
          'notificationId':
              notification.id,
          'isRead': true,
          'readAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  // ---------------------------------------------------------------------------
  // DISTANCE
  // ---------------------------------------------------------------------------

  double _calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371.0;

    final dLat =
        _degreesToRadians(lat2 - lat1);

    final dLon =
        _degreesToRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) *
                sin(dLat / 2) +
            cos(_degreesToRadians(lat1)) *
                cos(_degreesToRadians(lat2)) *
                sin(dLon / 2) *
                sin(dLon / 2);

    final c =
        2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }

  DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}