import 'package:equatable/equatable.dart';

abstract class MechanicNotificationEvent
    extends Equatable {
  const MechanicNotificationEvent();

  @override
  List<Object?> get props => [];
}

// -----------------------------------------------------------------------------
// WATCH NOTIFICATIONS
// -----------------------------------------------------------------------------

class WatchMechanicNotifications
    extends MechanicNotificationEvent {
  final double mechanicLatitude;
  final double mechanicLongitude;

  const WatchMechanicNotifications({
    required this.mechanicLatitude,
    required this.mechanicLongitude,
  });

  @override
  List<Object?> get props => [
        mechanicLatitude,
        mechanicLongitude,
      ];
}

// -----------------------------------------------------------------------------
// MARK ONE AS READ
// -----------------------------------------------------------------------------

class MarkNotificationAsRead
    extends MechanicNotificationEvent {
  final String notificationId;

  const MarkNotificationAsRead({
    required this.notificationId,
  });

  @override
  List<Object?> get props => [
        notificationId,
      ];
}

// -----------------------------------------------------------------------------
// MARK ALL AS READ
// -----------------------------------------------------------------------------

class MarkAllNotificationsAsRead
    extends MechanicNotificationEvent {
  const MarkAllNotificationsAsRead();
}

// -----------------------------------------------------------------------------
// REFRESH LOCATION
// -----------------------------------------------------------------------------

class UpdateMechanicNotificationLocation
    extends MechanicNotificationEvent {
  final double mechanicLatitude;
  final double mechanicLongitude;

  const UpdateMechanicNotificationLocation({
    required this.mechanicLatitude,
    required this.mechanicLongitude,
  });

  @override
  List<Object?> get props => [
        mechanicLatitude,
        mechanicLongitude,
      ];
}