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
    'service_categories', 'services', 'settings', 'settings_history', 'users', 'items', 'admin', 'notification_delivery_events'
]

def scan_lines():
    workspace = "d:\\om_event_python\\om_event"
    scan_dirs = ["lib", "supabase", "scripts", "functions"]
    
    references = {t: [] for t in TABLES}
    
    for s_dir in scan_dirs:
        target_dir = os.path.join(workspace, s_dir)
        if not os.path.exists(target_dir):
            continue
            
        for dirpath, _, filenames in os.walk(target_dir):
            if any(x in dirpath for x in ['.git', '.fvm', '.idea', '.dart_tool', 'build', 'node_modules']):
                continue
                
            for fname in filenames:
                ext = os.path.splitext(fname)[1].lower()
                if ext not in ['.dart', '.js', '.ts', '.py', '.sql']:
                    continue
                    
                fpath = os.path.join(dirpath, fname)
                rel_path = os.path.relpath(fpath, workspace).replace('\\', '/')
                
                try:
                    with open(fpath, 'r', encoding='utf-8', errors='ignore') as f:
                        lines = f.readlines()
                        
                    for idx, line in enumerate(lines, 1):
                        for t in TABLES:
                            is_used = False
                            
                            # Clean word matching
                            if t in line:
                                # Specifically check quote boundaries for Dart/JS/Python or word boundaries for SQL
                                if ext in ['.dart', '.js', '.ts', '.py']:
                                    if f"'{t}'" in line or f'"{t}"' in line or re.search(rf"\b{t}\b", line):
                                        is_used = True
                                elif ext == '.sql':
                                    if re.search(rf"\b{t}\b", line, re.IGNORECASE):
                                        is_used = True
                                        
                            if is_used:
                                references[t].append((rel_path, idx, line.strip()))
                except Exception as e:
                    print(f"Error reading {rel_path}: {e}")
                    
    return references

def print_report(refs):
    for t in TABLES:
        print(f"=== TABLE: {t} ===")
        print(f"References count: {len(refs[t])}")
        for r in refs[t][:10]:
            print(f"  {r[0]}:{r[1]} -> {r[2][:80]}")
        print()

if __name__ == "__main__":
    r = scan_lines()
    print_report(r)
    
    # Save raw refs for formatting into markdown
    import json
    with open("scratch/scanned_table_refs.json", "w", encoding="utf-8") as f:
        json.dump(r, f, indent=2)
