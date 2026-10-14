import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mech_go/Mechanic/MechanicRequests/mech_request_event.dart';
import 'mech_requests_repo.dart';
import 'mech_requests_state.dart';

class MechRequestsBloc
    extends Bloc<MechRequestsEvent, MechRequestsState> {
  final MechRequestsRepository _repository;

  StreamSubscription? _nearbySubscription;
  StreamSubscription? _allRequestsSubscription;

  MechRequestsBloc({
    required MechRequestsRepository repository,
  })  : _repository = repository,
        super(const MechRequestsState()) {
    on<WatchNearbyRequests>(_onWatchNearbyRequests);
    on<WatchAllMechanicRequests>(_onWatchAllMechanicRequests);

    on<AcceptMechanicRequest>(_onAcceptMechanicRequest);
    on<CancelMechanicRequest>(_onCancelMechanicRequest);
    on<MarkRequestOnTheWay>(_onMarkRequestOnTheWay);

    on<RefreshMechanicRequests>(
      _onRefreshMechanicRequests,
    );
  }

  /// ------------------------------------------------------------
  /// HOME - NEARBY REQUESTS
  /// ------------------------------------------------------------

  Future<void> _onWatchNearbyRequests(
    WatchNearbyRequests event,
    Emitter<MechRequestsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: MechRequestsStatus.loading,
        clearError: true,
      ),
    );

    await _nearbySubscription?.cancel();

    _nearbySubscription =
        _repository
            .watchNearbyRequests(
              mechanicLatitude:
                  event.mechanicLatitude,
              mechanicLongitude:
                  event.mechanicLongitude,
              radiusKm: event.radiusKm,
            )
            .listen(
      (requests) {
        add(
          _NearbyRequestsUpdated(requests),
        );
      },
      onError: (error) {
        add(
          _NearbyRequestsFailed(
            error.toString(),
          ),
        );
      },
    );
  }

  /// ------------------------------------------------------------
  /// ALL REQUESTS SCREEN
  /// ------------------------------------------------------------

  Future<void> _onWatchAllMechanicRequests(
    WatchAllMechanicRequests event,
    Emitter<MechRequestsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: MechRequestsStatus.loading,
        clearError: true,
      ),
    );

    await _allRequestsSubscription?.cancel();

    _allRequestsSubscription =
        _repository
            .watchAllMechanicRequests(
              mechanicLatitude:
                  event.mechanicLatitude,
              mechanicLongitude:
                  event.mechanicLongitude,
              radiusKm: event.radiusKm,
            )
            .listen(
      (requests) {
        add(
          _AllRequestsUpdated(requests),
        );
      },
      onError: (error) {
        add(
          _AllRequestsFailed(
            error.toString(),
          ),
        );
      },
    );
  }

  /// ------------------------------------------------------------
  /// ACCEPT
  /// ------------------------------------------------------------

  Future<void> _onAcceptMechanicRequest(
    AcceptMechanicRequest event,
    Emitter<MechRequestsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: MechRequestsStatus.accepting,
        actionRequestId: event.requestId,
        clearError: true,
      ),
    );

    try {
      await _repository.acceptRequest(
        event.requestId,
      );

      emit(
        state.copyWith(
          status: MechRequestsStatus.accepted,
          actionRequestId: event.requestId,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MechRequestsStatus.failure,
          errorMessage: e.toString(),
          actionRequestId: event.requestId,
        ),
      );
    }
  }

  /// ------------------------------------------------------------
  /// CANCEL
  /// ------------------------------------------------------------

  Future<void> _onCancelMechanicRequest(
    CancelMechanicRequest event,
    Emitter<MechRequestsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: MechRequestsStatus.cancelling,
        actionRequestId: event.requestId,
        clearError: true,
      ),
    );

    try {
      await _repository.cancelRequest(
        event.requestId,
      );

      emit(
        state.copyWith(
          status: MechRequestsStatus.cancelled,
          actionRequestId: event.requestId,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MechRequestsStatus.failure,
          errorMessage: e.toString(),
          actionRequestId: event.requestId,
        ),
      );
    }
  }

  /// ------------------------------------------------------------
  /// ON THE WAY
  /// ------------------------------------------------------------

  Future<void> _onMarkRequestOnTheWay(
    MarkRequestOnTheWay event,
    Emitter<MechRequestsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: MechRequestsStatus.updating,
        actionRequestId: event.requestId,
        clearError: true,
      ),
    );

    try {
      await _repository.markOnTheWay(
        event.requestId,
      );

      emit(
        state.copyWith(
          status: MechRequestsStatus.loaded,
          actionRequestId: event.requestId,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MechRequestsStatus.failure,
          errorMessage: e.toString(),
          actionRequestId: event.requestId,
        ),
      );
    }
  }

  /// ------------------------------------------------------------
  /// REFRESH
  /// ------------------------------------------------------------

  Future<void> _onRefreshMechanicRequests(
    RefreshMechanicRequests event,
    Emitter<MechRequestsState> emit,
  ) async {
    add(
      WatchNearbyRequests(
        mechanicLatitude:
            event.mechanicLatitude,
        mechanicLongitude:
            event.mechanicLongitude,
        radiusKm: event.radiusKm,
      ),
    );

    add(
      WatchAllMechanicRequests(
        mechanicLatitude:
            event.mechanicLatitude,
        mechanicLongitude:
            event.mechanicLongitude,
        radiusKm: event.radiusKm,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _nearbySubscription?.cancel();
    await _allRequestsSubscription?.cancel();

    return super.close();
  }
}

/// Internal event
class _NearbyRequestsUpdated
    extends MechRequestsEvent {
  final List requests;

  const _NearbyRequestsUpdated(this.requests);

  @override
  List<Object?> get props => [requests];
}

/// Internal event
class _AllRequestsUpdated
    extends MechRequestsEvent {
  final List requests;

  const _AllRequestsUpdated(this.requests);

  @override
  List<Object?> get props => [requests];
}

/// Internal event
class _NearbyRequestsFailed
    extends MechRequestsEvent {
  final String message;

  const _NearbyRequestsFailed(this.message);

  @override
  List<Object?> get props => [message];
}

/// Internal event
class _AllRequestsFailed
    extends MechRequestsEvent {
  final String message;

  const _AllRequestsFailed(this.message);

  @override
  List<Object?> get props => [message];
}