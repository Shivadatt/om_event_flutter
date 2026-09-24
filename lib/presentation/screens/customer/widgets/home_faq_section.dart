import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/constants/app_colors.dart';
import 'package:om_event/core/services/app_config_service.dart';
import 'package:om_event/domain/entities/settings_entities.dart';

class FAQSection extends StatefulWidget {
  final bool isDesktop;
  const FAQSection({super.key, required this.isDesktop});

  @override
  State<FAQSection> createState() => _FAQSectionState();
}

class _FAQSectionState extends State<FAQSection> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'ALL';

  final List<String> _categories = [
    'ALL',
    'BOOKING',
    'PACKAGES',
    'LOCATION',
    'CANCELLATION',
    'BOOKING PROCESS',
    'DECORATION',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paddingHorizontal = widget.isDesktop ? 64.0 : 24.0;

    return Material(
      color: const Color(0xFF183129), // Section Background
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: paddingHorizontal,
          vertical: widget.isDesktop ? 54 : 40,
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1440),
            child: Obx(() {
              final homepage = AppConfigService.to.rxHomepageSettings.value;
              final rawFaqs = homepage.faqs.isNotEmpty
                  ? homepage.faqs
                  : HomepageSettings.defaultVal().faqs;

              if (rawFaqs.isEmpty) {
                return const SizedBox.shrink();
              }

              // Filter by category and search text
              final filteredFaqs = rawFaqs.where((faq) {
                final map = Map<String, dynamic>.from(faq);
                final q = (map['question'] ?? '').toString().toLowerCase();
                final a = (map['answer'] ?? '').toString().toLowerCase();
                final cat = (map['category'] ?? '').toString().toUpperCase();

                final matchesCategory = _selectedCategory == 'ALL' ||
                    cat == _selectedCategory ||
                    q.contains(_selectedCategory.toLowerCase());

                final matchesQuery = _searchQuery.isEmpty ||
                    q.contains(_searchQuery.toLowerCase()) ||
                    a.contains(_searchQuery.toLowerCase());

                return matchesCategory && matchesQuery;
              }).toList();

              final headingWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "A FEW GOOD QUESTIONS",
                    style: AppTheme.sansBody(
                      fontSize: 10,
                      color: AppColors.secondaryAccent,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return const LinearGradient(
                        colors: [Colors.white, Color(0xFFFFE8A3), Color(0xFFF3D37A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: Text(
                      homepage.faqHeader.isNotEmpty
                          ? homepage.faqHeader.toUpperCase()
                          : "BEFORE THE CONFETTI FLIES.",
                      style: GoogleFonts.italiana(
                        fontSize: widget.isDesktop ? 34 : 26,
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Transparent answers to help you plan with clarity, trust, and complete peace of mind.",
                    style: AppTheme.sansBody(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.65),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Search Field
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10221C),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.secondaryAccent.withValues(alpha: 0.25),
                        width: 1.0,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: AppTheme.sansBody(fontSize: 13, color: Colors.white),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search questions...",
                        hintStyle: AppTheme.sansBody(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 18,
                          color: AppColors.secondaryAccent.withValues(alpha: 0.7),
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 16, color: Colors.white54),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedCategory = cat;
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.secondaryAccent.withValues(alpha: 0.2)
                                    : const Color(0xFF12241E),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.secondaryAccent
                                      : Colors.white.withValues(alpha: 0.12),
                                  width: isSelected ? 1.4 : 1.0,
                                ),
                              ),
                              child: Text(
                                cat,
                                style: AppTheme.sansBody(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  letterSpacing: 0.8,
                                  color: isSelected ? AppColors.secondaryAccent : Colors.white70,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );

              final faqsListWidget = filteredFaqs.isEmpty
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF12241E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.secondaryAccent.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.help_outline_rounded,
                            size: 40,
                            color: AppColors.secondaryAccent.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No questions match your query",
                            style: GoogleFonts.italiana(
                              fontSize: 18,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Try searching with different keywords or reset category filters.",
                            textAlign: TextAlign.center,
                            style: AppTheme.sansBody(
                              fontSize: 12,
                              color: Colors.white54,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _selectedCategory = 'ALL';
                              });
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.secondaryAccent),
                            label: Text(
                              "Reset Filters",
                              style: AppTheme.sansBody(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondaryAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: filteredFaqs.map((faq) {
                        final map = Map<String, dynamic>.from(faq);
                        return _faqItem(
                          map['question'] ?? '',
                          map['answer'] ?? '',
                          map['category'],
                        );
                      }).toList(),
                    );

              if (widget.isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 8,
                      child: headingWidget,
                    ),
                    const SizedBox(width: 56),
                    Expanded(
                      flex: 12,
                      child: faqsListWidget,
                    ),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headingWidget,
                    const SizedBox(height: 32),
                    faqsListWidget,
                  ],
                );
              }
            }),
          ),
        ),
      ),
    );
  }

  Widget _faqItem(String question, String answer, dynamic category) {
    return Theme(
      data: ThemeData(
        dividerColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF132720),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.secondaryAccent.withValues(alpha: 0.15),
            width: 1.0,
          ),
        ),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          title: Row(
            children: [
              if (category != null && category.toString().isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    category.toString().toUpperCase(),
                    style: AppTheme.sansBody(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                      color: AppColors.secondaryAccent,
                    ),
                  ),
                ),
              ],
              Expanded(
                child: Text(
                  question,
                  style: GoogleFonts.italiana(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          collapsedIconColor: AppColors.secondaryAccent,
          iconColor: AppColors.secondaryAccent,
          childrenPadding: const EdgeInsets.only(bottom: 18, left: 18, right: 18),
          children: [
            Text(
              answer,
              style: AppTheme.sansBody(
                fontSize: 13,
                height: 1.6,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
