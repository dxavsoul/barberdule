import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final docSnapshot =
          await _firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update user data: $e');
    }
  }

  Future<void> createUserData(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).set(data);
    } catch (e) {
      throw Exception('Failed to create user data: $e');
    }
  }

  Future<void> deleteUserData(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user data: $e');
    }
  }

  // Check if a user is a barber
  Future<bool> isUserBarber(String userId) async {
    try {
      final snapshot =
          await _firestore
              .collection('barbers')
              .where('userId', isEqualTo: userId)
              .limit(1)
              .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check if user is a barber: $e');
    }
  }

  // Check if a user is a customer
  Future<bool> isUserCustomer(String userId) async {
    try {
      final snapshot =
          await _firestore
              .collection('customers')
              .where('userId', isEqualTo: userId)
              .limit(1)
              .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check if user is a customer: $e');
    }
  }
}
