import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';

class ExperienceCustomizationPanel extends StatelessWidget {
  final dynamic item;
  final String selectedColor;
  final String selectedTheme;
  final TextEditingController notesController;
  final ValueChanged<String?> onColorChanged;
  final ValueChanged<String?> onThemeChanged;
  final bool isDesktop;
  final Color goldColor;
  final Color inputBgColor;

  const ExperienceCustomizationPanel({
    super.key,
    required this.item,
    required this.selectedColor,
    required this.selectedTheme,
    required this.notesController,
    required this.onColorChanged,
    required this.onThemeChanged,
    required this.isDesktop,
    required this.goldColor,
    required this.inputBgColor,
  });

  Widget _buildCustomDropdown({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.sansBody(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          decoration: BoxDecoration(
            color: inputBgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: goldColor.withValues(alpha: 0.25),
              width: 1.0,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: options.contains(value) ? value : options.firstOrNull,
              dropdownColor: const Color(0xFF121D18),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: goldColor,
                size: 18,
              ),
              style: AppTheme.sansBody(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              items:
                  options.map((opt) {
                    return DropdownMenuItem(value: opt, child: Text(opt));
                  }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = item.colors as List<String>;
    final themes = item.themes as List<String>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (colors.isNotEmpty || themes.isNotEmpty) ...[
          if (isDesktop && colors.isNotEmpty && themes.isNotEmpty)
            Row(
              children: [
                Expanded(
                  child: _buildCustomDropdown(
                    label: "Color Story",
                    value: selectedColor,
                    options: colors,
                    onChanged: onColorChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCustomDropdown(
                    label: "Design Mood / Theme",
                    value: selectedTheme,
                    options: themes,
                    onChanged: onThemeChanged,
                  ),
                ),
              ],
            )
          else ...[
            if (colors.isNotEmpty)
              _buildCustomDropdown(
                label: "Color Story",
                value: selectedColor,
                options: colors,
                onChanged: onColorChanged,
              ),
            if (themes.isNotEmpty) ...[
              const SizedBox(height: 10),
              _buildCustomDropdown(
                label: "Design Mood / Theme",
                value: selectedTheme,
                options: themes,
                onChanged: onThemeChanged,
              ),
            ],
          ],
          const SizedBox(height: 12),
        ],
        Text(
          "Your Note",
          style: AppTheme.sansBody(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: inputBgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: goldColor.withValues(alpha: 0.25),
              width: 1.0,
            ),
          ),
          child: TextField(
            controller: notesController,
            maxLines: 2,
            cursorColor: goldColor,
            style: AppTheme.sansBody(fontSize: 11.5, color: Colors.white),
            decoration: InputDecoration.collapsed(
              hintText: "Tell us about any specific details or ideas...",
              hintStyle: AppTheme.sansBody(fontSize: 11, color: Colors.white38),
            ),
          ),
        ),
      ],
    );
  }
}
