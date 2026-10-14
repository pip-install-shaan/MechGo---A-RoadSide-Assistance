import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mech_go/Mechanic/Earnings/earning_event.dart';
import 'package:mech_go/Mechanic/Earnings/earning_repo.dart';
import 'package:mech_go/Mechanic/Earnings/earning_state.dart';



class MechanicEarningsBloc
    extends Bloc<MechanicEarningsEvent, MechanicEarningsState> {
  final MechanicEarningsRepository _repository;

  StreamSubscription<List<Map<String, dynamic>>>?
      _earningsSubscription;

  MechanicEarningsBloc({
    required MechanicEarningsRepository repository,
  })  : _repository = repository,
        super(const MechanicEarningsState()) {
    on<WatchMechanicEarnings>(_onWatchMechanicEarnings);
    on<_EarningsUpdated>(_onEarningsUpdated);
on<_EarningsFailed>(_onEarningsFailed);
  }

void _onEarningsUpdated(
  _EarningsUpdated event,
  Emitter<MechanicEarningsState> emit,
) {
  emit(
    state.copyWith(
      status: MechanicEarningsStatus.loaded,
      earnings: event.earnings,
      clearError: true,
    ),
  );
}

void _onEarningsFailed(
  _EarningsFailed event,
  Emitter<MechanicEarningsState> emit,
) {
  emit(
    state.copyWith(
      status: MechanicEarningsStatus.failure,
      errorMessage: event.message,
    ),
  );
}

  Future<void> _onWatchMechanicEarnings(
    WatchMechanicEarnings event,
    Emitter<MechanicEarningsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: MechanicEarningsStatus.loading,
        clearError: true,
      ),
    );

    await _earningsSubscription?.cancel();

    _earningsSubscription =
        _repository.watchMechanicEarnings().listen(
      (earnings) {
        add(
          _EarningsUpdated(earnings),
        );
      },
      onError: (error) {
        add(
          _EarningsFailed(error.toString()),
        );
      },
    );
  }

  @override
  Future<void> close() async {
    await _earningsSubscription?.cancel();
    return super.close();
  }
}

class _EarningsUpdated extends MechanicEarningsEvent {
  final List<Map<String, dynamic>> earnings;

  const _EarningsUpdated(this.earnings);
}

class _EarningsFailed extends MechanicEarningsEvent {
  final String message;

  const _EarningsFailed(this.message);
}