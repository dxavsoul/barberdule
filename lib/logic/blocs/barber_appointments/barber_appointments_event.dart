import 'package:equatable/equatable.dart';

abstract class BarberAppointmentsEvent extends Equatable {
  const BarberAppointmentsEvent();

  @override
  List<Object?> get props => [];
}

class BarberAppointmentsLoadRequested extends BarberAppointmentsEvent {
  const BarberAppointmentsLoadRequested();
}

class BarberAppointmentCancelled extends BarberAppointmentsEvent {
  final String appointmentId;

  const BarberAppointmentCancelled(this.appointmentId);

  @override
  List<Object> get props => [appointmentId];
}

class BarberAppointmentCompleted extends BarberAppointmentsEvent {
  final String appointmentId;

  const BarberAppointmentCompleted(this.appointmentId);

  @override
  List<Object> get props => [appointmentId];
}
