import 'package:barberdule/data/repository/barbershop_repository.dart';
import 'package:barberdule/logic/blocs/map/map_event.dart';
import 'package:barberdule/logic/blocs/map/map_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repository/barber_repository.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final BarbershopRepository barbershopRepository;
  final BarberRepository barberRepository;

  MapBloc({required this.barbershopRepository, required this.barberRepository})
      : super(const MapInitial()) {
    on<LoadMapLocations>(_onLoadMapLocations);
  }

  Future<void> _onLoadMapLocations(
    LoadMapLocations event,
    Emitter<MapState> emit,
  ) async {
    try {
      emit(const MapLocationsLoading());

      final barbershops = await barbershopRepository.getAllBarbershops();
      final barbers = await barberRepository.getAllBarbers();

      emit(MapLocationsLoaded(barbershops: barbershops, barbers: barbers));
    } catch (e) {
      emit(MapError(message: e.toString()));
    }
  }
}
