import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final User user;
  final String? phoneNumber;
  final String? bio;
  final String? userType; // 'barber', 'customer', or null

  const ProfileLoaded({
    required this.user,
    this.phoneNumber,
    this.bio,
    this.userType,
  });

  @override
  List<Object?> get props => [user, phoneNumber, bio, userType];
}

class ProfileUpdateLoading extends ProfileState {
  const ProfileUpdateLoading();
}

class ProfileUpdateSuccess extends ProfileState {
  const ProfileUpdateSuccess();
}

class ProfileUpdateFailure extends ProfileState {
  final String error;

  const ProfileUpdateFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class ProfileSignOutSuccess extends ProfileState {
  const ProfileSignOutSuccess();
}

class ProfileSignOutFailure extends ProfileState {
  final String error;

  const ProfileSignOutFailure({required this.error});

  @override
  List<Object> get props => [error];
}
