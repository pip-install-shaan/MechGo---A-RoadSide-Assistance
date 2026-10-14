import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter_bloc/flutter_bloc.dart'; 
import 'package:mech_go/OTP/auth_repo.dart'; 
import 'auth_event.dart'; 
import 'auth_state.dart'; 

class AuthBloc extends Bloc<AuthEvent, AuthState> { 
  final AuthRepository _authRepository; 

  AuthBloc({ 
    required AuthRepository authRepository, 
  })  : _authRepository = authRepository, 
        super(const AuthState()) { 
    on<SignupRequested>(_onSignupRequested); 
    on<VerifyOtpRequested>(_onVerifyOtpRequested); 
    on<ResendOtpRequested>(_onResendOtpRequested); 
    on<LogoutRequested>(_onLogoutRequested); 
    on<LoginRequested>(_onLoginRequested); 
    on<_OtpSentInternally>(_onOtpSentInternally); 
    on<_OtpFailedInternally>(_onOtpFailedInternally); 
    on<ForgotPasswordRequested>(_onForgotPasswordRequested); 
    on<AdminLoginRequested>(_onAdminLoginRequested); 
    on<GoogleLoginRequested>(_onGoogleLoginRequested); 
  } 

  Future<void> _onLogoutRequested( 
    LogoutRequested event, 
    Emitter<AuthState> emit, 
  ) async { 
    try { 
      await _authRepository.signOut(); 

      emit( 
        const AuthState( 
          status: AuthStatus.loggedOut, 
        ), 
      ); 
    } catch (e) { 
      emit( 
        state.copyWith( 
          status: AuthStatus.failure, 
          errorMessage: e.toString(), 
        ), 
      ); 
    } 
  } 

  Future<void> _onGoogleLoginRequested( 
    GoogleLoginRequested event, 
    Emitter<AuthState> emit, 
  ) async { 
    emit( 
      state.copyWith( 
        status: AuthStatus.loading, 
        clearError: true, 
      ), 
    ); 

    try { 
      final User? user = await _authRepository.signInWithGoogle(); 

      if (user == null) { 
        emit( 
          state.copyWith( 
            status: AuthStatus.failure, 
            errorMessage: 'Google Sign-In was cancelled.', 
          ), 
        ); 
        return; 
      } 

      final String? existingRole = 
          await _authRepository.getUserRole(user.uid); 

      if (existingRole != null) { 
        if (existingRole != event.role) { 
          await _authRepository.signOut(); 

          emit( 
            state.copyWith( 
              status: AuthStatus.failure, 
              errorMessage: 
                  'This Google account is not registered as a $existingRole. Please use a different google account', 
            ), 
          ); 
          return; 
        } 
      } else { 
        await _authRepository.saveGoogleUserProfile( 
          uid: user.uid, 
          name: user.displayName ?? 'Guest User', 
          email: user.email ?? '', 
          role: event.role, 
        ); 
      } 

      emit( 
        state.copyWith( 
          status: AuthStatus.loginSuccess,
          uid: user.uid,
          name: user.displayName ?? 'Guest User', 
          email: user.email ?? '', 
          role: event.role, 
          rememberMe: event.rememberMe, 
          clearError: true, 
        ), 
      ); 
    } on FirebaseAuthException catch (e) { 
      emit( 
        state.copyWith( 
          status: AuthStatus.failure, 
          errorMessage: _getFirebaseErrorMessage(e), 
        ), 
      ); 
    } catch (e) { 
      emit( 
        state.copyWith( 
          status: AuthStatus.failure, 
          errorMessage: e.toString(), 
        ), 
      ); 
    } 
  } 

