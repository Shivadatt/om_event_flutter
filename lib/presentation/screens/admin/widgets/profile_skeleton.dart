import 'package:flutter/material.dart';

/// Loading skeleton placeholder built specifically for [ProfileScreen] startup states.
class ProfileSkeleton extends StatelessWidget {
  /// Creates a [ProfileSkeleton] widget instance.
  const ProfileSkeleton({super.key});

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF162822),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF254235)),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: List.generate(
          3,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _card(
              child: Column(
                children: List.generate(
                  4,
                  (j) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      height: j == 0 ? 80.0 : 24.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1915),
                        borderRadius: BorderRadius.circular(j == 0 ? 40 : 6),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
