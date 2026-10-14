import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mech_go/User/UserRequests/rejected_mechanic_model.dart';

class RequestModel {
  final String requestId;
  final String userId;

  final String userName;
  final String userPhone;

  final String vehicleType;
  final String problemType;
  final String description;

  final String location;

  // User's real GPS location when request was created
  final double latitude;
  final double longitude;

  final List<String> imageUrls;
  final List<RejectedMechanicModel> rejectedMechanics;
  
  final String status;

  // Mechanic information
  final String mechanicId;
  final String mechanicName;
  final String mechanicPhone;
  final String? mechanicEmail;
  final bool mechanicVerified;
  final String mechanicProfilePic;
  final double amount;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? acceptedAt;

  const RequestModel({
    required this.requestId,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.vehicleType,
    required this.problemType,
    required this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.imageUrls,
    this.rejectedMechanics = const [],
    required this.status,
    required this.mechanicProfilePic,
    required this.mechanicId,
    required this.mechanicName,
    required this.mechanicPhone,
    this.mechanicEmail,
    this.mechanicVerified = false,
    required this.amount,
    this.createdAt,
    this.updatedAt,
    this.acceptedAt,
  });

  factory RequestModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};

    return RequestModel(
      requestId: data['requestId'] ?? snapshot.id,

      userId: data['userId'] ?? '',

      userName: data['userName'] ?? '',
      userPhone: data['userPhone'] ?? '',

      vehicleType: data['vehicleType'] ?? '',
      problemType: data['problemType'] ?? '',
      description: data['description'] ?? '',
      
      location: data['location'] ?? '',

      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,

      imageUrls: List<String>.from(
        data['imageUrls'] ?? [],
      ),

      status: data['status'] ?? 'pending',
      mechanicProfilePic: data['mechanicProfilePic'] ,
      mechanicId: data['mechanicId'],
      mechanicName: data['mechanicName'],
      mechanicPhone: data['mechanicPhone'],
      mechanicEmail: data['mechanicEmail'],

      mechanicVerified:
          data['mechanicVerified'] ?? false,

      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      
      rejectedMechanics: (data['rejectedMechanics'] as List<dynamic>? ?? [])
      .whereType<Map<String, dynamic>>().map(
        RejectedMechanicModel.fromMap,
      ).toList(),
      createdAt: _timestampToDate(data['createdAt']),
      updatedAt: _timestampToDate(data['updatedAt']),
      acceptedAt: _timestampToDate(data['acceptedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,

      'userId': userId,

      'userName': userName,
      'userPhone': userPhone,

      'vehicleType': vehicleType,
      'problemType': problemType,
      'description': description,

      'location': location,

      // REAL USER GPS
      'latitude': latitude,
      'longitude': longitude,

      'imageUrls': imageUrls,
      'rejectedMechanics':
      rejectedMechanics.map((mechanic)=>mechanic.toMap()).toList(),
      'status': status,

      'mechanicId': mechanicId,
      'mechanicName': mechanicName,
      'mechanicPhone': mechanicPhone,
      'mechanicEmail': mechanicEmail,
      'mechanicVerified': mechanicVerified,
      'mechanicProfilePic': mechanicProfilePic,
      'amount': amount,

      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'acceptedAt': acceptedAt,
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

  RequestModel copyWith({
    String? requestId,
    String? userId,
    String? userName,
    String? userPhone,
    String? vehicleType,
    String? problemType,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    List<String>? imageUrls,
    List<RejectedMechanicModel>? rejectedMechanics,
    String? status,
    String? mechanicId,
    String? mechanicName,
    String? mechanicPhone,
    String? mechanicEmail,
    bool? mechanicVerified,
    String? mechanicProfilePic,
    double? amount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? acceptedAt,
  }) {
    return RequestModel(
      requestId: requestId ?? this.requestId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      vehicleType: vehicleType ?? this.vehicleType,
      problemType: problemType ?? this.problemType,
      description: description ?? this.description,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrls: imageUrls ?? this.imageUrls,
      rejectedMechanics: rejectedMechanics ?? this.rejectedMechanics,
      status: status ?? this.status,
      mechanicId: mechanicId ?? this.mechanicId,
      mechanicName: mechanicName ?? this.mechanicName,
      mechanicPhone: mechanicPhone ?? this.mechanicPhone,
      mechanicEmail: mechanicEmail ?? this.mechanicEmail,
      mechanicVerified:
          mechanicVerified ?? this.mechanicVerified,
      mechanicProfilePic: mechanicProfilePic ?? this.mechanicProfilePic,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
    );
  }
}