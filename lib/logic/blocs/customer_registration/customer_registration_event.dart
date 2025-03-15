import 'package:equatable/equatable.dart';

abstract class CustomerRegistrationEvent extends Equatable {
  const CustomerRegistrationEvent();

  @override
  List<Object> get props => [];
}

class CustomerRegistrationSubmitted extends CustomerRegistrationEvent {
  final String name;
  final String phoneNumber;
  final String email;
  final String password;

  const CustomerRegistrationSubmitted({
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [name, phoneNumber, email, password];
}
