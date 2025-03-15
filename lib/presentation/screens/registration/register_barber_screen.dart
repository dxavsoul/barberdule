import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repository/barber_repository.dart';
import '../../../data/repository/barbershop_repository.dart';
import '../../../logic/blocs/barber_registration/barber_registration_bloc.dart';
import '../../../logic/blocs/barber_registration/barber_registration_event.dart';
import '../../../logic/blocs/barber_registration/barber_registration_state.dart';
import '../../../routes.dart';
import 'working_hours_picker.dart';

class RegisterBarberScreen extends StatefulWidget {
  final String? barbershopId;

  const RegisterBarberScreen({Key? key, this.barbershopId}) : super(key: key);

  @override
  State<RegisterBarberScreen> createState() => _RegisterBarberScreenState();
}

class _RegisterBarberScreenState extends State<RegisterBarberScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _bioController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String? _selectedBarbershopId;
  List<String> _specialties = [];
  Map<String, dynamic> _workingHours = {};
  List<Map<String, dynamic>> _barbershops = [];
  bool _isLoading = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final List<String> _availableSpecialties = [
    'Haircut',
    'Beard Trim',
    'Shave',
    'Hair Coloring',
    'Hair Styling',
    'Kids Haircut',
    'Hot Towel Treatment',
    'Facial',
  ];

  @override
  void initState() {
    super.initState();
    _selectedBarbershopId = widget.barbershopId;

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

    _loadBarbershops();
  }

  Future<void> _loadBarbershops() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch barbershops from the repository
      final barbershopRepository = BarbershopRepository();
      final barbershopsStream = barbershopRepository.getAllBarbershops();

      // Convert stream to list
      final barbershops = await barbershopsStream.first;

      // Map to the format needed for dropdown
      _barbershops =
          barbershops
              .map(
                (barbershop) => {
                  'id': barbershop.id ?? 'unknown',
                  'name': barbershop.name,
                },
              )
              .toList();

      // If no barbershops found, show a message
      if (_barbershops.isEmpty) {
        _barbershops = [
          {'id': 'no_barbershops', 'name': 'No barbershops available'},
        ];
      }
    } catch (e) {
      // In case of error, use some default data
      _barbershops = [
        {'id': 'barbershop1', 'name': 'Classic Cuts'},
        {'id': 'barbershop2', 'name': 'Modern Styles'},
        {'id': 'barbershop3', 'name': 'Elite Barbers'},
      ];

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load barbershops: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _bioController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _toggleSpecialty(String specialty) {
    setState(() {
      if (_specialties.contains(specialty)) {
        _specialties.remove(specialty);
      } else {
        _specialties.add(specialty);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Register as Barber')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return BlocProvider(
      create:
          (context) => BarberRegistrationBloc(
            barberRepository: BarberRepository(),
            barbershopRepository: BarbershopRepository(),
          ),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: const Text('Register as Barber')),
            body: BlocConsumer<BarberRegistrationBloc, BarberRegistrationState>(
              listener: (context, state) {
                if (state is BarberRegistrationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Barber registered successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context, state.barberId);
                } else if (state is BarberRegistrationFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to register barber: ${state.error}',
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
                            labelText: 'Full Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
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

                        // Password
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscureConfirmPassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Bio
                        TextFormField(
                          controller: _bioController,
                          decoration: const InputDecoration(
                            labelText: 'Bio',
                            border: OutlineInputBorder(),
                            hintText:
                                'Tell clients about yourself and your experience',
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a bio';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Image URL (optional)
                        TextFormField(
                          controller: _imageUrlController,
                          decoration: const InputDecoration(
                            labelText: 'Profile Image URL (optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Barbershop Selection
                        if (widget.barbershopId == null) ...[
                          const Text(
                            'Select Barbershop',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedBarbershopId,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            hint: const Text('Select a barbershop'),
                            items:
                                _barbershops.map((barbershop) {
                                  return DropdownMenuItem<String>(
                                    value: barbershop['id'],
                                    child: Text(barbershop['name']),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedBarbershopId = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a barbershop';
                              }
                              if (value == 'no_barbershops') {
                                return 'No barbershops available. Please register a barbershop first.';
                              }
                              return null;
                            },
                          ),
                          if (_barbershops.length == 1 &&
                              _barbershops[0]['id'] == 'no_barbershops') ...[
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.add_business),
                              label: const Text('Register a Barbershop'),
                              onPressed: () async {
                                final result = await Navigator.pushNamed(
                                  context,
                                  AppRoutes.registerBarbershop,
                                );
                                if (result != null) {
                                  // Reload barbershops if a new one was registered
                                  _loadBarbershops();
                                }
                              },
                            ),
                          ],
                          const SizedBox(height: 24),
                        ],

                        // Specialties
                        const Text(
                          'Specialties',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              _availableSpecialties.map((specialty) {
                                final isSelected = _specialties.contains(
                                  specialty,
                                );
                                return FilterChip(
                                  label: Text(specialty),
                                  selected: isSelected,
                                  onSelected:
                                      (_) => _toggleSpecialty(specialty),
                                  backgroundColor: Colors.grey.shade200,
                                  selectedColor: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.3),
                                  checkmarkColor:
                                      Theme.of(context).primaryColor,
                                );
                              }).toList(),
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
                              state is BarberRegistrationLoading
                                  ? null
                                  : () {
                                    if (_formKey.currentState!.validate()) {
                                      if (_specialties.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Please select at least one specialty',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      final barbershopId =
                                          _selectedBarbershopId ??
                                          widget.barbershopId;
                                      if (barbershopId == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Please select a barbershop',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      if (barbershopId == 'no_barbershops') {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'No barbershops available. Please register a barbershop first.',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      context
                                          .read<BarberRegistrationBloc>()
                                          .add(
                                            BarberRegistrationSubmitted(
                                              name: _nameController.text,
                                              phoneNumber:
                                                  _phoneController.text,
                                              email: _emailController.text,
                                              password:
                                                  _passwordController.text,
                                              bio: _bioController.text,
                                              imageUrl:
                                                  _imageUrlController
                                                          .text
                                                          .isEmpty
                                                      ? null
                                                      : _imageUrlController
                                                          .text,
                                              specialties: _specialties,
                                              barbershopId: barbershopId,
                                              workingHours: _workingHours,
                                            ),
                                          );
                                    }
                                  },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child:
                              state is BarberRegistrationLoading
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text(
                                    'REGISTER AS BARBER',
                                    style: TextStyle(fontSize: 16),
                                  ),
                        ),

                        const SizedBox(height: 24),

                        // Divider with "or" text
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Login information
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account?',
                              style: TextStyle(fontSize: 16),
                            ),
                            TextButton(
                              onPressed: () {
                                // Navigate to login screen
                                Navigator.pushNamed(context, AppRoutes.login);
                              },
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Login information details
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            'If you already registered as a barber, you can login with your email and password to access your profile, manage your appointments, and update your availability.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 14),
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
