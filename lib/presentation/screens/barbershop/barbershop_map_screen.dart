import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../logic/blocs/map/map_bloc.dart';
import '../../../logic/blocs/map/map_event.dart';
import '../../../logic/blocs/map/map_state.dart';
import '../../../routes.dart';

class BarbershopMapScreen extends StatefulWidget {
  const BarbershopMapScreen({Key? key}) : super(key: key);

  @override
  State<BarbershopMapScreen> createState() => _BarbershopMapScreenState();
}

class _BarbershopMapScreenState extends State<BarbershopMapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  bool _showBarbershops = true;
  bool _showBarbers = true;

  static const CameraPosition _defaultLocation = CameraPosition(
    target: LatLng(37.7749, -122.4194), // San Francisco
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    context.read<MapBloc>().add(const LoadMapLocations());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Find Barbershops'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                switch (value) {
                  case 'barbershops':
                    _showBarbershops = !_showBarbershops;
                    break;
                  case 'barbers':
                    _showBarbers = !_showBarbers;
                    break;
                }
                _updateMarkers();
              });
            },
            itemBuilder: (context) => [
              CheckedPopupMenuItem(
                checked: _showBarbershops,
                value: 'barbershops',
                child: const Text('Show Barbershops'),
              ),
              CheckedPopupMenuItem(
                checked: _showBarbers,
                value: 'barbers',
                child: const Text('Show Independent Barbers'),
              ),
            ],
          ),
        ],
      ),
      body: BlocConsumer<MapBloc, MapState>(
        listener: (context, state) {
          if (state is MapLocationsLoaded) {
            _updateMarkers();
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: _defaultLocation,
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
              if (state is MapLocationsLoading)
                const Center(child: CircularProgressIndicator()),
              if (state is MapError)
                Center(
                  child: Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<MapBloc>().add(const LoadMapLocations());
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

  void _updateMarkers() {
    final state = context.read<MapBloc>().state;
    if (state is! MapLocationsLoaded) return;

    setState(() {
      _markers.clear();

      if (_showBarbershops) {
        for (final barbershop in state.barbershops) {
          _markers.add(
            Marker(
              markerId: MarkerId('barbershop_${barbershop.id}'),
              position: LatLng(
                barbershop.location.latitude,
                barbershop.location.longitude,
              ),
              infoWindow: InfoWindow(
                title: barbershop.name,
                snippet: barbershop.address,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.barbershopDetails,
                    arguments: {'barbershopId': barbershop.id},
                  );
                },
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue,
              ),
            ),
          );
        }
      }

      if (_showBarbers) {
        for (final barber in state.barbers) {
          if (barber.location != null && barber.barbershopId == null) {
            _markers.add(
              Marker(
                markerId: MarkerId('barber_${barber.id}'),
                position: LatLng(
                  barber.location!.latitude,
                  barber.location!.longitude,
                ),
                infoWindow: InfoWindow(
                  title: barber.name,
                  snippet: 'Independent Barber',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.barberDetails,
                      arguments: {'barberId': barber.id},
                    );
                  },
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueViolet,
                ),
              ),
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
