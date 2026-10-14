import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'request_model.dart';

class RequestRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  RequestRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _firestore =
            firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage =
            storage ?? FirebaseStorage.instance;

  User? get currentUser => _auth.currentUser;

  CollectionReference<Map<String, dynamic>>
      get _requests =>
          _firestore.collection('requests');

  CollectionReference<Map<String, dynamic>>
      get _mechanics =>
          _firestore.collection('mechanics');

  CollectionReference<Map<String, dynamic>>
      get _notifications =>
          _firestore.collection('notifications');

  // ============================================================
  // CREATE SERVICE REQUEST
  // ============================================================
  
  Future<void> _createUserNotification({
  required String userId,
  required String type,
  required String title,
  required String message,
  String requestId = '',
  String mechanicId = '',
  String mechanicName = '',
  String mechanicPhone = '',
  String mechanicDistance = '',
  String mechanicProfilePic = '',
}) async {
  await _firestore.collection('notifications').add({
    'userId': userId,
    'type': type,
    'title': title,
    'message': message,
    'requestId': requestId,
    'mechanicId': mechanicId,
    'mechanicName': mechanicName,
    'mechanicPhone': mechanicPhone,
    'mechanicDistance': mechanicDistance,
    'mechanicProfilePic': mechanicProfilePic,
    'isRead': false,
    'createdAt': FieldValue.serverTimestamp(),
  });
}

  Future<String> createServiceRequest({
    required String vehicleType,
    required String problemType,
    required String description,
    required String location,

    // REAL USER GPS
    required double latitude,
    required double longitude,

    required List<String> imagePaths,

    double amount = 0,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    // ----------------------------------------------------------
    // Get user profile
    // ----------------------------------------------------------

    final userDoc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    final userData = userDoc.data() ?? {};

    final String userName =
        userData['name'] ??
        user.displayName ??
        'User';

    final String userPhone =
        userData['phone'] ??
        user.phoneNumber ??
        '';

    // ----------------------------------------------------------
    // Upload request images
    // ----------------------------------------------------------

    final List<String> imageUrls = [];

    for (int i = 0; i < imagePaths.length; i++) {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';

      final storageRef = _storage
          .ref()
          .child('request_images')
          .child(user.uid)
          .child(fileName);

      await storageRef.putFile(
        // We will import dart:io below
        File(imagePaths[i]),
      );

      final downloadUrl =
          await storageRef.getDownloadURL();

      imageUrls.add(downloadUrl);
    }

    // ----------------------------------------------------------
    // Create request ID
    // ----------------------------------------------------------

    final requestRef = _requests.doc();

    final now = FieldValue.serverTimestamp();

    // ----------------------------------------------------------
    // Save request
    // ----------------------------------------------------------

    await requestRef.set({
      'requestId': requestRef.id,

      'userId': user.uid,

      'userName': userName,
      'userPhone': userPhone,

      'vehicleType': vehicleType,
      'problemType': problemType,
      'description': description,

      'location': location,

      // IMPORTANT:
      // These are the REAL coordinates obtained from GPS.
      'latitude': latitude,
      'longitude': longitude,

      'imageUrls': imageUrls,

      'status': 'pending',

      'mechanicId': null,
      'mechanicName': null,
      'mechanicPhone': null,
      'mechanicEmail': null,
      'mechanicVerified': false,

      'amount': amount,

      'createdAt': now,
      'updatedAt': now,
      'acceptedAt': null,
    });

    // ----------------------------------------------------------
    // Find nearby mechanics
    // ----------------------------------------------------------

    await _notifyNearbyMechanics(
      requestId: requestRef.id,
      userId: user.uid,
      userName: userName,
      problemType: problemType,
      userLatitude: latitude,
      userLongitude: longitude,
    );

    // ----------------------------------------------------------
    // Admin notification
    // ----------------------------------------------------------

    await _notifications.add({
      'title': 'New Service Request',
      'message':
          '$userName requested $problemType service.',
      'type': 'new_service_request',

      'requestId': requestRef.id,
      'userId': user.uid,

      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return requestRef.id;
  }

  // ============================================================
  // FIND AND NOTIFY NEARBY MECHANICS
  // ============================================================

  Future<void> _notifyNearbyMechanics({
    required String requestId,
    required String userId,
    required String userName,
    required String problemType,
    required double userLatitude,
    required double userLongitude,
  }) async {
    final mechanicsSnapshot = await _mechanics
        .where(
          'isAvailable',
          isEqualTo: true,
        )
        .get();

    final batch = _firestore.batch();

    // Initial radius: 10 KM
    const double maxDistanceKm = 10;

    for (final mechanicDoc
        in mechanicsSnapshot.docs) {
      final data = mechanicDoc.data();

      final mechanicLatitude =
          (data['latitude'] as num?)
                  ?.toDouble() ??
              0.0;

      final mechanicLongitude =
          (data['longitude'] as num?)
                  ?.toDouble() ??
              0.0;

      // Skip mechanics that don't have a valid GPS position.
      if (mechanicLatitude == 0.0 &&
          mechanicLongitude == 0.0) {
        continue;
      }

      final distanceKm = _calculateDistanceKm(
        userLatitude,
        userLongitude,
        mechanicLatitude,
        mechanicLongitude,
      );

      if (distanceKm <= maxDistanceKm) {
        final notificationRef =
            _notifications.doc();

        batch.set(notificationRef, {
          'title': 'New Nearby Service Request',

          'message':
              '$userName needs $problemType service.',

          'type': 'nearby_service_request',

          'requestId': requestId,
          'userId': userId,

          'mechanicId': mechanicDoc.id,

          'distanceKm': distanceKm,

          'isRead': false,

          'createdAt':
              FieldValue.serverTimestamp(),
        });
      }
    }

    await batch.commit();
  }

  // ============================================================
  // HAVERSINE DISTANCE
  // ============================================================

  double _calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusKm = 6371;

    final double dLat =
        _degreesToRadians(lat2 - lat1);

    final double dLon =
        _degreesToRadians(lon2 - lon1);

    final double a =
        sin(dLat / 2) *
                sin(dLat / 2) +
            cos(_degreesToRadians(lat1)) *
                cos(_degreesToRadians(lat2)) *
                sin(dLon / 2) *
                sin(dLon / 2);

    final double c =
        2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  // ============================================================
  // WATCH ONE REQUEST
  // ============================================================

  Stream<RequestModel?> watchRequest(
    String requestId,
  ) {
    return _requests
        .doc(requestId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }

      return RequestModel.fromFirestore(
        snapshot,
      );
    });
  }

  // ============================================================
  // WATCH USER REQUESTS
  // ============================================================

  Stream<List<RequestModel>> watchMyRequests() {
    final user = currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return _requests
        .where(
          'userId',
          isEqualTo: user.uid,
        )
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                RequestModel.fromFirestore,
              )
              .toList(),
        );
  }

  // ============================================================
  // WATCH PENDING REQUESTS
  // ============================================================

  Stream<List<RequestModel>>
      watchPendingRequests() {
    return _requests
        .where(
          'status',
          isEqualTo: 'pending',
        )
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                RequestModel.fromFirestore,
              )
              .toList(),
        );
  }

  // ============================================================
  // ACCEPT REQUEST
  // ============================================================


