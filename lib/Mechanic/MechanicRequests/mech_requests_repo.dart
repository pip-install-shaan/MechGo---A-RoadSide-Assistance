import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mech_go/User/UserRequests/request_model.dart';

class MechRequestsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  MechRequestsRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  String get mechanicId {
    final user = currentUser;

    if (user == null) {
      throw Exception('Mechanic is not logged in.');
    }

    return user.uid;
  }

  /// ------------------------------------------------------------
  /// WATCH NEARBY PENDING REQUESTS
  /// ------------------------------------------------------------

  Stream<List<RequestModel>> watchNearbyRequests({
    required double mechanicLatitude,
    required double mechanicLongitude,
    double radiusKm = 5,
  }) {
    return _firestore
        .collection('requests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map(
      (snapshot) {
        final List<RequestModel> requests = [];

        for (final document in snapshot.docs) {
          final data = document.data();

          final latitude = _toDouble(data['latitude']);
          final longitude = _toDouble(data['longitude']);

          if (latitude == null || longitude == null) {
            continue;
          }

          final distance = _calculateDistanceKm(
            mechanicLatitude,
            mechanicLongitude,
            latitude,
            longitude,
          );

          if (distance <= radiusKm) {
            requests.add(
              _requestFromDocument(
                document
              ),
            );
          }
        }

        requests.sort(
  (a, b) {
    final aDate = _requestDate(a);
    final bDate = _requestDate(b);

    return bDate.compareTo(aDate);
  },
);

        return requests;
      },
    );
  }

  /// ------------------------------------------------------------
  /// WATCH ALL REQUESTS RELEVANT TO THIS MECHANIC
  /// ------------------------------------------------------------

  Stream<List<RequestModel>> watchAllMechanicRequests({
    required double mechanicLatitude,
    required double mechanicLongitude,
    double radiusKm = 5,
  }) {
    return _firestore
        .collection('requests')
        .snapshots()
        .map(
      (snapshot) {
        final List<RequestModel> requests = [];

        for (final document in snapshot.docs) {
          final data = document.data();

          final String status =
              (data['status'] ?? 'pending').toString();

          final String? requestMechanicId =
              data['mechanicId']?.toString();

          final latitude = _toDouble(data['latitude']);
          final longitude = _toDouble(data['longitude']);

          final bool belongsToMechanic =
              requestMechanicId == mechanicId;

          /// Pending requests don't have a mechanic yet.
          /// They should only appear if they are within 5 km.
          bool nearbyPending = false;

          if (status == 'pending' &&
              latitude != null &&
              longitude != null) {
            final distance = _calculateDistanceKm(
              mechanicLatitude,
              mechanicLongitude,
              latitude,
              longitude,
            );

            nearbyPending = distance <= radiusKm;
          }

          /// Accepted/on_the_way/cancelled requests are already
          /// assigned to this mechanic.
          final bool assignedRequest =
              belongsToMechanic &&
              (
                status == 'accepted' ||
                status == 'on_the_way' ||
                status == 'cancelled' ||
                status == 'completed'
              );

          if (!nearbyPending && !assignedRequest) {
            continue;
          }


          requests.add(
            _requestFromDocument(
              document
            ),
          );
        }

        /// Newest first.
        requests.sort(
          (a, b) {
            final aDate = _requestDate(a);
            final bDate = _requestDate(b);

            return bDate.compareTo(aDate);
          },
        );

        return requests;
      },
    );
  }

  /// ------------------------------------------------------------
  /// ACCEPT REQUEST
  /// ------------------------------------------------------------

  Future<void> acceptRequest(String requestId) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('Mechanic is not logged in.');
    }

    final mechanicDocument = await _firestore
        .collection('mechanics')
        .doc(user.uid)
        .get();

    final mechanicData =
        mechanicDocument.data() ?? {};

    final mechanicName =
        (mechanicData['name'] ??
                user.displayName ??
                'Mechanic')
            .toString();

    final mechanicPhone =
        (mechanicData['phone'] ?? user.phoneNumber ?? '')
            .toString();

    final mechanicEmail =
        (mechanicData['email'] ?? user.email ?? '')
            .toString();

    final requestRef =
        _firestore.collection('requests').doc(requestId);

    await _firestore.runTransaction(
      (transaction) async {
        final requestSnapshot =
            await transaction.get(requestRef);

        if (!requestSnapshot.exists) {
          throw Exception('Request no longer exists.');
        }

        final data = requestSnapshot.data();

        if (data == null) {
          throw Exception('Request data is empty.');
        }

        final currentStatus =
            (data['status'] ?? 'pending').toString();

        /// Prevent two mechanics from accepting
        /// the same request.
        if (currentStatus != 'pending') {
          throw Exception(
            'This request has already been accepted '
            'or is no longer available.',
          );
        }

        transaction.update(
          requestRef,
          {
            'status': 'accepted',
            'mechanicId': user.uid,
            'mechanicName': mechanicName,
            'mechanicPhone': mechanicPhone,
            'mechanicEmail': mechanicEmail,
            'acceptedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );
      },
    );
  }

  /// ------------------------------------------------------------
  /// CANCEL REQUEST
  /// ------------------------------------------------------------

  Future<void> cancelRequest(String requestId) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('Mechanic is not logged in.');
    }

    final mechanicDocument = await _firestore
        .collection('mechanics')
        .doc(user.uid)
        .get();

    final mechanicData =
        mechanicDocument.data() ?? {};

    final mechanicName =
        (mechanicData['name'] ??
                user.displayName ??
                'Mechanic')
            .toString();

    final mechanicPhone =
        (mechanicData['phone'] ?? user.phoneNumber ?? '')
            .toString();

    final mechanicEmail =
        (mechanicData['email'] ?? user.email ?? '')
            .toString();

    await _firestore
        .collection('requests')
        .doc(requestId)
        .update(
      {
        'status': 'cancelled',
        'mechanicId': user.uid,
        'mechanicName': mechanicName,
        'mechanicPhone': mechanicPhone,
        'mechanicEmail': mechanicEmail,
        'cancelledBy': 'mechanic',
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );
  }

  /// ------------------------------------------------------------
  /// MARK ON THE WAY
  /// ------------------------------------------------------------

  Future<void> markOnTheWay(String requestId) async {
    final user = currentUser;

    if (user == null) {
      throw Exception('Mechanic is not logged in.');
    }

    await _firestore
        .collection('requests')
        .doc(requestId)
        .update(
      {
        'status': 'on_the_way',
        'onTheWayAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );
  }

  /// ------------------------------------------------------------
  /// REQUEST MODEL
  /// ------------------------------------------------------------

  RequestModel _requestFromDocument(
  DocumentSnapshot<Map<String, dynamic>> document,
) {
  return RequestModel.fromFirestore(document);
}

  /// ------------------------------------------------------------
  /// DISTANCE
  /// ------------------------------------------------------------

  double _calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371;

    final double dLat =
        _degreesToRadians(lat2 - lat1);

    final double dLon =
        _degreesToRadians(lon2 - lon1);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c =
        2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degree) {
    return degree * pi / 180;
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }


  DateTime _requestDate(RequestModel request) {

    return request.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
}