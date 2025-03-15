import 'package:equatable/equatable.dart';

abstract class BarberRegistrationState extends Equatable {
  const BarberRegistrationState();

  @override
  List<Object> get props => [];
}

class BarberRegistrationInitial extends BarberRegistrationState {}

class BarberRegistrationLoading extends BarberRegistrationState {}

class BarberRegistrationSuccess extends BarberRegistrationState {
  final String barberId;

  const BarberRegistrationSuccess(this.barberId);

  @override
  List<Object> get props => [barberId];
}

class BarberRegistrationFailure extends BarberRegistrationState {
  final String error;

  const BarberRegistrationFailure(this.error);

  @override
  List<Object> get props => [error];
}
