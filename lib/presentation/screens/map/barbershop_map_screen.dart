import 'package:barberdule/data/models/barber.dart';
import 'package:barberdule/data/models/barbershop.dart';
import 'package:barberdule/logic/blocs/map/map_bloc.dart';
import 'package:barberdule/logic/blocs/map/map_event.dart';
import 'package:barberdule/logic/blocs/map/map_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../routes.dart';

class BarbershopMapScreen extends StatefulWidget {
  const BarbershopMapScreen({Key? key}) : super(key: key);

  @override
  State<BarbershopMapScreen> createState() => _BarbershopMapScreenState();
}

class _BarbershopMapScreenState extends State<BarbershopMapScreen> {
  late GoogleMapController _mapController;
  final Map<String, Marker> _markers = {};
  bool _showBarbershops = true;
  bool _showIndependentBarbers = true;
  LatLng _currentPosition = const LatLng(0, 0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    context.read<MapBloc>().add(const LoadMapLocations());
    _initializeUserLocation();
  }

  Future<void> _initializeUserLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final position = await _getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      // Once map is created and position is available, animate to user location
      if (_mapController != null) {
        _animateToPosition(_currentPosition);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Could not get current location: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocConsumer<MapBloc, MapState>(
            listener: (context, state) {
              if (state is MapLocationsLoaded) {
                _updateMarkers(state);
              }
            },
            builder: (context, state) {
              if (state is MapLocationsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(
                    40.75723251257081, -73.98595866417125
                  ),
                  zoom: 12,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                  if (_currentPosition.latitude != 0 &&
                      _currentPosition.longitude != 0) {
                    _animateToPosition(_currentPosition);
                  }
                },
                markers: Set<Marker>.of(_markers.values),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              );
            },
          ),
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search barbershops and barbers',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        // Handle search
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        FilterChip(
                          label: const Text('Barbershops'),
                          selected: _showBarbershops,
                          onSelected: (selected) {
                            setState(() {
                              _showBarbershops = selected;
                              _updateMarkersVisibility();
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Independent Barbers'),
                          selected: _showIndependentBarbers,
                          onSelected: (selected) {
                            setState(() {
                              _showIndependentBarbers = selected;
                              _updateMarkersVisibility();
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateMarkers(MapLocationsLoaded state) {
    _markers.clear();

    // Add barbershop markers
    for (final barbershop in state.barbershops) {
      final marker = Marker(
        markerId: MarkerId('barbershop_${barbershop.id}'),
        position: LatLng(
          barbershop.location.latitude,
          barbershop.location.longitude,
        ),
        infoWindow: InfoWindow(
          title: barbershop.name,
          snippet: 'Tap to view details',
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.barbershopDetails,
              arguments: {'barbershopId': barbershop.id},
            );
          },
        ),
        // onTap: () {
        //   setState(() {
        //     _selectedBarbershop = barbershop;
        //   });
        //   _showBarbershopDetails(barbershop);
        // },
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
      _markers['barbershop_${barbershop.id}'] = marker;
    }

    // Add independent barber markers
    for (final barber in state.barbers) {
      if (barber.barbershopId == null || barber.barbershopId!.isEmpty) {
      final marker = Marker(
        markerId: MarkerId('barber_${barber.id}'),
        position: LatLng(barber.location!.latitude, barber.location!.longitude),
        infoWindow: InfoWindow(
          title: barber.name,
          snippet: 'Independent Barber - Tap to view details',
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.barberDetails,
              arguments: {'barberId': barber.id},
            );
          },
        ),
        // onTap: () {
        //   setState(() {
        //     _selectedBarber = barber;
        //   });
        //   _showBarberDetails(barber);
        // },
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      );
      _markers['barber_${barber.id}'] = marker;
      }
    }

    _updateMarkersVisibility();
  }

  void _updateMarkersVisibility() {
    setState(() {
      _markers.forEach((key, marker) {
        if (key.startsWith('barbershop_')) {
          _markers[key] = marker.copyWith(visibleParam: _showBarbershops);
        } else if (key.startsWith('barber_')) {
          _markers[key] = marker.copyWith(
            visibleParam: _showIndependentBarbers,
          );
        }
      });
    });
  }

  void _animateToPosition(LatLng position) {
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 15),
      ),
    );
  }

  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition();
  }

  void _showBarberDetails(Barber barber) async {
    final position = await _getCurrentPosition();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      barber.imageUrl ?? '',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          barber.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              barber.rating.toString(),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: barber.isActive
                                ? Colors.green[100]
                                : Colors.red[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            barber.isActive ? 'Open' : 'Closed',
                            style: TextStyle(
                              fontSize: 14,
                              color: barber.isActive
                                  ? Colors.green[800]
                                  : Colors.red[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Address',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                barber.address?? '',
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              const SizedBox(height: 16),
              const Text(
                'Distance',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                '${Geolocator.distanceBetween(position.latitude, position.longitude, barber.location!.latitude, barber.location!.longitude)} kilometers away',
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // In a real app, this would launch maps or navigation
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Navigation would start here'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.directions),
                      label: const Text('Directions'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // In a real app, this would open phone app
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Call would start here'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Call'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // In a real app, this would schedule an appointment
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking appointment would start here'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Book Appointment'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBarbershopDetails(Barbershop barbershop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      barbershop.imageUrl ?? '',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          barbershop.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              barbershop.rating.toString(),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: barbershop.isOpen
                                ? Colors.green[100]
                                : Colors.red[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            barbershop.isOpen ? 'Open' : 'Closed',
                            style: TextStyle(
                              fontSize: 14,
                              color: barbershop.isOpen
                                  ? Colors.green[800]
                                  : Colors.red[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Address',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                barbershop.address,
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              const SizedBox(height: 16),
              const Text(
                'Distance',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                '${barbershop.distance.toStringAsFixed(1)} kilometers away',
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // In a real app, this would launch maps or navigation
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Navigation would start here'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.directions),
                      label: const Text('Directions'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // In a real app, this would open phone app
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Call would start here'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Call'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // In a real app, this would schedule an appointment
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking appointment would start here'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Book Appointment'),
              ),
            ],
          ),
        );
      },
    );
  }
}