  Future<void> _onAdminLoginRequested( 
    AdminLoginRequested event, 
    Emitter<AuthState> emit, 
  ) async { 
    emit( 
      state.copyWith( 
        status: AuthStatus.loading, 
        clearError: true, 
      ), 
    ); 

    try { 
      final UserCredential credential = 
          await _authRepository.login( 
        email: event.email.trim(), 
        password: event.password, 
      ); 

      final User? user = credential.user; 

      if (user == null) { 
        throw FirebaseAuthException( 
          code: 'login-failed', 
          message: 'Could not login.', 
        ); 
      } 

      final String? storedRole = 
          await _authRepository.getUserRole(user.uid); 

      if (storedRole == null) { 
        await _authRepository.signOut(); 

        throw FirebaseAuthException( 
          code: 'profile-not-found', 
          message: 'Admin profile not found.', 
        ); 
      } 

      if (storedRole != 'admin') { 
        await _authRepository.signOut(); 

        throw FirebaseAuthException( 
          code: 'not-admin', 
          message: 'You are not authorized to access the admin panel.', 
        ); 
      } 

      emit( 
        state.copyWith( 
          status: AuthStatus.loginSuccess, 
          email: event.email.trim(), 
          role: 'admin', 
          rememberMe: event.rememberMe, 
          clearError: true, 
        ), 
      ); 
    } on FirebaseAuthException catch (e) { 
      emit( 
        state.copyWith( 
          status: AuthStatus.failure, 
          errorMessage: _getFirebaseErrorMessage(e), 
        ), 
      ); 
    } catch (e) { 
      emit( 
        state.copyWith( 
          status: AuthStatus.failure, 
          errorMessage: e.toString(), 
        ), 
      ); 
    } 
  } 

  Future<void> _onForgotPasswordRequested( 
    ForgotPasswordRequested event, 
    Emitter<AuthState> emit, 
  ) async { 
    emit( 
      state.copyWith( 
        status: AuthStatus.loading, 
        clearError: true, 
      ), 
    ); 

    try { 
      await _authRepository.sendPasswordResetEmail( 
        email: event.email.trim(), 
      ); 

      emit( 
        state.copyWith( 
          status: AuthStatus.passwordResetEmailSent, 
          email: event.email.trim(), 
          clearError: true, 
        ), 
      ); 
    } on FirebaseAuthException catch (e) { 
      emit( 
        state.copyWith( 
          status: AuthStatus.failure, 
          errorMessage: _getFirebaseErrorMessage(e), 
        ), 
      ); 
    } catch (e) { 
      emit( 
        state.copyWith( 
          status: AuthStatus.failure, 
          errorMessage: e.toString(), 
        ), 
      ); 
    } 
  } 

  Future<void> _onLoginRequested( 
    LoginRequested event, 
    Emitter<AuthState> emit, 
  ) async { 
    emit( 
      state.copyWith( 
        status: AuthStatus.loading, 
        clearError: true, 
      ), 
    ); 

    try { 
      final UserCredential credential = 
          await _authRepository.login( 
        email: event.email.trim(), 
        password: event.password, 
      ); 

      final User? user = credential.user; 

      if (user == null) { 
        throw FirebaseAuthException( 
          code: 'login-failed', 
          message: 'Could not login.', 
        ); 
      } 

      final String? storedRole = 
          await _authRepository.getUserRole(user.uid); 

      if (storedRole == null) { 
        await _authRepository.signOut(); 

        throw FirebaseAuthException( 
          code: 'profile-not-found', 
          message: 'User profile not found.', 
        ); 
      } 

      if (storedRole != event.role) { 
        await _authRepository.signOut(); 

        throw FirebaseAuthException( 
          code: 'wrong-role', 
          message: 
              'This account is registered as a $storedRole.', 
        ); 
      } 

      emit( 
        state.copyWith( 
          status: AuthStatus.loginSuccess, 
          email: event.email.trim(), 
          role: storedRole, 
          rememberMe: event.rememberMe, 
          clearError: true, 
        ), 
      ); 
    } on FirebaseAuthException catch (e) { 
      emit( 
        state.copyWith( 
          status: AuthStatus.failure, 
          errorMessage: _getFirebaseErrorMessage(e), 
        ), 
      ); 
    } catch (e) { 
      emit( 
        state.copyWith( 
          status: AuthStatus.failure, 
          errorMessage: e.toString(), 
        ), 
      ); 
    } 
  } 

