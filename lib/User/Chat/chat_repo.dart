import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ChatRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore =
            firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  CollectionReference<Map<String, dynamic>> _messagesCollection(
    String requestId,
  ) {
    return _firestore
        .collection('requests')
        .doc(requestId)
        .collection('messages');
  }

  /// Listen to all messages of this request in real time.
  Stream<List<Map<String, dynamic>>> watchMessages(
    String requestId,
  ) {
    return _messagesCollection(requestId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        return {
          'messageId': doc.id,
          ...data,
        };
      }).toList();
    });
  }

  /// Send a message.
  Future<void> sendMessage({
    required String requestId,
    required String text,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    final cleanText = text.trim();

    if (cleanText.isEmpty) {
      return;
    }

    await _messagesCollection(requestId).add({
      'senderId': user.uid,
      'senderRole': 'user',
      'text': cleanText,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}