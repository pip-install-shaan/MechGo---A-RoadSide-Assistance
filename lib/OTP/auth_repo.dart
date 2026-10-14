import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mech_go/Services/signin_google.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleAuth _googleAuth;
  
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleAuth? googleAuth,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleAuth =
          googleAuth ?? GoogleAuth();

 Future<User?> signInWithGoogle() async {
  return await _googleAuth.signInWithGoogle();
}

Future<void> saveGoogleUserProfile({
  required String uid,
  required String name,
  required String email,
  required String role,
}) async {
  await _firestore.collection('users').doc(uid).set({
    'uid': uid,
    'name': name,
    'email': email,
    'phone': '',
    'role': role,
    'authProvider': 'google',
    'phoneVerified': false,
    'createdAt': FieldValue.serverTimestamp(),
  });
}

  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ============================================================
  // SEND PHONE OTP
  // ============================================================

  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(FirebaseAuthException error) onVerificationFailed,
    void Function(PhoneAuthCredential credential)? onVerificationCompleted,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,

      verificationCompleted: (PhoneAuthCredential credential) {
        onVerificationCompleted?.call(credential);
      },

      verificationFailed: (FirebaseAuthException error) {
        onVerificationFailed(error);
      },

      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },

      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // ============================================================
  // VERIFY OTP AND LINK PHONE TO CURRENT USER
  // ============================================================

  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final User? user = _firebaseAuth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No authenticated user found.',
      );
    }

    final PhoneAuthCredential credential =
        PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    return await user.linkWithCredential(credential);
  }

  Future<UserCredential> login({
  required String email,
  required String password,
}) async {
  return await _firebaseAuth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
}

Future<void> sendPasswordResetEmail({
  required String email,
}) async {
  await _firebaseAuth.sendPasswordResetEmail(
    email: email.trim(),
  );
}

Future<String?> getUserRole(String uid) async {
  final document = await _firestore
      .collection('users')
      .doc(uid)
      .get();

  if (!document.exists) {
    return null;
  }

  final data = document.data();

  return data?['role'] as String?;
}

  Future<void> saveUserProfile({
    required String uid,
    required String name,
    required String email,
    required String phoneNumber,
    required String role,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phoneNumber,
      'role': role,
      'phoneVerified': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // GET CURRENT USER
  // ============================================================

  User? get currentUser {
    return _firebaseAuth.currentUser;
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> logout() async {
  await _firebaseAuth.signOut();
}
}