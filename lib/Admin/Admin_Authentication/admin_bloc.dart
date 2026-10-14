import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'admin_event.dart';
import 'admin_repo.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository _adminRepository;

  StreamSubscription<List<Map<String, dynamic>>>?
      _usersSubscription;

  StreamSubscription<List<Map<String, dynamic>>>?
      _mechanicsSubscription;

  AdminBloc({
    required AdminRepository adminRepository,
  }) : _adminRepository = adminRepository,
       super(const AdminState()) {

    // =========================================
    // DASHBOARD
    // =========================================

    on<LoadAdminDashboard>(
      _onLoadAdminDashboard,
    );

    // =========================================
    // ALL REQUESTS
    // =========================================

    on<LoadAllAdminRequests>(
      _onLoadAllAdminRequests,
    );

    // =========================================
    // WATCH USERS
    // =========================================

    on<WatchAdminUsers>(
      _onWatchAdminUsers,
    );

    // =========================================
    // WATCH MECHANICS
    // =========================================

    on<WatchAdminMechanics>(
      _onWatchAdminMechanics,
    );

    // =========================================
    // DELETE USER
    // =========================================

    on<DeleteAdminUser>(
      _onDeleteAdminUser,
    );

    // =========================================
    // DELETE MECHANIC
    // =========================================

    on<DeleteAdminMechanic>(
      _onDeleteAdminMechanic,
    );

    // =========================================
    // USERS UPDATED
    // =========================================

    on<AdminUsersUpdated>(
      (event, emit) {
        emit(
          state.copyWith(
            status: AdminStatus.success,
            users: event.users,
            totalUsers: event.users.length,
            clearError: true,
          ),
        );
      },
    );

    // =========================================
    // USERS FAILED
    // =========================================

    on<AdminUsersFailed>(
      (event, emit) {
        emit(
          state.copyWith(
            status: AdminStatus.failure,
            errorMessage: event.message,
          ),
        );
      },
    );

    // =========================================
    // MECHANICS UPDATED
    // =========================================

    on<AdminMechanicsUpdated>(
      (event, emit) {
        emit(
          state.copyWith(
            status: AdminStatus.success,
            mechanics: event.mechanics,
            totalMechanics: event.mechanics.length,
            clearError: true,
          ),
        );
      },
    );

    // =========================================
    // MECHANICS FAILED
    // =========================================

    on<AdminMechanicsFailed>(
      (event, emit) {
        emit(
          state.copyWith(
            status: AdminStatus.failure,
            errorMessage: event.message,
          ),
        );
      },
    );
  }

  // =========================================
  // WATCH USERS
  // =========================================

  void _onWatchAdminUsers(
    WatchAdminUsers event,
    Emitter<AdminState> emit,
  ) {
    emit(
      state.copyWith(
        status: AdminStatus.loading,
        clearError: true,
      ),
    );

    _usersSubscription?.cancel();

    _usersSubscription =
        _adminRepository.watchUsers().listen(
      (users) {
        add(
          AdminUsersUpdated(users),
        );
      },
      onError: (error) {
        add(
          AdminUsersFailed(
            error.toString(),
          ),
        );
      },
    );
  }

  // =========================================
  // WATCH MECHANICS
  // =========================================

  void _onWatchAdminMechanics(
    WatchAdminMechanics event,
    Emitter<AdminState> emit,
  ) {
    emit(
      state.copyWith(
        status: AdminStatus.loading,
        clearError: true,
      ),
    );

    _mechanicsSubscription?.cancel();

    _mechanicsSubscription =
        _adminRepository.watchMechanics().listen(
      (mechanics) {
        add(
          AdminMechanicsUpdated(mechanics),
        );
      },
      onError: (error) {
        add(
          AdminMechanicsFailed(
            error.toString(),
          ),
        );
      },
    );
  }

  // =========================================
  // LOAD ADMIN DASHBOARD
  // =========================================

  Future<void> _onLoadAdminDashboard(
    LoadAdminDashboard event,
    Emitter<AdminState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AdminStatus.loading,
        clearError: true,
      ),
    );

    try {
      final results = await Future.wait([
        _adminRepository.getTotalUsers(),
        _adminRepository.getTotalMechanics(),
        _adminRepository.getActiveRequests(),
        _adminRepository.getCompletedRequests(),
        _adminRepository.getTotalEarnings(),
        _adminRepository.getRecentRequests(),
      ]);

      emit(
        state.copyWith(
          status: AdminStatus.success,
          totalUsers: results[0] as int,
          totalMechanics: results[1] as int,
          activeRequests: results[2] as int,
          completedRequests: results[3] as int,
          totalEarnings: results[4] as double,
          recentRequests:
              results[5] as List<Map<String, dynamic>>,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AdminStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // =========================================
  // LOAD ALL REQUESTS
  // =========================================

  Future<void> _onLoadAllAdminRequests(
    LoadAllAdminRequests event,
    Emitter<AdminState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AdminStatus.loading,
        clearError: true,
      ),
    );

    try {
      final requests =
          await _adminRepository.getAllRequests();

      emit(
        state.copyWith(
          status: AdminStatus.success,
          allRequests: requests,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AdminStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // =========================================
  // DELETE USER
  // =========================================

  Future<void> _onDeleteAdminUser(
    DeleteAdminUser event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _adminRepository.deleteUser(
        event.uid,
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AdminStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // =========================================
  // DELETE MECHANIC
  // =========================================



  Future<void> _onDeleteAdminMechanic(
    DeleteAdminMechanic event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _adminRepository.deleteMechanic(
        event.uid,
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AdminStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // =========================================
  // CLOSE BLOC
  // =========================================

  @override
  Future<void> close() {
    _usersSubscription?.cancel();
    _mechanicsSubscription?.cancel();

    return super.close();
  }


}