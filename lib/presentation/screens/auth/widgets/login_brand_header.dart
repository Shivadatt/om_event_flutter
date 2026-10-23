import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/app_config_service.dart';
import '../../../../core/services/business_details_service.dart';
import 'login_constants.dart';

/// Reusable OM Events company logo loaded and cached from Firebase.
///
/// Preserves the original artwork's aspect ratio with [BoxFit.contain], eliminates
/// artificial circular clipping or extra gold borders, and avoids internal padding
/// that would compress the natural emblem.
class LoginCompanyLogo extends StatelessWidget {
  final double width;
  final double height;
  final Alignment alignment;

  const LoginCompanyLogo({
    super.key,
    double? size,
    double? width,
    double? height,
    this.alignment = Alignment.center,
    bool withGlow = false,
  })  : width = width ?? size ?? 85.0,
        height = height ?? size ?? 85.0;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<BusinessDetailsService>() &&
        !Get.isRegistered<AppConfigService>()) {
      return _buildContainer(null);
    }

    return Obx(() {
      final logoUrl = _resolveLogoUrl();
      return _buildContainer(logoUrl.isNotEmpty ? logoUrl : null);
    });
  }

  String _resolveLogoUrl() {
    if (Get.isRegistered<BusinessDetailsService>()) {
      final details = BusinessDetailsService.to.rxDetails.value;
      if (details.general.logo.trim().isNotEmpty) {
        return details.general.logo.trim();
      }
      if (details.general.coverImage.trim().isNotEmpty) {
        return details.general.coverImage.trim();
      }
    }
    if (Get.isRegistered<AppConfigService>()) {
      final profile = AppConfigService.to.rxBusinessProfile.value;
      if (profile.logo.trim().isNotEmpty) {
        return profile.logo.trim();
      }
      if (profile.whiteLogo.trim().isNotEmpty) {
        return profile.whiteLogo.trim();
      }
    }
    return '';
  }

  Widget _buildContainer(String? logoUrl) {
    return SizedBox(
      width: width,
      height: height,
      child: Align(
        alignment: alignment,
        child: _buildLogoImage(logoUrl),
      ),
    );
  }

  Widget _buildLogoImage(String? logoUrl) {
    if (logoUrl != null && logoUrl.isNotEmpty) {
      if (logoUrl.startsWith('assets/')) {
        return Image.asset(
          logoUrl,
          fit: BoxFit.contain,
          alignment: alignment,
          errorBuilder: (_, __, ___) => _buildFallback(),
        );
      }
      return CachedNetworkImage(
        imageUrl: logoUrl,
        fit: BoxFit.contain,
        alignment: alignment,
        filterQuality: FilterQuality.medium,
        placeholder: (_, __) => _buildLoadingState(),
        errorWidget: (_, __, ___) => _buildFallback(),
      );
    }
    return _buildFallback();
  }

  Widget _buildLoadingState() {
    final indicatorSize = (width < height ? width : height) * 0.35;
    return Center(
      child: SizedBox(
        width: indicatorSize,
        height: indicatorSize,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            LoginConstants.goldColor.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildFallback() {
    final fallbackSize = (width < height ? width : height).clamp(32.0, 48.0);
    return Container(
      width: fallbackSize,
      height: fallbackSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: LoginConstants.goldColor, width: 1.2),
        color: Colors.black.withValues(alpha: 0.25),
      ),
      child: Center(
        child: Icon(
          Icons.auto_awesome,
          size: fallbackSize * 0.45,
          color: LoginConstants.goldColor.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}

/// Top-left OM Events brand header used in the hero visual.
class LoginBrandHeader extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;
  final bool isCompact;

  const LoginBrandHeader({
    super.key,
    this.isMobile = false,
    this.isTablet = false,
    this.isDesktop = false,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final double logoWidth = isDesktop
        ? 110.0
        : (isMobile
            ? 65.0
            : (isTablet ? 85.0 : 95.0));
    final double logoHeight = logoWidth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        LoginCompanyLogo(
          width: logoWidth,
          height: logoHeight,
          alignment: Alignment.centerLeft,
        ),
        SizedBox(height: isMobile ? 3 : 5),
        Text(
          "OM EVENTS\nAND DECORATORS",
          style: GoogleFonts.dmSans(
            fontSize: isMobile ? 6.5 : (isTablet ? 7.0 : 7.5),
            fontWeight: FontWeight.w700,
            color: LoginConstants.goldColor,
            letterSpacing: 1.4,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

/// Centered OM Events brand badge rendered at the top of the login form panel.
class LoginFormBrandBadge extends StatelessWidget {
  final bool isCompact;

  const LoginFormBrandBadge({super.key, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    final double logoWidth = isCompact ? 85.0 : 95.0;
    final double logoHeight = logoWidth;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LoginCompanyLogo(
          width: logoWidth,
          height: logoHeight,
          alignment: Alignment.center,
        ),
        const SizedBox(height: 4),
        Text(
          "OM EVENTS\nAND DECORATORS",
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: isCompact ? 6.8 : 7.2,
            fontWeight: FontWeight.w700,
            color: LoginConstants.goldColor,
            letterSpacing: 1.3,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
