import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  final String? id;
  final String name;
  final double price;
  final String description;
  final int durationMinutes;
  final String? imageUrl;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? barbershopId;

  Service({
    this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.durationMinutes,
    this.imageUrl,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.barbershopId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'durationMinutes': durationMinutes,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt':
          createdAt != null ? Timestamp.fromDate(createdAt!) : Timestamp.now(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'barbershopId': barbershopId,
    };
  }

  factory Service.fromMap(Map<String, dynamic> map, String documentId) {
    return Service(
      id: documentId,
      name: map['name'] as String,
      price:
          (map['price'] is int)
              ? (map['price'] as int).toDouble()
              : map['price'] as double,
      description: map['description'] as String,
      durationMinutes: map['durationMinutes'] as int,
      imageUrl: map['imageUrl'] as String?,
      isActive: map['isActive'] as bool? ?? true,
      createdAt:
          map['createdAt'] != null
              ? (map['createdAt'] as Timestamp).toDate()
              : null,
      updatedAt:
          map['updatedAt'] != null
              ? (map['updatedAt'] as Timestamp).toDate()
              : null,
      barbershopId: map['barbershopId'] as String?,
    );
  }

  factory Service.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Service(
      id: doc.id,
      name: data['name'] as String,
      price:
          (data['price'] is int)
              ? (data['price'] as int).toDouble()
              : data['price'] as double,
      description: data['description'] as String,
      durationMinutes: data['durationMinutes'] as int,
      imageUrl: data['imageUrl'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      createdAt:
          data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : null,
      updatedAt:
          data['updatedAt'] != null
              ? (data['updatedAt'] as Timestamp).toDate()
              : null,
      barbershopId: data['barbershopId'] as String?,
    );
  }

  Service copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    int? durationMinutes,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? barbershopId,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      barbershopId: barbershopId ?? this.barbershopId,
    );
  }
}
