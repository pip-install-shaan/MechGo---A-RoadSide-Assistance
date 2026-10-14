import 'package:equatable/equatable.dart';
import 'package:mech_go/User/UserNotifications/user_notify_model.dart';


enum UserNotificationStatus {
  initial,
  loading,
  loaded,
  failure,
}

class UserNotificationState extends Equatable {
  final UserNotificationStatus status;

  final List<UserNotificationModel> notifications;

  final String? errorMessage;

  const UserNotificationState({
    this.status = UserNotificationStatus.initial,
    this.notifications = const [],
    this.errorMessage,
  });

  int get unreadCount {
    return notifications.where((notification) {
      return !notification.isRead;
    }).length;
  }

  UserNotificationState copyWith({
    UserNotificationStatus? status,
    List<UserNotificationModel>? notifications,
    String? errorMessage,
    bool clearError = false,
  }) {
    return UserNotificationState(
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