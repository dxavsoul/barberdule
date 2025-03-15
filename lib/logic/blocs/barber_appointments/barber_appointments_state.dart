import 'package:equatable/equatable.dart';
import '../../../data/models/appointment.dart';

abstract class BarberAppointmentsState extends Equatable {
  const BarberAppointmentsState();

  @override
  List<Object?> get props => [];
}

class BarberAppointmentsInitial extends BarberAppointmentsState {}

class BarberAppointmentsLoading extends BarberAppointmentsState {}

class BarberAppointmentsLoaded extends BarberAppointmentsState {
  final List<Appointment> upcomingAppointments;
  final List<Appointment> completedAppointments;
  final List<Appointment> cancelledAppointments;

  const BarberAppointmentsLoaded({
    required this.upcomingAppointments,
    required this.completedAppointments,
    required this.cancelledAppointments,
  });

  @override
  List<Object> get props => [
    upcomingAppointments,
    completedAppointments,
    cancelledAppointments,
  ];
}

class BarberAppointmentsOperationSuccess extends BarberAppointmentsState {
  final String message;

  const BarberAppointmentsOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class BarberAppointmentsOperationFailure extends BarberAppointmentsState {
  final String error;

  const BarberAppointmentsOperationFailure(this.error);

  @override
  List<Object> get props => [error];
}
