import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

abstract class BarberRegistrationEvent extends Equatable {
  const BarberRegistrationEvent();

  @override
  List<Object?> get props => [];
}

class BarberRegistrationSubmitted extends BarberRegistrationEvent {
  final String name;
  final String phoneNumber;
  final String email;
  final String password;
  final String bio;
  final String? imageUrl;
  final String address;
  final GeoPoint location;
  final List<String> specialties;
  final String barbershopId;
  final Map<String, dynamic> workingHours;

  const BarberRegistrationSubmitted({
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.password,
    required this.bio,
    this.imageUrl,
    required this.address,
    required this.location,
    required this.specialties,
    required this.barbershopId,
    required this.workingHours,
  });

  @override
  List<Object?> get props => [
    name,
    phoneNumber,
    email,
    password,
    bio,
    imageUrl,
    address,
    specialties,
    barbershopId,
    workingHours,
  ];
}
