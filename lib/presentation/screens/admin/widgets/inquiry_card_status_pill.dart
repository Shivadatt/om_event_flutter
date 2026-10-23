import 'package:flutter/material.dart';
import '../../../../domain/entities/lead.dart';

class InquiryCardStatusPill extends StatelessWidget {
  final Lead lead;
  final ValueChanged<String> onStatusChanged;
  static const Color goldColor = Color(0xFFECC24A);

  const InquiryCardStatusPill({
    super.key,
    required this.lead,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final s = lead.status.toLowerCase();
    Color bg;
    Color border;
    Color textCol;

    switch (s) {
      case 'new':
        bg = const Color(0xFF142B20);
        border = const Color(0xFF2E6B4A);
        textCol = const Color(0xFF6EDC98);
        break;
      case 'contacted':
        bg = const Color(0xFF192520);
        border = Colors.white24;
        textCol = Colors.white;
        break;
      case 'qualified':
        bg = const Color(0xFF232014);
        border = goldColor.withValues(alpha: 0.4);
        textCol = goldColor;
        break;
      case 'won':
        bg = const Color(0xFF142B20);
        border = const Color(0xFF4EBA7A);
        textCol = const Color(0xFF4EBA7A);
        break;
      case 'closed':
      default:
        bg = const Color(0xFF161616);
        border = Colors.white12;
        textCol = Colors.white54;
        break;
    }

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border, width: 0.8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: lead.status,
          dropdownColor: const Color(0xFF0C1914),
          icon: Icon(Icons.arrow_drop_down_rounded, color: textCol, size: 16),
          style: TextStyle(
            fontSize: 10.0,
            fontWeight: FontWeight.bold,
            color: textCol,
          ),
          items: const [
            DropdownMenuItem(value: 'new', child: Text("New")),
            DropdownMenuItem(value: 'contacted', child: Text("Contacted")),
            DropdownMenuItem(value: 'qualified', child: Text("Qualified")),
            DropdownMenuItem(value: 'won', child: Text("Won")),
            DropdownMenuItem(value: 'closed', child: Text("Closed")),
          ],
          onChanged: (val) {
            if (val != null) {
              onStatusChanged(val);
            }
          },
        ),
      ),
    );
  }
}
