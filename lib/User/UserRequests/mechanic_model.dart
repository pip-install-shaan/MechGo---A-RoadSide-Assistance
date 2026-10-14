class MechanicModel {
  final String id;
  final String name;
  final String phone;
  final String email;

  final double latitude;
  final double longitude;

  final bool isAvailable;

  final double rating;
  final int totalReviews;

  const MechanicModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.latitude,
    required this.longitude,
    required this.isAvailable,
    required this.rating,
    required this.totalReviews,
  });

  factory MechanicModel.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return MechanicModel(
      id: id,

      name: data['name'] ?? 'Mechanic',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',

      latitude: _toDouble(data['latitude']),
      longitude: _toDouble(data['longitude']),

      isAvailable: data['isAvailable'] ?? true,

      rating: _toDouble(data['rating']),
      totalReviews: data['totalReviews'] ?? 0,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0.0;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
      'isAvailable': isAvailable,
      'rating': rating,
      'totalReviews': totalReviews,
    };
  }
}