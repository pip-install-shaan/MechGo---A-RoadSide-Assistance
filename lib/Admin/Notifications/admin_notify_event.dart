import 'package:equatable/equatable.dart';

abstract class AdminNotifyEvent extends Equatable {
  const AdminNotifyEvent();

  @override
  List<Object?> get props => [];
}

/// Start listening to admin notifications.
class WatchAdminNotifications extends AdminNotifyEvent {
  const WatchAdminNotifications();
}

/// Mark one notification as read.
class MarkAdminNotificationAsRead extends AdminNotifyEvent {
  final String notificationId;

  const MarkAdminNotificationAsRead({
    required this.notificationId,
  });

  @override
  List<Object?> get props => [notificationId];
}

/// Mark all notifications as read.
class MarkAllAdminNotificationsAsRead extends AdminNotifyEvent {
  const MarkAllAdminNotificationsAsRead();
}

/// Delete one notification.
class DeleteAdminNotification extends AdminNotifyEvent {
  final String notificationId;

  const DeleteAdminNotification({
    required this.notificationId,
  });

  @override
  List<Object?> get props => [notificationId];
}

/// Delete all notifications.
class DeleteAllAdminNotifications extends AdminNotifyEvent {
  const DeleteAllAdminNotifications();
}