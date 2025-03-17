import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/barber.dart';
import '../../../data/repository/barber_repository.dart';
import '../../../routes.dart';

class BarberDetailsScreen extends StatelessWidget {
  final String barberId;

  const BarberDetailsScreen({Key? key, required this.barberId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barber Profile')),
      body: FutureBuilder<Barber?>(
        future: context.read<BarberRepository>().getBarberById(barberId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Barber not found'));
          }

          final barber = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (barber.imageUrl != null)
                  Image.network(
                    barber.imageUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        barber.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      if (barber.barbershopId != null)
                        FutureBuilder(
                          future: context
                              .read<BarberRepository>()
                              .getBarbershopName(barber.barbershopId!),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Row(
                                children: [
                                  const Icon(Icons.store, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(snapshot.data as String),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      const SizedBox(height: 16),
                      Text(
                        'About',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(barber.bio ?? 'No bio available'),
                      const SizedBox(height: 24),
                      Text(
                        'Services',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      _buildServicesList(barber.specialties),
                      const SizedBox(height: 24),
                      if (barber.rating != null) ...[
                        Text(
                          'Rating',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              '${barber.rating!.toStringAsFixed(1)} / 5.0',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.bookAppointment,
            arguments: {'barberId': barberId},
          );
        },
        icon: const Icon(Icons.calendar_today),
        label: const Text('Book Appointment'),
      ),
    );
  }

  Widget _buildServicesList(List<String> services) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: services.map((service) {
        return Chip(
          label: Text(service),
          backgroundColor: Colors.grey.shade200,
        );
      }).toList(),
    );
  }
}
