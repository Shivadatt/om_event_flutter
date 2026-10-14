import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/auth_controller.dart';
import 'widgets/add_admin_dialog.dart';
import 'widgets/admin_back_button.dart';
import 'widgets/admin_layout.dart';
import 'widgets/admin_role_card.dart';
import 'widgets/luxury_gold_waves_painter.dart';

/// Screen managing role access, status, and permissions for the administrator team
/// redesigned to match Option 4 — Premium Detailed Style.
class ManageAdminRolesScreen extends StatefulWidget {
  /// Creates a [ManageAdminRolesScreen] instance.
  const ManageAdminRolesScreen({super.key});

  @override
  State<ManageAdminRolesScreen> createState() => _ManageAdminRolesScreenState();
}

class _ManageAdminRolesScreenState extends State<ManageAdminRolesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final RxString _rxSearchQuery = ''.obs;

  static const Color _goldColor = Color(0xFFD4AF37);
  static const Color _cardBg = Color(0xFF0F1B16);

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      _rxSearchQuery.value = _searchCtrl.text.toLowerCase().trim();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();
    final authController = Get.find<AuthController>();
    final bool isInsideDrawer = AdminLayoutScope.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── 1. Luxury Gold Waves Atmospheric Background ──────────────
          const Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: LuxuryGoldWavesPainter(),
              ),
            ),
          ),

          // ── 2. Screen Content ─────────────────────────────────────────
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 24,
                vertical: isMobile ? 12 : 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top Header Row ──────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (!isInsideDrawer) ...[
                        const AdminBackButton(),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        "ADMIN MANAGEMENT",
                        style: GoogleFonts.dmSans(
                          fontSize: isMobile ? 12.5 : 13.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 2.2,
                        ),
                      ),
                      const Spacer(),

                      // Add Admin Icon / Button (compact gold shield + button matching reference)
                      Obx(() {
                        final isSuper = authController.rxAdminRole.value?.roleType == 'super_admin';
                        if (!isSuper) return const SizedBox();

                        return Tooltip(
                          message: "Add New Admin",
                          child: InkWell(
                            onTap: () => Get.dialog(
                              AddAdminDialog(controller: controller),
                            ),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: const Color(0xFF13221C),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _goldColor.withValues(alpha: 0.65),
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _goldColor.withValues(alpha: 0.22),
                                    blurRadius: 8,
                                    spreadRadius: 0.5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.center,
                                  children: [
                                    const Icon(
                                      Icons.shield,
                                      size: 19,
                                      color: _goldColor,
                                    ),
                                    Positioned(
                                      right: -2,
                                      bottom: -2,
                                      child: Container(
                                        padding: const EdgeInsets.all(1),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF13221C),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.add,
                                          size: 9.5,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Search Field Toolbar ─────────────────────────────
                  Container(
                    width: double.infinity,
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF09120E),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _goldColor.withValues(alpha: 0.4),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          size: 19,
                          color: _goldColor.withValues(alpha: 0.85),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                            cursorColor: _goldColor,
                            decoration: InputDecoration(
                              isDense: true,
                              filled: false,
                              fillColor: Colors.transparent,
                              hintText: "Search admin name or email...",
                              hintStyle: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: Colors.white38,
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        Obx(() {
                          if (_rxSearchQuery.value.isEmpty) {
                            return const SizedBox();
                          }
                          return InkWell(
                            onTap: () {
                              _searchCtrl.clear();
                              _rxSearchQuery.value = '';
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: Colors.white54,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Admin Cards List ─────────────────────────────────
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoadingAdminRoles.value) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(_goldColor),
                          ),
                        );
                      }

                      var list = controller.rxAdminRoles.toList();
                      final query = _rxSearchQuery.value;
                      if (query.isNotEmpty) {
                        list = list
                            .where(
                              (a) =>
                                  a.name.toLowerCase().contains(query) ||
                                  a.email.toLowerCase().contains(query),
                            )
                            .toList();
                      }

                      if (list.isEmpty) {
                        return Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 20,
                            ),
                            decoration: BoxDecoration(
                              color: _cardBg.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _goldColor.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  size: 38,
                                  color: _goldColor.withValues(alpha: 0.4),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  query.isEmpty
                                      ? "No administrator profiles found."
                                      : "No matching admins for \"$query\"",
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    color: Colors.white60,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final currentAdmin = authController.rxAdminRole.value;
                      final isSuper = currentAdmin?.roleType == 'super_admin';

                      return ListView.builder(
                        itemCount: list.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final admin = list[index];
                          return AdminRoleCard(
                            admin: admin,
                            isSuper: isSuper,
                            currentAdmin: currentAdmin,
                            controller: controller,
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

