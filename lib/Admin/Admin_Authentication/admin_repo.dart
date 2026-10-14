import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRepository{
  final FirebaseFirestore _firestore;

  AdminRepository({
    FirebaseFirestore? firestore,
  }): _firestore =firestore ?? FirebaseFirestore.instance;
   
  Future<int> getTotalUsers()async{
    final QuerySnapshot<Map<String, dynamic>> snapshot=await
    _firestore.collection('users').where('role',isEqualTo: 'user').get();
    return snapshot.size;
  }
  
  Future<int> getTotalMechanics() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _firestore
            .collection('users')
            .where('role', isEqualTo: 'mechanic')
            .get();

    return snapshot.size;
  }
  
  Future<List<Map<String, dynamic>>> getAllRequests() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _firestore
            .collection('requests')
            .orderBy(
              'createdAt',
              descending: true,
            )
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return {
        'requestId': doc.id,
        ...data,
      };
    }).toList();
  }

  // ==========================================
  // RECENT REQUESTS
  // ==========================================

  Future<List<Map<String, dynamic>>> getRecentRequests() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _firestore
            .collection('requests')
            .orderBy(
              'createdAt',
              descending: true,
            )
            .limit(5)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return {
        'requestId': doc.id,
        ...data,
      };
    }).toList();
  }
  

  Future<int> getActiveRequests() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _firestore
            .collection('requests')
            .where(
              'status',
              whereIn: [
                'pending',
                'accepted',
                'on_the_way',
              ],
            )
            .get();

    return snapshot.size;
  }

  // ==========================================
  // COMPLETED REQUESTS
  // ==========================================

  Future<int> getCompletedRequests() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _firestore
            .collection('requests')
            .where(
              'status',
              isEqualTo: 'completed',
            )
            .get();

    return snapshot.size;
  }

  // ==========================================
  // TOTAL EARNINGS
  // ==========================================

  Future<double> getTotalEarnings() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _firestore
            .collection('requests')
            .where(
              'status',
              isEqualTo: 'completed',
            )
            .get();

    double total = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final amount = data['amount'];

      if (amount is num) {
        total += amount.toDouble();
      }
    }

    return total;
  }

  Stream<List<Map<String, dynamic>>> watchUsers() {
  return _firestore
      .collection('users')
      .where('role', isEqualTo: 'user')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return {
        'uid': doc.id,
        ...doc.data(),
      };
    }).toList();
  });
}

Stream<List<Map<String, dynamic>>> watchMechanics() {
  return _firestore
      .collection('users')
      .where('role', isEqualTo: 'mechanic')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return {
        'uid': doc.id,
        ...doc.data(),
      };
    }).toList();
  });
}

Future<void> deleteUser(String uid) async {
  await _firestore
      .collection('users')
      .doc(uid)
      .delete();
}

Future<void> deleteMechanic(String uid) async {
  await _firestore
      .collection('users')
      .doc(uid)
      .delete();
}

// Future<void> logout() async {
//   await FirebaseAuth.instance.signOut();
// }

}