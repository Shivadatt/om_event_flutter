part of '../experience_form_dialog.dart';

extension _ExperienceFormFields on _ExperienceFormDialogState {
  Widget _buildInformationColumn(BuildContext context, {required bool isWide}) {
    const Color labelGold = Color(0xFFD4AF37);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Name & Slug Row
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _dialogField(
                  "Experience Name *",
                  nameCtrl,
                  hintText: "e.g., Birthday Celebration",
                  prefixIcon: const Icon(Icons.celebration_outlined, color: labelGold, size: 16),
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
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _dialogField(
                  "Slug / URL Handle *",
                  slugCtrl,
                  enabled: !isEdit,
                  hintText: "e.g., birthday-celebration",
                  prefixIcon: const Icon(Icons.link, color: labelGold, size: 16),
                ),
              ),
            ],
          )
        else ...[
          _dialogField(
            "Experience Name *",
            nameCtrl,
            hintText: "e.g., Birthday Celebration",
            prefixIcon: const Icon(Icons.celebration_outlined, color: labelGold, size: 16),
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
            hintText: "e.g., birthday-celebration",
            prefixIcon: const Icon(Icons.link, color: labelGold, size: 16),
          ),
        ],

        // Brand Categories
        Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 8),
          child: Text(
            "SELECT BRAND CATEGORIES *",
            style: AppTheme.sansBody(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: labelGold,
              letterSpacing: 0.8,
            ),
          ),
        ),
        _buildCategoryChips(),
        const SizedBox(height: 16),

        // Description
        _dialogField(
          "Description",
          descCtrl,
          maxLines: 3,
          hintText: "Private candle aisle, illuminated letters, florals and a sparkling reveal moment.",
          prefixIcon: const Padding(
            padding: EdgeInsets.only(bottom: 28),
            child: Icon(Icons.notes_outlined, color: labelGold, size: 16),
          ),
        ),

        // Pricing & Availability Row
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _dialogField(
                  "Price (INR) *",
                  priceCtrl,
                  keyboardType: TextInputType.number,
                  hintText: "e.g. 4999",
                  prefixIcon: const Icon(Icons.currency_rupee, color: labelGold, size: 16),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _dialogField(
                  "Offer Price (Discounted)",
                  offerCtrl,
                  keyboardType: TextInputType.number,
                  hintText: "e.g. 2950",
                  prefixIcon: const Icon(Icons.local_offer_outlined, color: labelGold, size: 16),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _dialogField(
                  "Duration (Hours)",
                  durCtrl,
                  keyboardType: TextInputType.number,
                  hintText: "e.g. 3",
                  prefixIcon: const Icon(Icons.timer_outlined, color: labelGold, size: 16),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildAvailabilityDropdown(),
              ),
            ],
          )
        else ...[
          Row(
            children: [
              Expanded(
                child: _dialogField(
                  "Price (INR) *",
                  priceCtrl,
                  keyboardType: TextInputType.number,
                  hintText: "e.g. 4999",
                  prefixIcon: const Icon(Icons.currency_rupee, color: labelGold, size: 16),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _dialogField(
                  "Offer Price (Discounted)",
                  offerCtrl,
                  keyboardType: TextInputType.number,
                  hintText: "e.g. 2950",
                  prefixIcon: const Icon(Icons.local_offer_outlined, color: labelGold, size: 16),
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
                  hintText: "e.g. 3",
                  prefixIcon: const Icon(Icons.timer_outlined, color: labelGold, size: 16),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildAvailabilityDropdown(),
              ),
            ],
          ),
        ],

        // Metadata: Tags / Colors / Themes
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _dialogField(
                  "Tags (comma-separated)",
                  tagsCtrl,
                  hintText: "proposal, premium, customizable",
                  prefixIcon: const Icon(Icons.tag, color: labelGold, size: 16),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _dialogField(
                  "Colors (comma-separated)",
                  colorsCtrl,
                  hintText: "Red, White, Gold",
                  prefixIcon: const Icon(Icons.palette_outlined, color: labelGold, size: 16),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _dialogField(
                  "Themes (comma-separated)",
                  themesCtrl,
                  hintText: "Romantic, Candlelight, Premium",
                  prefixIcon: const Icon(Icons.auto_awesome_outlined, color: labelGold, size: 16),
                ),
              ),
            ],
          )
        else ...[
          _dialogField(
            "Tags (comma-separated)",
            tagsCtrl,
            hintText: "proposal, premium, customizable",
            prefixIcon: const Icon(Icons.tag, color: labelGold, size: 16),
          ),
          Row(
            children: [
              Expanded(
                child: _dialogField(
                  "Colors (comma-separated)",
                  colorsCtrl,
                  hintText: "Red, White, Gold",
                  prefixIcon: const Icon(Icons.palette_outlined, color: labelGold, size: 16),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _dialogField(
                  "Themes (comma-separated)",
                  themesCtrl,
                  hintText: "Romantic, Candlelight, Premium",
                  prefixIcon: const Icon(Icons.auto_awesome_outlined, color: labelGold, size: 16),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryChips() {
    final categories = widget.controller.rxCategories;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        final isSelected = selectedCategoryIds.contains(cat.id);
        return InkWell(
          onTap: () {
            updateState(() {
              if (isSelected) {
                if (selectedCategoryIds.length > 1) {
                  selectedCategoryIds.remove(cat.id);
                } else {
                  Get.snackbar(
                    "Validation Error",
                    "At least one category must be selected.",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.black87,
                    colorText: Colors.white,
                  );
                }
              } else {
                selectedCategoryIds.add(cat.id);
              }
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF242217) : const Color(0xFF131D18),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF24352B),
                width: isSelected ? 1.4 : 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                  size: 15,
                  color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF6B7A72),
                ),
                const SizedBox(width: 6),
                Text(
                  cat.name,
                  style: AppTheme.sansBody(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? const Color(0xFFF5EEDB) : const Color(0xFF9EABA3),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAvailabilityDropdown() {
    const Color labelGold = Color(0xFFD4AF37);
    const Color inputFillColor = Color(0xFF131D18);
    const Color borderColor = Color(0xFF223228);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "AVAILABILITY",
            style: AppTheme.sansBody(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: labelGold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: availability,
            style: AppTheme.sansBody(fontSize: 13, color: Colors.white),
            dropdownColor: const Color(0xFF0E1612),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: labelGold, size: 18),
            decoration: InputDecoration(
              filled: true,
              fillColor: inputFillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: borderColor, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: borderColor, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: labelGold, width: 1.4),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
              DropdownMenuItem(
                value: 'booked',
                child: Text("Booked"),
              ),
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
    );
  }

  Widget _dialogField(
    String label,
    TextEditingController ctrl, {
    int maxLines = 1,
    bool enabled = true,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
    String? hintText,
    Widget? prefixIcon,
  }) {
    const Color labelGold = Color(0xFFD4AF37);
    const Color inputFillColor = Color(0xFF131D18);
    const Color borderColor = Color(0xFF223228);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTheme.sansBody(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: labelGold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            maxLines: maxLines,
            enabled: enabled,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: AppTheme.sansBody(
              fontSize: 13,
              color: enabled ? Colors.white : Colors.white60,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: enabled ? inputFillColor : inputFillColor.withValues(alpha: 0.5),
              hintText: hintText,
              hintStyle: AppTheme.sansBody(
                fontSize: 12,
                color: const Color(0xFF5A6961),
              ),
              prefixIcon: prefixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: borderColor, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: borderColor, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: labelGold, width: 1.4),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: borderColor.withValues(alpha: 0.5), width: 1.0),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
