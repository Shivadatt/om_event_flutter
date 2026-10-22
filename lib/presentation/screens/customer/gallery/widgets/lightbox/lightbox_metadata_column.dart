import 'package:flutter/material.dart';
import '../../../../../../core/config/app_theme.dart';
import '../../../../../../domain/entities/experience.dart';
import '../../../../../../domain/entities/gallery_item.dart';

class LightboxMetadataColumn extends StatelessWidget {
  final GalleryItem item;
  final Experience? matchedExp;
  final Color goldColor;

  const LightboxMetadataColumn({
    super.key,
    required this.item,
    required this.matchedExp,
    required this.goldColor,
  });

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final m = months[dt.month - 1];
    return '${dt.day} $m ${dt.year}';
  }

  Widget _buildMetadataRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 15, color: goldColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTheme.sansBody(
              fontSize: 11.5,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeText =
        (matchedExp != null && matchedExp!.themes.isNotEmpty)
            ? matchedExp!.themes.first
            : (item.title.isNotEmpty ? item.title : 'Premium Green & Gold');
    final dateStr = _formatDate(item.createdAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMetadataRow(
          icon: Icons.location_on_outlined,
          text: "Ahmedabad, Gujarat",
        ),
        const SizedBox(height: 6),
        _buildMetadataRow(
          icon: Icons.calendar_today_outlined,
          text: "Event Date: $dateStr",
        ),
        const SizedBox(height: 6),
        _buildMetadataRow(icon: Icons.groups_outlined, text: "Guests: 150+"),
        const SizedBox(height: 6),
        _buildMetadataRow(
          icon: Icons.diamond_outlined,
          text: "Theme: $themeText",
        ),
      ],
    );
  }
}
