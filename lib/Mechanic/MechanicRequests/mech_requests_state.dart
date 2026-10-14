import 'package:equatable/equatable.dart';
import 'package:mech_go/User/UserRequests/request_model.dart';

enum MechRequestsStatus {
  initial,
  loading,
  loaded,
  accepting,
  accepted,
  cancelling,
  cancelled,
  updating,
  failure,
}

class MechRequestsState extends Equatable {
  final MechRequestsStatus status;

  final List<RequestModel> nearbyRequests;
  final List<RequestModel> allRequests;

  final String? errorMessage;
  final String? actionRequestId;

  const MechRequestsState({
    this.status = MechRequestsStatus.initial,
    this.nearbyRequests = const [],
    this.allRequests = const [],
    this.errorMessage,
    this.actionRequestId,
  });

  MechRequestsState copyWith({
    MechRequestsStatus? status,
    List<RequestModel>? nearbyRequests,
    List<RequestModel>? allRequests,
    String? errorMessage,
    String? actionRequestId,
    bool clearError = false,
    bool clearActionRequestId = false,
  }) {
    return MechRequestsState(
      status: status ?? this.status,
      nearbyRequests: nearbyRequests ?? this.nearbyRequests,
      allRequests: allRequests ?? this.allRequests,
      errorMessage:
          clearError ? null : errorMessage ?? this.errorMessage,
      actionRequestId: clearActionRequestId
          ? null
          : actionRequestId ?? this.actionRequestId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        nearbyRequests,
        allRequests,
        errorMessage,
        actionRequestId,
      ];
}