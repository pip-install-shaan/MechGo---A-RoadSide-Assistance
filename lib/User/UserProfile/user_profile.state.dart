import 'package:equatable/equatable.dart';
import 'package:mech_go/User/Payment/complete_payment_request.dart';

import 'user_profile_model.dart';

enum UserProfileStatus {
  initial,
  loading,
  loaded,
  updating,
  failure,
  loggedOut,
}

class UserProfileState extends Equatable {
  final UserProfileStatus status;
  final UserProfileModel? user;
  final CompletedPaymentRequest? completedPaymentRequest;
  final String? errorMessage;

  const UserProfileState({
    this.status = UserProfileStatus.initial,
    this.user,
    this.completedPaymentRequest,
    this.errorMessage,
  });

  UserProfileState copyWith({
    UserProfileStatus? status,
    UserProfileModel? user,
    CompletedPaymentRequest? completedPaymentRequest,
    String? errorMessage,
    bool clearError = false,
    bool clearCompletedPaymentRequest = false,
  }) {
    return UserProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      completedPaymentRequest:
          clearCompletedPaymentRequest
              ? null
              : completedPaymentRequest ??
                  this.completedPaymentRequest,
      errorMessage:
          clearError
              ? null
              : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        user,
        completedPaymentRequest,
        errorMessage,
      ];
}