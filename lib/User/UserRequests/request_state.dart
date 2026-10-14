import 'package:equatable/equatable.dart';

import 'request_model.dart';

enum RequestStatus {
  initial,

  loading,

  creating,
  created,

  loaded,

  cancelled,

  accepting,
  accepted,

  mechanicLocationLoading,
  mechanicLocationUpdated,

  failure,
}

class RequestState extends Equatable {
  final RequestStatus status;

  final String? requestId;

  final List<RequestModel> requests;

  final RequestModel? selectedRequest;

  final double? mechanicLatitude;
  final double? mechanicLongitude;

  final String? errorMessage;

  const RequestState({
    this.status = RequestStatus.initial,
    this.requestId,
    this.requests = const [],
    this.selectedRequest,
    this.mechanicLatitude,
    this.mechanicLongitude,
    this.errorMessage,
  });

  RequestState copyWith({
    RequestStatus? status,
    String? requestId,
    List<RequestModel>? requests,
    RequestModel? selectedRequest,
    double? mechanicLatitude,
    double? mechanicLongitude,
    String? errorMessage,

    bool clearError = false,
    bool clearSelectedRequest = false,
    bool clearMechanicLocation = false,
  }) {
    return RequestState(
      status: status ?? this.status,

      requestId: requestId ?? this.requestId,

      requests: requests ?? this.requests,

      selectedRequest: clearSelectedRequest
          ? null
          : selectedRequest ?? this.selectedRequest,

      mechanicLatitude: clearMechanicLocation
          ? null
          : mechanicLatitude ?? this.mechanicLatitude,

      mechanicLongitude: clearMechanicLocation
          ? null
          : mechanicLongitude ?? this.mechanicLongitude,

      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        requestId,
        requests,
        selectedRequest,
        mechanicLatitude,
        mechanicLongitude,
        errorMessage,
      ];
}