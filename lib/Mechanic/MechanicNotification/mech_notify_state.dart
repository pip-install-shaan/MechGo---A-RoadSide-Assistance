import 'package:equatable/equatable.dart';

enum MechanicNotificationStatus {
  initial,
  loading,
  loaded,
  markingRead,
  failure,
}

class MechanicNotification {
  final String id;

  final String title;
  final String message;

  final String type;

  final String? requestId;
  final String? userId;
  final String? userName;

  final String? problemType;

  final double? distanceKm;

  final DateTime? createdAt;

  final bool isRead;

  const MechanicNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.requestId,
    this.userId,
    this.userName,
    this.problemType,
    this.distanceKm,
    this.createdAt,
    this.isRead = false,
  });

  MechanicNotification copyWith({
    bool? isRead,
  }) {
    return MechanicNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      requestId: requestId,
      userId: userId,
      userName: userName,
      problemType: problemType,
      distanceKm: distanceKm,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

class MechanicNotificationState
    extends Equatable {
  final MechanicNotificationStatus status;

  final List<MechanicNotification>
      notifications;

  final String? errorMessage;

  final double mechanicLatitude;
  final double mechanicLongitude;

  const MechanicNotificationState({
    this.status =
        MechanicNotificationStatus.initial,
    this.notifications = const [],
    this.errorMessage,
    this.mechanicLatitude = 0,
    this.mechanicLongitude = 0,
  });

  int get unreadCount {
    return notifications
        .where((notification) =>
            !notification.isRead)
        .length;
  }

  MechanicNotificationState copyWith({
    MechanicNotificationStatus? status,
    List<MechanicNotification>? notifications,
    String? errorMessage,
    bool clearError = false,
    double? mechanicLatitude,
    double? mechanicLongitude,
  }) {
    return MechanicNotificationState(
      status: status ?? this.status,
      notifications:
          notifications ?? this.notifications,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
      mechanicLatitude:
          mechanicLatitude ??
              this.mechanicLatitude,
      mechanicLongitude:
          mechanicLongitude ??
              this.mechanicLongitude,
    );
  }

  @override
  List<Object?> get props => [
        status,
        notifications,
        errorMessage,
        mechanicLatitude,
        mechanicLongitude,
      ];
}