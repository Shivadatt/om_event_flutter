import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/package_option.dart';

class ExperiencePackageTierSelector extends StatelessWidget {
  final dynamic item;
  final PackageOption? currentPkg;
  final ValueChanged<PackageOption> onSelectPackage;
  final Color goldColor;

  const ExperiencePackageTierSelector({
    super.key,
    required this.item,
    required this.currentPkg,
    required this.onSelectPackage,
    required this.goldColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "CHOOSE PACKAGE TIER",
          style: AppTheme.sansBody(
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.4,
            color: goldColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children:
              (item.dynamicPackages as List<PackageOption>).map<Widget>((pkg) {
                final isSelected = currentPkg?.id == pkg.id;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => onSelectPackage(pkg),
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? goldColor
                                  : const Color(0xFF0F1814),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color:
                                isSelected
                                    ? goldColor
                                    : goldColor.withValues(alpha: 0.25),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: goldColor.withValues(alpha: 0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              pkg.tier.toUpperCase(),
                              style: AppTheme.sansBody(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected
                                        ? const Color(0xFF09120E)
                                        : Colors.white60,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              AppFormatters.formatCurrency(pkg.effectivePrice),
                              style: AppTheme.sansBody(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected
                                        ? const Color(0xFF09120E)
                                        : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
        const SizedBox(height: 12),
        if (currentPkg != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1410),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: goldColor.withValues(alpha: 0.2),
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${currentPkg!.name} Included Features:",
                  style: AppTheme.sansBody(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: goldColor,
                  ),
                ),
                const SizedBox(height: 6),
                ...currentPkg!.features.map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_rounded, color: goldColor, size: 13),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            f,
                            style: AppTheme.sansBody(
                              fontSize: 11,
                              color: Colors.white70,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
