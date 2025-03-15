import 'package:equatable/equatable.dart';
import '../../../data/models/barbershop.dart';
import '../../../data/models/barber.dart';

abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object> get props => [];
}

class MapInitial extends MapState {
  const MapInitial();
}

class MapLocationsLoading extends MapState {
  const MapLocationsLoading();
}

class MapLocationsLoaded extends MapState {
  final List<Barbershop> barbershops;
  final List<Barber> barbers;

  const MapLocationsLoaded({required this.barbershops, required this.barbers});

  @override
  List<Object> get props => [barbershops, barbers];
}

class MapError extends MapState {
  final String message;

  const MapError({required this.message});

  @override
  List<Object> get props => [message];
}
