import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:barberdule/data/repository/auth_repository.dart';
import 'package:barberdule/data/repository/user_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository authRepository;
  final UserRepository userRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ProfileBloc({required this.authRepository, required this.userRepository})
    : super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onProfileLoadRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
    on<ProfileSignOutRequested>(_onProfileSignOutRequested);
  }

  void _onProfileLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Get additional user data from Firestore if needed
        final userData = await userRepository.getUserData(user.uid);

        // Determine user type by checking collections
        String? userType;
        final isBarber = await userRepository.isUserBarber(user.uid);
        final isCustomer = await userRepository.isUserCustomer(user.uid);

        if (isBarber) {
          userType = 'barber';
        } else if (isCustomer) {
          userType = 'customer';
        }

        emit(
          ProfileLoaded(
            user: user,
            phoneNumber: userData?['phoneNumber'] as String?,
            bio: userData?['bio'] as String?,
            userType: userType,
          ),
        );
      } else {
        emit(const ProfileSignOutSuccess());
      }
    } catch (e) {
      emit(ProfileUpdateFailure(error: e.toString()));
    }
  }

  void _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileUpdateLoading());
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Update Firebase Auth user profile
        if (event.displayName != null || event.photoURL != null) {
          await user.updateDisplayName(event.displayName);
          await user.updatePhotoURL(event.photoURL);
        }

        // Update additional user data in Firestore
        await userRepository.updateUserData(user.uid, {
          if (event.phoneNumber != null) 'phoneNumber': event.phoneNumber,
          if (event.bio != null) 'bio': event.bio,
        });

        // Reload user to get updated data
        await user.reload();
        final updatedUser = _auth.currentUser;

        if (updatedUser != null) {
          final userData = await userRepository.getUserData(updatedUser.uid);

          // Determine user type
          String? userType;
          final isBarber = await userRepository.isUserBarber(updatedUser.uid);
          final isCustomer = await userRepository.isUserCustomer(
            updatedUser.uid,
          );

          if (isBarber) {
            userType = 'barber';
          } else if (isCustomer) {
            userType = 'customer';
          }

          emit(
            ProfileLoaded(
              user: updatedUser,
              phoneNumber: userData?['phoneNumber'] as String?,
              bio: userData?['bio'] as String?,
              userType: userType,
            ),
          );
        }
      }
    } catch (e) {
      emit(ProfileUpdateFailure(error: e.toString()));
    }
  }

  void _onProfileSignOutRequested(
    ProfileSignOutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await authRepository.logout();
      emit(const ProfileSignOutSuccess());
    } catch (e) {
      emit(ProfileSignOutFailure(error: e.toString()));
    }
  }
}
