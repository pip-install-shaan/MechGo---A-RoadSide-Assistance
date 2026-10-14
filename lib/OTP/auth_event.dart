import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Fired when user/mechanic submits the signup form.
class SignupRequested extends AuthEvent {
  final String name;
  final String email;
  final String phoneNumber;
  final String password;
  final String role;
  final bool rememberMe;

  const SignupRequested({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.role,
    required this.rememberMe,
  });

  @override
  List<Object?> get props => [
        name,
        email,
        phoneNumber,
        password,
        role,
        rememberMe,
      ];
}

/// Fired when user enters the OTP.
class VerifyOtpRequested extends AuthEvent {
  final String verificationId;
  final String smsCode;

  const VerifyOtpRequested({
    required this.verificationId,
    required this.smsCode,
  });

  @override
  List<Object?> get props => [
        verificationId,
        smsCode,
      ];
}

/// Fired when user requests another OTP.
class ResendOtpRequested extends AuthEvent {
  final String phoneNumber;

  const ResendOtpRequested({
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [
        phoneNumber,
      ];
}

class LoginRequested extends AuthEvent{
  final String email;
  final String password;
  final String role;
  final bool rememberMe;

  const LoginRequested({
    required this.email,
    required this.password,
    required this.role,
    required this.rememberMe,
  });

  @override
  List<Object> get props =>[
    email, 
    password,
    role, 
    rememberMe,
  ];
}
class ForgotPasswordRequested extends AuthEvent {
  final String email;

  const ForgotPasswordRequested({
    required this.email,
  });

  @override
  List<Object?> get props => [email];
}


class AdminLoginRequested extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;

  const AdminLoginRequested({
    required this.email,
    required this.password,
    required this.rememberMe,
  });

  @override
  List<Object?> get props => [
        email,
        password,
        rememberMe,
      ];
}

class GoogleLoginRequested extends AuthEvent {
  final bool rememberMe;
  final String role;

  const GoogleLoginRequested({
    required this.rememberMe,
    required this.role,
  });

  @override
  List<Object?> get props => [role, rememberMe];
}

/// Fired when user logs out.
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}