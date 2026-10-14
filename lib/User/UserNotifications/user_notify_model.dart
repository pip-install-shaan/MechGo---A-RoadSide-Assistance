import 'package:cloud_firestore/cloud_firestore.dart';

class UserNotificationModel {
  final String id;
  final String userId;

  final String type;
  final String title;
  final String message;

  final String requestId;

  final String mechanicId;
  final String mechanicName;
  final String mechanicPhone;
  final String mechanicDistance;
  final String mechanicProfilePic;

  final String appVersion;

  final bool isRead;
  final bool isAppUpdate;

  final DateTime? createdAt;

  const UserNotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.requestId,
    required this.mechanicId,
    required this.mechanicName,
    required this.mechanicPhone,
    required this.mechanicDistance,
    required this.mechanicProfilePic,
    required this.appVersion,
    required this.isRead,
    required this.isAppUpdate,
    required this.createdAt,
  });

  factory UserNotificationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return UserNotificationModel(
      id: doc.id,
      userId: data['userId']?.toString() ?? '',
      type: data['type']?.toString() ?? 'general',
      title: data['title']?.toString() ?? 'Notification',
      message: data['message']?.toString() ?? '',
      requestId: data['requestId']?.toString() ?? '',
      mechanicId: data['mechanicId']?.toString() ?? '',
      mechanicName: data['mechanicName']?.toString() ?? 'Mechanic',
      mechanicPhone: data['mechanicPhone']?.toString() ?? '',
      mechanicDistance: data['mechanicDistance']?.toString() ?? '',
      mechanicProfilePic:
          data['mechanicProfilePic']?.toString() ?? '',
      appVersion: data['appVersion']?.toString() ?? '',
      isRead: data['isRead'] == true,
      isAppUpdate: data['isAppUpdate'] == true ||
          data['type']?.toString() == 'app_update',
      createdAt: _parseTimestamp(data['createdAt']),
    );
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }

  UserNotificationModel copyWith({
    bool? isRead,
  }) {
    return UserNotificationModel(
      id: id,
      userId: userId,
      type: type,
      title: title,
      message: message,
      requestId: requestId,
      mechanicId: mechanicId,
      mechanicName: mechanicName,
      mechanicPhone: mechanicPhone,
      mechanicDistance: mechanicDistance,
      mechanicProfilePic: mechanicProfilePic,
      appVersion: appVersion,
      isRead: isRead ?? this.isRead,
      isAppUpdate: isAppUpdate,
      createdAt: createdAt,
    );
  }
}