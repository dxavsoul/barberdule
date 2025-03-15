import 'package:equatable/equatable.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object> get props => [];
}

class LoadMapLocations extends MapEvent {
  const LoadMapLocations();
}

class LoadBarbershops extends MapEvent {}

class RefreshBarbershops extends MapEvent {}
