import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repository/customer_repository.dart';
import '../../../data/models/customer.dart';
import 'customer_registration_event.dart';
import 'customer_registration_state.dart';

class CustomerRegistrationBloc
    extends Bloc<CustomerRegistrationEvent, CustomerRegistrationState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CustomerRepository _customerRepository = CustomerRepository();

  CustomerRegistrationBloc() : super(CustomerRegistrationInitial()) {
    on<CustomerRegistrationSubmitted>(_onCustomerRegistrationSubmitted);
  }

  Future<void> _onCustomerRegistrationSubmitted(
    CustomerRegistrationSubmitted event,
    Emitter<CustomerRegistrationState> emit,
  ) async {
    emit(CustomerRegistrationLoading());
    try {
      String userId;
      final currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.email == event.email) {
        // Use existing user
        userId = currentUser.uid;
      } else {
        try {
          // Create user with email and password
          final userCredential = await _auth.createUserWithEmailAndPassword(
            email: event.email.trim(),
            password: event.password,
          );
          userId = userCredential.user!.uid;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            // If email already exists, try to sign in
            try {
              final userCredential = await _auth.signInWithEmailAndPassword(
                email: event.email,
                password: event.password,
              );
              userId = userCredential.user!.uid;
            } catch (signInError) {
              emit(
                CustomerRegistrationFailure(
                  'This email is already in use. Please use a different email or sign in first.',
                ),
              );
              return;
            }
          } else {
            throw e;
          }
        }
      }

      // Create customer profile
      final customer = Customer(
        userId: userId,
        name: event.name,
        phoneNumber: event.phoneNumber,
        email: event.email.trim(),
        createdAt: DateTime.now(),
        isActive: true,
      );

      // Save customer data to Firestore
      await _customerRepository.createCustomer(customer);

      emit(CustomerRegistrationSuccess());
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak';
          break;
        case 'email-already-in-use':
          errorMessage = 'The account already exists for that email';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid';
          break;
        default:
          errorMessage = 'Authentication error: ${e.message}';
      }
      emit(CustomerRegistrationFailure(errorMessage));
    } catch (e) {
      emit(CustomerRegistrationFailure(e.toString()));
    }
  }
}