  void _onOtpSentInternally( 
    _OtpSentInternally event, 
    Emitter<AuthState> emit, 
  ) { 
    emit( 
      state.copyWith( 
        status: AuthStatus.otpSent, 
        verificationId: event.verificationId, 
        phoneNumber: event.phoneNumber, 
        clearError: true, 
      ), 
    ); 
  } 

  void _onOtpFailedInternally( 
    _OtpFailedInternally event, 
    Emitter<AuthState> emit, 
  ) { 
    emit( 
      state.copyWith( 
        status: AuthStatus.failure, 
        errorMessage: event.errorMessage ?? 
            'Unable to send OTP. Please try again.', 
      ), 
    ); 
  } 

  Future<void> _onSignupRequested( 
    SignupRequested event, 
    Emitter<AuthState> emit, 
  ) async { 
    emit( 
      state.copyWith( 
        status: AuthStatus.loading, 
        errorMessage: null, 
        clearError: true, 
      ), 
    ); 

    try { 
      final UserCredential userCredential = 
          await _authRepository.createAccount( 
        email: event.email.trim(), 
        password: event.password, 
      ); 

      final User? user = userCredential.user; 

      if (user == null) { 
        throw FirebaseAuthException( 
          code: 'account-creation-failed', 
          message: 'Could not create the account.', 
        ); 
      } 

      emit( 
        state.copyWith( 
          status: AuthStatus.signupSuccess, 
          name: event.name.trim(), 
          email: event.email.trim(), 
          phoneNumber: event.phoneNumber.trim(), 
          role: event.role, 
          rememberMe: event.rememberMe, 
          clearError: true, 
        ), 
      ); 

      await _authRepository.sendPhoneOtp( 
        phoneNumber: event.phoneNumber.trim(), 
        onCodeSent: (String verificationId) { 
          add( 
            _OtpSentInternally( 
              verificationId: verificationId, 
              phoneNumber: event.phoneNumber.trim(), 
            ), 
          ); 
        }, 
        onVerificationFailed: (FirebaseAuthException error) { 
          add( 
            _OtpFailedInternally( 
              errorCode: error.code, 
              errorMessage: error.message, 
            ), 
          ); 
        }, 
        onVerificationCompleted: (PhoneAuthCredential credential) {}, 
      ); 
    } on FirebaseAuthException catch (e) { 
      emit( 
        state.copyWith( 
          status: AuthStatus.failure, 
          errorMessage: _getFirebaseErrorMessage(e), 
          clearError: false, 
        ), 
      ); 
    } catch (e) { 
      emit( 
        state.copyWith( 
          status: AuthStatus.failure, 
          errorMessage: e.toString(), 
        ), 
      ); 
    } 
  } 

  Future<void> _onVerifyOtpRequested( 
    VerifyOtpRequested event, 
    Emitter<AuthState> emit, 
  ) async { 
    emit( 
      state.copyWith( 
        status: AuthStatus.otpVerifying, 
        clearError: true, 
      ), 
    ); 

    try { 
      final UserCredential credential = 
          await _authRepository.verifyOtp( 
        verificationId: event.verificationId, 
        smsCode: event.smsCode, 
      ); 

      final User? user = credential.user; 

      if (user == null) { 
        throw FirebaseAuthException( 
          code: 'verification-failed', 
          message: 'Phone verification failed.', 
        ); 
      } 

      if (state.name == null || 
          state.email == null || 
          state.phoneNumber == null || 
          state.role == null) { 
        throw FirebaseAuthException( 
          code: 'missing-signup-data', 
          message: 'Signup information is missing.', 
        ); 
      } 

      await _authRepository.saveUserProfile( 
        uid: user.uid, 
        name: state.name!, 
        email: state.email!, 
        phoneNumber: state.phoneNumber!, 
        role: state.role!, 
      ); 

      emit( 
        state.copyWith( 
          status: AuthStatus.success, 
          clearError: true, 
        ), 
      ); 
    } on FirebaseAuthException catch (e) { 
      emit( 
        state.copyWith( 
          status: AuthStatus.failure, 
          errorMessage: _getFirebaseErrorMessage(e), 
        ), 
      ); 
    } catch (e) { 
      emit( 
        state.copyWith( 
          status: AuthStatus.failure, 
          errorMessage: e.toString(), 
        ), 
      ); 
    } 
  } 

