import 'package:equatable/equatable.dart';
import '../../../data/models/service.dart';

abstract class ServiceState extends Equatable {
  const ServiceState();

  @override
  List<Object?> get props => [];
}

class ServiceInitial extends ServiceState {}

class ServiceLoading extends ServiceState {}

class ServiceLoaded extends ServiceState {
  final List<Service> services;

  const ServiceLoaded(this.services);

  @override
  List<Object> get props => [services];
}

class ServiceOperationSuccess extends ServiceState {
  final String message;

  const ServiceOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class ServiceOperationFailure extends ServiceState {
  final String error;

  const ServiceOperationFailure(this.error);

  @override
  List<Object> get props => [error];
}

class ServiceSearchResult extends ServiceState {
  final List<Service> services;
  final String query;

  const ServiceSearchResult(this.services, this.query);

  @override
  List<Object> get props => [services, query];
}
