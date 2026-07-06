import json
import os

def build_report():
    with open("scratch/scanned_table_refs.json", "r", encoding="utf-8") as f:
        refs = json.load(f)
        
    TABLES_METADATA = {
        'categories': {
            'purpose': 'Active decoration item categories loaded in the home page catalog grid.',
            'can_delete': 'NO',
            'reason': 'Required for home and catalog views rendering.',
            'status': 'ACTIVE / REQUIRED'
        },
        'service_categories': {
            'purpose': 'Legacy categories table retained for backwards compatibility.',
            'can_delete': 'NO',
            'reason': 'Rule 1: Keep separate, do not delete/merge legacy table.',
            'status': 'LEGACY (Compatibility backup)'
        },
        'experiences': {
            'purpose': 'Active decoration catalog items and packages.',
            'can_delete': 'NO',
            'reason': 'Primary catalog data provider for public views.',
            'status': 'ACTIVE / REQUIRED'
        },
        'services': {
            'purpose': 'Legacy services table retained for backwards compatibility.',
            'can_delete': 'NO',
            'reason': 'Rule 2: Keep separate, do not delete/merge legacy table.',
            'status': 'LEGACY (Compatibility backup)'
        },
        'items': {
            'purpose': 'Firestore items collection representation.',
            'can_delete': 'NO',
            'reason': 'Rule 2 & 3: Must exist as its own table, currently missing.',
            'status': 'MISSING'
        },
        'admins': {
            'purpose': 'Staff user profiles mapped to roles and permissions.',
            'can_delete': 'NO',
            'reason': 'Core authentication and authorization module.',
            'status': 'ACTIVE / REQUIRED'
        },
        'admin_profiles': {
            'purpose': 'Legacy profiles table, replaced by admins.',
            'can_delete': 'YES',
            'reason': 'Dropped cleanly in migration 20260706000005.',
            'status': 'UNUSED (Deleted)'
        },
        'bookings': {
            'purpose': 'CRM reservation transactions.',
            'can_delete': 'NO',
            'reason': 'Core transactional business log.',
            'status': 'ACTIVE / REQUIRED'
        },
        'customer_profiles': {
            'purpose': 'Customer session profile details.',
            'can_delete': 'NO',
            'reason': 'Active user profiles resolver.',
            'status': 'ACTIVE / REQUIRED'
        },
        'notification_queue': {
            'purpose': 'Outbox buffer queue for push alerts.',
            'can_delete': 'NO',
            'reason': 'Required for FCM pushes webhook triggering.',
            'status': 'ACTIVE / REQUIRED'
        },
        'notification_tokens': {
            'purpose': 'FCM registration device tokens.',
            'can_delete': 'NO',
            'reason': 'FCM notifications delivery payload addressing.',
            'status': 'ACTIVE / REQUIRED'
        },
        'notification_delivery_events': {
            'purpose': 'Delivery tracking receipts.',
            'can_delete': 'NO',
            'reason': 'Missing from Supabase (required by Firestore matching).',
            'status': 'MISSING'
        }
    }
    
    report = []
    report.append("# Complete Database Usage Audit Report\n")
    report.append("This document tracks all mapped database relations, their usages in Flutter repositories, and missing Firestore matches.\n")
    
    report.append("## 1. Table Usage Mappings\n")
    
    for t, meta in TABLES_METADATA.items():
        report.append(f"### Table: `{t}`")
        report.append(f"*   **Status**: **{meta['status']}**")
        report.append(f"*   **Purpose**: {meta['purpose']}")
        report.append(f"*   **Can Delete?**: **{meta['can_delete']}**")
        report.append(f"*   **Reason**: {meta['reason']}")
        
        # Extract files using it
        t_refs = refs.get(t, [])
        if t_refs:
            report.append("*   **References**:")
            # Group by file to reduce verbose output
            file_groups = {}
            for r in t_refs:
                file_groups.setdefault(r[0], []).append(r[1])
                
            for fpath, lines in sorted(file_groups.items())[:8]:
                lines_str = ", ".join(map(str, sorted(list(set(lines)))[:5]))
                if len(lines) > 5:
                    lines_str += "..."
                report.append(f"    *   [{os.path.basename(fpath)}](file:///{fpath}) (Lines: {lines_str})")
        report.append("")
        
    # Section for Missing & Extra tables
    report.append("## 2. Missing & Extra Tables Analysis\n")
    report.append("### Missing Tables (Required to match Firestore collections)")
    report.append("The following tables exist in the Firestore source of truth but do not have dedicated tables in Supabase:")
    report.append("1.  `items` (Firestore collection holds decoration packages).")
    report.append("2.  `notification_delivery_events` (Firestore collection logs delivery statuses).")
    report.append("")
    report.append("### Extra Tables (Backups and legacy compatibility)")
    report.append("1.  `service_categories` (Kept for compatibility per Rule 1).")
    report.append("2.  `services` (Kept for compatibility per Rule 2).")
    report.append("")
    
    # SQL generation
    report.append("## 3. Migration DDL for Missing Tables\n")
    report.append("```sql")
    report.append("-- 1. Create items table (matching Firestore items collection)")
    report.append("CREATE TABLE IF NOT EXISTS public.items (")
    report.append("  id TEXT PRIMARY KEY,")
    report.append("  name TEXT NOT NULL,")
    report.append("  description TEXT,")
    report.append("  price NUMERIC(10, 2) DEFAULT 0.00,")
    report.append("  image_url TEXT,")
    report.append("  is_active BOOLEAN DEFAULT TRUE,")
    report.append("  created_at TIMESTAMPTZ DEFAULT NOW()")
    report.append(");")
    report.append("")
    report.append("-- 2. Create notification_delivery_events table")
    report.append("CREATE TABLE IF NOT EXISTS public.notification_delivery_events (")
    report.append("  id TEXT PRIMARY KEY,")
    report.append("  notification_id TEXT,")
    report.append("  status TEXT DEFAULT 'pending',")
    report.append("  delivered_at TIMESTAMPTZ,")
    report.append("  error_message TEXT,")
    report.append("  created_at TIMESTAMPTZ DEFAULT NOW()")
    report.append(");")
    report.append("```")
    
    # Save file
    artifact_path = "C:/Users/ASUS/.gemini/antigravity-ide/brain/ca7213b7-3ae2-437b-8704-d00ceb9d9b96/database_usage_matrix_audit.md"
    with open(artifact_path, "w", encoding="utf-8") as f:
        f.write("\n".join(report))
        
    print("Usage matrix report generated!")

if __name__ == "__main__":
    build_report()
