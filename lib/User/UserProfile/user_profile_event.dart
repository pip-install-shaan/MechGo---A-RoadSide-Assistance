import 'package:equatable/equatable.dart';

class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object?> get props => [];
}

class FetchUserProfile extends UserProfileEvent {
  const FetchUserProfile();
}

class WatchUserProfile extends UserProfileEvent {
  const WatchUserProfile();
}

class FetchCompletedPaymentRequest extends UserProfileEvent {
  const FetchCompletedPaymentRequest();
}

class UpdateUserProfile extends UserProfileEvent {
  final String name;
  final String profilePic;

  const UpdateUserProfile({
    required this.name,
    required this.profilePic,
  });

  @override
  List<Object?> get props => [
        name,
        profilePic,
      ];
}

class LogoutUser extends UserProfileEvent {
  const LogoutUser();
}