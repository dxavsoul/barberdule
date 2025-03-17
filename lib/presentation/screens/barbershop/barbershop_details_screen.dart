import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/barbershop.dart';
import '../../../data/models/barber.dart';
import '../../../data/repository/barbershop_repository.dart';
import '../../../data/repository/barber_repository.dart';
import '../../../routes.dart';

class BarbershopDetailsScreen extends StatelessWidget {
  final String barbershopId;

  const BarbershopDetailsScreen({Key? key, required this.barbershopId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barbershop Details')),
      body: FutureBuilder<Barbershop?>(
        future: context.read<BarbershopRepository>().getBarbershopById(
              barbershopId,
            ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Barbershop not found'));
          }

          final barbershop = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (barbershop.imageUrl != null)
                  Image.network(
                    barbershop.imageUrl!,
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
                        barbershop.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(child: Text(barbershop.address)),
                        ],
                      ),
                      if (barbershop.phone != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.phone, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(barbershop.phone!),
                          ],
                        ),
                      ],
                      if (barbershop.email != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.email, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(barbershop.email!),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        'About',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        barbershop.description ?? 'No description available',
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Working Hours',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      _buildWorkingHours(barbershop.workingHours),
                      const SizedBox(height: 24),
                      Text(
                        'Our Barbers',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      _buildBarbersList(context, barbershop.id!),
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
            arguments: {'barbershopId': barbershopId},
          );
        },
        icon: const Icon(Icons.calendar_today),
        label: const Text('Book Appointment'),
      ),
    );
  }

  Widget _buildWorkingHours(Map<String, dynamic> workingHours) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return Column(
      children: days.map((day) {
        final hours = workingHours[day.toLowerCase()];
        if (hours == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(day),
              Text(
                hours['closed']
                    ? 'Closed'
                    : '${hours['open']} - ${hours['close']}',
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBarbersList(BuildContext context, String barbershopId) {
    return StreamBuilder<List<Barber>>(
      stream: context.read<BarberRepository>().getBarbersByBarbershop(
            barbershopId,
          ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final barbers = snapshot.data ?? [];

        if (barbers.isEmpty) {
          return const Center(child: Text('No barbers available'));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: barbers.length,
          itemBuilder: (context, index) {
            final barber = barbers[index];
            return ListTile(
              leading: barber.imageUrl != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(barber.imageUrl!),
                    )
                  : const CircleAvatar(child: Icon(Icons.person)),
              title: Text(barber.name),
              subtitle: Text(barber.bio ?? ''),
              trailing: barber.rating != null
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(barber.rating!.toStringAsFixed(1)),
                      ],
                    )
                  : null,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.barberDetails,
                  arguments: {'barberId': barber.id},
                );
              },
            );
          },
        );
      },
    );
  }
}
