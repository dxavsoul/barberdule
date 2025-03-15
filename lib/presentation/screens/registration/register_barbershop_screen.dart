import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repository/barbershop_repository.dart';
import '../../../logic/blocs/barbershop_registration/barbershop_registration_bloc.dart';
import '../../../logic/blocs/barbershop_registration/barbershop_registration_event.dart';
import '../../../logic/blocs/barbershop_registration/barbershop_registration_state.dart';
import 'working_hours_picker.dart';

class RegisterBarbershopScreen extends StatefulWidget {
  const RegisterBarbershopScreen({Key? key}) : super(key: key);

  @override
  State<RegisterBarbershopScreen> createState() =>
      _RegisterBarbershopScreenState();
}

class _RegisterBarbershopScreenState extends State<RegisterBarbershopScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  double _latitude = 0.0;
  double _longitude = 0.0;
  Map<String, dynamic> _workingHours = {};

  @override
  void initState() {
    super.initState();
    // Initialize with default working hours
    _workingHours = {
      'monday': {'open': '09:00', 'close': '18:00', 'isOpen': true},
      'tuesday': {'open': '09:00', 'close': '18:00', 'isOpen': true},
      'wednesday': {'open': '09:00', 'close': '18:00', 'isOpen': true},
      'thursday': {'open': '09:00', 'close': '18:00', 'isOpen': true},
      'friday': {'open': '09:00', 'close': '18:00', 'isOpen': true},
      'saturday': {'open': '09:00', 'close': '16:00', 'isOpen': true},
      'sunday': {'open': '00:00', 'close': '00:00', 'isOpen': false},
    };

    // If user is logged in, pre-fill email
    final user = _auth.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    // In a real app, you would use Geolocator to get the current location
    // For simplicity, we'll use a placeholder
    setState(() {
      _latitude = 37.7749;
      _longitude = -122.4194;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Location updated')));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => BarbershopRegistrationBloc(
            barbershopRepository: BarbershopRepository(),
          ),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: const Text('Register Barbershop')),
            body: BlocConsumer<
              BarbershopRegistrationBloc,
              BarbershopRegistrationState
            >(
              listener: (context, state) {
                if (state is BarbershopRegistrationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Barbershop registered successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context, state.barbershopId);
                } else if (state is BarbershopRegistrationFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to register barbershop: ${state.error}',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Name
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Barbershop Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Address
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'Address',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Location
                        Column(
                          children: [
                            Text(
                              'Location: ${_latitude != 0.0 ? '$_latitude, $_longitude' : 'Not set'}',
                              style: const TextStyle(fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                            ElevatedButton(
                              onPressed: _getCurrentLocation,
                              child: const Text('Get Current Location'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Phone
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Email
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Description
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Image URL (optional)
                        TextFormField(
                          controller: _imageUrlController,
                          decoration: const InputDecoration(
                            labelText: 'Image URL (optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Working Hours
                        const Text(
                          'Working Hours',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        WorkingHoursPicker(
                          workingHours: _workingHours,
                          onChanged: (hours) {
                            setState(() {
                              _workingHours = hours;
                            });
                          },
                        ),

                        const SizedBox(height: 32),

                        // Register Button
                        ElevatedButton(
                          onPressed:
                              state is BarbershopRegistrationLoading
                                  ? null
                                  : () {
                                    if (_formKey.currentState!.validate()) {
                                      context
                                          .read<BarbershopRegistrationBloc>()
                                          .add(
                                            BarbershopRegistrationSubmitted(
                                              name: _nameController.text,
                                              address: _addressController.text,
                                              phoneNumber:
                                                  _phoneController.text,
                                              email: _emailController.text,
                                              description:
                                                  _descriptionController.text,
                                              imageUrl:
                                                  _imageUrlController
                                                          .text
                                                          .isEmpty
                                                      ? null
                                                      : _imageUrlController
                                                          .text,
                                              location: GeoPoint(
                                                _latitude,
                                                _longitude,
                                              ),
                                              workingHours: _workingHours,
                                              ownerId:
                                                  FirebaseAuth
                                                      .instance
                                                      .currentUser!
                                                      .uid,
                                            ),
                                          );
                                    }
                                  },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child:
                              state is BarbershopRegistrationLoading
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text(
                                    'REGISTER BARBERSHOP',
                                    style: TextStyle(fontSize: 16),
                                  ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
