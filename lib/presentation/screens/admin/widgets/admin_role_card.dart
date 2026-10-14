import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/admin_role.dart';
import '../../../controllers/admin_controller.dart';

/// Card component to render and configure individual [AdminRole] profiles.
/// Redesigned to match Option 4 — Premium Detailed Style:
/// - Compact dark black/emerald background with subtle gold wave contours
/// - Glowing circular gold avatar with prominent bold initial
/// - Crisp role and active badges
/// - Gold active-toggle and square rounded action buttons (Shield & Red Delete)
/// - Fully responsive for Desktop, Tablet, and Mobile
class AdminRoleCard extends StatelessWidget {
  final AdminRole admin;
  final bool isSuper;
  final AdminRole? currentAdmin;
  final AdminController controller;

  const AdminRoleCard({
    super.key,
    required this.admin,
    required this.isSuper,
    required this.currentAdmin,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isAdminSuper = admin.roleType == 'super_admin';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1612),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.38),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          children: [
            // Subtle flowing golden wave contours in the bottom right
            Positioned.fill(
              child: CustomPaint(
                painter: const _CardGoldWavesPainter(),
              ),
            ),

            // Foreground Card Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: LayoutBuilder(builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 560;

                if (isCompact) {
                  return _buildCompactMobileLayout(context, isAdminSuper);
                }

                return _buildDesktopLayout(context, isAdminSuper);
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── Desktop / Tablet Horizontal Layout ──────────────────────────────────────
  Widget _buildDesktopLayout(BuildContext context, bool isAdminSuper) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Left: Glowing Circular Gold Avatar (compact 44px)
        _buildAvatar(size: 44),
        const SizedBox(width: 14),

        // 2. Middle: Name, Email, Role & Active Badges
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                admin.name.isNotEmpty ? admin.name : 'Administrator',
                style: GoogleFonts.dmSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                admin.email,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: const Color(0xFF8E9E96),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildRoleBadge(isAdminSuper),
                  const SizedBox(width: 6),
                  _buildStatusBadge(),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 14),

