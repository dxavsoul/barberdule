import 'package:barberdule/config/theme.dart';
import 'package:barberdule/data/repository/auth_repository.dart';
import 'package:barberdule/data/repository/barber_repository.dart';
import 'package:barberdule/data/repository/barbershop_repository.dart';
import 'package:barberdule/data/repository/user_repository.dart';
import 'package:barberdule/data/repository/appointment_repository.dart';
import 'package:barberdule/data/repository/service_repository.dart';
import 'package:barberdule/logic/blocs/auth/auth_bloc.dart';
import 'package:barberdule/logic/blocs/auth/auth_event.dart';
import 'package:barberdule/logic/blocs/barber_appointments/barber_appointments_bloc.dart';
import 'package:barberdule/logic/blocs/map/map_bloc.dart';
import 'package:barberdule/logic/blocs/profile/profile_bloc.dart';
import 'package:barberdule/logic/blocs/profile/profile_event.dart';
import 'package:barberdule/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(),
        ),
        RepositoryProvider<UserRepository>(
          create: (context) => UserRepository(),
        ),
        RepositoryProvider<AppointmentRepository>(
          create: (context) => AppointmentRepository(),
        ),
        RepositoryProvider<ServiceRepository>(
          create: (context) => ServiceRepository(),
        ),
        RepositoryProvider<BarberRepository>(
          create: (context) => BarberRepository(),
        ),
        RepositoryProvider<BarbershopRepository>(
          create: (context) => BarbershopRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: RepositoryProvider.of<AuthRepository>(
                context,
              ),
            )..add(AuthCheckRequested()),
          ),
          BlocProvider<ProfileBloc>(
            create: (context) => ProfileBloc(
              authRepository: RepositoryProvider.of<AuthRepository>(
                context,
              ),
              userRepository: RepositoryProvider.of<UserRepository>(
                context,
              ),
            )..add(const ProfileLoadRequested()),
          ),
          BlocProvider<BarberAppointmentsBloc>(
            create: (context) => BarberAppointmentsBloc(
              appointmentRepository:
                  RepositoryProvider.of<AppointmentRepository>(context),
            ),
          ),
          BlocProvider<MapBloc>(
            create: (context) {
              final mapBloc = MapBloc(
                barbershopRepository:
                    RepositoryProvider.of<BarbershopRepository>(context),
                barberRepository: RepositoryProvider.of<BarberRepository>(
                  context,
                ),
              );
              return mapBloc;
            },
          ),
        ],
        child: MaterialApp(
          title: 'Barberdule',
          theme: appTheme,
          onGenerateRoute: AppRoutes.generateRoute,
          initialRoute:
              _auth.currentUser != null ? AppRoutes.main : AppRoutes.welcome,
        ),
      ),
    );
  }
}
