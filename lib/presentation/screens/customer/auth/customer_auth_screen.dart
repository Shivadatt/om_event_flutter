import 'package:flutter/material.dart';
import 'widgets/customer_auth_box.dart';

/// Full screen container route wrapper for [CustomerAuthBox].
class CustomerAuthScreen extends StatelessWidget {
  const CustomerAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF091210),
      body: Center(
        child: SingleChildScrollView(
          child: CustomerAuthBox(),
        ),
      ),
    );
  }
}
