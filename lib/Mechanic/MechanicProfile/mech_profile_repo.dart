import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MechanicProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  MechanicProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _firestore =
            firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage =
            storage ?? FirebaseStorage.instance;

  User get currentUser {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Mechanic is not logged in.');
    }

    return user;
  }

  DocumentReference<Map<String, dynamic>> get _profileReference {
    return _firestore
        .collection('users')
        .doc(currentUser.uid);
  }

  /// Watches mechanic profile in real time.
  Stream<Map<String, dynamic>> watchMechanicProfile() async* {
    final user = currentUser;

    final document = await _profileReference.get();

    if (!document.exists) {
      // Create a basic profile instead of crashing.
      await _profileReference.set(
        {
          'uid': user.uid,
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'phone': user.phoneNumber ?? '',
          'role': 'mechanic',
          'phoneVerified': user.phoneNumber != null,
          'createdAt': FieldValue.serverTimestamp(),
          'workshopName': user.displayName ?? '',
          'specialization': 'Mechanic',
          'profilePic': '',
          'rating': 0,
          'reviewCount': 0,
        },
        SetOptions(merge: true),
      );
    }

    yield* _profileReference.snapshots().map((snapshot) {
      if (!snapshot.exists) {
        throw Exception('Unable to load mechanic profile.');
      }

      final data = snapshot.data() ?? {};

      return {
        'uid': data['uid'] ?? user.uid,
        'name': data['name'] ?? '',
        'email': data['email'] ?? user.email ?? '',
        'phone': data['phone'] ?? user.phoneNumber ?? '',
        'role': data['role'] ?? 'mechanic',
        'workshopName': data['workshopName'] ?? '',
        'specialization':
            data['specialization'] ?? 'Mechanic',
        'profilePic': data['profilePic'] ?? '',
        'rating': _toDouble(data['rating']),
        'reviewCount': _toInt(data['reviewCount']),
      };
    });
  }

  /// Update mechanic profile.
  Future<void> updateMechanicProfile({
    required String name,
    required String workshopName,
    required String specialization,
    File? profileImage,
  }) async {
    String profilePic = '';

    if (profileImage != null) {
      final storageReference = _storage
          .ref()
          .child('mechanic_profiles')
          .child('${currentUser.uid}.jpg');

      await storageReference.putFile(profileImage);

      profilePic =
          await storageReference.getDownloadURL();
    }

    final Map<String, dynamic> data = {
      'name': name.trim(),
      'workshopName': workshopName.trim(),
      'specialization': specialization.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (profileImage != null) {
      data['profilePic'] = profilePic;
    }

    await _profileReference.set(
      data,
      SetOptions(merge: true),
    );

    // Also keep Firebase Auth display name synchronized.
    await currentUser.updateDisplayName(name.trim());
  }

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  int _toInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? 0;
  }
}