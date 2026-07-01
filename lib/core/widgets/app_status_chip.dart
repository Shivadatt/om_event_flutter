import 'package:flutter/material.dart';

/// Centralized Status Badge Chip component.
class AppStatusChip extends StatelessWidget {
  final String status;

  const AppStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'qualified':
      case 'completed':
      case 'available':
        color = Colors.green;
        break;
      case 'pending':
      case 'new':
      case 'contacted':
        color = Colors.amber;
        break;
      case 'draft':
      case 'in_progress':
        color = Colors.blue;
        break;
      case 'cancelled':
      case 'lost':
      case 'fully_booked':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
