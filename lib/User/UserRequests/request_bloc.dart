import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import 'request_event.dart';
import 'request_repo.dart';
import 'request_state.dart';

class RequestBloc
    extends Bloc<RequestEvent, RequestState> {
  final RequestRepository _requestRepository;

  StreamSubscription?
      _myRequestsSubscription;

  StreamSubscription?
      _requestSubscription;

  StreamSubscription?
      _pendingRequestsSubscription;

  StreamSubscription?
      _mechanicLocationSubscription;

  RequestBloc({
    required RequestRepository requestRepository,
  })  : _requestRepository =
            requestRepository,
        super(const RequestState()) {
    on<CreateRequest>(_onCreateRequest);

    on<WatchMyRequests>(
      _onWatchMyRequests,
    );

    on<MyRequestsUpdated>(
      _onMyRequestsUpdated,
    );

    on<MyRequestsFailed>(
      _onMyRequestsFailed,
    );

    on<WatchRequest>(
      _onWatchRequest,
    );

    on<RequestUpdated>(
      _onRequestUpdated,
    );

    on<CancelRequest>(
      _onCancelRequest,
    );

    on<WatchPendingRequests>(
      _onWatchPendingRequests,
    );

    on<PendingRequestsUpdated>(
      _onPendingRequestsUpdated,
    );

    on<AcceptRequest>(
      _onAcceptRequest,
    );
     
     on<RejectMechanic>(
      _onRejectMechanic,
     );
    on<WatchAssignedMechanic>(
      _onWatchAssignedMechanic,
    );

    on<MechanicLocationUpdated>(
      _onMechanicLocationUpdated,
    );

    on<UpdateMechanicLocation>(
      _onUpdateMechanicLocation,
    );
  }

  // ============================================================
  // CREATE REQUEST
  // ============================================================
   
   // ============================================================
// REJECT MECHANIC
// ============================================================

Future<void> _onRejectMechanic(
  RejectMechanic event,
  Emitter<RequestState> emit,
) async {
  emit(
    state.copyWith(
      status: RequestStatus.loading,
      clearError: true,
    ),
  );

  try {
    await _requestRepository.rejectMechanic(
      event.requestId,
    );

    emit(
      state.copyWith(
        status: RequestStatus.loaded,
        clearError: true,
      ),
    );
  } catch (e) {
    emit(
      state.copyWith(
        status: RequestStatus.failure,
        errorMessage: e.toString(),
      ),
    );
  }
}

  Future<void> _onCreateRequest(
    CreateRequest event,
    Emitter<RequestState> emit,
  ) async {
    emit(
      state.copyWith(
        status: RequestStatus.creating,
        clearError: true,
      ),
    );

    try {
      final requestId =
          await _requestRepository
              .createServiceRequest(
        vehicleType:
            event.vehicleType,
        problemType:
            event.problemType,
        description:
            event.description,
        location:
            event.location,
        latitude:
            event.latitude,
        longitude:
            event.longitude,
        imagePaths:
            event.imagePaths, amount: event.amount,
      );

      emit(
        state.copyWith(
          status:
              RequestStatus.created,
          requestId:
              requestId,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status:
              RequestStatus.failure,
          errorMessage:
              e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // WATCH USER REQUESTS
  // ============================================================

  Future<void> _onWatchMyRequests(
    WatchMyRequests event,
    Emitter<RequestState> emit,
  ) async {
    emit(
      state.copyWith(
        status:
            RequestStatus.loading,
        clearError: true,
      ),
    );

    await _myRequestsSubscription?.cancel();

    _myRequestsSubscription =
        _requestRepository
            .watchMyRequests()
            .listen(
      (requests) {
        add(
          MyRequestsUpdated(
            requests,
          ),
        );
      },
      onError: (error) {
        add(
          MyRequestsFailed(
            error.toString(),
          ),
        );
      },
    );
  }

  // ============================================================
  // USER REQUESTS UPDATED
  // ============================================================

  void _onMyRequestsUpdated(
    MyRequestsUpdated event,
    Emitter<RequestState> emit,
  ) {
    emit(
      state.copyWith(
        status:
            RequestStatus.loaded,
        requests:
            event.requests,
        clearError: true,
      ),
    );
  }

  // ============================================================
  // REQUEST ERROR
  // ============================================================

  void _onMyRequestsFailed(
    MyRequestsFailed event,
    Emitter<RequestState> emit,
  ) {
    emit(
      state.copyWith(
        status:
            RequestStatus.failure,
        errorMessage:
            event.message,
      ),
    );
  }

  // ============================================================
  // WATCH SINGLE REQUEST
  // ============================================================

  Future<void> _onWatchRequest(
    WatchRequest event,
    Emitter<RequestState> emit,
  ) async {
    emit(
      state.copyWith(
        status:
            RequestStatus.loading,
        clearError: true,
      ),
    );

    await _requestSubscription?.cancel();

    _requestSubscription =
        _requestRepository
            .watchRequest(
              event.requestId,
            )
            .listen(
      (request) {
        add(
          RequestUpdated(
            request,
          ),
        );
      },
      onError: (error) {
        add(
          MyRequestsFailed(
            error.toString(),
          ),
        );
      },
    );
  }

  // ============================================================
  // SINGLE REQUEST UPDATED
  // ============================================================

  void _onRequestUpdated(
    RequestUpdated event,
    Emitter<RequestState> emit,
  ) {
    if (event.request == null) {
      emit(
        state.copyWith(
          status:
              RequestStatus.failure,
          errorMessage:
              'Request not found.',
        ),
      );

      return;
    }

    emit(
      state.copyWith(
        status:
            RequestStatus.loaded,
        selectedRequest:
            event.request,
        clearError: true,
      ),
    );
  }

  // ============================================================
  // CANCEL
  // ============================================================

  Future<void> _onCancelRequest(
    CancelRequest event,
    Emitter<RequestState> emit,
  ) async {
    emit(
      state.copyWith(
        status:
            RequestStatus.loading,
        clearError: true,
      ),
    );

    try {
      await _requestRepository
          .cancelRequest(
        event.requestId,
      );

      emit(
        state.copyWith(
          status:
              RequestStatus.cancelled,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status:
              RequestStatus.failure,
          errorMessage:
              e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // MECHANIC PENDING REQUESTS
  // ============================================================

  Future<void> _onWatchPendingRequests(
    WatchPendingRequests event,
    Emitter<RequestState> emit,
  ) async {
    emit(
      state.copyWith(
        status:
            RequestStatus.loading,
        clearError: true,
      ),
    );

    await _pendingRequestsSubscription
        ?.cancel();

    _pendingRequestsSubscription =
        _requestRepository
            .watchPendingRequests()
            .listen(
      (requests) {
        final nearbyRequests =
            requests.where((request) {
          final distance =
              _distanceInKm(
            event.mechanicLatitude,
            event.mechanicLongitude,
            request.latitude,
            request.longitude,
          );

          return distance <=
              event.radiusKm;
        }).toList();

        add(
          PendingRequestsUpdated(
            nearbyRequests,
          ),
        );
      },
      onError: (error) {
        add(
          MyRequestsFailed(
            error.toString(),
          ),
        );
      },
    );
  }

  // ============================================================
  // PENDING UPDATED
  // ============================================================

  void _onPendingRequestsUpdated(
    PendingRequestsUpdated event,
    Emitter<RequestState> emit,
  ) {
    emit(
      state.copyWith(
        status:
            RequestStatus.loaded,
        requests:
            event.requests,
        clearError: true,
      ),
    );
  }

  // ============================================================
  // ACCEPT
  // ============================================================

  Future<void> _onAcceptRequest(
    AcceptRequest event,
    Emitter<RequestState> emit,
  ) async {
    emit(
      state.copyWith(
        status:
            RequestStatus.accepting,
        clearError: true,
      ),
    );

    try {
      final user =
          _requestRepository.currentUser;

      if (user == null) {
        throw Exception(
          'Mechanic is not logged in.',
        );
      }

      final accepted =
          await _requestRepository
              .acceptRequest(
        requestId:
            event.requestId,
        mechanicId:
            user.uid,
      );

      if (!accepted) {
        throw Exception(
          'This request has already been accepted by another mechanic.',
        );
      }

      emit(
        state.copyWith(
          status:
              RequestStatus.accepted,
          requestId:
              event.requestId,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status:
              RequestStatus.failure,
          errorMessage:
              e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // USER WATCHES ASSIGNED MECHANIC
  // ============================================================

// ============================================================
// USER WATCHES ASSIGNED MECHANIC
// ============================================================

Future<void> _onWatchAssignedMechanic(
  WatchAssignedMechanic event,
  Emitter<RequestState> emit,
) async {
  emit(
    state.copyWith(
      status:
          RequestStatus.mechanicLocationLoading,
      clearError: true,
    ),
  );

  await _mechanicLocationSubscription
      ?.cancel();

  _mechanicLocationSubscription =
      _requestRepository
          .watchMechanicLocation(
            event.mechanicId,
          )
          .listen(
    (location) {
      if (location == null) {
        return;
      }

      final latitude =
          location['latitude'];

      final longitude =
          location['longitude'];

      if (latitude == null ||
          longitude == null) {
        return;
      }

      add(
        MechanicLocationUpdated(
          latitude: latitude,
          longitude: longitude,
        ),
      );
    },
  );
}

  // ============================================================
  // MECHANIC LOCATION UPDATED
  // ============================================================

  void _onMechanicLocationUpdated(
    MechanicLocationUpdated event,
    Emitter<RequestState> emit,
  ) {
    emit(
      state.copyWith(
        status:
            RequestStatus.mechanicLocationUpdated,
        mechanicLatitude:
            event.latitude,
        mechanicLongitude:
            event.longitude,
      ),
    );
  }

  // ============================================================
  // MECHANIC UPDATES OWN LOCATION
  // ============================================================

  Future<void> _onUpdateMechanicLocation(
    UpdateMechanicLocation event,
    Emitter<RequestState> emit,
  ) async {
    try {
      await _requestRepository
          .updateMechanicLocation(
        latitude:
            event.latitude,
        longitude:
            event.longitude,
      );
    } catch (e) {
      emit(
        state.copyWith(
          status:
              RequestStatus.failure,
          errorMessage:
              e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // DISTANCE
  // ============================================================

  double _distanceInKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371.0;

    final dLat =
        _degreesToRadians(
      lat2 - lat1,
    );

    final dLon =
        _degreesToRadians(
      lon2 - lon1,
    );

    final a =
        _sin(dLat / 2) *
                _sin(dLat / 2) +
            _cos(
                  _degreesToRadians(lat1),
                ) *
                _cos(
                  _degreesToRadians(lat2),
                ) *
                _sin(dLon / 2) *
                _sin(dLon / 2);

    final c =
        2 *
            _atan2(
              _sqrt(a),
              _sqrt(1 - a),
            );

    return earthRadius * c;
  }

  double _degreesToRadians(
    double degrees,
  ) {
    return degrees * 3.141592653589793 / 180;
  }
double _sin(double value) => math.sin(value);

double _cos(double value) => math.cos(value);

double _sqrt(double value) => math.sqrt(value);

double _atan2(double y, double x) => math.atan2(y, x);

  @override
  Future<void> close() async {
    await _myRequestsSubscription
        ?.cancel();

    await _requestSubscription
        ?.cancel();

    await _pendingRequestsSubscription
        ?.cancel();

    await _mechanicLocationSubscription
        ?.cancel();

    return super.close();
  }
}