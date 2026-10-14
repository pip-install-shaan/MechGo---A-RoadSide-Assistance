import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MechanicChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  MechanicChatRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // ============================================================
  // CURRENT MECHANIC
  // ============================================================

  User? get currentUser {
    return _auth.currentUser;
  }


  // ============================================================
  // WATCH CHAT MESSAGES
  // ============================================================

  Stream<List<Map<String, dynamic>>> watchMessages({
    required String requestId,
  }) {
    if (requestId.trim().isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('requests')
        .doc(requestId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) {
            return snapshot.docs.map((doc) {
              final data = doc.data();

              return {
                'id': doc.id,
                ...data,
              };
            }).toList();
          },
        );
  }


  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<void> sendMessage({
    required String requestId,
    required String text,
  }) async {
    final mechanic = _auth.currentUser;

    if (mechanic == null) {
      throw Exception(
        'Mechanic is not logged in.',
      );
    }

    final cleanRequestId = requestId.trim();
    final cleanText = text.trim();

    if (cleanRequestId.isEmpty) {
      throw Exception(
        'Request ID is missing.',
      );
    }

    if (cleanText.isEmpty) {
      return;
    }

    await _firestore
        .collection('requests')
        .doc(cleanRequestId)
        .collection('messages')
        .add({
      'senderId': mechanic.uid,
      'senderRole': 'mechanic',
      'senderName': mechanic.displayName ?? 'Mechanic',
      'text': cleanText,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}