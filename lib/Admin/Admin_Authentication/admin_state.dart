import 'package:equatable/equatable.dart';

enum AdminStatus {
  initial,
  loading,
  success,
  failure,
}

class AdminState extends Equatable {
  final AdminStatus status;

  final int totalUsers;
  final int totalMechanics;
  final int activeRequests;
  final int completedRequests;
  final int pendingMechanics;
  final double totalEarnings;
  final String? errorMessage;

  final List<Map<String, dynamic>> recentRequests;
  final List<Map<String, dynamic>> allRequests;
  
  final List<Map<String, dynamic>> users;
  final List<Map<String, dynamic>> mechanics;

  const AdminState({
    this.status = AdminStatus.initial,
    this.totalUsers = 0,
    this.totalMechanics = 0,
    this.activeRequests = 0,
    this.completedRequests = 0,
    this.pendingMechanics = 0,
    this.totalEarnings = 0.0,
    this.errorMessage,
    this.recentRequests = const [],
    this.allRequests = const [],
    this.users=const [],
    this.mechanics=const [],
  });

  AdminState copyWith({
    AdminStatus? status,
    int? totalUsers,
    int? totalMechanics,
    int? activeRequests,
    int? completedRequests,
    int? pendingMechanics,
    double? totalEarnings,
    String? errorMessage,
    bool clearError = false,
    List<Map<String, dynamic>>? recentRequests,
    List<Map<String, dynamic>>? allRequests,
    List<Map<String, dynamic>>? users,
    List<Map<String, dynamic>>? mechanics,
  }) {
    return AdminState(
      status: status ?? this.status,
      totalUsers: totalUsers ?? this.totalUsers,
      totalMechanics: totalMechanics ?? this.totalMechanics,
      activeRequests: activeRequests ?? this.activeRequests,
      completedRequests: completedRequests ?? this.completedRequests,
      pendingMechanics: pendingMechanics ?? this.pendingMechanics,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      recentRequests: recentRequests ?? this.recentRequests,
      allRequests: allRequests ?? this.allRequests,
      users: users ?? this.users,
      mechanics: mechanics ?? this.mechanics ,
    );
  }

  @override
  List<Object?> get props => [
        status,
        totalUsers,
        totalMechanics,
        activeRequests,
        completedRequests,
        pendingMechanics,
        totalEarnings,
        errorMessage,
        recentRequests,
        allRequests,
        users,
        mechanics
      ];
}