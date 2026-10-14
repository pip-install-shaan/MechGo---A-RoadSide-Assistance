import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'payment_model.dart';

class PaymentRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  PaymentRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore =
            firestore ?? FirebaseFirestore.instance,
        _auth =
            auth ?? FirebaseAuth.instance;

  User? get currentUser =>
      _auth.currentUser;

  // ==========================================================
  // PAYMENT COLLECTION
  // ==========================================================

  CollectionReference<Map<String, dynamic>>
      get _payments =>
          _firestore.collection('payments');

  // ==========================================================
  // CREATE CASH PAYMENT
  // ==========================================================

  Future<PaymentModel>
      createCashPayment({
    required String requestId,
    required String mechanicId,
    required String mechanicName,
    required double amount,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    final paymentReference =
        _payments.doc();

    final paymentId =
        paymentReference.id;

    await paymentReference.set({
      'paymentId': paymentId,
      'requestId': requestId,
      'userId': user.uid,
      'mechanicId': mechanicId,
      'mechanicName': mechanicName,
      'amount': amount,
      'method': 'cash',
      'status': 'pending',
      'transactionId': '',
      'createdAt':
          FieldValue.serverTimestamp(),
      'updatedAt':
          FieldValue.serverTimestamp(),
    });

    await _firestore
        .collection('requests')
        .doc(requestId)
        .update({
      'paymentId': paymentId,
      'paymentMethod': 'cash',
      'paymentStatus': 'pending',
    });

    final snapshot =
        await paymentReference.get();

    return PaymentModel.fromFirestore(
      snapshot,
    );
  }

  // ==========================================================
  // WATCH PAYMENT
  // ==========================================================

  Stream<PaymentModel?>
      watchPayment(
    String requestId,
  ) {
    return _payments
        .where(
          'requestId',
          isEqualTo: requestId,
        )
        .snapshots()
        .map(
      (snapshot) {
        if (snapshot.docs.isEmpty) {
          return null;
        }

        return PaymentModel.fromFirestore(
          snapshot.docs.first,
        );
      },
    );
  }

  // ==========================================================
  // ONLINE PAYMENT
  // ==========================================================
  //
  // IMPORTANT:
  //
  // DO NOT put JazzCash/Easypaisa merchant
  // passwords/secrets inside this Flutter code.
  //
  // This method is intentionally a placeholder
  // until your Firebase Cloud Function is connected.
  //

  Future<String> createOnlinePayment({
    required String requestId,
    required String mechanicId,
    required String mechanicName,
    required double amount,
    required PaymentMethod method,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    // Later this will call:
    //
    // Firebase Cloud Function
    //       ↓
    // JazzCash / Easypaisa / Card Gateway
    //
    // and return the provider checkout URL.

    throw UnimplementedError(
      'Online payment gateway is not connected yet.',
    );
  }
}