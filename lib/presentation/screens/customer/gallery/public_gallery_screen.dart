import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/gallery_controller.dart';
import '../../../widgets/app_page_container.dart';
import 'widgets/atmospheric_golden_swirl_painter.dart';
import 'widgets/gallery_card.dart';
import 'widgets/gallery_empty_state.dart';
import 'widgets/gallery_header_bar.dart';
import 'widgets/gallery_hero_header.dart';
import 'widgets/gallery_lightbox_dialog.dart';

class PublicGalleryScreen extends StatefulWidget {
  const PublicGalleryScreen({super.key});

  @override
  State<PublicGalleryScreen> createState() => _PublicGalleryScreenState();
}

class _PublicGalleryScreenState extends State<PublicGalleryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _categoryScrollCtrl = ScrollController();
  late final GalleryController _controller;

  static const Color _goldColor = Color(0xFFD4AF37);
  static const Color _darkBgColor = Color(0xFF08110E);
  static const Color _headerBgColor = Color(0xF2091411);

  @override
  void initState() {
    super.initState();
    _controller =
        Get.isRegistered<GalleryController>()
            ? Get.find<GalleryController>()
            : Get.put(GalleryController());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _categoryScrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1000;
    final isTablet = width >= 650 && width < 1000;
    final hPad = AppPageContainer.horizontalPadding(context);

    return Scaffold(
      backgroundColor: _darkBgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          GalleryHeaderBar(
            hPad: hPad,
            isDesktop: isDesktop,
            screenWidth: width,
            goldColor: _goldColor,
            headerBgColor: _headerBgColor,
          ),
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: AtmosphericGoldenSwirlPainter()),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: AppPageContainer.maxContentWidth,
                      ),
                      child: GalleryHeroHeader(
                        searchCtrl: _searchCtrl,
                        categoryScrollCtrl: _categoryScrollCtrl,
                        controller: _controller,
                        isDesktop: isDesktop,
                        isTablet: isTablet,
                        goldColor: _goldColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            if (_controller.rxIsLoading.value &&
                _controller.rxGalleryItems.isEmpty) {
              return const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: _goldColor),
                ),
              );
            }

            final items = _controller.filteredItems;

            if (items.isEmpty) {
              return GalleryEmptyState(
                searchCtrl: _searchCtrl,
                controller: _controller,
                goldColor: _goldColor,
              );
            }

            final crossAxisCount = isDesktop ? 4 : (isTablet ? 2 : 1);
            final childAspectRatio =
                isDesktop ? 1.12 : (isTablet ? 1.22 : 1.32);

            return SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 12),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: AppPageContainer.maxContentWidth,
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return GalleryCard(
                          item: item,
                          onTap:
                              () => showGalleryLightbox(
                                context,
                                items: items,
                                initialIndex: index,
                              ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          }),
          const SliverToBoxAdapter(child: SizedBox(height: 60)),
        ],
      ),
    );
  }
}
