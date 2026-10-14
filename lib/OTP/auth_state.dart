import 'package:equatable/equatable.dart';

enum AuthStatus {
  initial,
  loading,

  // Signup
  signupSuccess,

  // OTP
  otpSent,
  otpVerifying,
  otpVerified,
  otpResending,

  // Final authentication
  success,

  // Logout
  loggedOut,

  // Error
  failure,
  loginSuccess,
  passwordResetEmailSent,
}

class AuthState extends Equatable {
  final AuthStatus status;
  
  final String? uid;
  final String? verificationId;
  final String? phoneNumber;

  final String? name;
  final String? email;
  final String? role;

  final bool rememberMe;

  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.uid,
    this.verificationId,
    this.phoneNumber,
    this.name,
    this.email,
    this.role,
    this.rememberMe = false,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? uid,
    String? verificationId,
    String? phoneNumber,
    String? name,
    String? email,
    String? role,
    bool? rememberMe,
    String? errorMessage,

    // Allows us to explicitly clear nullable values.
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      uid: uid ?? this.uid,
      verificationId: verificationId ?? this.verificationId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      rememberMe: rememberMe ?? this.rememberMe,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        uid,
        verificationId,
        phoneNumber,
        name,
        email,
        role,
        rememberMe,
        errorMessage,
      ];
}