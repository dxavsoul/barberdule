import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/barber.dart';
import '../../../data/repository/barber_repository.dart';
import '../../../data/repository/barbershop_repository.dart';
import '../../../data/repository/user_repository.dart';
import '../../../logic/blocs/profile/profile_bloc.dart';
import '../../../logic/blocs/profile/profile_state.dart';

class BarberApprovalScreen extends StatefulWidget {
  const BarberApprovalScreen({Key? key}) : super(key: key);

  @override
  State<BarberApprovalScreen> createState() => _BarberApprovalScreenState();
}

class _BarberApprovalScreenState extends State<BarberApprovalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BarberRepository _barberRepository = BarberRepository();
  final BarbershopRepository _barbershopRepository = BarbershopRepository();
  final UserRepository _userRepository = UserRepository();
  String? _barbershopId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBarbershopId();
  }

  Future<void> _loadBarbershopId() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final state = context.read<ProfileBloc>().state;
      if (state is ProfileLoaded) {
        final userId = state.user.uid;
        final barbershop = await _barbershopRepository.getBarbershopByOwnerId(
          userId,
        );

        if (barbershop != null) {
          setState(() {
            _barbershopId = barbershop.id;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading barbershop: $e')));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_barbershopId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Barber Approvals')),
        body: const Center(child: Text('You do not own a barbershop.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Barber Approvals'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Pending'), Tab(text: 'Approved')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildPendingBarbersList(), _buildApprovedBarbersList()],
      ),
    );
  }

  Widget _buildPendingBarbersList() {
    return StreamBuilder<List<Barber>>(
      stream: _barberRepository.getPendingBarbersByBarbershop(_barbershopId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final barbers = snapshot.data ?? [];

        if (barbers.isEmpty) {
          return const Center(child: Text('No pending barber applications.'));
        }

        return ListView.builder(
          itemCount: barbers.length,
          itemBuilder: (context, index) {
            final barber = barbers[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              barber.imageUrl != null
                                  ? NetworkImage(barber.imageUrl!)
                                  : null,
                          child:
                              barber.imageUrl == null
                                  ? const Icon(Icons.person)
                                  : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                barber.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(barber.email),
                              const SizedBox(height: 4),
                              Text(barber.phoneNumber),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Bio:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(barber.bio),
                    const SizedBox(height: 16),
                    Text(
                      'Specialties:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children:
                          barber.specialties.map((specialty) {
                            return Chip(
                              label: Text(specialty),
                              backgroundColor: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => _showRejectDialog(barber),
                          child: const Text('Reject'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () => _approveBarber(barber.id!),
                          child: const Text('Approve'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildApprovedBarbersList() {
    return StreamBuilder<List<Barber>>(
      stream: _barberRepository.getApprovedBarbersByBarbershop(_barbershopId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final barbers = snapshot.data ?? [];

        if (barbers.isEmpty) {
          return const Center(child: Text('No approved barbers yet.'));
        }

        return ListView.builder(
          itemCount: barbers.length,
          itemBuilder: (context, index) {
            final barber = barbers[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    barber.imageUrl != null
                        ? NetworkImage(barber.imageUrl!)
                        : null,
                child:
                    barber.imageUrl == null ? const Icon(Icons.person) : null,
              ),
              title: Text(barber.name),
              subtitle: Text(barber.email),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showRemoveBarberDialog(barber),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _approveBarber(String barberId) async {
    try {
      await _barberRepository.approveBarber(barberId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barber approved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error approving barber: $e')));
    }
  }

  Future<void> _rejectBarber(String barberId, String reason) async {
    try {
      await _barberRepository.rejectBarber(barberId, reason);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barber application rejected')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error rejecting barber: $e')));
    }
  }

  Future<void> _removeBarber(String barberId) async {
    try {
      await _barberRepository.deleteBarber(barberId);
      await _barbershopRepository.removeBarberFromBarbershop(
        _barbershopId!,
        barberId,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barber removed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error removing barber: $e')));
    }
  }

  void _showRejectDialog(Barber barber) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reject Barber Application'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Please provide a reason for rejection:'),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    hintText: 'Reason for rejection',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (reasonController.text.trim().isNotEmpty) {
                    Navigator.pop(context);
                    _rejectBarber(barber.id!, reasonController.text.trim());
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please provide a reason for rejection'),
                      ),
                    );
                  }
                },
                child: const Text('Reject'),
              ),
            ],
          ),
    );
  }

  void _showRemoveBarberDialog(Barber barber) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove Barber'),
            content: Text(
              'Are you sure you want to remove ${barber.name} from your barbershop?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  _removeBarber(barber.id!);
                },
                child: const Text('Remove'),
              ),
            ],
          ),
    );
  }
}
