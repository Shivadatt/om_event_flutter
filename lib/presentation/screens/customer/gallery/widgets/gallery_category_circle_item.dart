import 'package:flutter/material.dart';
import '../../../../../../core/config/app_theme.dart';
import '../../../../../../core/widgets/app_image.dart';

class GalleryCategoryCircleItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? imageUrl;
  final bool isAll;
  final Color goldColor;

  const GalleryCategoryCircleItem({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.imageUrl,
    this.isAll = false,
    required this.goldColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(36),
        hoverColor: Colors.transparent,
        splashColor: goldColor.withValues(alpha: 0.15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 58,
              height: 58,
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected
                          ? goldColor
                          : goldColor.withValues(alpha: 0.3),
                  width: isSelected ? 2.0 : 1.0,
                ),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: goldColor.withValues(alpha: 0.45),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ]
                        : [
                          const BoxShadow(
                            color: Colors.black38,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
              ),
              child: ClipOval(
                child:
                    isAll
                        ? Container(
                          color:
                              isSelected
                                  ? const Color(0xFF152621)
                                  : const Color(0xFF0F1B18),
                          child: Center(
                            child: Icon(
                              Icons.grid_view_rounded,
                              size: 22,
                              color: isSelected ? goldColor : Colors.white70,
                            ),
                          ),
                        )
                        : (imageUrl != null && imageUrl!.isNotEmpty)
                        ? Stack(
                          fit: StackFit.expand,
                          children: [
                            AppImage(url: imageUrl!, fit: BoxFit.cover),
                            Container(
                              color:
                                  isSelected
                                      ? goldColor.withValues(alpha: 0.15)
                                      : Colors.black.withValues(alpha: 0.25),
                            ),
                          ],
                        )
                        : Container(
                          color: const Color(0xFF152621),
                          child: Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 20,
                              color:
                                  isSelected
                                      ? goldColor
                                      : goldColor.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 7),
            SizedBox(
              width: 72,
              height: 28,
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.sansBody(
                    fontSize: isSelected ? 10.5 : 10.0,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? goldColor : Colors.white70,
                    letterSpacing: 0.2,
                    height: 1.15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
