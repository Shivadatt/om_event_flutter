import 'package:flutter/material.dart';

/// Reusable Admin loading progress spinner.
class AdminLoading extends StatelessWidget {
  const AdminLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC8A26A)),
      ),
    );
  }
}
