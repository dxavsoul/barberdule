import 'package:equatable/equatable.dart';

abstract class CustomerRegistrationState extends Equatable {
  const CustomerRegistrationState();

  @override
  List<Object> get props => [];
}

class CustomerRegistrationInitial extends CustomerRegistrationState {}

class CustomerRegistrationLoading extends CustomerRegistrationState {}

class CustomerRegistrationSuccess extends CustomerRegistrationState {}

class CustomerRegistrationFailure extends CustomerRegistrationState {
  final String error;

  const CustomerRegistrationFailure(this.error);

  @override
  List<Object> get props => [error];
}
