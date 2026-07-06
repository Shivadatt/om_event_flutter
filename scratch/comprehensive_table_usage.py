import os
import re

TABLES = [
    'activity_logs', 'admin_profiles', 'admins', 'booking_gallery', 'booking_timelines', 'bookings',
    'categories', 'chat_messages', 'chat_rooms', 'contact_numbers', 'customer_activity', 'customer_bookings',
    'customer_documents', 'customer_leads', 'customer_notifications', 'customer_payments', 'customer_profiles',
    'customer_quotes', 'customer_reviews', 'customer_wishlist', 'customers', 'dead_letter_notifications',
    'delivery_events', 'experiences', 'gallery', 'leads', 'notification_logs', 'notification_preferences',
    'notification_queue', 'notification_templates', 'notification_tokens', 'offers', 'payments', 'permissions',
    'quotations', 'rebook_requests', 'reviews', 'role_permissions', 'roles', 'scheduled_notifications',
    'service_categories', 'services', 'settings', 'settings_history', 'users'
]

def scan_codebase():
    workspace = "d:\\om_event_python\\om_event"
    usage = {t: {
        'repositories': [],
        'controllers': [],
        'screens_widgets': [],
        'sql_migrations': [],
        'edge_functions': [],
        'other': []
    } for t in TABLES}
    
    for dirpath, _, filenames in os.walk(workspace):
        # Skip directories that are build outputs or configuration folders
        if any(x in dirpath for x in ['.git', '.fvm', '.idea', '.dart_tool', 'build']):
            continue
            
        for fname in filenames:
            ext = os.path.splitext(fname)[1].lower()
            if ext not in ['.dart', '.js', '.ts', '.py', '.sql']:
                continue
                
            fpath = os.path.join(dirpath, fname)
            rel_path = os.path.relpath(fpath, workspace).replace('\\', '/')
            
            try:
                with open(fpath, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                    
                # Clean references check
                for t in TABLES:
                    is_used = False
                    
                    if ext == '.dart':
                        # Match table name in quotes or direct references
                        if re.search(rf"\.from\(['\"]{t}['\"]\)", content) or re.search(rf"['\"]{t}['\"]", content):
                            is_used = True
                    elif ext == '.sql':
                        # Match word boundaries for SQL
                        if re.search(rf"\b{t}\b", content, re.IGNORECASE):
                            is_used = True
                    elif ext in ['.js', '.ts']:
                        if re.search(rf"['\"]{t}['\"]", content) or re.search(rf"\b{t}\b", content):
                            is_used = True
                            
                    if is_used:
                        # Categorise file
                        if 'repository' in rel_path.lower():
                            usage[t]['repositories'].append(rel_path)
                        elif 'controller' in rel_path.lower():
                            usage[t]['controllers'].append(rel_path)
                        elif 'screen' in rel_path.lower() or 'widget' in rel_path.lower() or 'view' in rel_path.lower():
                            usage[t]['screens_widgets'].append(rel_path)
                        elif 'supabase/migrations' in rel_path.lower() or rel_path.endswith('.sql'):
                            usage[t]['sql_migrations'].append(rel_path)
                        elif 'supabase/functions' in rel_path.lower() or 'functions/' in rel_path.lower():
                            usage[t]['edge_functions'].append(rel_path)
                        else:
                            usage[t]['other'].append(rel_path)
                            
            except Exception as e:
                print(f"Error reading {rel_path}: {e}")
                
    return usage

def generate_report(usage):
    report = []
    report.append("# Comprehensive Database Table Usage & Dependency Report\n")
    report.append("This document tracks every table defined in the Supabase schema and details its consumption across the Flutter client repositories, GetX controllers, UI widgets, SQL triggers/migrations, and Edge Functions.\n")
    
    report.append("## 1. Table Usage Breakdown & Reference Lists\n")
    
    for t in TABLES:
        # Classify table
        has_repo = len(usage[t]['repositories']) > 0
        has_ctrl = len(usage[t]['controllers']) > 0
        has_ui = len(usage[t]['screens_widgets']) > 0
        has_sql = len(usage[t]['sql_migrations']) > 0
        has_edge = len(usage[t]['edge_functions']) > 0
        
        classification = "UNUSED"
        if has_repo or has_ctrl or has_ui:
            classification = "ACTIVE"
            # Hardcoded classifications for duplicates
            if t in ('services', 'service_categories'):
                classification = "LEGACY (Active Fallback)"
        elif t == 'admin_profiles':
            classification = "UNUSED (Deleted)"
        elif has_sql or has_edge:
            classification = "ACTIVE (Database Infrastructure)"
            
        report.append(f"### Table: `{t}`")
        report.append(f"*   **Classification**: **{classification}**")
        
        if has_repo:
            report.append("*   **Repositories**:")
            for r in usage[t]['repositories']:
                report.append(f"    *   [{os.path.basename(r)}](file:///{r})")
        if has_ctrl:
            report.append("*   **Controllers**:")
            for c in usage[t]['controllers']:
                report.append(f"    *   [{os.path.basename(c)}](file:///{c})")
        if has_ui:
            report.append("*   **Screens & Widgets**:")
            for w in usage[t]['screens_widgets'][:5]: # Cap at 5 for length
                report.append(f"    *   [{os.path.basename(w)}](file:///{w})")
            if len(usage[t]['screens_widgets']) > 5:
                report.append(f"    *   ... and {len(usage[t]['screens_widgets'])-5} more")
        if has_sql:
            report.append("*   **SQL Migrations & DDL**:")
            for s in usage[t]['sql_migrations'][:5]:
                report.append(f"    *   [{os.path.basename(s)}](file:///{s})")
            if len(usage[t]['sql_migrations']) > 5:
                report.append(f"    *   ... and {len(usage[t]['sql_migrations'])-5} more")
        if has_edge:
            report.append("*   **Edge & Cloud Functions**:")
            for e in usage[t]['edge_functions'][:5]:
                report.append(f"    *   [{os.path.basename(e)}](file:///{e})")
            if len(usage[t]['edge_functions']) > 5:
                report.append(f"    *   ... and {len(usage[t]['edge_functions'])-5} more")
        report.append("")
        
    # Append Duplicate Analysis
    report.append("## 2. Codebase Duplication Analysis\n")
    report.append("### Duplicate Repositories")
    report.append("*   **`SupabaseServiceRepository`** vs **`SupabaseCatalogRepository`**")
    report.append("    *   `SupabaseCatalogRepository` is actively bound and consumed by `CatalogController` to load category lists and catalog items.")
    report.append("    *   `SupabaseServiceRepository` is unreferenced in screen bindings (Legacy/Dead Code). It has been updated to canonical tables for safety.")
    report.append("")
    report.append("### Duplicate Models")
    report.append("*   **`CategoryModel`** vs **`CategoryEntity`**")
    report.append("    *   Clean architecture maps `CategoryModel` (data layer with Supabase serializers) to `CategoryEntity` (domain layer entities used in UI). This is normal architecture pattern.")
    report.append("*   **`ExperienceModel`** vs **`Experience`**")
    report.append("    *   Mapped domain entity pattern.")
    report.append("")
    report.append("### Duplicate SQL Setup")
    report.append("*   `20260706000001_create_missing_tables.sql` creates `categories` / `experiences` / `admin_profiles` / `booking_gallery`.")
    report.append("*   `20260706000002_create_missing_rbac_and_services.sql` creates `service_categories` / `services` / `admins` / `gallery`.")
    report.append("    *   This is the origin of the duplicate catalog tables in your database.")
    
    # Save file
    artifact_path = "C:\\Users\\ASUS\\.gemini\\antigravity-ide\\brain\\ca7213b7-3ae2-437b-8704-d00ceb9d9b96\\comprehensive_database_audit.md"
    with open(artifact_path, "w", encoding="utf-8") as f:
        f.write("\n".join(report))
        
    print("Report written successfully!")

if __name__ == "__main__":
    u = scan_codebase()
    generate_report(u)
