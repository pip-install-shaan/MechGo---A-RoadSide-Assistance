enum MechanicProfileStatus {
  initial,
  loading,
  loaded,
  updating,
  updateSuccess,
  failure,
  loggingOut,
  logoutSuccess,
}

class MechanicProfileState {
  final MechanicProfileStatus status;

  final String name;
  final String email;
  final String phone;
  final String role;

  final String workshopName;
  final String specialization;

  final String profilePic;

  final double rating;
  final int reviewCount;

  final String? errorMessage;

  const MechanicProfileState({
    this.status = MechanicProfileStatus.initial,
    this.name = '',
    this.email = '',
    this.phone = '',
    this.role = 'mechanic',
    this.workshopName = '',
    this.specialization = '',
    this.profilePic = '',
    this.rating = 0,
    this.reviewCount = 0,
    this.errorMessage,
  });

  MechanicProfileState copyWith({
    MechanicProfileStatus? status,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? workshopName,
    String? specialization,
    String? profilePic,
    double? rating,
    int? reviewCount,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MechanicProfileState(
      status: status ?? this.status,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      workshopName: workshopName ?? this.workshopName,
      specialization: specialization ?? this.specialization,
      profilePic: profilePic ?? this.profilePic,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      errorMessage:
          clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}