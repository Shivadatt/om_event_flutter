part of '../experience_form_dialog.dart';

extension _ExperienceFormFields on _ExperienceFormDialogState {
  Widget _buildFormFields(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryAccent = AppColors.primaryAccent;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color inputFillColor = isDark ? const Color(0xFF1A1715) : const Color(0xFFFAF8F5);
    final Color borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _dialogField(
          "Experience Name *",
          nameCtrl,
          hintText: "e.g., Royal Gold Canopy Stage",
          prefixIcon: Icon(Icons.star_outline, color: primaryAccent.withValues(alpha: 0.4), size: 18),
          onChanged: (val) {
            if (!isEdit) {
              slugCtrl.text = val
                  .toLowerCase()
                  .trim()
                  .replaceAll(RegExp(r'\s+'), '-')
                  .replaceAll(RegExp(r'[^a-z0-9\-]'), '');
            }
          },
        ),
        _dialogField(
          "Slug / URL Handle *",
          slugCtrl,
          enabled: !isEdit,
          hintText: "e.g., royal-gold-canopy",
          prefixIcon: Icon(Icons.link, color: primaryAccent.withValues(alpha: 0.4), size: 18),
        ),
        const SizedBox(height: 8),
        Text(
          "SELECT BRAND CATEGORIES",
          style: AppTheme.sansBody(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: primaryAccent,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: inputFillColor,
            border: Border.all(color: borderColor, width: 1.2),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: widget.controller.rxCategories.map((cat) {
              final isChecked = selectedCategoryIds.contains(cat.id);
              return CheckboxListTile(
                title: Text(
                  cat.name.toUpperCase(),
                  style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
                ),
                value: isChecked,
                dense: true,
                activeColor: primaryAccent,
                checkColor: Colors.black,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                onChanged: (bool? val) {
                  updateState(() {
                    if (val == true) {
                      selectedCategoryIds.add(cat.id);
                    } else {
                      if (selectedCategoryIds.length > 1) {
                        selectedCategoryIds.remove(cat.id);
                      } else {
                        Get.snackbar(
                          "Validation Error",
                          "At least one category must be selected.",
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
        _dialogField(
          "Description",
          descCtrl,
          maxLines: 3,
          hintText: "e.g., Grand entry decor featuring golden arches and premium lilies...",
          prefixIcon: Icon(Icons.description_outlined, color: primaryAccent.withValues(alpha: 0.4), size: 18),
        ),
        Row(
          children: [
            Expanded(
              child: _dialogField(
                "Price (INR) *",
                priceCtrl,
                keyboardType: TextInputType.number,
                hintText: "e.g., 25000",
                prefixIcon: Icon(Icons.currency_rupee, color: primaryAccent.withValues(alpha: 0.4), size: 18),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _dialogField(
                "Offer Price (Discounted)",
                offerCtrl,
                keyboardType: TextInputType.number,
                hintText: "e.g., 19999",
                prefixIcon: Icon(Icons.discount_outlined, color: primaryAccent.withValues(alpha: 0.4), size: 18),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _dialogField(
                "Duration (Hours)",
                durCtrl,
                keyboardType: TextInputType.number,
                hintText: "e.g., 4",
                prefixIcon: Icon(Icons.timer_outlined, color: primaryAccent.withValues(alpha: 0.4), size: 18),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "AVAILABILITY",
                      style: AppTheme.sansBody(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: primaryAccent,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: availability,
                      style: AppTheme.sansBody(fontSize: 14, color: textColor),
                      dropdownColor: cardColor,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: inputFillColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: borderColor, width: 1.2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: borderColor, width: 1.2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: primaryAccent, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'available',
                          child: Text("Available"),
                        ),
                        DropdownMenuItem(
                          value: 'unavailable',
                          child: Text("Unavailable"),
                        ),
                        DropdownMenuItem(value: 'booked', child: Text("Booked")),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          updateState(() {
                            availability = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        _dialogField(
          "Tags (comma-separated)",
          tagsCtrl,
          hintText: "e.g., gold, royal, stage",
          prefixIcon: Icon(Icons.tag, color: primaryAccent.withValues(alpha: 0.4), size: 18),
        ),
        Row(
          children: [
            Expanded(
              child: _dialogField(
                "Colors (comma-separated)",
                colorsCtrl,
                hintText: "e.g., #D4AF37, #FAF6EE",
                prefixIcon: Icon(Icons.palette_outlined, color: primaryAccent.withValues(alpha: 0.4), size: 18),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _dialogField(
                "Themes (comma-separated)",
                themesCtrl,
                hintText: "e.g., Floral, Regal",
                prefixIcon: Icon(Icons.auto_awesome_outlined, color: primaryAccent.withValues(alpha: 0.4), size: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
