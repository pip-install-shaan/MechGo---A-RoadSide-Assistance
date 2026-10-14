import 'package:equatable/equatable.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

// =========================================
// DASHBOARD
// =========================================

class LoadAdminDashboard extends AdminEvent {
  const LoadAdminDashboard();
}

// =========================================
// REQUESTS
// =========================================

class LoadAllAdminRequests extends AdminEvent {
  const LoadAllAdminRequests();
}

// =========================================
// WATCH USERS
// =========================================

class WatchAdminUsers extends AdminEvent {
  const WatchAdminUsers();
}

// =========================================
// WATCH MECHANICS
// =========================================

class WatchAdminMechanics extends AdminEvent {
  const WatchAdminMechanics();
}

// =========================================
// DELETE USER
// =========================================

class DeleteAdminUser extends AdminEvent {
  final String uid;

  const DeleteAdminUser(this.uid);

  @override
  List<Object?> get props => [uid];
}

// =========================================
// DELETE MECHANIC
// =========================================

class DeleteAdminMechanic extends AdminEvent {
  final String uid;

  const DeleteAdminMechanic(this.uid);

  @override
  List<Object?> get props => [uid];
}

// =========================================
// USERS UPDATED
// =========================================

class AdminUsersUpdated extends AdminEvent {
  final List<Map<String, dynamic>> users;

  const AdminUsersUpdated(this.users);

  @override
  List<Object?> get props => [users];
}

// =========================================
// USERS FAILED
// =========================================

class AdminUsersFailed extends AdminEvent {
  final String message;

  const AdminUsersFailed(this.message);

  @override
  List<Object?> get props => [message];
}

// =========================================
// MECHANICS UPDATED
// =========================================

class AdminMechanicsUpdated extends AdminEvent {
  final List<Map<String, dynamic>> mechanics;

  const AdminMechanicsUpdated(this.mechanics);

  @override
  List<Object?> get props => [mechanics];
}

// =========================================
// MECHANICS FAILED
// =========================================

class AdminMechanicsFailed extends AdminEvent {
  final String message;

  const AdminMechanicsFailed(this.message);

  @override
  List<Object?> get props => [message];
}