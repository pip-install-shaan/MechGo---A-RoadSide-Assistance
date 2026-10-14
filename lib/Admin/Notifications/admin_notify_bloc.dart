import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'admin_notify_event.dart';
import 'admin_notify_repo.dart';
import 'admin_notify_state.dart';

class AdminNotifyBloc
    extends Bloc<AdminNotifyEvent, AdminNotifyState> {
  final AdminNotifyRepository _repository;

  StreamSubscription<List<AdminNotificationModel>>?
      _notificationsSubscription;

  AdminNotifyBloc({
    required AdminNotifyRepository repository,
  })  : _repository = repository,
        super(const AdminNotifyState()) {
    on<WatchAdminNotifications>(
      _onWatchAdminNotifications,
    );

    on<MarkAdminNotificationAsRead>(
      _onMarkNotificationAsRead,
    );

    on<MarkAllAdminNotificationsAsRead>(
      _onMarkAllNotificationsAsRead,
    );

    on<DeleteAdminNotification>(
      _onDeleteNotification,
    );

    on<DeleteAllAdminNotifications>(
      _onDeleteAllNotifications,
    );
  }

  // ==========================================================
  // WATCH
  // ==========================================================

  Future<void> _onWatchAdminNotifications(
    WatchAdminNotifications event,
    Emitter<AdminNotifyState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AdminNotifyStatus.loading,
        clearError: true,
      ),
    );

    await _notificationsSubscription?.cancel();

    _notificationsSubscription =
        _repository.watchAdminNotifications().listen(
      (notifications) {
        add(
          _AdminNotificationsUpdated(
            notifications,
          ),
        );
      },
      onError: (error) {
        add(
          _AdminNotificationsFailed(
            error.toString(),
          ),
        );
      },
    );
  }

  // ==========================================================
  // MARK ONE READ
  // ==========================================================

  Future<void> _onMarkNotificationAsRead(
    MarkAdminNotificationAsRead event,
    Emitter<AdminNotifyState> emit,
  ) async {
    try {
      await _repository.markAsRead(
        event.notificationId,
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AdminNotifyStatus.failure,
          errorMessage:
              'Unable to mark notification as read: $e',
        ),
      );
    }
  }

  // ==========================================================
  // MARK ALL READ
  // ==========================================================

  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllAdminNotificationsAsRead event,
    Emitter<AdminNotifyState> emit,
  ) async {
    try {
      await _repository.markAllAsRead();
    } catch (e) {
      emit(
        state.copyWith(
          status: AdminNotifyStatus.failure,
          errorMessage:
              'Unable to mark all notifications as read: $e',
        ),
      );
    }
  }

  // ==========================================================
  // DELETE ONE
  // ==========================================================

  Future<void> _onDeleteNotification(
    DeleteAdminNotification event,
    Emitter<AdminNotifyState> emit,
  ) async {
    try {
      await _repository.deleteNotification(
        event.notificationId,
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AdminNotifyStatus.failure,
          errorMessage:
              'Unable to delete notification: $e',
        ),
      );
    }
  }

  // ==========================================================
  // DELETE ALL
  // ==========================================================

  Future<void> _onDeleteAllNotifications(
    DeleteAllAdminNotifications event,
    Emitter<AdminNotifyState> emit,
  ) async {
    try {
      await _repository.deleteAllNotifications();
    } catch (e) {
      emit(
        state.copyWith(
          status: AdminNotifyStatus.failure,
          errorMessage:
              'Unable to delete notifications: $e',
        ),
      );
    }
  }

  // ==========================================================
  // INTERNAL EVENTS
  // ==========================================================

  void onInternalNotificationsUpdated(
    _AdminNotificationsUpdated event,
    Emitter<AdminNotifyState> emit,
  ) {
    emit(
      state.copyWith(
        status: AdminNotifyStatus.loaded,
        notifications: event.notifications,
        clearError: true,
      ),
    );
  }

  void onInternalNotificationsFailed(
    _AdminNotificationsFailed event,
    Emitter<AdminNotifyState> emit,
  ) {
    emit(
      state.copyWith(
        status: AdminNotifyStatus.failure,
        errorMessage: event.error,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _notificationsSubscription?.cancel();
    return super.close();
  }
}

// ==========================================================
// INTERNAL BLOC EVENTS
// ==========================================================

class _AdminNotificationsUpdated
    extends AdminNotifyEvent {
  final List<AdminNotificationModel> notifications;

  const _AdminNotificationsUpdated(
    this.notifications,
  );

  @override
  List<Object?> get props => [notifications];
}

class _AdminNotificationsFailed
    extends AdminNotifyEvent {
  final String error;

  const _AdminNotificationsFailed(
    this.error,
  );

  @override
  List<Object?> get props => [error];
}