        // 3. Right: Active Status Toggle & Action Buttons
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Active Switch Row
            _buildActiveSwitchRow(),
            const SizedBox(height: 6),
            // Action Buttons (Shield & Delete)
            _buildActionButtons(context, isAdminSuper),
          ],
        ),
      ],
    );
  }

  // ── Compact Mobile Layout (< 560px) ─────────────────────────────────────────
  Widget _buildCompactMobileLayout(BuildContext context, bool isAdminSuper) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAvatar(size: 40),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    admin.name.isNotEmpty ? admin.name : 'Administrator',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    admin.email,
                    style: GoogleFonts.dmSans(
                      fontSize: 10.5,
                      color: const Color(0xFF8E9E96),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _buildRoleBadge(isAdminSuper),
                _buildStatusBadge(),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActiveSwitchRow(),
                const SizedBox(width: 6),
                _buildActionButtons(context, isAdminSuper),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ── Circular Gold Avatar ───────────────────────────────────────────────────
  Widget _buildAvatar({double size = 44}) {
    final initial = admin.name.isNotEmpty ? admin.name[0].toUpperCase() : 'A';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF070E0B),
        border: Border.all(
          color: const Color(0xFFE2B755),
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.dmSans(
            fontSize: size * 0.44,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ── Role Badge ─────────────────────────────────────────────────────────────
  Widget _buildRoleBadge(bool isAdminSuper) {
    if (isAdminSuper) {
      // Crimson / Burgundy pill for SUPER ADMIN matching reference
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
        decoration: BoxDecoration(
          color: const Color(0xFF8B2522),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
            width: 0.8,
          ),
        ),
        child: Text(
          "SUPER ADMIN",
          style: GoogleFonts.dmSans(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.8,
          ),
        ),
      );
    }

    // Gold / Champagne pill for DEMO ADMIN or other roles matching reference
    final label = admin.roleType == 'demo_admin'
        ? "DEMO ADMIN"
        : admin.roleType.replaceAll('_', ' ').toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
      decoration: BoxDecoration(
        color: const Color(0xFFE2B755),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF08110E),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // ── Status Badge ───────────────────────────────────────────────────────────
  Widget _buildStatusBadge() {
    if (admin.isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
        decoration: BoxDecoration(
          color: const Color(0xFF0D281B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF34C759).withValues(alpha: 0.35),
            width: 0.8,
          ),
        ),
        child: Text(
          "ACTIVE",
          style: GoogleFonts.dmSans(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF34C759),
            letterSpacing: 0.8,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: const Color(0xFF2E1212),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.redAccent.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: Text(
        "INACTIVE",
        style: GoogleFonts.dmSans(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: const Color(0xFFFF5252),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // ── Active Switch Row ──────────────────────────────────────────────────────
  Widget _buildActiveSwitchRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Active",
          style: GoogleFonts.dmSans(
            fontSize: 11,
            color: const Color(0xFFBAC5C0),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 6),
        Transform.scale(
          scale: 0.72,
          child: Switch(
            value: admin.isActive,
            activeThumbColor: const Color(0xFFF7D58B),
            activeTrackColor: const Color(0xFFB88E2C),
            inactiveThumbColor: const Color(0xFF75857F),
            inactiveTrackColor: const Color(0xFF1A2621),
            onChanged: (val) {
              if (currentAdmin?.roleType == 'demo_admin') {
                Get.snackbar(
                  "Unauthorized",
                  "Demo Admins cannot modify status.",
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }
              final updated = AdminRole(
                uid: admin.uid,
                name: admin.name,
                email: admin.email,
                role: admin.role,
                isActive: val,
                createdAt: admin.createdAt,
                updatedAt: DateTime.now(),
                createdBy: admin.createdBy,
                roleType: admin.roleType,
                permissions: admin.permissions,
              );
              controller.saveAdminRole(updated, isEdit: true);
            },
          ),
        ),
      ],
    );
  }

  // ── Action Buttons (Shield & Red Delete) ────────────────────────────────────
  Widget _buildActionButtons(BuildContext context, bool isAdminSuper) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Shield / Permissions Action Button
        Tooltip(
          message: isSuper ? "Manage Permissions" : "View Permissions",
          child: InkWell(
            onTap: () => _showPermissionsDialog(context, admin, isSuper),
            borderRadius: BorderRadius.circular(7),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF13221C),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: const Color(0xFFE2B755).withValues(alpha: 0.45),
                  width: 1.0,
                ),
              ),
              child: const Icon(
                Icons.shield_outlined,
                size: 16,
                color: Color(0xFFE2B755),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Delete Action Button (Red Destructive)
        if (isSuper)
          Tooltip(
            message: "Delete Admin",
            child: InkWell(
              onTap: () {
                if (isAdminSuper) {
                  Get.snackbar(
                    "Unauthorized",
                    "Super Admins cannot be deleted.",
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }
                _confirmDelete(context, admin.uid);
              },
              borderRadius: BorderRadius.circular(7),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF221313),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: Colors.redAccent.withValues(alpha: 0.45),
                    width: 1.0,
                  ),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  size: 16,
                  color: Color(0xFFFF5252),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, String uid) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF141E1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.primaryAccent.withValues(alpha: 0.3)),
        ),
        title: Text(
          "REMOVE ADMIN",
          style: AppTheme.serifHeader(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFF7F2EA),
          ),
        ),
        content: Text(
          "Are you sure you want to remove this administrator profile? They will immediately lose dashboard privileges.",
          style: AppTheme.sansBody(
            fontSize: 13,
            color: const Color(0xFFBAC5C0),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("CANCEL"),
            onPressed: () => Get.back(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text("DELETE"),
            onPressed: () {
              Get.back();
              controller.deleteAdminRole(uid);
            },
          ),
        ],
      ),
    );
  }

  void _showPermissionsDialog(
    BuildContext context,
    AdminRole admin,
    bool canEdit,
  ) {
    final Map<String, bool> tempPermissions = Map.from(admin.permissions);
    final permissionKeys = [
      'can_manage_categories',
      'can_manage_items',
      'can_manage_customers',
      'can_manage_users',
      'can_manage_reviews',
      'can_manage_quotes',
      'can_manage_leads',
      'can_manage_settings',
      'can_create',
      'can_edit',
      'can_delete',
    ];

    for (var key in permissionKeys) {
      tempPermissions.putIfAbsent(key, () => false);
    }

    String selectedRoleType = admin.roleType;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          final isSuperSelected = selectedRoleType == 'super_admin';
          return AlertDialog(
            backgroundColor: const Color(0xFF141E1A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: const Color(0xFFD4AF37).withValues(alpha: 0.35)),
            ),
            title: Text(
              "${admin.name.toUpperCase()} PERMISSIONS",
              style: AppTheme.serifHeader(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFE2B755),
                letterSpacing: 1.2,
              ),
            ),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (canEdit) ...[
                      DropdownButtonFormField<String>(
                        initialValue: selectedRoleType,
                        decoration: InputDecoration(
                          labelText: "Role Type",
                          labelStyle: AppTheme.sansBody(fontSize: 12, color: AppColors.darkMuted),
                          filled: true,
                          fillColor: const Color(0xFF0D1512),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.primaryAccent.withValues(alpha: 0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.primaryAccent.withValues(alpha: 0.2)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                        dropdownColor: const Color(0xFF141E1A),
                        items: const [
                          DropdownMenuItem(
                            value: 'super_admin',
                            child: Text("Super Admin (Full Access)", style: TextStyle(color: Colors.white, fontSize: 13)),
                          ),
                          DropdownMenuItem(
                            value: 'demo_admin',
                            child: Text("Demo Admin (Fine-grained)", style: TextStyle(color: Colors.white, fontSize: 13)),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              selectedRoleType = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      isSuperSelected
                          ? "Super Admins automatically hold all operational permissions."
                          : "Fine-grained permission controls for Demo Admin:",
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFFBAC5C0),
                      ),
                    ),
                    const Divider(height: 20, thickness: 0.5, color: Colors.white12),
                    ...permissionKeys.map((key) {
                      final label = key
                          .replaceAll('can_', '')
                          .replaceAll('_', ' ')
                          .toUpperCase();
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        activeColor: const Color(0xFFD4AF37),
                        checkColor: const Color(0xFF08110E),
                        title: Text(
                          label,
                          style: AppTheme.sansBody(fontSize: 12.5, color: Colors.white),
                        ),
                        value: isSuperSelected ? true : tempPermissions[key],
                        enabled: canEdit && !isSuperSelected,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              tempPermissions[key] = val;
                            });
                          }
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                child: Text(canEdit ? "CANCEL" : "CLOSE"),
                onPressed: () => Get.back(),
              ),
              if (canEdit)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAccent,
                    foregroundColor: const Color(0xFF091210),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text("SAVE CHANGES", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    final updated = AdminRole(
                      uid: admin.uid,
                      name: admin.name,
                      email: admin.email,
                      role: admin.role,
                      isActive: admin.isActive,
                      createdAt: admin.createdAt,
                      updatedAt: DateTime.now(),
                      createdBy: admin.createdBy,
                      roleType: selectedRoleType,
                      permissions: tempPermissions,
                    );
                    Get.back();
                    controller.saveAdminRole(updated, isEdit: true);
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── Subtle Flowing Golden Wave Contour Painter on Admin Cards ────────────────
class _CardGoldWavesPainter extends CustomPainter {
  const _CardGoldWavesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final w = size.width;
    final h = size.height;
    const goldColor = Color(0xFFD4AF37);

    // Draw 8 concentric flowing bezier lines along the bottom right
    const count = 8;
    for (int i = 0; i < count; i++) {
      final double progress = i / count;
      final double alpha = (0.04 + 0.14 * (1.0 - (progress - 0.5).abs() * 2))
          .clamp(0.03, 0.20);

      final paint = Paint()
        ..color = goldColor.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;

      final path = Path();
      final startX = w * (0.35 + progress * 0.15);
      final startY = h + 10.0;

      final cp1X = w * (0.55 + progress * 0.10);
      final cp1Y = h * (0.85 - progress * 0.10);

      final cp2X = w * (0.78 + progress * 0.08);
      final cp2Y = h * (0.75 - progress * 0.16);

      final endX = w * (1.02 + progress * 0.02);
      final endY = h * (0.60 - progress * 0.22);

      path.moveTo(startX, startY);
      path.cubicTo(cp1X, cp1Y, cp2X, cp2Y, endX, endY);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CardGoldWavesPainter oldDelegate) => false;
}
