import 'package:equatable/equatable.dart';
import '../../../data/models/service.dart';

abstract class ServiceEvent extends Equatable {
  const ServiceEvent();

  @override
  List<Object?> get props => [];
}

class ServiceLoadRequested extends ServiceEvent {
  final String? barbershopId;

  const ServiceLoadRequested({this.barbershopId});

  @override
  List<Object?> get props => [barbershopId];
}

class ServiceCreateRequested extends ServiceEvent {
  final Service service;

  const ServiceCreateRequested(this.service);

  @override
  List<Object> get props => [service];
}

class ServiceUpdateRequested extends ServiceEvent {
  final String id;
  final Service service;

  const ServiceUpdateRequested(this.id, this.service);

  @override
  List<Object> get props => [id, service];
}

class ServiceDeleteRequested extends ServiceEvent {
  final String id;

  const ServiceDeleteRequested(this.id);

  @override
  List<Object> get props => [id];
}

class ServiceSearchRequested extends ServiceEvent {
  final String query;

  const ServiceSearchRequested(this.query);

  @override
  List<Object> get props => [query];
}
