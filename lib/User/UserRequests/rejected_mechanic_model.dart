import 'package:cloud_firestore/cloud_firestore.dart';

class RejectedMechanicModel {
  final String mechanicId;
  final String mechanicName;
  final String mechanicPhone;
  final String mechanicProfilePic;
  final DateTime? rejectedAt;

  const RejectedMechanicModel({
    required this.mechanicId,
    required this.mechanicName,
    required this.mechanicPhone,
    required this.mechanicProfilePic,
    this.rejectedAt,
  });

  factory RejectedMechanicModel.fromMap(
    Map<String, dynamic> data,
  ) {
    return RejectedMechanicModel(
      mechanicId: data['mechanicId']?.toString() ?? '',
      mechanicName: data['mechanicName']?.toString() ?? 'Mechanic',
      mechanicPhone: data['mechanicPhone']?.toString() ?? '',
      mechanicProfilePic:
          data['mechanicProfilePic']?.toString() ?? '',
      rejectedAt: _timestampToDate(data['rejectedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mechanicId': mechanicId,
      'mechanicName': mechanicName,
      'mechanicPhone': mechanicPhone,
      'mechanicProfilePic': mechanicProfilePic,
      'rejectedAt': rejectedAt,
    };
  }

  static DateTime? _timestampToDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}