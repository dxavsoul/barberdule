import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/appointment.dart';
import '../../../data/repository/appointment_repository.dart';
import 'barber_appointments_event.dart';
import 'barber_appointments_state.dart';

class BarberAppointmentsBloc
    extends Bloc<BarberAppointmentsEvent, BarberAppointmentsState> {
  final AppointmentRepository _appointmentRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription? _appointmentsSubscription;

  BarberAppointmentsBloc({required AppointmentRepository appointmentRepository})
    : _appointmentRepository = appointmentRepository,
      super(BarberAppointmentsInitial()) {
    on<BarberAppointmentsLoadRequested>(_onBarberAppointmentsLoadRequested);
    on<BarberAppointmentCancelled>(_onBarberAppointmentCancelled);
    on<BarberAppointmentCompleted>(_onBarberAppointmentCompleted);
  }

  Future<void> _onBarberAppointmentsLoadRequested(
    BarberAppointmentsLoadRequested event,
    Emitter<BarberAppointmentsState> emit,
  ) async {
    emit(BarberAppointmentsLoading());
    await _appointmentsSubscription?.cancel();

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        emit(
          const BarberAppointmentsOperationFailure('User not authenticated'),
        );
        return;
      }

      final barberId = currentUser.uid;
      final stream = _appointmentRepository.getBarberAppointments(
        barberId: barberId,
      );

      _appointmentsSubscription = stream.listen(
        (appointments) {
          add(const BarberAppointmentsLoadRequested());
        },
        onError: (error) {
          emit(BarberAppointmentsOperationFailure(error.toString()));
        },
      );

      final appointments = await stream.first;

      // Filter appointments by status
      final upcomingAppointments =
          appointments
              .where((appointment) => appointment.status == 'upcoming')
              .toList();
      final completedAppointments =
          appointments
              .where((appointment) => appointment.status == 'completed')
              .toList();
      final cancelledAppointments =
          appointments
              .where((appointment) => appointment.status == 'cancelled')
              .toList();

      // Sort appointments by date (newest first for completed/cancelled, soonest first for upcoming)
      upcomingAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      completedAppointments.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      cancelledAppointments.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      emit(
        BarberAppointmentsLoaded(
          upcomingAppointments: upcomingAppointments,
          completedAppointments: completedAppointments,
          cancelledAppointments: cancelledAppointments,
        ),
      );
    } catch (e) {
      emit(BarberAppointmentsOperationFailure(e.toString()));
    }
  }

  Future<void> _onBarberAppointmentCancelled(
    BarberAppointmentCancelled event,
    Emitter<BarberAppointmentsState> emit,
  ) async {
    try {
      await _appointmentRepository.cancelAppointment(event.appointmentId);
      emit(
        const BarberAppointmentsOperationSuccess(
          'Appointment cancelled successfully',
        ),
      );
    } catch (e) {
      emit(
        BarberAppointmentsOperationFailure(
          'Failed to cancel appointment: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onBarberAppointmentCompleted(
    BarberAppointmentCompleted event,
    Emitter<BarberAppointmentsState> emit,
  ) async {
    try {
      await _appointmentRepository.completeAppointment(event.appointmentId);
      emit(
        const BarberAppointmentsOperationSuccess(
          'Appointment marked as completed',
        ),
      );
    } catch (e) {
      emit(
        BarberAppointmentsOperationFailure(
          'Failed to complete appointment: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _appointmentsSubscription?.cancel();
    return super.close();
  }
}
