import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service.dart';

class ServiceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'services';

  // Get all services
  Stream<List<Service>> getAllServices() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Service.fromFirestore(doc)).toList(),
        );
  }

  // Get services by barbershop ID
  Stream<List<Service>> getServicesByBarbershop(String barbershopId) {
    return _firestore
        .collection(_collection)
        .where('barbershopId', isEqualTo: barbershopId)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Service.fromFirestore(doc)).toList(),
        );
  }

  // Get a single service by ID
  Future<Service?> getServiceById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Service.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get service: $e');
    }
  }

  // Create a new service
  Future<String> createService(Service service) async {
    try {
      final Map<String, dynamic> data = service.toMap();
      // Ensure createdAt is set
      data['createdAt'] = Timestamp.now();

      final docRef = await _firestore.collection(_collection).add(data);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create service: $e');
    }
  }

  // Update a service
  Future<void> updateService(String id, Service service) async {
    try {
      final Map<String, dynamic> data = service.toMap();
      // Set updatedAt timestamp
      data['updatedAt'] = Timestamp.now();

      await _firestore.collection(_collection).doc(id).update(data);
    } catch (e) {
      throw Exception('Failed to update service: $e');
    }
  }

  // Delete a service (or mark as inactive)
  Future<void> deleteService(String id) async {
    try {
      // Option 1: Hard delete
      // await _firestore.collection(_collection).doc(id).delete();

      // Option 2: Soft delete (mark as inactive)
      await _firestore.collection(_collection).doc(id).update({
        'isActive': false,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to delete service: $e');
    }
  }

  // Get services by search query
  Future<List<Service>> searchServices(String query) async {
    try {
      // This is a simple implementation that searches by name
      // For more complex search, consider using Algolia or a similar service
      final snapshot =
          await _firestore
              .collection(_collection)
              .where('isActive', isEqualTo: true)
              .orderBy('name')
              .get();

      final services =
          snapshot.docs.map((doc) => Service.fromFirestore(doc)).toList();

      // Filter services that contain the query in their name or description
      return services
          .where(
            (service) =>
                service.name.toLowerCase().contains(query.toLowerCase()) ||
                service.description.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to search services: $e');
    }
  }

  // Batch create services
  Future<List<String>> batchCreateServices(List<Service> services) async {
    try {
      final batch = _firestore.batch();
      final List<DocumentReference> refs = [];

      for (final service in services) {
        final ref = _firestore.collection(_collection).doc();
        refs.add(ref);

        final Map<String, dynamic> data = service.toMap();
        data['createdAt'] = Timestamp.now();

        batch.set(ref, data);
      }

      await batch.commit();
      return refs.map((ref) => ref.id).toList();
    } catch (e) {
      throw Exception('Failed to batch create services: $e');
    }
  }
}
