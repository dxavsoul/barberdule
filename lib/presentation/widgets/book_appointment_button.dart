import 'package:flutter/material.dart';
import '../../routes.dart';

class BookAppointmentButton extends StatelessWidget {
  final String? barberId;
  final Color? backgroundColor;
  final Color? textColor;

  const BookAppointmentButton({
    Key? key,
    this.barberId,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(
          context,
          AppRoutes.bookAppointment,
          arguments: barberId != null ? {'barberId': barberId} : null,
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
        foregroundColor: textColor ?? Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: const Text('Book Appointment', style: TextStyle(fontSize: 16)),
    );
  }
}