// ============================================================
// REJECT CURRENT MECHANIC
// ============================================================

Future<void> rejectMechanic(
  String requestId,
) async {
  final user = currentUser;

  if (user == null) {
    throw Exception(
      'User is not logged in.',
    );
  }

  final requestRef = _requests.doc(requestId);

  final requestSnapshot =
      await requestRef.get();

  if (!requestSnapshot.exists) {
    throw Exception(
      'Request not found.',
    );
  }

  final data =
      requestSnapshot.data();

  if (data == null) {
    throw Exception(
      'Request data not found.',
    );
  }

  if (data['userId'] != user.uid) {
    throw Exception(
      'You cannot modify this request.',
    );
  }

  if (data['status'] != 'accepted') {
    throw Exception(
      'Only an accepted mechanic can be rejected.',
    );
  }

  final mechanicId =
      data['mechanicId']?.toString() ?? '';

  if (mechanicId.isEmpty) {
    throw Exception(
      'Mechanic information is missing.',
    );
  }

  final rejectedMechanic = {
    'mechanicId': mechanicId,

    'mechanicName':
        data['mechanicName']?.toString() ??
            'Mechanic',

    'mechanicPhone':
        data['mechanicPhone']?.toString() ?? '',

    'mechanicProfilePic':
        data['mechanicProfilePic']?.toString() ?? '',

    'rejectedAt':
        Timestamp.now(),
  };

  final existingRejected =
      List<Map<String, dynamic>>.from(
    (data['rejectedMechanics'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>(),
  );

  existingRejected.add(
    rejectedMechanic,
  );

  await requestRef.update({
    'status': 'pending',

    // Remove current mechanic
    'mechanicId': null,
    'mechanicName': null,
    'mechanicPhone': null,
    'mechanicEmail': null,
    'mechanicVerified': false,
    'mechanicProfilePic': '',

    'acceptedAt': null,

    'rejectedMechanics':
        existingRejected,

    'updatedAt':
        FieldValue.serverTimestamp(),
  });

  await _notifications.add({
    'title': 'Mechanic Rejected',

    'message':
        'The user rejected the assigned mechanic.',

    'type': 'mechanic_rejected',

    'requestId': requestId,

    'userId': user.uid,

    'mechanicId': mechanicId,

    'isRead': false,

    'createdAt':
        FieldValue.serverTimestamp(),
  });
}
  // ============================================================
// ACCEPT REQUEST
// ============================================================

// ============================================================
// ACCEPT REQUEST
// ============================================================

Future<bool> acceptRequest({
  required String requestId,
  required String mechanicId,
}) async {
  final mechanicRef =
      _mechanics.doc(mechanicId);

  final requestRef =
      _requests.doc(requestId);

  // ------------------------------------------------------------
  // GET MECHANIC PROFILE
  // ------------------------------------------------------------

  final mechanicSnapshot =
      await mechanicRef.get();

  if (!mechanicSnapshot.exists) {
    throw Exception(
      'Mechanic profile not found.',
    );
  }

  final mechanicData =
      mechanicSnapshot.data();

  if (mechanicData == null) {
    throw Exception(
      'Mechanic profile data not found.',
    );
  }

  final String mechanicName =
      mechanicData['name']?.toString() ??
          'Mechanic';

  final String mechanicPhone =
      mechanicData['phone']?.toString() ??
          '';

  final String mechanicEmail =
      mechanicData['email']?.toString() ??
          '';

  final bool mechanicVerified =
      mechanicData['isVerified'] == true;

  final String mechanicProfilePic =
      mechanicData['profilePic']?.toString() ??
          mechanicData['profileImage']?.toString() ??
          '';

  // ------------------------------------------------------------
  // ACCEPT REQUEST
  // ------------------------------------------------------------

  try {
    String? userId;

    final bool accepted =
        await _firestore.runTransaction<bool>(
      (transaction) async {
        final requestSnapshot =
            await transaction.get(
          requestRef,
        );

        if (!requestSnapshot.exists) {
          throw Exception(
            'Request does not exist.',
          );
        }

        final requestData =
            requestSnapshot.data();

        if (requestData == null) {
          throw Exception(
            'Request data not found.',
          );
        }

        final String status =
            requestData['status']
                    ?.toString() ??
                'pending';

        // ------------------------------------------------------
        // Another mechanic already accepted it
        // ------------------------------------------------------

        if (status != 'pending') {
          return false;
        }

        // Get USER ID from the request itself.
        userId =
            requestData['userId']?.toString();

        if (userId == null ||
            userId!.isEmpty) {
          throw Exception(
            'User ID is missing from the request.',
          );
        }

        // ------------------------------------------------------
        // Update request
        // ------------------------------------------------------

        transaction.update(
          requestRef,
          {
            'status': 'accepted',
            'mechanicId': mechanicId,
            'mechanicName': mechanicName,
            'mechanicPhone': mechanicPhone,
            'mechanicEmail': mechanicEmail,
            'mechanicVerified':
                mechanicVerified,
            'mechanicProfilePic':
                mechanicProfilePic,
            'acceptedAt':
                FieldValue.serverTimestamp(),
            'updatedAt':
                FieldValue.serverTimestamp(),
          },
        );

        return true;
      },
    );

    // ----------------------------------------------------------
    // CREATE USER NOTIFICATION
    //
    // IMPORTANT:
    // This is OUTSIDE the transaction.
    // ----------------------------------------------------------

    if (accepted &&
        userId != null &&
        userId!.isNotEmpty) {
      await _createUserNotification(
        userId: userId!,
        type: 'request_accepted',
        title: 'Request Accepted',
        message:
            '$mechanicName has accepted your mechanic request.',
        requestId: requestId,
        mechanicId: mechanicId,
        mechanicName: mechanicName,
        mechanicPhone: mechanicPhone,
        mechanicProfilePic:
            mechanicProfilePic,
      );
    }

    return accepted;
  } catch (e) {
    rethrow;
  }
}


// ============================================================
// WATCH MECHANIC LIVE LOCATION
// ============================================================

Stream<Map<String, double>?> watchMechanicLocation(
  String mechanicId,
) {
  return _mechanics
      .doc(mechanicId)
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.data();

    if (data == null) {
      return null;
    }

    final latitude =
        (data['latitude'] as num?)?.toDouble();

    final longitude =
        (data['longitude'] as num?)?.toDouble();

    if (latitude == null ||
        longitude == null) {
      return null;
    }

    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  });
}

