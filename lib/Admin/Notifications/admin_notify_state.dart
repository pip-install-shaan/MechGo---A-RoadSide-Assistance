import 'package:equatable/equatable.dart';

enum AdminNotifyStatus {
  initial,
  loading,
  loaded,
  failure,
}

class AdminNotificationModel extends Equatable {
  final String id;
  final String title;
  final String message;
  final String type;
  final String role;
  final String userId;
  final String relatedId;
  final bool isRead;
  final DateTime? createdAt;

  const AdminNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.role,
    required this.userId,
    required this.relatedId,
    required this.isRead,
    required this.createdAt,
  });

  factory AdminNotificationModel.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    DateTime? createdAt;

    final timestamp = data['createdAt'];

    if (timestamp != null) {
      if (timestamp is DateTime) {
        createdAt = timestamp;
      } else {
        try {
          createdAt = timestamp.toDate();
        } catch (_) {
          createdAt = null;
        }
      }
    }

    return AdminNotificationModel(
      id: id,
      title: data['title']?.toString() ?? 'Notification',
      message: data['message']?.toString() ?? '',
      type: data['type']?.toString() ?? 'general',
      role: data['role']?.toString() ?? '',
      userId: data['userId']?.toString() ?? '',
      relatedId: data['relatedId']?.toString() ?? '',
      isRead: data['isRead'] == true,
      createdAt: createdAt,
    );
  }

  AdminNotificationModel copyWith({
    String? title,
    String? message,
    String? type,
    String? role,
    String? userId,
    String? relatedId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AdminNotificationModel(
      id: id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      role: role ?? this.role,
      userId: userId ?? this.userId,
      relatedId: relatedId ?? this.relatedId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        type,
        role,
        userId,
        relatedId,
        isRead,
        createdAt,
      ];
}

class AdminNotifyState extends Equatable {
  final AdminNotifyStatus status;
  final List<AdminNotificationModel> notifications;
  final String? errorMessage;

  const AdminNotifyState({
    this.status = AdminNotifyStatus.initial,
    this.notifications = const [],
    this.errorMessage,
  });

  int get unreadCount {
    return notifications.where((notification) {
      return !notification.isRead;
    }).length;
  }

  AdminNotifyState copyWith({
    AdminNotifyStatus? status,
    List<AdminNotificationModel>? notifications,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdminNotifyState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      errorMessage:
          clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        notifications,
        errorMessage,
      ];
}