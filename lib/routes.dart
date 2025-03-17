import 'package:barberdule/presentation/screens/barbershop/barbershop_map_screen.dart';
import 'package:flutter/material.dart';
import 'presentation/screens/booking/book_appointment_screen.dart';
import 'presentation/screens/barber/barber_profile_screen.dart';
import 'presentation/screens/barber/barber_appointments_screen.dart';
import 'presentation/screens/admin/manage_services_screen.dart';
import 'presentation/screens/registration/register_barbershop_screen.dart';
import 'presentation/screens/registration/register_barber_screen.dart';
import 'presentation/screens/registration/register_customer_screen.dart';
import 'presentation/screens/registration/registration_choice_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/screens/welcome_screen.dart';
import 'presentation/screens/barbershop/barber_approval_screen.dart';
import 'presentation/screens/customer/appointment_history_screen.dart';
import 'presentation/screens/barbershop/barbershop_details_screen.dart';
import 'presentation/screens/barber/barber_details_screen.dart';

class AppRoutes {
  static const String bookAppointment = '/book-appointment';
  static const String barberProfile = '/barber-profile';
  static const String barberAppointments = '/barber-appointments';
  static const String manageServices = '/manage-services';
  static const String registerBarbershop = '/register-barbershop';
  static const String registerBarber = '/register-barber';
  static const String registerCustomer = '/register-customer';
  static const String registrationChoice = '/registration-choice';
  static const String login = '/login';
  static const String main = '/';
  static const String welcome = '/welcome';
  static const String barberApproval = '/barber-approval';
  static const String appointmentHistory = '/appointment-history';
  static const String barbershopDetails = '/barbershop-details';
  static const String barberDetails = '/barber-details';
  static const String exploreBarbers = '/explorer-barbers';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case bookAppointment:
        final args = settings.arguments as Map<String, dynamic>?;
        final String? barberId = args?['barberId'];
        return MaterialPageRoute(
          builder: (_) => BookAppointmentScreen(barberId: barberId),
        );

      case barberProfile:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BarberProfileScreen(
            barberId: args['barberId'],
            barberName: args['barberName'],
            barberImage: args['barberImage'],
            barberDescription: args['barberDescription'],
            services: List<String>.from(args['services']),
            rating: args['rating'],
          ),
        );

      case barberAppointments:
        return MaterialPageRoute(
          builder: (_) => const BarberAppointmentsScreen(),
        );

      case manageServices:
        final args = settings.arguments as Map<String, dynamic>?;
        final String? barbershopId = args?['barbershopId'];
        return MaterialPageRoute(
          builder: (_) => ManageServicesScreen(barbershopId: barbershopId),
        );

      case registerBarbershop:
        return MaterialPageRoute(
          builder: (_) => const RegisterBarbershopScreen(),
        );

      case registerBarber:
        final args = settings.arguments as Map<String, dynamic>?;
        final String? barbershopId = args?['barbershopId'];
        return MaterialPageRoute(
          builder: (_) => RegisterBarberScreen(barbershopId: barbershopId),
        );

      case registerCustomer:
        return MaterialPageRoute(
          builder: (_) => const RegisterCustomerScreen(),
        );

      case registrationChoice:
        return MaterialPageRoute(
          builder: (_) => const RegistrationChoiceScreen(),
        );

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case barberApproval:
        return MaterialPageRoute(builder: (_) => const BarberApprovalScreen());

      case welcome:
        return MaterialPageRoute(builder: (_) => WelcomeScreen());

      case main:
        return MaterialPageRoute(builder: (_) => const MainScreen());

      case appointmentHistory:
        return MaterialPageRoute(
          builder: (_) => const AppointmentHistoryScreen(),
        );

      case barbershopDetails:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) =>
              BarbershopDetailsScreen(barbershopId: args['barbershopId']),
        );

      case barberDetails:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BarberDetailsScreen(barberId: args['barberId']),
        );

      case exploreBarbers:
        return MaterialPageRoute(
          builder: (_) => const BarbershopMapScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
