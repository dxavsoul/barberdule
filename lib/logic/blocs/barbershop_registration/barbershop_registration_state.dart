import 'package:equatable/equatable.dart';

abstract class BarbershopRegistrationState extends Equatable {
  const BarbershopRegistrationState();

  @override
  List<Object> get props => [];
}

class BarbershopRegistrationInitial extends BarbershopRegistrationState {}

class BarbershopRegistrationLoading extends BarbershopRegistrationState {}

class BarbershopRegistrationSuccess extends BarbershopRegistrationState {
  final String barbershopId;

  const BarbershopRegistrationSuccess(this.barbershopId);

  @override
  List<Object> get props => [barbershopId];
}

class BarbershopRegistrationFailure extends BarbershopRegistrationState {
  final String error;

  const BarbershopRegistrationFailure(this.error);

  @override
  List<Object> get props => [error];
}
