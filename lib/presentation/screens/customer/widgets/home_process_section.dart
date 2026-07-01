import 'package:flutter/material.dart';
import 'package:om_event/core/config/app_theme.dart';

class ProcessSection extends StatelessWidget {
  final bool isDesktop;
  const ProcessSection({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final paddingHorizontal = isDesktop ? 64.0 : 24.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: paddingHorizontal,
        vertical: 80,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Easy by design",
                style: AppTheme.sansBody(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Your celebration, without the chaos.",
                style: AppTheme.serifHeader(fontSize: 32),
              ),
              const SizedBox(height: 36),
              isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _stepRow(
                            context,
                            "01",
                            "Choose your canvas",
                            "Browse our event collections and add the ideas that feel like you.",
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _stepRow(
                            context,
                            "02",
                            "Make it personal",
                            "Tune colors, themes and quantities. Leave us the details—we love those.",
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _stepRow(
                            context,
                            "03",
                            "Know your number",
                            "See every charge clearly and download a polished, itemized quotation.",
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _stepRow(
                            context,
                            "04",
                            "We bring the wonder",
                            "Our crew handles production, styling and teardown. You stay in the moment.",
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _stepRow(
                          context,
                          "01",
                          "Choose your canvas",
                          "Browse our event collections and add the ideas that feel like you.",
                        ),
                        _stepRow(
                          context,
                          "02",
                          "Make it personal",
                          "Tune colors, themes and quantities. Leave us the details—we love those.",
                        ),
                        _stepRow(
                          context,
                          "03",
                          "Know your number",
                          "See every charge clearly and download a polished, itemized quotation.",
                        ),
                        _stepRow(
                          context,
                          "04",
                          "We bring the wonder",
                          "Our crew handles production, styling and teardown. You stay in the moment.",
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepRow(
    BuildContext context,
    String step,
    String title,
    String desc,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.darkLine : AppTheme.lightLine,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step,
            style: AppTheme.serifHeader(
              fontSize: 24,
              color: isDark ? AppTheme.darkGold : AppTheme.lightGold,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.serifHeader(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: AppTheme.sansBody(
                    fontSize: 13,
                    color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
