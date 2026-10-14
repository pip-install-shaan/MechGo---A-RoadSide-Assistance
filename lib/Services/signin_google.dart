import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signInWithGoogle() async {
    try {
      debugPrint('STEP 1: Starting Google Sign-In');

      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      await googleSignIn.initialize(
        serverClientId:
            '385406124486-d45er7ss6o4ht5e75dqloi6b9v67dqaq.apps.googleusercontent.com',
      );

      debugPrint('STEP 2: Google Sign-In initialized');

      final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();

      if (googleUser == null) {
        debugPrint('Google Sign-In cancelled');
        return null;
      }

      debugPrint('Google User: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      debugPrint('STEP 3: Google authentication received');

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      debugPrint('STEP 4: Firebase credential created');

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'google-user-null',
          message: 'Firebase returned no user.',
        );
      }

      debugPrint('STEP 5: Firebase login successful: ${user.email}');
      return user;
    } catch (e, stackTrace) {
      debugPrint('GOOGLE SIGN-IN ERROR: $e');
      debugPrint('STACK TRACE: $stackTrace');
      rethrow;
    }
  }
}