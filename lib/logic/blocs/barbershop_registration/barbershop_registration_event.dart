import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

abstract class BarbershopRegistrationEvent extends Equatable {
  const BarbershopRegistrationEvent();

  @override
  List<Object> get props => [];
}

class BarbershopRegistrationSubmitted extends BarbershopRegistrationEvent {
  final String name;
  final String address;
  final String phone;
  final String email;
  final String description;
  final String? imageUrl;
  final GeoPoint location;
  final Map<String, dynamic> workingHours;
  final String? ownerId;

  const BarbershopRegistrationSubmitted({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.description,
    this.imageUrl,
    required this.location,
    required this.workingHours,
    this.ownerId,
  });

  @override
  List<Object> get props => [
        name,
        address,
        phone,
        email,
        description,
        location,
        workingHours,
        ownerId ?? '',
      ];
}
