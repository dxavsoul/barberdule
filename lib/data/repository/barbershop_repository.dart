import 'dart:math' as math;
import 'package:barberdule/data/models/barbershop.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BarbershopRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'barbershops';

  BarbershopRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Get all barbershops as a stream
  Stream<List<Barbershop>> getAllBarbershopsStream() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Barbershop.fromJson(data);
      }).toList();
    });
  }

  // Get all barbershops as a future
  Future<List<Barbershop>> getAllBarbershops() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        print(doc.id);
        data['id'] = doc.id;
        return Barbershop.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching barbershops: $e');
      return [];
    }
  }

  // Get a single barbershop by ID
  Future<Barbershop?> getBarbershopById(String barbershopId) async {
    try {
      final doc =
          await _firestore.collection(_collection).doc(barbershopId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      data['id'] = doc.id;
      return Barbershop.fromJson(data);
    } catch (e) {
      print('Error fetching barbershop: $e');
      return null;
    }
  }

  // Get a barbershop by owner ID
  Future<Barbershop?> getBarbershopByOwnerId(String ownerId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('ownerId', isEqualTo: ownerId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        data['id'] = snapshot.docs.first.id;
        return Barbershop.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get barbershop by owner ID: $e');
    }
  }

  // Create a new barbershop
  Future<String?> createBarbershop(Barbershop barbershop) async {
    try {
      final docRef =
          await _firestore.collection(_collection).add(barbershop.toJson()).then((DocumentReference doc) {
            print('Document ID: ${doc.id}');
            return doc;
          });
      return docRef.id;
    } catch (e) {
      print('Error creating barbershop: $e');
      return null;
    }
  }

  // Update an existing barbershop
  Future<bool> updateBarbershop(
    String barbershopId,
    Barbershop barbershop,
  ) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(barbershopId)
          .update(barbershop.toJson());
      return true;
    } catch (e) {
      print('Error updating barbershop: $e');
      return false;
    }
  }

  // Delete a barbershop
  Future<bool> deleteBarbershop(String barbershopId) async {
    try {
      await _firestore.collection(_collection).doc(barbershopId).delete();
      return true;
    } catch (e) {
      print('Error deleting barbershop: $e');
      return false;
    }
  }

  // Update barbershop rating
  Future<bool> updateBarbershopRating(
    String barbershopId,
    double rating,
  ) async {
    try {
      await _firestore.collection(_collection).doc(barbershopId).update({
        'rating': rating,
      });
      return true;
    } catch (e) {
      print('Error updating barbershop rating: $e');
      return false;
    }
  }

  // Get barbershops near a location
  Future<List<Barbershop>> getNearbyBarbershops(
    GeoPoint center,
    double radiusInKm,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();

      final barbershops = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Barbershop.fromJson(data);
      }).toList();

      // Filter barbershops by distance (simplified calculation)
      return barbershops.where((shop) {
        final lat1 = center.latitude;
        final lon1 = center.longitude;
        final lat2 = shop.location.latitude;
        final lon2 = shop.location.longitude;

        // Approximate distance calculation using the Haversine formula
        const earthRadius = 6371.0; // in kilometers
        final dLat = _toRadians(lat2 - lat1);
        final dLon = _toRadians(lon2 - lon1);
        final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
            math.sin(dLon / 2) *
                math.sin(dLon / 2) *
                math.cos(_toRadians(lat1)) *
                math.cos(_toRadians(lat2));
        final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
        final distance = earthRadius * c;

        return distance <= radiusInKm;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get nearby barbershops: $e');
    }
  }

  // Helper method to convert degrees to radians
  double _toRadians(double degree) {
    return degree * (math.pi / 180);
  }

  // Add a barber to a barbershop
  Future<void> addBarberToBarbershop(
    String barbershopId,
    String barberId,
  ) async {
    try {
      await _firestore.collection(_collection).doc(barbershopId).update({
        'barberIds': FieldValue.arrayUnion([barberId]),
      });
    } catch (e) {
      throw Exception('Failed to add barber to barbershop: $e');
    }
  }

  // Remove a barber from a barbershop
  Future<void> removeBarberFromBarbershop(
    String barbershopId,
    String barberId,
  ) async {
    try {
      await _firestore.collection(_collection).doc(barbershopId).update({
        'barberIds': FieldValue.arrayRemove([barberId]),
      });
    } catch (e) {
      throw Exception('Failed to remove barber from barbershop: $e');
    }
  }
}