// ============================================================
// UPDATE CURRENT MECHANIC LOCATION
// ============================================================

Future<void> updateMechanicLocation({
  required double latitude,
  required double longitude,
}) async {
  final user = currentUser;

  if (user == null) {
    throw Exception(
      'Mechanic is not logged in.',
    );
  }

  await _mechanics.doc(user.uid).set(
    {
      'latitude': latitude,
      'longitude': longitude,
      'locationUpdatedAt':
          FieldValue.serverTimestamp(),
    },
    SetOptions(
      merge: true,
    ),
  );
}
  // ============================================================
  // CANCEL REQUEST
  // ============================================================

  Future<void> cancelRequest(
    String requestId,
  ) async {
    final user = currentUser;

    if (user == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    final requestRef =
        _requests.doc(requestId);

    final requestSnapshot =
        await requestRef.get();

    if (!requestSnapshot.exists) {
      throw Exception(
        'Request not found.',
      );
    }

    final requestData =
        requestSnapshot.data()!;

    if (requestData['userId'] !=
        user.uid) {
      throw Exception(
        'You cannot cancel this request.',
      );
    }

    final status =
        requestData['status'];

    if (status != 'pending') {
      throw Exception(
        'Only pending requests can be cancelled.',
      );
    }

    await requestRef.update({
      'status': 'cancelled',
      'updatedAt':
          FieldValue.serverTimestamp(),
    });

    await _notifications.add({
      'title': 'Request Cancelled',

      'message':
          'A user cancelled their service request.',

      'type': 'request_cancelled',

      'requestId': requestId,
      'userId': user.uid,

      'isRead': false,

      'createdAt':
          FieldValue.serverTimestamp(),
    });
  }
}