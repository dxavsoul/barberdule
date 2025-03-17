import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/barber.dart';
import '../../../data/repository/barber_repository.dart';
import '../../../data/repository/barbershop_repository.dart';
import 'barber_registration_event.dart';
import 'barber_registration_state.dart';

class BarberRegistrationBloc
    extends Bloc<BarberRegistrationEvent, BarberRegistrationState> {
  final BarberRepository _barberRepository;
  final BarbershopRepository _barbershopRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  BarberRegistrationBloc({
    required BarberRepository barberRepository,
    required BarbershopRepository barbershopRepository,
  })  : _barberRepository = barberRepository,
        _barbershopRepository = barbershopRepository,
        super(BarberRegistrationInitial()) {
    on<BarberRegistrationSubmitted>(_onBarberRegistrationSubmitted);
  }

  Future<void> _onBarberRegistrationSubmitted(
    BarberRegistrationSubmitted event,
    Emitter<BarberRegistrationState> emit,
  ) async {
    emit(BarberRegistrationLoading());
    try {
      String userId;

      // Check if user is already logged in
      final currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.email == event.email) {
        // Use existing user
        userId = currentUser.uid;
      } else {
        try {
          // Create new user with email and password
          final userCredential = await _auth.createUserWithEmailAndPassword(
            email: event.email,
            password: event.password,
          );
          userId = userCredential.user!.uid;

          // Update user profile
          await userCredential.user!.updateDisplayName(event.name);
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
                BarberRegistrationFailure(
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

      final barber = Barber(
        userId: userId,
        name: event.name,
        phoneNumber: event.phoneNumber,
        email: event.email,
        bio: event.bio,
        imageUrl: event.imageUrl,
        address: event.address,
        location: event.location,
        specialties: event.specialties,
        barbershopId: event.barbershopId,
        workingHours: event.workingHours,
      );

      final barberId = await _barberRepository.createBarber(barber);

      // Add barber to barbershop
      await _barbershopRepository.addBarberToBarbershop(
        event.barbershopId,
        barberId!,
      );

      emit(BarberRegistrationSuccess(barberId));
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
      emit(BarberRegistrationFailure(errorMessage));
    } catch (e) {
      emit(BarberRegistrationFailure(e.toString()));
    }
  }
}
