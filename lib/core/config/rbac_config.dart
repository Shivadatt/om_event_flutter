class RbacConfig {
  static const Map<String, List<String>> permissionGroups = {
    'Dashboard': [
      'view_dashboard',
      'view_analytics',
      'view_reports',
      'view_revenue',
      'view_statistics',
      'view_charts',
      'view_activity',
    ],
    'Business CMS': [
      'manage_business_profile',
      'manage_company_details',
      'manage_logo',
      'manage_favicon',
      'manage_contact_information',
      'manage_branches',
      'manage_addresses',
      'manage_working_hours',
      'manage_theme',
      'manage_seo',
      'manage_homepage',
      'manage_footer',
      'manage_policies',
      'manage_feature_flags',
      'manage_maintenance_mode',
    ],
    'Categories': [
      'view_categories',
      'create_category',
      'edit_category',
      'delete_category',
      'publish_category',
      'hide_category',
      'change_category_order',
      'upload_category_image',
    ],
    'Experiences': [
      'view_services',
      'create_service',
      'edit_service',
      'delete_service',
      'publish_service',
      'hide_service',
      'upload_service_images',
      'upload_service_videos',
      'manage_service_pricing',
      'manage_service_packages',
    ],
    'Gallery': [
      'view_gallery',
      'upload_gallery_images',
      'edit_gallery',
      'delete_gallery',
      'reorder_gallery',
    ],
    'Videos': [
      'view_videos',
      'upload_videos',
      'edit_videos',
      'delete_videos',
    ],
    'Customers': [
      'view_customers',
      'create_customer',
      'edit_customer',
      'delete_customer',
      'export_customers',
    ],
    'Leads': [
      'view_leads',
      'assign_leads',
      'update_lead_status',
      'delete_leads',
      'export_leads',
    ],
    'Bookings': [
      'view_bookings',
      'create_booking',
      'edit_booking',
      'delete_booking',
      'approve_booking',
      'reject_booking',
      'complete_booking',
      'cancel_booking',
    ],
    'Payments': [
      'view_payments',
      'add_payment',
      'edit_payment',
      'delete_payment',
      'refund_payment',
    ],
    'Quotations': [
      'view_quotes',
      'create_quote',
      'edit_quote',
      'delete_quote',
      'approve_quote',
      'generate_quote_pdf',
      'download_quote_pdf',
      'send_quote',
    ],
    'Reviews': [
      'view_reviews',
      'approve_reviews',
      'reject_reviews',
      'delete_reviews',
      'feature_reviews',
    ],
    'Testimonials': [
      'view_testimonials',
      'create_testimonials',
      'edit_testimonials',
      'delete_testimonials',
    ],
    'Users & Roles': [
      'view_users',
      'create_users',
      'edit_users',
      'delete_users',
      'reset_password',
      'assign_roles',
      'view_roles',
      'create_roles',
      'edit_roles',
      'delete_roles',
      'assign_permissions',
    ],
    'Notifications': [
      'view_notifications',
      'create_notifications',
      'send_push_notifications',
      'send_email',
      'send_sms',
    ],
    'Templates': [
      'view_email_templates',
      'create_email_templates',
      'edit_email_templates',
      'delete_email_templates',
      'view_pdf_templates',
      'edit_pdf_templates',
      'manage_invoice_layout',
    ],
    'Analytics & Reports': [
      'view_system_analytics',
      'export_reports',
      'view_revenue_reports',
      'view_booking_reports',
      'view_customer_reports',
    ],
    'SEO': [
      'manage_seo_meta',
      'manage_seo_sitemap',
      'manage_seo_robots',
      'manage_seo_canonical',
      'manage_seo_schema',
    ],
    'Settings & System': [
      'manage_general_settings',
      'manage_firebase_settings',
      'manage_supabase_settings',
      'manage_storage_settings',
      'manage_app_settings',
      'manage_system_settings',
      'manage_system_logs',
      'manage_storage_files',
      'manage_media_files',
    ],
    'Advanced Operations': [
      'export_data',
      'import_data',
      'seed_database',
      'backup_database',
      'restore_database',
      'clear_cache',
    ],
  };

  static const Map<String, String> roleLabels = {
    'super_admin': 'Super Admin',
    'demo_admin': 'Demo Admin',
    'manager': 'Manager',
    'sales': 'Sales',
    'crm': 'CRM',
    'marketing': 'Marketing',
    'content_manager': 'Content Manager',
    'support': 'Support',
    'finance': 'Finance',
    'custom': 'Custom Role',
  };

  static List<String> get allPermissions =>
      permissionGroups.values.expand((element) => element).toList();

  static Map<String, bool> getPresetPermissions(String roleType) {
    final Map<String, bool> perms = {};
    for (var p in allPermissions) {
      perms[p] = false;
    }

    if (roleType == 'super_admin') {
      perms.updateAll((key, value) => true);
    } else if (roleType == 'demo_admin') {
      perms['view_dashboard'] = true;
      perms['view_categories'] = true;
      perms['view_services'] = true;
      perms['view_gallery'] = true;
      perms['view_reviews'] = true;
      perms['view_bookings'] = true;
      perms['view_payments'] = true;
      perms['view_customers'] = true;
      perms['view_leads'] = true;
      perms['view_users'] = true;
    } else if (roleType == 'manager') {
      perms['view_dashboard'] = true;
      perms['view_categories'] = true;
      perms['create_category'] = true;
      perms['edit_category'] = true;
      perms['view_services'] = true;
      perms['create_service'] = true;
      perms['edit_service'] = true;
      perms['view_gallery'] = true;
      perms['upload_gallery_images'] = true;
      perms['view_reviews'] = true;
      perms['approve_reviews'] = true;
      perms['view_bookings'] = true;
      perms['approve_booking'] = true;
      perms['view_customers'] = true;
      perms['create_customer'] = true;
      perms['view_leads'] = true;
    } else if (roleType == 'sales') {
      perms['view_dashboard'] = true;
      perms['view_bookings'] = true;
      perms['view_customers'] = true;
      perms['create_customer'] = true;
      perms['edit_customer'] = true;
      perms['view_leads'] = true;
      perms['assign_leads'] = true;
      perms['update_lead_status'] = true;
      perms['view_payments'] = true;
    } else if (roleType == 'crm') {
      perms['view_dashboard'] = true;
      perms['view_customers'] = true;
      perms['create_customer'] = true;
      perms['edit_customer'] = true;
      perms['view_leads'] = true;
      perms['view_reviews'] = true;
    } else if (roleType == 'marketing') {
      perms['view_dashboard'] = true;
      perms['view_analytics'] = true;
      perms['view_reports'] = true;
      perms['view_reviews'] = true;
      perms['feature_reviews'] = true;
      perms['manage_seo'] = true;
    } else if (roleType == 'content_manager') {
      perms['view_dashboard'] = true;
      perms['view_categories'] = true;
      perms['create_category'] = true;
      perms['edit_category'] = true;
      perms['view_services'] = true;
      perms['create_service'] = true;
      perms['edit_service'] = true;
      perms['view_gallery'] = true;
      perms['upload_gallery_images'] = true;
      perms['delete_gallery'] = true;
      perms['manage_homepage'] = true;
      perms['manage_footer'] = true;
    } else if (roleType == 'support') {
      perms['view_dashboard'] = true;
      perms['view_bookings'] = true;
      perms['view_customers'] = true;
      perms['view_reviews'] = true;
      perms['approve_reviews'] = true;
      perms['view_leads'] = true;
    } else if (roleType == 'finance') {
      perms['view_dashboard'] = true;
      perms['view_payments'] = true;
      perms['refund_payment'] = true;
      perms['view_reports'] = true;
      perms['manage_invoice_layout'] = true;
    }

    return perms;
  }
}
