import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MechanicEarningsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  MechanicEarningsRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get mechanicId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Mechanic is not logged in.');
    }

    return user.uid;
  }

  /// Realtime stream of completed requests
  /// belonging to the logged-in mechanic.
  Stream<List<Map<String, dynamic>>> watchMechanicEarnings() {
    return _firestore
        .collection('requests')
        .where('mechanicId', isEqualTo: mechanicId)
        .where('status', isEqualTo: 'completed')
        .snapshots()
        .map((snapshot) {
      final earnings = snapshot.docs.map((document) {
        final data = document.data();

        return {
          'requestId': document.id,
          'userName': data['userName'] ?? 'Customer',
          'amount': _toDouble(data['amount']),
          'completedAt': _toDateTime(data['completedAt']),
          'createdAt': _toDateTime(data['createdAt']),
        };
      }).toList();

      earnings.sort((a, b) {
        final aDate =
            a['completedAt'] as DateTime? ??
            a['createdAt'] as DateTime? ??
            DateTime.fromMillisecondsSinceEpoch(0);

        final bDate =
            b['completedAt'] as DateTime? ??
            b['createdAt'] as DateTime? ??
            DateTime.fromMillisecondsSinceEpoch(0);

        return bDate.compareTo(aDate);
      });

      return earnings;
    });
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}