import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Barbershop extends Equatable {
  final String id;
  final String name;
  final String address;
  final String? phone;
  final String? email;
  final String? description;
  final String? imageUrl;
  final GeoPoint location;
  final Map<String, dynamic> workingHours;
  final double? rating;
  final int reviewCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isOpen;
  final double distance;
  final String ownerId; // Firebase Auth user ID of the owner

  // Add getters for latitude and longitude
  double get latitude => location.latitude;
  double get longitude => location.longitude;

  Barbershop({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    this.email,
    this.description,
    this.imageUrl,
    required this.location,
    required this.workingHours,
    this.rating,
    this.reviewCount = 0,
    this.isActive = true,
    DateTime? createdAt,
    this.updatedAt,
    this.isOpen = false,
    this.distance = 0.0,
    required this.ownerId,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Barbershop.fromJson(Map<String, dynamic> json) {
    return Barbershop(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      location: json['location'] as GeoPoint,
      workingHours: Map<String, dynamic>.from(json['workingHours'] as Map),
      rating: json['rating'] as double?,
      reviewCount: json['reviewCount'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      isOpen: json['isOpen'] as bool? ?? false,
      distance: json['distance'] as double? ?? 0.0,
      ownerId: json['ownerId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'description': description,
      'imageUrl': imageUrl,
      'location': location,
      'workingHours': workingHours,
      'rating': rating,
      'reviewCount': reviewCount,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isOpen': isOpen,
      'distance': distance,
      'ownerId': ownerId,
    };
  }

  Barbershop copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    String? email,
    String? description,
    String? imageUrl,
    GeoPoint? location,
    Map<String, dynamic>? workingHours,
    double? rating,
    int? reviewCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isOpen,
    double? distance,
    String? ownerId,
  }) {
    return Barbershop(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      workingHours: workingHours ?? this.workingHours,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isOpen: isOpen ?? this.isOpen,
      distance: distance ?? this.distance,
      ownerId: ownerId ?? this.ownerId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        phone,
        email,
        description,
        imageUrl,
        location,
        workingHours,
        rating,
        reviewCount,
        isActive,
        createdAt,
        updatedAt,
        isOpen,
        distance,
        ownerId,
      ];
}
