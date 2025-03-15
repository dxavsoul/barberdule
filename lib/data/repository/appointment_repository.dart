import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/appointment.dart';

class AppointmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get appointments for a specific barber
  Stream<List<Appointment>> getBarberAppointments({String? barberId}) {
    final String barberIdToUse;

    if (barberId != null) {
      barberIdToUse = barberId;
    } else {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      barberIdToUse = user.uid;
    }

    return _firestore
        .collection('appointments')
        .where('barberId', isEqualTo: barberIdToUse)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Appointment.fromFirestore(doc))
              .toList();
        });
  }

  // Get appointments for a specific customer
  Stream<List<Appointment>> getCustomerAppointments(String customerId) {
    return _firestore
        .collection('appointments')
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Appointment.fromFirestore(doc))
              .toList();
        });
  }

  // Create a new appointment
  Future<String> createAppointment(Appointment appointment) async {
    try {
      final docRef = await _firestore
          .collection('appointments')
          .add(appointment.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create appointment: $e');
    }
  }

  // Update an appointment
  Future<void> updateAppointment(Appointment appointment) async {
    try {
      await _firestore
          .collection('appointments')
          .doc(appointment.id)
          .update(appointment.toMap());
    } catch (e) {
      throw Exception('Failed to update appointment: $e');
    }
  }

  // Cancel an appointment
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to cancel appointment: $e');
    }
  }

  // Mark an appointment as completed
  Future<void> completeAppointment(String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'completed',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to complete appointment: $e');
    }
  }

  // Get a single appointment by ID
  Future<Appointment> getAppointmentById(String appointmentId) async {
    try {
      final doc =
          await _firestore.collection('appointments').doc(appointmentId).get();
      if (!doc.exists) {
        throw Exception('Appointment not found');
      }
      return Appointment.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get appointment: $e');
    }
  }

  // Delete an appointment (admin only)
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).delete();
    } catch (e) {
      throw Exception('Failed to delete appointment: $e');
    }
  }
}
