import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_input.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/catalog_controller.dart';
import '../../widgets/item_visual_placeholder.dart';

class ExperienceDetailScreen extends StatefulWidget {
  const ExperienceDetailScreen({super.key});

  @override
  State<ExperienceDetailScreen> createState() => _ExperienceDetailScreenState();
}

class _ExperienceDetailScreenState extends State<ExperienceDetailScreen> {
  final _notesController = TextEditingController();
  String _selectedColor = '';
  String _selectedTheme = '';

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Widget _buildImage(
    String url,
    String title,
    String categorySlug,
    String categoryName,
  ) {
    if (url.isEmpty) {
      return ItemVisualPlaceholder(
        title: title,
        categorySlug: categorySlug,
        categoryName: categoryName,
      );
    }
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) => ItemVisualPlaceholder(
              title: title,
              categorySlug: categorySlug,
              categoryName: categoryName,
            ),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder:
          (_, __, ___) => ItemVisualPlaceholder(
            title: title,
            categorySlug: categorySlug,
            categoryName: categoryName,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slug = Get.parameters['slug'];
    final catalogController = Get.find<CatalogController>();
    final cartController = Get.find<CartController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 800;

    final item = catalogController.rxExperiences.firstWhereOrNull(
      (element) => element.slug == slug,
    );

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Details")),
        body: const Center(child: Text("Experience not found.")),
      );
    }

    // Initialize customizer dropdowns
    if (_selectedColor.isEmpty && item.colors.isNotEmpty) {
      _selectedColor = item.colors.first;
    }
    if (_selectedTheme.isEmpty && item.themes.isNotEmpty) {
      _selectedTheme = item.themes.first;
    }

    final detailContent = [
      Text(
        "${item.categoryName.toUpperCase()} · CUSTOMIZABLE",
        style: AppTheme.sansBody(
          fontSize: 10,
          color: isDark ? AppTheme.darkGold : AppTheme.lightGold,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        item.name,
        style: AppTheme.serifHeader(
          fontSize: 34,
          color: isDark ? AppTheme.darkInk : AppTheme.lightInk,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          const Icon(Icons.star, size: 14, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            "${item.rating} (${item.reviewCount} Verified Reviews)",
            style: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      const SizedBox(height: 20),
      Text(
        item.description,
        style: AppTheme.sansBody(
          fontSize: 14,
          color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
          height: 1.6,
        ),
      ),
      const SizedBox(height: 24),
      Row(
        children: [
          Text(
            AppFormatters.formatCurrency(item.effectivePrice),
            style: AppTheme.sansBody(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(
            "starting price",
            style: AppTheme.sansBody(
              fontSize: 11,
              color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
            ),
          ),
        ],
      ),
      const Divider(height: 40),

      // Customizer Settings Dropdowns
      Text(
        "CUSTOMISE YOUR SETUP",
        style: AppTheme.sansBody(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      const SizedBox(height: 18),
      if (item.colors.isNotEmpty) ...[
        Text(
          "COLOR STORY",
          style: AppTheme.sansBody(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? AppTheme.darkLine : AppTheme.lightLine,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedColor,
              items:
                  item.colors
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedColor = val);
              },
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
      if (item.themes.isNotEmpty) ...[
        Text(
          "DESIGN MOOD / THEME",
          style: AppTheme.sansBody(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? AppTheme.darkLine : AppTheme.lightLine,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedTheme,
              items:
                  item.themes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedTheme = val);
              },
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
      CustomInput(
        label: "Special Notes / Oddly Specific Details",
        placeholder: "Add name signage, access rules or a unique request...",
        controller: _notesController,
        maxLines: 3,
      ),
      const SizedBox(height: 24),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppTheme.darkLine : AppTheme.lightLine,
              width: 1,
            ),
          ),
        ),
        child: Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check, color: Colors.green, size: 12),
                const SizedBox(width: 4),
                Text(
                  "Styling & Installation",
                  style: AppTheme.sansBody(
                    fontSize: 10,
                    color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check, color: Colors.green, size: 12),
                const SizedBox(width: 4),
                Text(
                  "Teardown",
                  style: AppTheme.sansBody(
                    fontSize: 10,
                    color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check, color: Colors.green, size: 12),
                const SizedBox(width: 4),
                Text(
                  "Dedicated Coordinator",
                  style: AppTheme.sansBody(
                    fontSize: 10,
                    color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      CustomButton(
        text: "Add to my selection",
        onPressed: () {
          cartController.addToCart(
            item,
            color: _selectedColor,
            theme: _selectedTheme,
            notes: _notesController.text,
          );
          Get.back();
          Get.snackbar(
            "Added to Canvas",
            "${item.name} added to your selection.",
          );
        },
      ),
      const SizedBox(height: 40),
    ];

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF141A18) : const Color(0xFFFBF9F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child:
                isDesktop
                    ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Image/Placeholder
                        Expanded(
                          flex: 10,
                          child: Container(
                            height: 520,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    isDark
                                        ? AppTheme.darkLine
                                        : AppTheme.lightLine,
                              ),
                            ),
                            child: _buildImage(
                              item.imageUrl,
                              item.name,
                              item.categorySlug,
                              item.categoryName,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                        // Right Column: Customizer fields
                        Expanded(
                          flex: 10,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: detailContent,
                            ),
                          ),
                        ),
                      ],
                    )
                    : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 320,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    isDark
                                        ? AppTheme.darkLine
                                        : AppTheme.lightLine,
                              ),
                            ),
                            child: _buildImage(
                              item.imageUrl,
                              item.name,
                              item.categorySlug,
                              item.categoryName,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ...detailContent,
                        ],
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}
