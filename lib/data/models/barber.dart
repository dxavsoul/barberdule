import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum BarberApprovalStatus { pending, approved, rejected }

extension BarberApprovalStatusExtension on BarberApprovalStatus {
  String get name {
    switch (this) {
      case BarberApprovalStatus.pending:
        return 'pending';
      case BarberApprovalStatus.approved:
        return 'approved';
      case BarberApprovalStatus.rejected:
        return 'rejected';
    }
  }

  static BarberApprovalStatus fromString(String status) {
    switch (status) {
      case 'pending':
        return BarberApprovalStatus.pending;
      case 'approved':
        return BarberApprovalStatus.approved;
      case 'rejected':
        return BarberApprovalStatus.rejected;
      default:
        return BarberApprovalStatus.pending;
    }
  }
}

class Barber extends Equatable {
  final String? id;
  final String userId;
  final String name;
  final String? imageUrl;
  final String? bio;
  // final List<String> services;
  final double? rating;
  final String? barbershopId;
  final GeoPoint? location;
  final String phoneNumber;
  final String email;
  final List<String> specialties;
  final Map<String, dynamic> workingHours;
  final bool isActive;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final BarberApprovalStatus approvalStatus;
  final String? rejectionReason;

  Barber({
    this.id,
    required this.name,
    this.imageUrl,
    this.bio,
    // required this.services,
    this.rating,
    this.barbershopId,
    this.location,
    required this.userId,
    required this.phoneNumber,
    required this.email,
    required this.specialties,
    required this.workingHours,
    this.isActive = true,
    this.reviewCount = 0,
    DateTime? createdAt,
    this.updatedAt,
    this.approvalStatus = BarberApprovalStatus.pending,
    this.rejectionReason,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Barber.fromJson(Map<String, dynamic> json) {
    return Barber(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String?,
      bio: json['bio'] as String?,
      // services: List<String>.from(json['services'] as List),
      rating: json['rating'] as double?,
      barbershopId: json['barbershopId'] as String?,
      location: json['location'] as GeoPoint?,
      userId: json['userId'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String,
      specialties: List<String>.from(json['specialties'] as List),
      workingHours: Map<String, dynamic>.from(json['workingHours'] as Map),
      isActive: json['isActive'] as bool? ?? true,
      reviewCount: json['reviewCount'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      approvalStatus: BarberApprovalStatusExtension.fromString(
        json['approvalStatus'] as String? ?? 'pending',
      ),
      rejectionReason: json['rejectionReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'bio': bio,
      // 'services': services,
      'rating': rating,
      'barbershopId': barbershopId,
      'location': location,
      'userId': userId,
      'phoneNumber': phoneNumber,
      'email': email,
      'specialties': specialties,
      'workingHours': workingHours,
      'isActive': isActive,
      'reviewCount': reviewCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'approvalStatus': approvalStatus.name,
      'rejectionReason': rejectionReason,
    };
  }

  Barber copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? bio,
    List<String>? services,
    double? rating,
    String? barbershopId,
    GeoPoint? location,
    String? userId,
    String? phoneNumber,
    String? email,
    List<String>? specialties,
    Map<String, dynamic>? workingHours,
    bool? isActive,
    int? reviewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    BarberApprovalStatus? approvalStatus,
    String? rejectionReason,
  }) {
    return Barber(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      bio: bio ?? this.bio,
      // services: services ?? this.services,
      rating: rating ?? this.rating,
      barbershopId: barbershopId ?? this.barbershopId,
      location: location ?? this.location,
      userId: userId ?? this.userId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      specialties: specialties ?? this.specialties,
      workingHours: workingHours ?? this.workingHours,
      isActive: isActive ?? this.isActive,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        imageUrl,
        bio,
        // services,
        rating,
        barbershopId,
        location,
        userId,
        phoneNumber,
        email,
        specialties,
        workingHours,
        isActive,
        reviewCount,
        createdAt,
        updatedAt,
        approvalStatus,
        rejectionReason,
      ];
}
