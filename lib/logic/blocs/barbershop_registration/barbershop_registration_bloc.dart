import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/barbershop.dart';
import '../../../data/repository/barbershop_repository.dart';
import 'barbershop_registration_event.dart';
import 'barbershop_registration_state.dart';

class BarbershopRegistrationBloc
    extends Bloc<BarbershopRegistrationEvent, BarbershopRegistrationState> {
  final BarbershopRepository _barbershopRepository;

  BarbershopRegistrationBloc({
    required BarbershopRepository barbershopRepository,
  }) : _barbershopRepository = barbershopRepository,
       super(BarbershopRegistrationInitial()) {
    on<BarbershopRegistrationSubmitted>(_onBarbershopRegistrationSubmitted);
  }

  Future<void> _onBarbershopRegistrationSubmitted(
    BarbershopRegistrationSubmitted event,
    Emitter<BarbershopRegistrationState> emit,
  ) async {
    emit(BarbershopRegistrationLoading());
    try {
      
      final barbershop = Barbershop(
        name: event.name,
        address: event.address,
        phone: event.phone,
        email: event.email,
        description: event.description,
        imageUrl: event.imageUrl,
        location: event.location,
        barberIds: [],
        workingHours: event.workingHours,
        ownerId: event.ownerId,
      );

      final barbershopId = await _barbershopRepository.createBarbershop(
        barbershop,
      );
      emit(BarbershopRegistrationSuccess(barbershopId!));
    } catch (e) {
      emit(BarbershopRegistrationFailure(e.toString()));
    }
  }
}
