import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_routes.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      'title': 'Celebrations,\nthoughtfully composed.',
      'subtitle':
          'From the first sketch to the final flower, create an experience that feels unmistakably yours.',
    },
    {
      'title': 'Design your event canvas.',
      'subtitle':
          'Browse our curated collection of signature packages and personalize the colors, themes, and units.',
    },
    {
      'title': 'Honest, live pricing.',
      'subtitle':
          'Build your selections, see every charge transparently, and download a polished quotation instantly.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Get.offNamed(AppRoutes.home),
                child: Text(
                  "SKIP",
                  style: AppTheme.sansBody(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "0${index + 1}",
                          style: AppTheme.serifHeader(
                            fontSize: 48,
                            color:
                                isDark ? AppTheme.darkGold : AppTheme.lightGold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide['title']!,
                          style: AppTheme.serifHeader(
                            fontSize: 34,
                            color:
                                isDark ? AppTheme.darkInk : AppTheme.lightInk,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide['subtitle']!,
                          style: AppTheme.sansBody(
                            fontSize: 15,
                            color:
                                isDark
                                    ? AppTheme.darkMuted
                                    : AppTheme.lightMuted,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators
                  Row(
                    children: List.generate(
                      _slides.length,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              _currentPage == index
                                  ? (isDark
                                      ? AppTheme.darkGold
                                      : AppTheme.lightGold)
                                  : (isDark
                                      ? AppTheme.darkLine
                                      : AppTheme.lightLine),
                        ),
                      ),
                    ),
                  ),
                  // Button
                  SizedBox(
                    width: 140,
                    child: CustomButton(
                      text:
                          _currentPage == _slides.length - 1
                              ? "GET STARTED"
                              : "NEXT",
                      onPressed: () {
                        if (_currentPage < _slides.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          Get.offNamed(AppRoutes.home);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
