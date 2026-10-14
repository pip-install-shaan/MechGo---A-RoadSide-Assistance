import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mech_go/User/UserNotifications/user_notify_event.dart';
import 'package:mech_go/User/UserNotifications/user_notify_model.dart';
import 'package:mech_go/User/UserNotifications/user_notify_repo.dart';
import 'package:mech_go/User/UserNotifications/user_notify_state.dart';



class UserNotificationBloc
    extends Bloc<
        UserNotificationEvent,
        UserNotificationState> {
  final UserNotificationRepository
      _userNotificationRepository;

  StreamSubscription<
          List<UserNotificationModel>>?
      _myUserNotificationSubscription;

  StreamSubscription<
          List<UserNotificationModel>>?
      _appUpdateSubscription;

  UserNotificationBloc({
    required UserNotificationRepository
        userNotificationRepository,
  })  : _userNotificationRepository =
            userNotificationRepository,
        super(
          const UserNotificationState(),
        ) {
    on<WatchUserNotifications>(
      _onWatchUserNotifications,
    );

    on<UserNotificationsUpdated>(
      _onUserNotificationsUpdated,
    );

    on<AppUpdatesUpdated>(
      _onAppUpdatesUpdated,
    );

    on<MarkNotificationRead>(
      _onMarkNotificationRead,
    );

    on<MarkAllNotificationsRead>(
      _onMarkAllNotificationsRead,
    );

    on<UserNotificationError>(
      _onUserNotificationError,
    );
  }

  List<UserNotificationModel>
      _userNotifications = [];

  List<UserNotificationModel>
      _appUpdates = [];

  Future<void> _onWatchUserNotifications(
    WatchUserNotifications event,
    Emitter<UserNotificationState> emit,
  ) async {
    emit(
      state.copyWith(
        status: UserNotificationStatus.loading,
        clearError: true,
      ),
    );

    await _myUserNotificationSubscription
        ?.cancel();

    await _appUpdateSubscription?.cancel();

    final user =
        _userNotificationRepository.currentUser;

    if (user == null) {
      emit(
        state.copyWith(
          status: UserNotificationStatus.failure,
          errorMessage:
              'User is not logged in.',
        ),
      );
      return;
    }

    _myUserNotificationSubscription =
        _userNotificationRepository
            .watchMyNotifications()
            .listen(
      (notifications) {
        add(
          UserNotificationsUpdated(
            notifications,
          ),
        );
      },
      onError: (error) {
        add(
          UserNotificationError(
            error.toString(),
          ),
        );
      },
    );

    _appUpdateSubscription =
        _userNotificationRepository
            .watchAppUpdates()
            .listen(
      (updates) {
        add(
          AppUpdatesUpdated(
            updates,
          ),
        );
      },
      onError: (error) {
        add(
          UserNotificationError(
            error.toString(),
          ),
        );
      },
    );
  }

  void _onUserNotificationsUpdated(
    UserNotificationsUpdated event,
    Emitter<UserNotificationState> emit,
  ) {
    _userNotifications = event.notifications;

    _emitCombinedNotifications(emit);
  }

  void _onAppUpdatesUpdated(
    AppUpdatesUpdated event,
    Emitter<UserNotificationState> emit,
  ) {
    _appUpdates = event.updates;

    _emitCombinedNotifications(emit);
  }

  void _emitCombinedNotifications(
    Emitter<UserNotificationState> emit,
  ) {
    final combined = <UserNotificationModel>[
      ..._userNotifications,
      ..._appUpdates,
    ];

    final unique =
        <String, UserNotificationModel>{};

    for (final notification in combined) {
      unique[notification.id] = notification;
    }

    final result = unique.values.toList();

    result.sort((a, b) {
      final aDate = a.createdAt;
      final bDate = b.createdAt;

      if (aDate == null && bDate == null) {
        return 0;
      }

      if (aDate == null) {
        return 1;
      }

      if (bDate == null) {
        return -1;
      }

      return bDate.compareTo(aDate);
    });

    emit(
      state.copyWith(
        status: UserNotificationStatus.loaded,
        notifications: result,
        clearError: true,
      ),
    );
  }

  Future<void> _onMarkNotificationRead(
    MarkNotificationRead event,
    Emitter<UserNotificationState> emit,
  ) async {
    try {
      if (event.notificationId.startsWith('app_')) {
        return;
      }

      await _userNotificationRepository
          .markAsRead(
        event.notificationId,
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: UserNotificationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onMarkAllNotificationsRead(
    MarkAllNotificationsRead event,
    Emitter<UserNotificationState> emit,
  ) async {
    try {
      await _userNotificationRepository
          .markAllAsRead();
    } catch (e) {
      emit(
        state.copyWith(
          status: UserNotificationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onUserNotificationError(
    UserNotificationError event,
    Emitter<UserNotificationState> emit,
  ) {
    emit(
      state.copyWith(
        status: UserNotificationStatus.failure,
        errorMessage: event.message,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _myUserNotificationSubscription
        ?.cancel();

    await _appUpdateSubscription?.cancel();

    return super.close();
  }
}