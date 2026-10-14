import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_notify_state.dart';

class AdminNotifyRepository {
  final FirebaseFirestore _firestore;

  AdminNotifyRepository({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>
      get _notificationsCollection =>
          _firestore.collection('admin_notifications');

  // ==========================================================
  // WATCH ADMIN NOTIFICATIONS
  // ==========================================================

  Stream<List<AdminNotificationModel>>
      watchAdminNotifications() {
    return _notificationsCollection.snapshots().map(
      (snapshot) {
        final notifications =
            snapshot.docs.map((doc) {
          return AdminNotificationModel.fromMap(
            doc.id,
            doc.data(),
          );
        }).toList();

        // Newest notification first.
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
      },
    );
  }

  // ==========================================================
  // MARK ONE AS READ
  // ==========================================================

  Future<void> markAsRead(
    String notificationId,
  ) async {
    await _notificationsCollection
        .doc(notificationId)
        .update({
      'isRead': true,
    });
  }

  // ==========================================================
  // MARK ALL AS READ
  // ==========================================================

  Future<void> markAllAsRead() async {
    final snapshot =
        await _notificationsCollection
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

  // ==========================================================
  // DELETE ONE
  // ==========================================================

  Future<void> deleteNotification(
    String notificationId,
  ) async {
    await _notificationsCollection
        .doc(notificationId)
        .delete();
  }

  // ==========================================================
  // DELETE ALL
  // ==========================================================

  Future<void> deleteAllNotifications() async {
    final snapshot =
        await _notificationsCollection.get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // ==========================================================
  // CREATE ADMIN NOTIFICATION
  // ==========================================================
  //
  // This method will be called from USER/MANIC repositories
  // whenever an important event happens.
  //
  // ==========================================================

  Future<void> createAdminNotification({
    required String title,
    required String message,
    required String type,
    String role = '',
    String userId = '',
    String relatedId = '',
  }) async {
    await _notificationsCollection.add({
      'title': title,
      'message': message,
      'type': type,
      'role': role,
      'userId': userId,
      'relatedId': relatedId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ==========================================================
  // NEW USER
  // ==========================================================

  Future<void> notifyNewUser({
    required String userId,
    required String userName,
  }) async {
    await createAdminNotification(
      title: 'New User Registered',
      message:
          '$userName has created a new MechGo account.',
      type: 'new_user',
      role: 'user',
      userId: userId,
      relatedId: userId,
    );
  }

  // ==========================================================
  // NEW MECHANIC
  // ==========================================================

  Future<void> notifyNewMechanic({
    required String mechanicId,
    required String mechanicName,
  }) async {
    await createAdminNotification(
      title: 'New Mechanic Registered',
      message:
          '$mechanicName has created a new mechanic account.',
      type: 'new_mechanic',
      role: 'mechanic',
      userId: mechanicId,
      relatedId: mechanicId,
    );
  }

  // ==========================================================
  // NEW SERVICE REQUEST
  // ==========================================================

  Future<void> notifyNewRequest({
    required String requestId,
    required String userId,
    required String userName,
    required String problemType,
  }) async {
    await createAdminNotification(
      title: 'New Service Request',
      message:
          '$userName created a new $problemType service request.',
      type: 'new_request',
      role: 'user',
      userId: userId,
      relatedId: requestId,
    );
  }

  // ==========================================================
  // REQUEST ACCEPTED
  // ==========================================================

  Future<void> notifyRequestAccepted({
    required String requestId,
    required String mechanicId,
    required String mechanicName,
  }) async {
    await createAdminNotification(
      title: 'Request Accepted',
      message:
          '$mechanicName accepted a service request.',
      type: 'request_accepted',
      role: 'mechanic',
      userId: mechanicId,
      relatedId: requestId,
    );
  }

  // ==========================================================
  // REQUEST CANCELLED
  // ==========================================================

  Future<void> notifyRequestCancelled({
    required String requestId,
    required String userId,
    required String userName,
  }) async {
    await createAdminNotification(
      title: 'Request Cancelled',
      message:
          '$userName cancelled a service request.',
      type: 'request_cancelled',
      role: 'user',
      userId: userId,
      relatedId: requestId,
    );
  }

  // ==========================================================
  // PAYMENT COMPLETED
  // ==========================================================

  Future<void> notifyPaymentCompleted({
    required String requestId,
    required String userId,
    required double amount,
  }) async {
    await createAdminNotification(
      title: 'Payment Completed',
      message:
          'A payment of Rs. ${amount.toStringAsFixed(0)} '
          'was completed.',
      type: 'payment_completed',
      role: 'user',
      userId: userId,
      relatedId: requestId,
    );
  }
}