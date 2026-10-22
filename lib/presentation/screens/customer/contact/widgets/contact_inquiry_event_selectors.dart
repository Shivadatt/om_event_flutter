import 'package:flutter/material.dart';
import '../../../../../core/config/app_theme.dart';

class ContactInquiryEventSelectors extends StatelessWidget {
  final String selectedEventType;
  final List<String> eventTypes;
  final ValueChanged<String?> onEventTypeChanged;
  final DateTime? selectedDate;
  final VoidCallback onSelectDate;
  final Color goldColor;

  const ContactInquiryEventSelectors({
    super.key,
    required this.selectedEventType,
    required this.eventTypes,
    required this.onEventTypeChanged,
    required this.selectedDate,
    required this.onSelectDate,
    required this.goldColor,
  });

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Text(
        text,
        style: AppTheme.sansBody(
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: goldColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel("EVENT TYPE"),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF071410),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: goldColor.withValues(alpha: 0.25)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedEventType,
              dropdownColor: const Color(0xFF0C1914),
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
              items: eventTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type, style: AppTheme.sansBody(fontSize: 12.5, color: Colors.white)),
                );
              }).toList(),
              onChanged: onEventTypeChanged,
            ),
          ),
        ),
        const SizedBox(height: 12),

        _buildFieldLabel("ESTIMATED CELEBRATION DATE"),
        InkWell(
          onTap: onSelectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF071410),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: goldColor.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_month_outlined, size: 16, color: goldColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                        : "Select estimated event date (optional)",
                    style: AppTheme.sansBody(
                      fontSize: 12.5,
                      color: selectedDate != null ? Colors.white : Colors.white38,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
