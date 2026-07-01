import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../domain/entities/admin_role.dart';

/// Card component to display read-only account details and privileges inside ProfileScreen.
class ProfileSecurityCard extends StatelessWidget {
  /// The active admin role profile.
  final AdminRole admin;

  /// Creates a [ProfileSecurityCard] widget instance.
  const ProfileSecurityCard({super.key, required this.admin});

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  TextStyle _label({
    Color color = const Color(0xFFA4A9A7),
    double size = 9,
    double spacing = 1.5,
  }) {
    return GoogleFonts.dmSans(
      fontSize: size,
      fontWeight: FontWeight.bold,
      color: color,
      letterSpacing: spacing,
    );
  }

  TextStyle _muted({double size = 12}) {
    return GoogleFonts.dmSans(fontSize: size, color: const Color(0xFFA4A9A7));
  }

  TextStyle _body({double size = 13}) {
    return GoogleFonts.dmSans(fontSize: size, color: Colors.white);
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFC8A26A)),
        const SizedBox(width: 10),
        Text(title, style: _label(color: const Color(0xFFC8A26A), size: 10)),
      ],
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

  Widget _secRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: _muted()),
          Text(value, style: _body(size: 12).copyWith(color: valueColor)),
        ],
      ),
    );
  }

  Widget _permChip(String label, {bool isSuper = false}) {
    final text = label.replaceAll('can_', '').replaceAll('_', ' ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color:
            isSuper
                ? const Color(0xFFC8A26A).withValues(alpha: 0.1)
                : const Color(0xFF0D2218),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color:
              isSuper
                  ? const Color(0xFFC8A26A).withValues(alpha: 0.3)
                  : const Color(0xFF1B3828),
        ),
      ),
      child: Text(
        text,
        style: _label(
          color: isSuper ? const Color(0xFFC8A26A) : const Color(0xFF5A9070),
          size: 10,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('ACCOUNT DETAILS', Icons.info_outline_rounded),
          const SizedBox(height: 20),
          _secRow(
            'UID',
            admin.uid.length > 12
                ? '${admin.uid.substring(0, 12)}...'
                : admin.uid,
          ),
          const Divider(color: Color(0xFF1A2E25), height: 1),
          _secRow(
            'Role Type',
            admin.roleType.replaceAll('_', ' ').toUpperCase(),
          ),
          const Divider(color: Color(0xFF1A2E25), height: 1),
          _secRow(
            'Status',
            admin.isActive ? 'Active' : 'Disabled',
            valueColor:
                admin.isActive ? const Color(0xFF3BA776) : Colors.redAccent,
          ),
          const Divider(color: Color(0xFF1A2E25), height: 1),
          _secRow('Created', _formatDate(admin.createdAt)),
          if (admin.lastLogin != null) ...[
            const Divider(color: Color(0xFF1A2E25), height: 1),
            _secRow('Last Login', _formatDate(admin.lastLogin!)),
          ],
          const SizedBox(height: 20),
          Text('PERMISSIONS', style: _label()),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (admin.roleType == 'super_admin')
                _permChip('All Permissions', isSuper: true)
              else
                ...admin.permissions.entries
                    .where((e) => e.value)
                    .map((e) => _permChip(e.key)),
            ],
          ),
        ],
      ),
    );
  }
}
