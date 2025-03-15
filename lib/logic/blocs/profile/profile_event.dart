import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class ProfileUpdateRequested extends ProfileEvent {
  final String? displayName;
  final String? photoURL;
  final String? phoneNumber;
  final String? bio;

  const ProfileUpdateRequested({
    this.displayName,
    this.photoURL,
    this.phoneNumber,
    this.bio,
  });

  @override
  List<Object?> get props => [displayName, photoURL, phoneNumber, bio];
}

class ProfileSignOutRequested extends ProfileEvent {
  const ProfileSignOutRequested();
}
