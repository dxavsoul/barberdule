import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/barber.dart';

class BarberRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'barbers';

  BarberRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Get all barbers as a stream
  Stream<List<Barber>> getAllBarbersStream() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Barber.fromJson(data);
      }).toList();
    });
  }

  // Get a single barber by ID
  Future<Barber?> getBarberById(String barberId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(barberId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      data['id'] = doc.id;
      return Barber.fromJson(data);
    } catch (e) {
      print('Error fetching barber: $e');
      return null;
    }
  }

  // Get a barber by user ID
  Future<Barber?> getBarberByUserId(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      final data = doc.data();
      data['id'] = doc.id;
      return Barber.fromJson(data);
    } catch (e) {
      print('Error fetching barber by user ID: $e');
      return null;
    }
  }

  Future<String?> getBarbershopName(String barbershopId) async {
    try {
      final doc =
          await _firestore.collection('barbershops').doc(barbershopId).get();
      if (!doc.exists) return null;
      return doc.data()?['name'] as String?;
    } catch (e) {
      print('Error fetching barbershop name: $e');
      return null;
    }
  }

  // Get all barbers
  Future<List<Barber>> getAllBarbers() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Barber.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching all barbers: $e');
      return [];
    }
  }

  // Get barbers by barbershop
  Stream<List<Barber>> getBarbersByBarbershop(String barbershopId) {
    return _firestore
        .collection(_collection)
        .where('barbershopId', isEqualTo: barbershopId)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Barber.fromJson(data);
          }).toList(),
        );
  }

  // Create a new barber
  Future<String?> createBarber(Barber barber) async {
    try {
      final docRef =
          await _firestore.collection(_collection).add(barber.toJson());
      return docRef.id;
    } catch (e) {
      print('Error creating barber: $e');
      return null;
    }
  }

  // Update an existing barber
  Future<bool> updateBarber(String barberId, Barber barber) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(barberId)
          .update(barber.toJson());
      return true;
    } catch (e) {
      print('Error updating barber: $e');
      return false;
    }
  }

  // Delete a barber
  Future<bool> deleteBarber(String barberId) async {
    try {
      await _firestore.collection(_collection).doc(barberId).delete();
      return true;
    } catch (e) {
      print('Error deleting barber: $e');
      return false;
    }
  }

  // Get pending barbers by barbershop
  Stream<List<Barber>> getPendingBarbersByBarbershop(String barbershopId) {
    return _firestore
        .collection(_collection)
        .where('barbershopId', isEqualTo: barbershopId)
        .where('isActive', isEqualTo: true)
        .where('approvalStatus', isEqualTo: BarberApprovalStatus.pending.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Barber.fromJson(data);
          }).toList(),
        );
  }

  // Get approved barbers by barbershop
  Stream<List<Barber>> getApprovedBarbersByBarbershop(String barbershopId) {
    return _firestore
        .collection(_collection)
        .where('barbershopId', isEqualTo: barbershopId)
        .where('isActive', isEqualTo: true)
        .where('approvalStatus', isEqualTo: BarberApprovalStatus.approved.name)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Barber.fromJson(data);
          }).toList(),
        );
  }

  // Approve a barber
  Future<bool> approveBarber(String barberId) async {
    try {
      await _firestore.collection(_collection).doc(barberId).update({
        'approvalStatus': 'approved',
      });
      return true;
    } catch (e) {
      print('Error approving barber: $e');
      return false;
    }
  }

  // Reject a barber
  Future<bool> rejectBarber(String barberId, String reason) async {
    try {
      await _firestore.collection(_collection).doc(barberId).update({
        'approvalStatus': 'rejected',
        'rejectionReason': reason,
      });
      return true;
    } catch (e) {
      print('Error rejecting barber: $e');
      return false;
    }
  }

  // Update barber rating
  Future<bool> updateBarberRating(String barberId, double rating) async {
    try {
      await _firestore.collection(_collection).doc(barberId).update({
        'rating': rating,
      });
      return true;
    } catch (e) {
      print('Error updating barber rating: $e');
      return false;
    }
  }
}
