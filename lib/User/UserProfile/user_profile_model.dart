import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool phoneVerified;
  final String profilePic;
  final String? selectedPaymentMethodId;
  final DateTime? createdAt;

  const UserProfileModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.phoneVerified,
    required this.profilePic,
    this.selectedPaymentMethodId,
    this.createdAt,
  });

  factory UserProfileModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    final timestamp = data['createdAt'];

    return UserProfileModel(
      uid: data['uid']?.toString() ?? doc.id,
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      role: data['role']?.toString() ?? 'user',
      phoneVerified:
          data['phoneVerified'] == true,
      profilePic:
          data['profilePic']?.toString() ?? '',
      selectedPaymentMethodId:
          data['selectedPaymentMethodId']
              ?.toString(),
      createdAt: timestamp is Timestamp
          ? timestamp.toDate()
          : null,
    );
  }
}