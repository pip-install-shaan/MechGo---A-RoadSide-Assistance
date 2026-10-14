import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mech_go/User/UserNotifications/user_notify_model.dart';



class UserNotificationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UserNotificationRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore =
            firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  CollectionReference<Map<String, dynamic>>
      get _notifications =>
          _firestore.collection('notifications');

  CollectionReference<Map<String, dynamic>>
      get _appUpdates =>
          _firestore.collection('app_updates');

  // ============================================================
  // WATCH USER NOTIFICATIONS
  // ============================================================

  Stream<List<UserNotificationModel>>
      watchMyNotifications() {
    final user = currentUser;

    if (user == null) {
      return Stream.value(const []);
    }

    return _notifications
        .where(
          'userId',
          isEqualTo: user.uid,
        )
        .snapshots()
        .map((snapshot) {
      final notifications = snapshot.docs
          .map(
            UserNotificationModel.fromFirestore,
          )
          .toList();

      notifications.sort((a, b) {
        final aDate = a.createdAt;
        final bDate = b.createdAt;

        if (aDate == null && bDate == null) {
          return 0;
        }

        if (aDate == null) {
          return 1;
        }

        if (bDate == null) {
          return -1;
        }

        return bDate.compareTo(aDate);
      });

      return notifications;
    });
  }

  // ============================================================
  // WATCH APP UPDATES
  // ============================================================

  Stream<List<UserNotificationModel>>
      watchAppUpdates() {
    return _appUpdates
        .where(
          'isActive',
          isEqualTo: true,
        )
        .snapshots()
        .map((snapshot) {
      final updates = snapshot.docs.map((doc) {
        final data = doc.data();

        return UserNotificationModel(
          id: 'app_${doc.id}',
          userId: '',
          type: 'app_update',
          title:
              data['title']?.toString() ??
                  'MechGo Updated',
          message:
              data['message']?.toString() ??
                  'A new update is available.',
          requestId: '',
          mechanicId: '',
          mechanicName: '',
          mechanicPhone: '',
          mechanicDistance: '',
          mechanicProfilePic: '',
          appVersion:
              data['version']?.toString() ?? '',
          isRead: true,
          isAppUpdate: true,
          createdAt:
              _parseTimestamp(data['createdAt']),
        );
      }).toList();

      updates.sort((a, b) {
        final aDate = a.createdAt;
        final bDate = b.createdAt;

        if (aDate == null && bDate == null) {
          return 0;
        }

        if (aDate == null) {
          return 1;
        }

        if (bDate == null) {
          return -1;
        }

        return bDate.compareTo(aDate);
      });

      return updates;
    });
  }

  // ============================================================
  // MARK ONE AS READ
  // ============================================================

  Future<void> markAsRead(
    String notificationId,
  ) async {
    final user = currentUser;

    if (user == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    final notificationRef =
        _notifications.doc(notificationId);

    final snapshot =
        await notificationRef.get();

    if (!snapshot.exists) {
      throw Exception(
        'Notification not found.',
      );
    }

    final data = snapshot.data();

    if (data == null ||
        data['userId']?.toString() != user.uid) {
      throw Exception(
        'You cannot modify this notification.',
      );
    }

    await notificationRef.update({
      'isRead': true,
    });
  }

  // ============================================================
  // MARK ALL AS READ
  // ============================================================

  Future<void> markAllAsRead() async {
    final user = currentUser;

    if (user == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    final snapshot = await _notifications
        .where(
          'userId',
          isEqualTo: user.uid,
        )
        .where(
          'isRead',
          isEqualTo: false,
        )
        .get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.update(
        doc.reference,
        {
          'isRead': true,
        },
      );
    }

    await batch.commit();
  }

  // ============================================================
  // CREATE USER NOTIFICATION
  // ============================================================

  Future<void> createNotification({
    required String userId,
    required String type,
    required String title,
    required String message,
    String requestId = '',
    String mechanicId = '',
    String mechanicName = '',
    String mechanicPhone = '',
    String mechanicDistance = '',
    String mechanicProfilePic = '',
  }) async {
    await _notifications.add({
      'userId': userId,
      'type': type,
      'title': title,
      'message': message,
      'requestId': requestId,
      'mechanicId': mechanicId,
      'mechanicName': mechanicName,
      'mechanicPhone': mechanicPhone,
      'mechanicDistance': mechanicDistance,
      'mechanicProfilePic': mechanicProfilePic,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  DateTime? _parseTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}