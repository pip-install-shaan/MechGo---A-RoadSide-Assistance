import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'mech_profile_event.dart';
import 'mech_profile_repo.dart';
import 'mech_profile_state.dart';

class MechanicProfileBloc
    extends Bloc<MechanicProfileEvent, MechanicProfileState> {
  final MechanicProfileRepository _repository;

  StreamSubscription<Map<String, dynamic>>?
      _profileSubscription;

  MechanicProfileBloc({
    required MechanicProfileRepository repository,
  })  : _repository = repository,
        super(const MechanicProfileState()) {
    on<FetchMechanicProfile>(_onFetchMechanicProfile);
    on<UpdateMechanicProfile>(_onUpdateMechanicProfile);
    on<LogoutMechanic>(_onLogoutMechanic);

    on<_ProfileUpdated>(_onProfileUpdated);
    on<_ProfileFailed>(_onProfileFailed);
  }

  // --------------------------------------------------------------------------
  // FETCH PROFILE
  // --------------------------------------------------------------------------

  Future<void> _onFetchMechanicProfile(
    FetchMechanicProfile event,
    Emitter<MechanicProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        status: MechanicProfileStatus.loading,
        clearError: true,
      ),
    );

    await _profileSubscription?.cancel();

    try {
      _profileSubscription =
          _repository.watchMechanicProfile().listen(
        (profile) {
          add(
            _ProfileUpdated(profile),
          );
        },
        onError: (error) {
          add(
            _ProfileFailed(
              error.toString(),
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MechanicProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // --------------------------------------------------------------------------
  // PROFILE UPDATED
  // --------------------------------------------------------------------------

  void _onProfileUpdated(
    _ProfileUpdated event,
    Emitter<MechanicProfileState> emit,
  ) {
    final profile = event.profile;

    emit(
      state.copyWith(
        status: MechanicProfileStatus.loaded,
        name: profile['name'] ?? '',
        email: profile['email'] ?? '',
        phone: profile['phone'] ?? '',
        role: profile['role'] ?? 'mechanic',
        workshopName:
            profile['workshopName'] ?? '',
        specialization:
            profile['specialization'] ?? 'Mechanic',
        profilePic:
            profile['profilePic'] ?? '',
        rating:
            (profile['rating'] ?? 0).toDouble(),
        reviewCount:
            (profile['reviewCount'] ?? 0).toInt(),
        clearError: true,
      ),
    );
  }

  // --------------------------------------------------------------------------
  // PROFILE ERROR
  // --------------------------------------------------------------------------

  void _onProfileFailed(
    _ProfileFailed event,
    Emitter<MechanicProfileState> emit,
  ) {
    emit(
      state.copyWith(
        status: MechanicProfileStatus.failure,
        errorMessage: event.message,
      ),
    );
  }

  // --------------------------------------------------------------------------
  // UPDATE PROFILE
  // --------------------------------------------------------------------------

  Future<void> _onUpdateMechanicProfile(
    UpdateMechanicProfile event,
    Emitter<MechanicProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        status: MechanicProfileStatus.updating,
        clearError: true,
      ),
    );

    try {
      await _repository.updateMechanicProfile(
        name: event.name,
        workshopName: event.workshopName,
        specialization: event.specialization,
        profileImage: event.profileImage,
      );

      emit(
        state.copyWith(
          status: MechanicProfileStatus.updateSuccess,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MechanicProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // --------------------------------------------------------------------------
  // LOGOUT
  // --------------------------------------------------------------------------

  Future<void> _onLogoutMechanic(
    LogoutMechanic event,
    Emitter<MechanicProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        status: MechanicProfileStatus.loggingOut,
        clearError: true,
      ),
    );

    try {
      await _profileSubscription?.cancel();

      await _repository.logout();

      emit(
        state.copyWith(
          status: MechanicProfileStatus.logoutSuccess,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MechanicProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _profileSubscription?.cancel();
    return super.close();
  }
}

// --------------------------------------------------------------------------
// INTERNAL EVENTS
// --------------------------------------------------------------------------

class _ProfileUpdated extends MechanicProfileEvent {
  final Map<String, dynamic> profile;

  const _ProfileUpdated(this.profile);
}

class _ProfileFailed extends MechanicProfileEvent {
  final String message;

  const _ProfileFailed(this.message);
}