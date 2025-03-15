import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/appointment.dart';
import '../../../data/models/service.dart';
import '../../../data/repository/appointment_repository.dart';
import '../../../data/repository/service_repository.dart';

class BookAppointmentScreen extends StatefulWidget {
  final String? barberId;

  const BookAppointmentScreen({Key? key, this.barberId}) : super(key: key);

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final AppointmentRepository _appointmentRepository = AppointmentRepository();
  final ServiceRepository _serviceRepository = ServiceRepository();

  String? _selectedBarberId;
  Service? _selectedService;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  List<Service> _services = [];
  bool _isLoading = true;

  final List<Map<String, String>> _barbers = [
    {'id': 'barber1', 'name': 'John Smith'},
    {'id': 'barber2', 'name': 'Mike Johnson'},
    {'id': 'barber3', 'name': 'David Williams'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.barberId != null) {
      _selectedBarberId = widget.barberId;
    }
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
    });

    // For demo purposes, we'll create some sample services
    // In a real app, you would fetch these from Firestore using _serviceRepository.getAllServices()
    _services = [
      Service(
        id: 'service1',
        name: 'Haircut',
        price: 30.0,
        description: 'Classic haircut with scissors or clippers',
        durationMinutes: 30,
      ),
      Service(
        id: 'service2',
        name: 'Beard Trim',
        price: 15.0,
        description: 'Beard shaping and trimming',
        durationMinutes: 15,
      ),
      Service(
        id: 'service3',
        name: 'Haircut & Beard',
        price: 40.0,
        description: 'Haircut with beard trimming and shaping',
        durationMinutes: 45,
      ),
      Service(
        id: 'service4',
        name: 'Hair Coloring',
        price: 50.0,
        description: 'Professional hair coloring service',
        durationMinutes: 60,
      ),
      Service(
        id: 'service5',
        name: 'Shave',
        price: 20.0,
        description: 'Traditional straight razor shave',
        durationMinutes: 20,
      ),
    ];

    if (_services.isNotEmpty) {
      _selectedService = _services.first;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _bookAppointment() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBarberId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please select a barber')));
        return;
      }

      if (_selectedService == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a service')),
        );
        return;
      }

      // Combine date and time
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Create appointment with all required fields
      final appointment = Appointment(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
        barberId: _selectedBarberId ?? 'unknown',
        barberName:
            _barbers.firstWhere(
              (b) => b['id'] == _selectedBarberId,
              orElse: () => {'id': 'unknown', 'name': 'Unknown Barber'},
            )['name']!,
        customerId: 'current_user_id', // Replace with actual user ID from auth
        customerName: 'Current User', // Replace with actual user name
        barbershopId: 'default_barbershop',
        barbershopName: 'Default Barbershop',
        serviceId: _selectedService?.id ?? 'unknown',
        serviceName: _selectedService?.name ?? 'Unknown Service',
        servicePrice: _selectedService?.price ?? 0.0,
        dateTime: dateTime,
        duration: _selectedService?.durationMinutes ?? 30,
        status: 'upcoming',
        createdAt: DateTime.now(),
      );

      try {
        await _appointmentRepository.createAppointment(appointment);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Appointment booked successfully!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to book appointment: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Book Appointment')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barber Selection
              if (widget.barberId == null) ...[
                const Text(
                  'Select Barber',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedBarberId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  hint: const Text('Select a barber'),
                  items:
                      _barbers.map((barber) {
                        return DropdownMenuItem<String>(
                          value: barber['id']!,
                          child: Text(barber['name']!),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBarberId = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
              ],

              // Service Selection
              const Text(
                'Select Service',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<Service>(
                value: _selectedService,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                items:
                    _services.map((service) {
                      return DropdownMenuItem<Service>(
                        value: service,
                        child: Text(
                          '${service.name} - \$${service.price.toStringAsFixed(2)} (${service.durationMinutes} min)',
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedService = value;
                    });
                  }
                },
              ),

              if (_selectedService != null) ...[
                const SizedBox(height: 8),
                Text(
                  _selectedService!.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Date Selection
              const Text(
                'Select Date',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Time Selection
              const Text(
                'Select Time',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectTime(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_selectedTime.format(context)),
                      const Icon(Icons.access_time),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Price and Duration Display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Price:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${_selectedService?.price.toStringAsFixed(2) ?? "0.00"}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Duration:', style: TextStyle(fontSize: 16)),
                        Text(
                          '${_selectedService?.durationMinutes ?? 0} minutes',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Book Button
              ElevatedButton(
                onPressed: _bookAppointment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Book Appointment',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
