import 'package:equatable/equatable.dart';
import 'package:mech_go/User/UserNotifications/user_notify_model.dart';



abstract class UserNotificationEvent extends Equatable {
  const UserNotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Starts both realtime listeners.
class WatchUserNotifications extends UserNotificationEvent {
  const WatchUserNotifications();
}

/// Fired whenever user's notification collection changes.
class UserNotificationsUpdated extends UserNotificationEvent {
  final List<UserNotificationModel> notifications;

  const UserNotificationsUpdated(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

/// Fired whenever app_updates changes.
class AppUpdatesUpdated extends UserNotificationEvent {
  final List<UserNotificationModel> updates;

  const AppUpdatesUpdated(this.updates);

  @override
  List<Object?> get props => [updates];
}

/// Marks one notification as read.
class MarkNotificationRead extends UserNotificationEvent {
  final String notificationId;

  const MarkNotificationRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Marks all notifications as read.
class MarkAllNotificationsRead extends UserNotificationEvent {
  const MarkAllNotificationsRead();
}

/// Internal error event.
class UserNotificationError extends UserNotificationEvent {
  final String message;

  const UserNotificationError(this.message);

  @override
  List<Object?> get props => [message];
}