import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../domain/entities/admin_role.dart';

/// Card component displaying profile overview, completion, avatar, and metrics inside ProfileScreen.
class ProfileHeroCard extends StatelessWidget {
  /// The active admin role profile.
  final AdminRole admin;

  /// Whether the logged-in administrator is a super admin.
  final bool isSuperAdmin;

  /// Whether a photo upload operation is currently in progress.
  final bool isUploadingPhoto;

  /// Callback action to show photo options sheet.
  final VoidCallback onShowPhotoOptions;

  /// Creates a [ProfileHeroCard] widget instance.
  const ProfileHeroCard({
    super.key,
    required this.admin,
    required this.isSuperAdmin,
    required this.isUploadingPhoto,
    required this.onShowPhotoOptions,
  });

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Unknown';
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
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  int _calcCompletion(AdminRole admin) {
    int s = 0;
    if (admin.name.isNotEmpty) s++;
    if (admin.email.isNotEmpty) s++;
    if (admin.phone.isNotEmpty) s++;
    if (admin.designation.isNotEmpty) s++;
    if (admin.bio.isNotEmpty) s++;
    if (admin.address.isNotEmpty) s++;
    if (admin.photoUrl.isNotEmpty) s++;
    return ((s / 7) * 100).round();
  }

  TextStyle _label({
    Color color = const Color(0xFFC8A26A),
    double size = 11,
    double spacing = 0.5,
  }) {
    return GoogleFonts.dmSans(
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: spacing,
    );
  }

  TextStyle _muted({double size = 12}) {
    return GoogleFonts.dmSans(fontSize: size, color: const Color(0xFF7A8F85));
  }

  TextStyle _body({double size = 13}) {
    return GoogleFonts.dmSans(
      fontSize: size,
      color: const Color(0xFFF0F0EE),
      fontWeight: FontWeight.w500,
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF162822),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF254235)),
      ),
      child: child,
    );
  }

  Widget _avatarFallback(String name) {
    return Container(
      color: const Color(0xFF0D1915),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'A',
          style: AppTheme.serifHeader(
            fontSize: 44,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFC8A26A),
          ),
        ),
      ),
    );
  }

  Widget _roleBadge(AdminRole admin) {
    final isSuper = admin.roleType == 'super_admin';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color:
            isSuper
                ? const Color(0xFFC8A26A).withValues(alpha: 0.12)
                : const Color(0xFF254235).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isSuper
                  ? const Color(0xFFC8A26A).withValues(alpha: 0.35)
                  : const Color(0xFF254235),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSuper
                ? Icons.verified_rounded
                : Icons.admin_panel_settings_outlined,
            size: 13,
            color: isSuper ? const Color(0xFFC8A26A) : const Color(0xFF7A9B8A),
          ),
          const SizedBox(width: 6),
          Text(
            admin.roleType.replaceAll('_', ' ').toUpperCase(),
            style: _label(
              color:
                  isSuper ? const Color(0xFFC8A26A) : const Color(0xFF7A9B8A),
              size: 10,
              spacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _completionMeter(int completion) {
    final meterColor =
        completion >= 80
            ? const Color(0xFF3BA776)
            : completion >= 50
            ? const Color(0xFFC8A26A)
            : Colors.redAccent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PROFILE COMPLETION',
              style: _label(
                color: const Color(0xFFA4A9A7),
                size: 9,
                spacing: 1.5,
              ),
            ),
            Text(
              '$completion%',
              style: _label(color: Colors.white, size: 9, spacing: 1.5),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: completion / 100,
            backgroundColor: const Color(0xFF1E3028),
            valueColor: AlwaysStoppedAnimation<Color>(meterColor),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          completion >= 80
              ? 'Great! Your profile is almost complete.'
              : 'Fill more details to complete your profile.',
          style: _muted(size: 11),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF4A7060)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: _label(size: 10, color: const Color(0xFF7A8F85)),
              ),
              const SizedBox(height: 2),
              Text(value, style: _body(size: 13)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final completion = _calcCompletion(admin);
    final photoUrl = admin.photoUrl;

    return _card(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFC8A26A),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC8A26A).withValues(alpha: 0.15),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: ClipOval(
                  child:
                      isUploadingPhoto
                          ? Container(
                            color: const Color(0xFF0D1915),
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                  Color(0xFFC8A26A),
                                ),
                                strokeWidth: 2.5,
                              ),
                            ),
                          )
                          : photoUrl.isNotEmpty
                          ? Image.network(
                            photoUrl,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => _avatarFallback(admin.name),
                          )
                          : _avatarFallback(admin.name),
                ),
              ),
              if (isSuperAdmin)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: isUploadingPhoto ? null : onShowPhotoOptions,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC8A26A),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF0B1714),
                          width: 2.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Color(0xFF0B1714),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            admin.name.isNotEmpty ? admin.name : 'Administrator',
            style: AppTheme.serifHeader(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFF0F0EE),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          if (admin.designation.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                admin.designation,
                style: _muted(size: 13),
                textAlign: TextAlign.center,
              ),
            ),
          _roleBadge(admin),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFF1E3028), height: 1),
          const SizedBox(height: 20),
          _infoRow(Icons.email_outlined, 'Email', admin.email),
          if (admin.phone.isNotEmpty) ...[
            const SizedBox(height: 12),
            _infoRow(Icons.phone_outlined, 'Phone', admin.phone),
          ],
          const SizedBox(height: 12),
          _infoRow(
            Icons.calendar_today_outlined,
            'Member Since',
            _formatDate(admin.createdAt),
          ),
          if (admin.lastLogin != null) ...[
            const SizedBox(height: 12),
            _infoRow(
              Icons.access_time_rounded,
              'Last Login',
              _formatDate(admin.lastLogin),
            ),
          ],
          const SizedBox(height: 24),
          _completionMeter(completion),
        ],
      ),
    );
  }
}
