import 'package:barberdule/data/repository/barbershop_repository.dart';
import 'package:barberdule/logic/blocs/map/map_event.dart';
import 'package:barberdule/logic/blocs/map/map_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/barbershop.dart';
import '../../../data/models/barber.dart';
import '../../../data/repository/barber_repository.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final BarbershopRepository _barbershopRepository;
  final BarberRepository _barberRepository;

  MapBloc({
    required BarbershopRepository barbershopRepository,
    required BarberRepository barberRepository,
  })  : _barbershopRepository = barbershopRepository,
        _barberRepository = barberRepository,
        super(const MapInitial()) {
    on<LoadMapLocations>(_onLoadMapLocations);
  }

  Future<void> _onLoadMapLocations(
    LoadMapLocations event,
    Emitter<MapState> emit,
  ) async {
    try {
      emit(const MapLocationsLoading());

      final barbershops = await _barbershopRepository.getAllBarbershops();
      final barbers = await _barberRepository.getAllBarbers();

      emit(MapLocationsLoaded(barbershops: barbershops, barbers: barbers));
    } catch (e) {
      emit(MapError(message: e.toString()));
    }
  }
}
