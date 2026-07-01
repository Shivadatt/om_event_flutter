/// Centralized app string constants — labels, messages, and display text.
class AppStrings {
  AppStrings._();

  // ── Business ──────────────────────────────────────────────────────────────
  static const String businessName = 'Om Events';
  static const String businessPhone = '919512149944';
  static const String businessEmail = 'omeventsanddecorators@gmail.com';
  static const String businessEmailDisplay = 'omeventsanddecorators@gmail.com';
  static const String demoAdminEmail = 'admin@gmail.com';
  static const String whatsappMessage =
      "Hello Om Events, I'd like to plan an event.";

  // ── App Metadata ──────────────────────────────────────────────────────────
  static const String appTitle = 'Om Events';
  static const String appTagline = 'Crafting Unforgettable Moments';

  // ── Error & Auth Messages ─────────────────────────────────────────────────
  static const String errUserAuthFailed = 'User authentication failed.';
  static const String errAdminNotFound = 'Admin profile not found.';
  static const String errAccountDisabled = 'Your account has been disabled.';
  static const String errInvalidCredentials = 'Invalid email or password.';
  static const String errAuthFailed = 'Authentication failed.';
  static const String errQuoteNotFound = 'Quotation not found.';
  static const String errExperienceNotFound = 'Experience details not found.';

  // ── Seeder Messages ───────────────────────────────────────────────────────
  static const String seederCheckStatus = 'Checking migration status...';
  static const String seederAlreadyDone =
      'Migration already completed. Skipping.';
  static const String seederPruning = 'Pruning existing collections...';
  static const String seederUploadCategories =
      'Uploading category media to Supabase...';
  static const String seederUploadItems =
      'Uploading decoration items media to Supabase...';
  static const String seederUploadGallery =
      'Uploading secondary gallery images to Supabase...';
  static const String seederUploadReviews =
      'Uploading review media to Supabase...';
  static const String seederCommitting =
      'Committing SQL data to Firestore collections...';
  static const String seederLockMarker = 'Setting migration lock marker...';
  static const String seederSuccess = 'Migration completed successfully!';
  static const String seederFailed = 'Migration failed: ';

  // ── Admin Bootstrap ───────────────────────────────────────────────────────
  static const String superAdminUid = 'super-admin-uid';
  static const String demoAdminUid = 'demo-admin-uid';
  static const String superAdminName = 'Super Admin';
  static const String demoAdminName = 'Demo Admin';
  static const String createdBySystem = 'system';

  // ── Firebase Auth Error Codes ─────────────────────────────────────────────
  static const String firebaseUserNotFound = 'user-not-found';
  static const String firebaseWrongPassword = 'wrong-password';
  static const String firebaseInvalidCredential = 'invalid-credential';

  // ── Cache Keys ────────────────────────────────────────────────────────────
  static const String cartCacheKey = 'oe-cart-selection';
  static const String themeCacheKey = 'oe-app-theme';
  static const String adminTokenKey = 'oe-admin-jwt-token';

  // ── Firestore Field Keys ──────────────────────────────────────────────────
  static const String fieldUid = 'uid';
  static const String fieldName = 'name';
  static const String fieldEmail = 'email';
  static const String fieldPhone = 'phone';
  static const String fieldRole = 'role';
  static const String fieldRoleType = 'role_type';
  static const String fieldIsActive = 'is_active';
  static const String fieldIsActiveAlt = 'isActive';
  static const String fieldCreatedAt = 'created_at';
  static const String fieldUpdatedAt = 'updated_at';
  static const String fieldCreatedBy = 'created_by';
  static const String fieldPermissions = 'permissions';
  static const String fieldStatus = 'status';
  static const String fieldPublicId = 'public_id';
  static const String fieldPhotoUrl = 'photo_url';
  static const String fieldPopularity = 'popularity';
  static const String fieldIsPublished = 'is_published';
  static const String fieldSortOrder = 'sort_order';
  static const String fieldIsActive2 = 'is_active';
  static const String fieldCategoryId = 'category_id';
  static const String fieldIsFeatured = 'is_featured';
  static const String fieldSlug = 'slug';
  static const String fieldImageUrl = 'image_url';
  static const String fieldVideoUrl = 'video_url';
  static const String fieldUrl = 'url';
}
