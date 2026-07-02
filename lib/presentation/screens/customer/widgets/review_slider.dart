import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../domain/entities/review.dart';
import 'review_card.dart';

class ReviewSlider extends StatefulWidget {
  final List<Review> reviews;
  final bool isDesktop;

  const ReviewSlider({
    super.key,
    required this.reviews,
    required this.isDesktop,
  });

  @override
  State<ReviewSlider> createState() => _ReviewSliderState();
}

class _ReviewSliderState extends State<ReviewSlider> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoPlay();
  }

  @override
  void dispose() {
    _stopAutoPlay();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _stopAutoPlay();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;
      final pageCount = _getPageCount();
      if (pageCount <= 1) return;
      final nextPage = (_currentPage + 1) % pageCount;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  int _getItemsPerPage(double width) {
    if (width >= 1024) return 3; // Desktop
    if (width >= 600) return 2;  // Tablet
    return 1;                   // Mobile
  }

  int _getPageCount() {
    final width = MediaQuery.of(context).size.width;
    final itemsPerPage = _getItemsPerPage(width);
    if (widget.reviews.isEmpty) return 0;
    return (widget.reviews.length / itemsPerPage).ceil();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reviews.isEmpty) return const SizedBox.shrink();

    final width = MediaQuery.of(context).size.width;
    final itemsPerPage = _getItemsPerPage(width);
    final pageCount = _getPageCount();

    // Chunk reviews into pages
    final List<List<Review>> pages = [];
    for (var i = 0; i < widget.reviews.length; i += itemsPerPage) {
      final end = (i + itemsPerPage < widget.reviews.length)
          ? i + itemsPerPage
          : widget.reviews.length;
      pages.add(widget.reviews.sublist(i, end));
    }

    return Column(
      children: [
        Row(
          children: [
            if (pageCount > 1)
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: _navigationButton(
                  icon: Icons.chevron_left,
                  onPressed: () {
                    _startAutoPlay();
                    final prevPage = (_currentPage - 1 + pageCount) % pageCount;
                    _pageController.animateToPage(
                      prevPage,
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeInOutCubic,
                    );
                  },
                ),
              ),
            Expanded(
              child: SizedBox(
                height: 200,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: pages.length,
                  itemBuilder: (context, pageIndex) {
                    final pageItems = pages[pageIndex];
                    return Row(
                      children: List.generate(itemsPerPage, (index) {
                        if (index < pageItems.length) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ReviewCard(review: pageItems[index]),
                            ),
                          );
                        } else {
                          return Expanded(
                            child: Container(),
                          );
                        }
                      }),
                    );
                  },
                ),
              ),
            ),
            if (pageCount > 1)
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: _navigationButton(
                  icon: Icons.chevron_right,
                  onPressed: () {
                    _startAutoPlay();
                    final nextPage = (_currentPage + 1) % pageCount;
                    _pageController.animateToPage(
                      nextPage,
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeInOutCubic,
                    );
                  },
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        if (pageCount > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pageCount, (index) {
              final isSelected = _currentPage == index;
              return GestureDetector(
                onTap: () {
                  _startAutoPlay();
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeInOutCubic,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isSelected ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFC9A77E) : const Color(0xFF1E352C),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
      ],
    );
  }

  Widget _navigationButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E19),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF1E352C), width: 1),
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFFC9A77E)),
        iconSize: 20,
        onPressed: onPressed,
      ),
    );
  }
}
