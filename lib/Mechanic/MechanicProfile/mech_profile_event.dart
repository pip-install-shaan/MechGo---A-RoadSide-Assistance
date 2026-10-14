import 'dart:io';

abstract class MechanicProfileEvent {
  const MechanicProfileEvent();
}

/// Fetch mechanic profile from Firestore
class FetchMechanicProfile extends MechanicProfileEvent {
  const FetchMechanicProfile();
}

/// Update mechanic profile
class UpdateMechanicProfile extends MechanicProfileEvent {
  final String name;
  final String workshopName;
  final String specialization;
  final File? profileImage;

  const UpdateMechanicProfile({
    required this.name,
    required this.workshopName,
    required this.specialization,
    this.profileImage,
  });
}

/// Logout mechanic
class LogoutMechanic extends MechanicProfileEvent {
  const LogoutMechanic();
}