  Future<void> _onResendOtpRequested( 
    ResendOtpRequested event, 
    Emitter<AuthState> emit, 
  ) async { 
    emit( 
      state.copyWith( 
        status: AuthStatus.otpResending, 
        clearError: true, 
      ), 
    ); 

    try { 
      await _authRepository.sendPhoneOtp( 
        phoneNumber: event.phoneNumber, 
        onCodeSent: (String verificationId) { 
          add( 
            _OtpSentInternally( 
              verificationId: verificationId, 
              phoneNumber: event.phoneNumber, 
            ), 
          ); 
        }, 
        onVerificationFailed: (FirebaseAuthException error) { 
          add( 
            _OtpFailedInternally( 
              errorCode: error.code, 
              errorMessage: error.message, 
            ), 
          ); 
        }, 
        onVerificationCompleted: (PhoneAuthCredential credential) {}, 
      ); 
    } on FirebaseAuthException catch (e) { 
      emit( 
        state.copyWith( 
          status: AuthStatus.failure, 
          errorMessage: _getFirebaseErrorMessage(e), 
        ), 
      ); 
    } 
  } 

  String _getFirebaseErrorMessage( 
    FirebaseAuthException e, 
  ) { 
    switch (e.code) { 
      case 'email-already-in-use': 
        return 'This email is already registered.'; 
      case 'invalid-email': 
        return 'Please enter a valid email address.'; 
      case 'weak-password': 
        return 'Password is too weak. Use at least 6 characters.'; 
      case 'operation-not-allowed': 
        return 'This authentication method is not enabled in Firebase.'; 
      case 'user-not-found': 
        return 'No account found with this email.'; 
      case 'invalid-phone-number': 
        return 'Please enter a valid phone number.'; 
      case 'invalid-verification-code': 
        return 'The OTP code is incorrect.'; 
      case 'session-expired': 
        return 'The OTP has expired. Please request a new one.'; 
      case 'credential-already-in-use': 
        return 'This phone number is already linked to another account.'; 
      case 'provider-already-linked': 
        return 'This phone number is already linked to this account.'; 
      case 'too-many-requests': 
        return 'Too many attempts. Please try again later.'; 
      case 'quota-exceeded': 
        return 'SMS quota exceeded. Please try again later.'; 
      case 'no-current-user': 
        return 'Your signup session has expired. Please signup again.'; 
      case 'missing-signup-data': 
        return 'Signup information is missing.'; 
      case 'not-admin': 
        return 'You are not authorized to access the admin panel.'; 
      case 'profile-not-found': 
        return 'Profile not found.'; 
      case 'invalid-credential': 
        return 'Incorrect email or password.'; 
      case 'wrong-password': 
        return 'Incorrect password.'; 
      default: 
        return e.message ?? 'Authentication/Login failed. Please try again.'; 
    } 
  } 
} 

class _OtpSentInternally extends AuthEvent { 
  final String verificationId; 
  final String phoneNumber; 

  const _OtpSentInternally({ 
    required this.verificationId, 
    required this.phoneNumber, 
  }); 

  @override 
  List<Object?> get props => [ 
        verificationId, 
        phoneNumber, 
      ]; 
} 

class _OtpFailedInternally extends AuthEvent { 
  final String errorCode; 
  final String? errorMessage; 

  const _OtpFailedInternally({ 
    required this.errorCode, 
    this.errorMessage, 
  }); 

  @override 
  List<Object?> get props => [ 
        errorCode, 
        errorMessage, 
      ]; 
}