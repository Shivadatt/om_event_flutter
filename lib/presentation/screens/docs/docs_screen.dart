import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';

class DocsScreen extends StatelessWidget {
  const DocsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF15211E) : const Color(0xFFFBF9F4);
    final cardColor = isDark ? const Color(0xFF1E2E2A) : const Color(0xFFF4F0E6);
    final textColor = isDark ? const Color(0xFFE5DDD0) : const Color(0xFF15211E);
    final mutedColor = isDark ? const Color(0xFF9E9689) : const Color(0xFF5E6662);
    final goldColor = isDark ? AppTheme.darkGold : AppTheme.lightGold;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  TextButton.icon(
                    onPressed: () => Get.offAllNamed('/'),
                    icon: Icon(Icons.arrow_back, size: 16, color: goldColor),
                    label: Text(
                      "Back to website",
                      style: AppTheme.sansBody(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: goldColor,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Eyebrow
                  Text(
                    "Developer reference".toUpperCase(),
                    style: AppTheme.sansBody(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: goldColor,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Heading
                  Text(
                    "Om Events REST API",
                    style: AppTheme.serifHeader(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    "JSON endpoints are same-origin, rate-limited, and return conventional HTTP status codes. Admin endpoints require authorization.",
                    style: AppTheme.sansBody(
                      fontSize: 14,
                      color: mutedColor,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: cardColor,
                          border: Border.all(color: goldColor.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "Authorization: Bearer <token>",
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: goldColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Section: Public Catalog
                  _buildSection(
                    title: "Public catalog",
                    endpoints: [
                      "GET /api/categories",
                      "GET /api/items?q=&category=&sort=&page=",
                      "GET /api/items/{slug}",
                      "GET /api/reviews",
                    ],
                    cardColor: cardColor,
                    textColor: textColor,
                    goldColor: goldColor,
                  ),

                  const SizedBox(height: 32),

                  // Section: Customer Actions
                  _buildSection(
                    title: "Customer actions",
                    endpoints: [
                      "POST /api/leads",
                      "POST /api/quotes",
                      "GET /api/quotes/{public_id}/pdf",
                    ],
                    cardColor: cardColor,
                    textColor: textColor,
                    goldColor: goldColor,
                  ),

                  const SizedBox(height: 32),

                  // Section: Administration
                  _buildSection(
                    title: "Administration",
                    endpoints: [
                      "POST /api/auth/login",
                      "GET /api/auth/me",
                      "GET /api/admin/stats",
                    ],
                    cardColor: cardColor,
                    textColor: textColor,
                    goldColor: goldColor,
                  ),

                  const SizedBox(height: 48),

                  // Footer Notes
                  Text(
                    "See postman/Om-Events.postman_collection.json for request bodies and examples.",
                    style: AppTheme.sansBody(
                      fontSize: 13,
                      color: mutedColor,
                    ).copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<String> endpoints,
    required Color cardColor,
    required Color textColor,
    required Color goldColor,
  }) {
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
            children: endpoints.map((endpoint) {
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
