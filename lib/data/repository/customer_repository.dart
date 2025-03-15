import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer.dart';

class CustomerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'customers';

  // Get a customer by user ID
  Future<Customer?> getCustomerByUserId(String userId) async {
    try {
      final snapshot =
          await _firestore
              .collection(_collection)
              .where('userId', isEqualTo: userId)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        return Customer.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get customer: $e');
    }
  }

  // Create a new customer
  Future<String> createCustomer(Customer customer) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(customer.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create customer: $e');
    }
  }

  // Update a customer
  Future<void> updateCustomer(String id, Customer customer) async {
    try {
      await _firestore.collection(_collection).doc(id).update(customer.toMap());
    } catch (e) {
      throw Exception('Failed to update customer: $e');
    }
  }

  // Delete a customer (or mark as inactive)
  Future<void> deleteCustomer(String id) async {
    try {
      // Option 1: Hard delete
      // await _firestore.collection(_collection).doc(id).delete();

      // Option 2: Soft delete (mark as inactive)
      await _firestore.collection(_collection).doc(id).update({
        'isActive': false,
      });
    } catch (e) {
      throw Exception('Failed to delete customer: $e');
    }
  }

  // Get all customers
  Stream<List<Customer>> getAllCustomers() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Customer.fromFirestore(doc))
              .toList();
        });
  }
}
