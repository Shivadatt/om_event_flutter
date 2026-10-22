import 'package:flutter/material.dart';
import 'widgets/service_area_bottom_cta.dart';
import 'widgets/service_area_coverage_resolver.dart';
import 'widgets/service_area_header.dart';
import 'widgets/service_area_hero_section.dart';
import 'widgets/service_area_studios_section.dart';
import 'widgets/service_area_zones_section.dart';

class ServiceAreaScreen extends StatefulWidget {
  const ServiceAreaScreen({super.key});

  @override
  State<ServiceAreaScreen> createState() => _ServiceAreaScreenState();
}

class _ServiceAreaScreenState extends State<ServiceAreaScreen> {
  final TextEditingController _pincodeCtrl = TextEditingController();
  Map<String, dynamic>? _checkResult;

  static const Color _goldColor = Color(0xFFD4AF37);

  @override
  void dispose() {
    _pincodeCtrl.dispose();
    super.dispose();
  }

  void _checkCoverage([String? overrideQuery]) {
    final query = (overrideQuery ?? _pincodeCtrl.text).trim();
    if (query.isEmpty) return;

    if (overrideQuery != null) {
      _pincodeCtrl.text = overrideQuery;
    }

    setState(() {
      _checkResult = ServiceAreaCoverageResolver.resolveCoverage(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1200;
    final isLaptop = screenWidth >= 1024 && screenWidth < 1200;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isMobile = screenWidth < 600;

    final horizontalPadding =
        isDesktop
            ? 20.0
            : (isLaptop
                ? 16.0
                : (isTablet ? 14.0 : (screenWidth <= 360 ? 6.0 : 10.0)));
    final containerPadding =
        isDesktop
            ? 22.0
            : (isLaptop
                ? 18.0
                : (isTablet ? 16.0 : (screenWidth <= 360 ? 10.0 : 12.0)));

    return Scaffold(
      backgroundColor: const Color(0xFF060D0A),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          ServiceAreaHeader(
            isDesktop: isDesktop,
            isMobile: isMobile,
            screenWidth: screenWidth,
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: isDesktop ? 16 : 10,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final availableWidth = constraints.maxWidth;
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF08120E),
                          borderRadius: BorderRadius.circular(
                            isMobile ? 16 : 22,
                          ),
                          border: Border.all(
                            color: _goldColor.withValues(alpha: 0.22),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.6),
                              blurRadius: 28,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(containerPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ServiceAreaHeroSection(
                              pincodeCtrl: _pincodeCtrl,
                              checkResult: _checkResult,
                              onCheck: () => _checkCoverage(),
                              onClearResult: () => setState(() => _checkResult = null),
                              onCitySelected: (cityName) => _checkCoverage(cityName),
                              isDesktop: isDesktop,
                              isLaptop: isLaptop,
                              isTablet: isTablet,
                              isMobile: isMobile,
                              goldColor: _goldColor,
                            ),
                            SizedBox(height: isMobile ? 20 : 24),
                            ServiceAreaStudiosSection(
                              isDesktop: isDesktop,
                              isLaptop: isLaptop,
                              isTablet: isTablet,
                              isMobile: isMobile,
                              availableWidth: availableWidth,
                              goldColor: _goldColor,
                            ),
                            SizedBox(height: isMobile ? 20 : 24),
                            ServiceAreaZonesSection(
                              isDesktop: isDesktop,
                              isLaptop: isLaptop,
                              isTablet: isTablet,
                              isMobile: isMobile,
                              availableWidth: availableWidth,
                              goldColor: _goldColor,
                            ),
                            SizedBox(height: isMobile ? 22 : 26),
                            ServiceAreaBottomCta(
                              goldColor: _goldColor,
                              isMobile: isMobile,
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
