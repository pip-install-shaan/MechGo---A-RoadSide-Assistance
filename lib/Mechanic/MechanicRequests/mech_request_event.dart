import 'package:equatable/equatable.dart';

abstract class MechRequestsEvent extends Equatable {
  const MechRequestsEvent();

  @override
  List<Object?> get props => [];
}

class WatchPendingRequests extends MechRequestsEvent {
  final double mechanicLatitude;
  final double mechanicLongitude;
  final double radiusKm;

  const WatchPendingRequests({
    required this.mechanicLatitude,
    required this.mechanicLongitude,
    this.radiusKm = 20,
  });
}

/// Get nearby pending requests for the mechanic.
/// Only requests within [radiusKm] are returned.
class WatchNearbyRequests extends MechRequestsEvent {
  final double mechanicLatitude;
  final double mechanicLongitude;
  final double radiusKm;

  const WatchNearbyRequests({
    required this.mechanicLatitude,
    required this.mechanicLongitude,
    this.radiusKm = 5,
  });

  @override
  List<Object?> get props => [
        mechanicLatitude,
        mechanicLongitude,
        radiusKm,
      ];
}

/// Get every request relevant to this mechanic:
/// pending nearby + accepted + on_the_way + cancelled.
class WatchAllMechanicRequests extends MechRequestsEvent {
  final double mechanicLatitude;
  final double mechanicLongitude;
  final double radiusKm;

  const WatchAllMechanicRequests({
    required this.mechanicLatitude,
    required this.mechanicLongitude,
    this.radiusKm = 5,
  });

  @override
  List<Object?> get props => [
        mechanicLatitude,
        mechanicLongitude,
        radiusKm,
      ];
}

class AcceptMechanicRequest extends MechRequestsEvent {
  final String requestId;

  const AcceptMechanicRequest(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class CancelMechanicRequest extends MechRequestsEvent {
  final String requestId;

  const CancelMechanicRequest(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class MarkRequestOnTheWay extends MechRequestsEvent {
  final String requestId;

  const MarkRequestOnTheWay(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class RefreshMechanicRequests extends MechRequestsEvent {
  final double mechanicLatitude;
  final double mechanicLongitude;
  final double radiusKm;

  const RefreshMechanicRequests({
    required this.mechanicLatitude,
    required this.mechanicLongitude,
    this.radiusKm = 5,
  });

  @override
  List<Object?> get props => [
        mechanicLatitude,
        mechanicLongitude,
        radiusKm,
      ];
}