import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'user_profile_event.dart';
import 'user_profile_repo.dart';
import 'user_profile.state.dart';
import 'user_profile_model.dart';

class UserProfileBloc
    extends Bloc<UserProfileEvent, UserProfileState> {
  final UserProfileRepository _repository;

  StreamSubscription<UserProfileModel>?
      _profileSubscription;

  UserProfileBloc({
    required UserProfileRepository repository,
  })  : _repository = repository,
        super(const UserProfileState()) {
    on<FetchUserProfile>(_onFetchUserProfile);
    on<WatchUserProfile>(_onWatchUserProfile);
    on<FetchCompletedPaymentRequest>(
      _onFetchCompletedPaymentRequest,
    );
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<LogoutUser>(_onLogoutUser);
  }

  // ==========================================================
  // FETCH / WATCH PROFILE
  // ==========================================================

  Future<void> _onFetchUserProfile(
    FetchUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        status: UserProfileStatus.loading,
        clearError: true,
      ),
    );

    await _profileSubscription?.cancel();

    _profileSubscription =
        _repository.watchUserProfile().listen(
      (user) {
        add(
          _InternalProfileUpdated(user),
        );
      },
      onError: (error) {
        add(
          _InternalProfileFailed(
            error.toString(),
          ),
        );
      },
    );

    add(
      const FetchCompletedPaymentRequest(),
    );
  }

  Future<void> _onWatchUserProfile(
    WatchUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    await _profileSubscription?.cancel();

    _profileSubscription =
        _repository.watchUserProfile().listen(
      (user) {
        add(
          _InternalProfileUpdated(user),
        );
      },
      onError: (error) {
        add(
          _InternalProfileFailed(
            error.toString(),
          ),
        );
      },
    );
  }

  // ==========================================================
  // COMPLETED PAYMENT REQUEST
  // ==========================================================

  Future<void> _onFetchCompletedPaymentRequest(
    FetchCompletedPaymentRequest event,
    Emitter<UserProfileState> emit,
  ) async {
    try {
      final paymentRequest =
          await _repository.getCompletedPaymentRequest();

      emit(
        state.copyWith(
          completedPaymentRequest:
              paymentRequest,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ==========================================================
  // UPDATE PROFILE
  // ==========================================================

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        status: UserProfileStatus.updating,
        clearError: true,
      ),
    );

    try {
      await _repository.updateUserProfile(
        name: event.name,
        profilePic: event.profilePic,
      );

      emit(
        state.copyWith(
          status: UserProfileStatus.loaded,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: UserProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================

  Future<void> _onLogoutUser(
    LogoutUser event,
    Emitter<UserProfileState> emit,
  ) async {
    try {
      await _repository.logout();

      emit(
        state.copyWith(
          status: UserProfileStatus.loggedOut,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: UserProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ==========================================================
  // INTERNAL PROFILE UPDATED
  // ==========================================================

  void onInternalProfileUpdated(
    _InternalProfileUpdated event,
    Emitter<UserProfileState> emit,
  ) {
    emit(
      state.copyWith(
        status: UserProfileStatus.loaded,
        user: event.user,
        clearError: true,
      ),
    );
  }

  void onInternalProfileFailed(
    _InternalProfileFailed event,
    Emitter<UserProfileState> emit,
  ) {
    emit(
      state.copyWith(
        status: UserProfileStatus.failure,
        errorMessage: event.message,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _profileSubscription?.cancel();
    return super.close();
  }
}

// ============================================================
// INTERNAL EVENTS
// ============================================================

class _InternalProfileUpdated extends UserProfileEvent {
  final UserProfileModel user;

  const _InternalProfileUpdated(this.user);

  @override
  List<Object?> get props => [user];
}

class _InternalProfileFailed extends UserProfileEvent {
  final String message;

  const _InternalProfileFailed(this.message);

  @override
  List<Object?> get props => [message];
}