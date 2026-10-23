import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/customer_model.dart';

class ClientPortalLoginCard extends StatelessWidget {
  final CustomerModel customer;
  final bool isLoginEnabled;
  final bool isProcessing;
  final bool isMobile;
  final VoidCallback onSendInvite;
  final ValueChanged<bool> onToggleLogin;

  const ClientPortalLoginCard({
    super.key,
    required this.customer,
    required this.isLoginEnabled,
    required this.isProcessing,
    this.isMobile = false,
    required this.onSendInvite,
    required this.onToggleLogin,
  });

  Widget _buildInviteBtn({bool fullWidth = false}) {
    final btn = ElevatedButton.icon(
      icon: const Icon(Icons.send_rounded, size: 14),
      label: const Text("Send Portal Invite"),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold),
      ),
      onPressed: onSendInvite,
    );
    return fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }

  Widget _buildToggleBtn({bool fullWidth = false}) {
    final btn = isLoginEnabled
        ? OutlinedButton.icon(
            icon: const Icon(Icons.block_rounded, size: 14, color: AppColors.error),
            label: const Text(
              "Disable Client Login",
              style: TextStyle(color: AppColors.error),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error, width: 0.8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold),
            ),
            onPressed: () => onToggleLogin(false),
          )
        : ElevatedButton.icon(
            icon: const Icon(Icons.check_circle_outline, size: 14),
            label: const Text("Enable Client Login"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold),
            ),
            onPressed: () => onToggleLogin(true),
          );
    return fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = isLoginEnabled ? Colors.green : Colors.red;

    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF132219) : const Color(0xFFF3EFEA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryAccent.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.vpn_key_outlined,
                      size: 16,
                      color: AppColors.primaryAccent,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        "CLIENT PORTAL LOGIN",
                        style: AppTheme.sansBody(
                          fontSize: isMobile ? 10 : 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryAccent,
                          letterSpacing: isMobile ? 0.6 : 1.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: statusColor, width: 0.8),
                ),
                child: Text(
                  isLoginEnabled ? "Enabled" : "Disabled",
                  style: AppTheme.sansBody(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            customer.email.isNotEmpty
                ? "Linked Email: ${customer.email}"
                : "No email address configured. An email is required for portal login.",
            style: AppTheme.sansBody(
              fontSize: 11,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          if (isProcessing)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryAccent,
                  ),
                ),
              ),
            )
          else if (isMobile)
            Column(
              children: [
                if (isLoginEnabled && customer.email.isNotEmpty) ...[
                  _buildInviteBtn(fullWidth: true),
                  const SizedBox(height: 8),
                ],
                _buildToggleBtn(fullWidth: true),
              ],
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (isLoginEnabled && customer.email.isNotEmpty)
                  _buildInviteBtn(fullWidth: false),
                _buildToggleBtn(fullWidth: false),
              ],
            ),
        ],
      ),
    );
  }
}
