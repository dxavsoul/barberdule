import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repository/service_repository.dart';
import 'service_event.dart';
import 'service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final ServiceRepository _serviceRepository;
  StreamSubscription? _servicesSubscription;

  ServiceBloc({required ServiceRepository serviceRepository})
    : _serviceRepository = serviceRepository,
      super(ServiceInitial()) {
    on<ServiceLoadRequested>(_onServiceLoadRequested);
    on<ServiceCreateRequested>(_onServiceCreateRequested);
    on<ServiceUpdateRequested>(_onServiceUpdateRequested);
    on<ServiceDeleteRequested>(_onServiceDeleteRequested);
    on<ServiceSearchRequested>(_onServiceSearchRequested);
  }

  Future<void> _onServiceLoadRequested(
    ServiceLoadRequested event,
    Emitter<ServiceState> emit,
  ) async {
    emit(ServiceLoading());
    await _servicesSubscription?.cancel();

    try {
      final stream =
          event.barbershopId != null
              ? _serviceRepository.getServicesByBarbershop(event.barbershopId!)
              : _serviceRepository.getAllServices();

      _servicesSubscription = stream.listen(
        (services) =>
            add(ServiceLoadRequested(barbershopId: event.barbershopId)),
        onError: (error) => emit(ServiceOperationFailure(error.toString())),
      );

      final services = await stream.first;
      emit(ServiceLoaded(services));
    } catch (e) {
      emit(ServiceOperationFailure(e.toString()));
    }
  }

  Future<void> _onServiceCreateRequested(
    ServiceCreateRequested event,
    Emitter<ServiceState> emit,
  ) async {
    emit(ServiceLoading());
    try {
      await _serviceRepository.createService(event.service);
      emit(const ServiceOperationSuccess('Service created successfully'));

      // Reload services
      if (state is ServiceLoaded) {
        final loadedState = state as ServiceLoaded;
        final services = await _serviceRepository.getAllServices().first;
        emit(ServiceLoaded(services));
      }
    } catch (e) {
      emit(ServiceOperationFailure(e.toString()));
    }
  }

  Future<void> _onServiceUpdateRequested(
    ServiceUpdateRequested event,
    Emitter<ServiceState> emit,
  ) async {
    emit(ServiceLoading());
    try {
      await _serviceRepository.updateService(event.id, event.service);
      emit(const ServiceOperationSuccess('Service updated successfully'));

      // Reload services
      if (state is ServiceLoaded) {
        final loadedState = state as ServiceLoaded;
        final services = await _serviceRepository.getAllServices().first;
        emit(ServiceLoaded(services));
      }
    } catch (e) {
      emit(ServiceOperationFailure(e.toString()));
    }
  }

  Future<void> _onServiceDeleteRequested(
    ServiceDeleteRequested event,
    Emitter<ServiceState> emit,
  ) async {
    emit(ServiceLoading());
    try {
      await _serviceRepository.deleteService(event.id);
      emit(const ServiceOperationSuccess('Service deleted successfully'));

      // Reload services
      if (state is ServiceLoaded) {
        final loadedState = state as ServiceLoaded;
        final services = await _serviceRepository.getAllServices().first;
        emit(ServiceLoaded(services));
      }
    } catch (e) {
      emit(ServiceOperationFailure(e.toString()));
    }
  }

  Future<void> _onServiceSearchRequested(
    ServiceSearchRequested event,
    Emitter<ServiceState> emit,
  ) async {
    emit(ServiceLoading());
    try {
      final services = await _serviceRepository.searchServices(event.query);
      emit(ServiceSearchResult(services, event.query));
    } catch (e) {
      emit(ServiceOperationFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _servicesSubscription?.cancel();
    return super.close();
  }
}
