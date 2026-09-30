import 'package:get/get.dart';
import '../services/business_details_service.dart';

/// Single source of truth for OM Events & Decorators official branches.
/// The business operates exclusively out of two canonical creative bases / branches:
/// 1. Kadi (Mehsana)
/// 2. Thangadh (Surendranagar)
///
/// NOTE: Ahmedabad is a primary coverage area / service territory, NOT a business branch.
class AppBranches {
  AppBranches._();

  static const String kadi = 'Kadi';
  static const String thangadh = 'Thangadh';

  /// The only two valid business branches.
  static const List<String> canonicalBranches = [kadi, thangadh];

  /// Returns canonical branches, dynamically augmented by active branches from business settings if present.
  /// Explicitly filters out non-branch locations like Ahmedabad.
  static List<String> getAvailableBranches() {
    try {
      if (Get.isRegistered<BusinessDetailsService>()) {
        final registered = BusinessDetailsService.to.rxDetails.value.branches
            .where((b) => b.isActive)
            .map((b) => b.branchName.trim())
            .where((name) => name.isNotEmpty && name.toLowerCase() != 'ahmedabad')
            .toList();

        if (registered.isNotEmpty) {
          final Set<String> result = {};
          for (final b in registered) {
            final lower = b.toLowerCase();
            if (lower.contains('kadi')) {
              result.add(kadi);
            } else if (lower.contains('thangadh')) {
              result.add(thangadh);
            }
          }
          if (result.isNotEmpty) {
            return result.toList();
          }
        }
      }
    } catch (_) {}
    return canonicalBranches;
  }

  /// Validates whether a branch value is one of the recognized canonical branches.
  static bool isValidBranch(String? branch) {
    if (branch == null || branch.trim().isEmpty) return true;
    final clean = branch.trim().toLowerCase();
    return clean == kadi.toLowerCase() || clean == thangadh.toLowerCase();
  }
}
