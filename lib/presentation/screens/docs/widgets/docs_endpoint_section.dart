import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';

class DocsEndpointSection extends StatelessWidget {
  final String title;
  final List<String> endpoints;
  final Color cardColor;
  final Color textColor;
  final Color goldColor;

  const DocsEndpointSection({
    super.key,
    required this.title,
    required this.endpoints,
    required this.cardColor,
    required this.textColor,
    required this.goldColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.serifHeader(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                endpoints.map((endpoint) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      endpoint,
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC39463),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}
