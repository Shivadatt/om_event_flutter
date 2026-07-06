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

def analyze_project():
    workspace = "d:\\om_event_python\\om_event"
    table_references = {t: [] for t in TABLES}
    
    for dirpath, _, filenames in os.walk(workspace):
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
                    
                # Look for each table name
                for t in TABLES:
                    # Look for client queries: .from('table') or .table('table') or SQL from/join/into
                    patterns = [
                        rf"\.from\(['\"]{t}['\"]\)",
                        rf"\.table\(['\"]{t}['\"]\)",
                        rf"['\"]{t}['\"]", # rough lookup for SQL/triggers
                    ]
                    
                    is_referenced = False
                    # For Dart files, check if table is inside quotes in queries
                    if ext == '.dart':
                        if re.search(rf"\.from\(['\"]{t}['\"]\)", content) or re.search(rf"['\"]{t}['\"]", content):
                            is_referenced = True
                    # For SQL files, check if table name is present
                    elif ext == '.sql':
                        if re.search(rf"\b{t}\b", content, re.IGNORECASE):
                            is_referenced = True
                    # For JS/TS files, check if table name is present
                    elif ext in ['.js', '.ts']:
                        if re.search(rf"['\"]{t}['\"]", content) or re.search(rf"\b{t}\b", content):
                            is_referenced = True
                            
                    if is_referenced:
                        table_references[t].append((rel_path, ext))
            except Exception as e:
                print(f"Error reading {rel_path}: {e}")
                
    return table_references

def main():
    refs = analyze_project()
    print("ANALYSIS RESULT:")
    for t, files in refs.items():
        if files:
            print(f"\nTable: {t} (found in {len(files)} files)")
            for f, ext in files[:10]: # Print first 10 files
                print(f"  - {f}")
            if len(files) > 10:
                print(f"  - ... and {len(files)-10} more")

if __name__ == "__main__":
    main()
