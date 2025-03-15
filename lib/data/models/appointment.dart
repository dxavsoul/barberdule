import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String barberId;
  final String barberName;
  final String? barberPhotoUrl;
  final String customerId;
  final String customerName;
  final String? customerPhotoUrl;
  final String barbershopId;
  final String barbershopName;
  final String serviceId;
  final String serviceName;
  final double servicePrice;
  final DateTime dateTime;
  final int duration;
  final String status; // 'upcoming', 'completed', 'cancelled'
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Appointment({
    required this.id,
    required this.barberId,
    required this.barberName,
    this.barberPhotoUrl,
    required this.customerId,
    required this.customerName,
    this.customerPhotoUrl,
    required this.barbershopId,
    required this.barbershopName,
    required this.serviceId,
    required this.serviceName,
    required this.servicePrice,
    required this.dateTime,
    required this.duration,
    required this.status,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Appointment(
      id: doc.id,
      barberId: data['barberId'] as String,
      barberName: data['barberName'] as String,
      barberPhotoUrl: data['barberPhotoUrl'] as String?,
      customerId: data['customerId'] as String,
      customerName: data['customerName'] as String,
      customerPhotoUrl: data['customerPhotoUrl'] as String?,
      barbershopId: data['barbershopId'] as String,
      barbershopName: data['barbershopName'] as String,
      serviceId: data['serviceId'] as String,
      serviceName: data['serviceName'] as String,
      servicePrice: (data['servicePrice'] as num).toDouble(),
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      duration: data['duration'] as int,
      status: data['status'] as String,
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt:
          data['updatedAt'] != null
              ? (data['updatedAt'] as Timestamp).toDate()
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'barberId': barberId,
      'barberName': barberName,
      'barberPhotoUrl': barberPhotoUrl,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhotoUrl': customerPhotoUrl,
      'barbershopId': barbershopId,
      'barbershopName': barbershopName,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'servicePrice': servicePrice,
      'dateTime': Timestamp.fromDate(dateTime),
      'duration': duration,
      'status': status,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  Appointment copyWith({
    String? id,
    String? barberId,
    String? barberName,
    String? barberPhotoUrl,
    String? customerId,
    String? customerName,
    String? customerPhotoUrl,
    String? barbershopId,
    String? barbershopName,
    String? serviceId,
    String? serviceName,
    double? servicePrice,
    DateTime? dateTime,
    int? duration,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      barberId: barberId ?? this.barberId,
      barberName: barberName ?? this.barberName,
      barberPhotoUrl: barberPhotoUrl ?? this.barberPhotoUrl,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhotoUrl: customerPhotoUrl ?? this.customerPhotoUrl,
      barbershopId: barbershopId ?? this.barbershopId,
      barbershopName: barbershopName ?? this.barbershopName,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      servicePrice: servicePrice ?? this.servicePrice,
      dateTime: dateTime ?? this.dateTime,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
