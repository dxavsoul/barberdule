import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/service.dart';
import '../../../data/repository/service_repository.dart';
import '../../../logic/blocs/service/service_bloc.dart';
import '../../../logic/blocs/service/service_event.dart';
import '../../../logic/blocs/service/service_state.dart';
import 'edit_service_screen.dart';

class ManageServicesScreen extends StatefulWidget {
  final String? barbershopId;

  const ManageServicesScreen({Key? key, this.barbershopId}) : super(key: key);

  @override
  State<ManageServicesScreen> createState() => _ManageServicesScreenState();
}

class _ManageServicesScreenState extends State<ManageServicesScreen> {
  late final ServiceBloc _serviceBloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _serviceBloc = ServiceBloc(
      serviceRepository: RepositoryProvider.of<ServiceRepository>(context),
    );
    _serviceBloc.add(ServiceLoadRequested(barbershopId: widget.barbershopId));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _serviceBloc.close();
    super.dispose();
  }

  Future<void> _navigateToEditService(
    BuildContext context, [
    Service? service,
  ]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditServiceScreen(
              service: service,
              barbershopId: widget.barbershopId,
            ),
      ),
    );

    if (result != null && result is Service) {
      if (service == null) {
        // Create new service
        _serviceBloc.add(ServiceCreateRequested(result));
      } else {
        // Update existing service
        _serviceBloc.add(ServiceUpdateRequested(service.id!, result));
      }
    }
  }

  void _deleteService(Service service) {
    _serviceBloc.add(ServiceDeleteRequested(service.id!));
  }

  void _searchServices(String query) {
    if (query.isEmpty) {
      _serviceBloc.add(ServiceLoadRequested(barbershopId: widget.barbershopId));
    } else {
      _serviceBloc.add(ServiceSearchRequested(query));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _serviceBloc,
      child: BlocConsumer<ServiceBloc, ServiceState>(
        listener: (context, state) {
          if (state is ServiceOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is ServiceOperationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Manage Services'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _navigateToEditService(context),
                ),
              ],
            ),
            body: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search services...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _searchServices('');
                                },
                              )
                              : null,
                    ),
                    onChanged: _searchServices,
                  ),
                ),

                // Services list
                Expanded(child: _buildServicesList(state)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildServicesList(ServiceState state) {
    if (state is ServiceLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<Service> services = [];

    if (state is ServiceLoaded) {
      services = state.services;
    } else if (state is ServiceSearchResult) {
      services = state.services;
    }

    if (services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No services available',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              state is ServiceSearchResult
                  ? 'No services match your search'
                  : 'Add a service to get started',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _navigateToEditService(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Service'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              service.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  service.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Duration: ${service.durationMinutes} min',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            trailing: Text(
              '\$${service.price.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            isThreeLine: true,
            onTap: () => _navigateToEditService(context, service),
            onLongPress: () => _showDeleteDialog(context, service),
          ),
        );
      },
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, Service service) async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Service'),
            content: Text('Are you sure you want to delete ${service.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteService(service);
                },
                child: const Text(
                  'DELETE',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
