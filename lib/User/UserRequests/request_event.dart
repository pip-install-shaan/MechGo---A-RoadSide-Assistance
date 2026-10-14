import 'package:equatable/equatable.dart';

import 'request_model.dart';

abstract class RequestEvent extends Equatable {
  const RequestEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================
// CREATE REQUEST - USER
// ============================================================

class CreateRequest extends RequestEvent {
  final String vehicleType;
  final String problemType;
  final String description;
  final String location;
  final List<String> imagePaths;

  final double latitude;
  final double longitude;

  final double amount;

  const CreateRequest({
    required this.vehicleType,
    required this.problemType,
    required this.description,
    required this.location,
    required this.imagePaths,
    required this.latitude,
    required this.longitude,
    this.amount = 0,
  });

  @override
  List<Object?> get props => [
        vehicleType,
        problemType,
        description,
        location,
        imagePaths,
        latitude,
        longitude,
        amount,
      ];
}

// ============================================================
// WATCH USER REQUESTS
// ============================================================

class WatchMyRequests extends RequestEvent {
  const WatchMyRequests();
}

// ============================================================
// USER REQUESTS UPDATED
// ============================================================

class MyRequestsUpdated extends RequestEvent {
  final List<RequestModel> requests;

  const MyRequestsUpdated(this.requests);

  @override
  List<Object?> get props => [requests];
}

// ============================================================
// REQUEST ERROR
// ============================================================

class MyRequestsFailed extends RequestEvent {
  final String message;

  const MyRequestsFailed(this.message);

  @override
  List<Object?> get props => [message];
}

// ============================================================
// WATCH SINGLE REQUEST
// ============================================================

class WatchRequest extends RequestEvent {
  final String requestId;

  const WatchRequest(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

// ============================================================
// SINGLE REQUEST UPDATED
// ============================================================

class RequestUpdated extends RequestEvent {
  final RequestModel? request;

  const RequestUpdated(this.request);

  @override
  List<Object?> get props => [request];
}

// ============================================================
// CANCEL REQUEST
// ============================================================

class CancelRequest extends RequestEvent {
  final String requestId;

  const CancelRequest(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

// ============================================================
// WATCH PENDING REQUESTS - MECHANIC
// ============================================================

class WatchPendingRequests extends RequestEvent {
  final double mechanicLatitude;
  final double mechanicLongitude;

  final double radiusKm;

  const WatchPendingRequests({
    required this.mechanicLatitude,
    required this.mechanicLongitude,
    this.radiusKm = 20,
  });

  @override
  List<Object?> get props => [
        mechanicLatitude,
        mechanicLongitude,
        radiusKm,
      ];
}

// ============================================================
// PENDING REQUESTS UPDATED
// ============================================================

class PendingRequestsUpdated extends RequestEvent {
  final List<RequestModel> requests;

  const PendingRequestsUpdated(this.requests);

  @override
  List<Object?> get props => [requests];
}

// ============================================================
// ACCEPT REQUEST - MECHANIC
// ============================================================

class AcceptRequest extends RequestEvent {
  final String requestId;

  const AcceptRequest(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class RejectMechanic extends RequestEvent {
  final String requestId;

  const RejectMechanic(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

// ============================================================
// WATCH ASSIGNED MECHANIC LOCATION - USER
// ============================================================

class WatchAssignedMechanic extends RequestEvent {
  final String mechanicId;

  const WatchAssignedMechanic(this.mechanicId);

  @override
  List<Object?> get props => [mechanicId];
}

// ============================================================
// MECHANIC LOCATION UPDATED
// ============================================================

class MechanicLocationUpdated extends RequestEvent {
  final double latitude;
  final double longitude;

  const MechanicLocationUpdated({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [
        latitude,
        longitude,
      ];
}

// ============================================================
// UPDATE MECHANIC LOCATION
// ============================================================

class UpdateMechanicLocation extends RequestEvent {
  final double latitude;
  final double longitude;

  const UpdateMechanicLocation({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [
        latitude,
        longitude,
      ];
}