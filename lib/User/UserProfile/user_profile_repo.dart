import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mech_go/User/Payment/complete_payment_request.dart';
import 'user_profile_model.dart';

class UserProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UserProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore =
            firestore ?? FirebaseFirestore.instance,
        _auth =
            auth ?? FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  // ==========================================================
  // USER PROFILE
  // ==========================================================

  Stream<UserProfileModel> watchUserProfile() {
    final user = currentUser;

    if (user == null) {
      return Stream.error(
        Exception('User is not logged in.'),
      );
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map(
      (snapshot) {
        if (!snapshot.exists) {
          throw Exception(
            'User profile does not exist.',
          );
        }

        return UserProfileModel.fromFirestore(
          snapshot,
        );
      },
    );
  }

  // ==========================================================
  // UPDATE PROFILE
  // ==========================================================

  Future<void> updateUserProfile({
    required String name,
    required String profilePic,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .update({
      'name': name,
      'profilePic': profilePic,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==========================================================
  // COMPLETED REQUEST FOR PAYMENT
  // ==========================================================

  Future<CompletedPaymentRequest?>
      getCompletedPaymentRequest() async {
    final user = currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final snapshot = await _firestore
        .collection('requests')
        .where(
          'userId',
          isEqualTo: user.uid,
        )
        .where(
          'status',
          isEqualTo: 'completed',
        )
        .orderBy(
          'createdAt',
          descending: true,
        )
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    final data = snapshot.docs.first.data();

    final requestId =
        data['requestId']?.toString() ??
            snapshot.docs.first.id;

    final mechanicId =
        data['mechanicId']?.toString() ?? '';

    final mechanicName =
        data['mechanicName']?.toString() ??
            'Mechanic';

    final mechanicPhone =
        data['mechanicPhone']?.toString() ?? '';

    final mechanicProfilePic =
        data['mechanicProfilePic']?.toString() ?? '';

    final amount =
        (data['finalAmount'] as num?)?.toDouble() ??
            (data['estimatedAmount'] as num?)?.toDouble() ??
            0.0;

    return CompletedPaymentRequest(
      requestId: requestId,
      mechanicId: mechanicId,
      mechanicName: mechanicName,
      mechanicPhone: mechanicPhone,
      mechanicProfilePic: mechanicProfilePic,
      amount: amount,
    );
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================

  Future<void> logout() async {
    await _auth.signOut();
  }
}