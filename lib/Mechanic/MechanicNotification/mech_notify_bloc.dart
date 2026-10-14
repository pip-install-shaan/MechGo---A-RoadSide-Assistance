import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'mech_notify_event.dart';
import 'mech_notify_repo.dart';
import 'mech_notify_state.dart';

class MechanicNotificationBloc
    extends Bloc<MechanicNotificationEvent,
        MechanicNotificationState> {
  final MechanicNotificationRepository
      _repository;

  StreamSubscription<
          List<MechanicNotification>>?
      _notificationSubscription;

  MechanicNotificationBloc({
    required MechanicNotificationRepository
        repository,
  })  : _repository = repository,
        super(
          const MechanicNotificationState(),
        ) {
    on<WatchMechanicNotifications>(
      _onWatchNotifications,
    );

    on<UpdateMechanicNotificationLocation>(
      _onUpdateLocation,
    );

    on<MarkNotificationAsRead>(
      _onMarkAsRead,
    );

    on<MarkAllNotificationsAsRead>(
      _onMarkAllAsRead,
    );

    on<_NotificationsUpdated>(
      _onNotificationsUpdated,
    );

    on<_NotificationsFailed>(
      _onNotificationsFailed,
    );
  }

  // --------------------------------------------------------------------------
  // WATCH
  // --------------------------------------------------------------------------

  Future<void> _onWatchNotifications(
    WatchMechanicNotifications event,
    Emitter<MechanicNotificationState>
        emit,
  ) async {
    emit(
      state.copyWith(
        status:
            MechanicNotificationStatus.loading,
        mechanicLatitude:
            event.mechanicLatitude,
        mechanicLongitude:
            event.mechanicLongitude,
        clearError: true,
      ),
    );

    await _notificationSubscription?.cancel();

    try {
      _notificationSubscription =
          _repository
              .watchNotifications(
        mechanicLatitude:
            event.mechanicLatitude,
        mechanicLongitude:
            event.mechanicLongitude,
      )
              .listen(
        (notifications) {
          add(
            _NotificationsUpdated(
              notifications,
            ),
          );
        },
        onError: (error) {
          add(
            _NotificationsFailed(
              error.toString(),
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          status:
              MechanicNotificationStatus.failure,
          errorMessage:
              e.toString(),
        ),
      );
    }
  }

  // --------------------------------------------------------------------------
  // LOCATION UPDATE
  // --------------------------------------------------------------------------

  Future<void> _onUpdateLocation(
    UpdateMechanicNotificationLocation
        event,
    Emitter<MechanicNotificationState>
        emit,
  ) async {
    add(
      WatchMechanicNotifications(
        mechanicLatitude:
            event.mechanicLatitude,
        mechanicLongitude:
            event.mechanicLongitude,
      ),
    );
  }

  // --------------------------------------------------------------------------
  // NOTIFICATIONS UPDATED
  // --------------------------------------------------------------------------

  void _onNotificationsUpdated(
    _NotificationsUpdated event,
    Emitter<MechanicNotificationState>
        emit,
  ) {
    emit(
      state.copyWith(
        status:
            MechanicNotificationStatus.loaded,
        notifications:
            event.notifications,
        clearError: true,
      ),
    );
  }

  // --------------------------------------------------------------------------
  // ERROR
  // --------------------------------------------------------------------------

  void _onNotificationsFailed(
    _NotificationsFailed event,
    Emitter<MechanicNotificationState>
        emit,
  ) {
    emit(
      state.copyWith(
        status:
            MechanicNotificationStatus.failure,
        errorMessage:
            event.message,
      ),
    );
  }

  // --------------------------------------------------------------------------
  // MARK ONE READ
  // --------------------------------------------------------------------------

  Future<void> _onMarkAsRead(
    MarkNotificationAsRead event,
    Emitter<MechanicNotificationState>
        emit,
  ) async {
    final notification =
        state.notifications
            .where(
              (item) =>
                  item.id ==
                  event.notificationId,
            )
            .firstOrNull;

    if (notification == null) {
      return;
    }

    try {
      await _repository.markAsRead(
        notification,
      );

      final updated =
          state.notifications.map(
        (item) {
          if (item.id ==
              event.notificationId) {
            return item.copyWith(
              isRead: true,
            );
          }

          return item;
        },
      ).toList();

      emit(
        state.copyWith(
          status:
              MechanicNotificationStatus.loaded,
          notifications: updated,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status:
              MechanicNotificationStatus.failure,
          errorMessage:
              e.toString(),
        ),
      );
    }
  }

  // --------------------------------------------------------------------------
  // MARK ALL READ
  // --------------------------------------------------------------------------

  Future<void> _onMarkAllAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<MechanicNotificationState>
        emit,
  ) async {
    try {
      await _repository.markAllAsRead(
        state.notifications,
      );

      final updated =
          state.notifications.map(
        (notification) {
          return notification.copyWith(
            isRead: true,
          );
        },
      ).toList();

      emit(
        state.copyWith(
          status:
              MechanicNotificationStatus.loaded,
          notifications: updated,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status:
              MechanicNotificationStatus.failure,
          errorMessage:
              e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _notificationSubscription?.cancel();
    return super.close();
  }
}

// -----------------------------------------------------------------------------
// INTERNAL EVENTS
// -----------------------------------------------------------------------------

class _NotificationsUpdated
    extends MechanicNotificationEvent {
  final List<MechanicNotification>
      notifications;

  const _NotificationsUpdated(
    this.notifications,
  );
}

class _NotificationsFailed
    extends MechanicNotificationEvent {
  final String message;

  const _NotificationsFailed(
    this.message,
  );
}