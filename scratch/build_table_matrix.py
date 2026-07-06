import os
import re

TABLES = [
    'categories',
    'service_categories',
    'experiences',
    'services',
    'admins',
    'roles',
    'permissions',
    'users',
    'bookings',
    'gallery',
    'reviews',
    'settings',
    'notification_queue',
    'notification_logs',
    'notification_preferences',
    'notification_templates',
    'notification_tokens',
    'scheduled_notifications',
    'delivery_events',
    'dead_letter_notifications'
]

def scan_files():
    workspace = "d:\\om_event_python\\om_event"
    matrix = {t: {
        'Repository': [],
        'Controller': [],
        'Widget': [],
        'Screen': [],
        'Service': [],
        'Model': [],
        'Binding': [],
        'SQL': [],
        'Edge Function': []
    } for t in TABLES}
    
    for dirpath, _, filenames in os.walk(workspace):
        if any(x in dirpath for x in ['.git', '.fvm', '.idea', '.dart_tool', 'build']):
            continue
            
        for fname in filenames:
            ext = os.path.splitext(fname)[1].lower()
            if ext not in ['.dart', '.js', '.ts', '.sql']:
                continue
                
            fpath = os.path.join(dirpath, fname)
            rel_path = os.path.relpath(fpath, workspace).replace('\\', '/')
            base_name = os.path.basename(fpath)
            
            try:
                with open(fpath, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                    
                for t in TABLES:
                    is_used = False
                    if ext == '.dart':
                        if re.search(rf"\.from\(['\"]{t}['\"]\)", content) or re.search(rf"['\"]{t}['\"]", content):
                            is_used = True
                    elif ext == '.sql':
                        if re.search(rf"\b{t}\b", content, re.IGNORECASE):
                            is_used = True
                    elif ext in ['.js', '.ts']:
                        if re.search(rf"['\"]{t}['\"]", content) or re.search(rf"\b{t}\b", content):
                            is_used = True
                            
                    if is_used:
                        # Map file path to specific Flutter/DB class type
                        if 'repository' in rel_path.lower():
                            matrix[t]['Repository'].append(base_name)
                        elif 'controller' in rel_path.lower():
                            matrix[t]['Controller'].append(base_name)
                        elif 'widget' in rel_path.lower() or 'card' in rel_path.lower() or 'row' in rel_path.lower() or 'button' in rel_path.lower():
                            matrix[t]['Widget'].append(base_name)
                        elif 'screen' in rel_path.lower() or 'view' in rel_path.lower():
                            matrix[t]['Screen'].append(base_name)
                        elif 'service' in rel_path.lower():
                            matrix[t]['Service'].append(base_name)
                        elif 'model' in rel_path.lower():
                            matrix[t]['Model'].append(base_name)
                        elif 'binding' in rel_path.lower():
                            matrix[t]['Binding'].append(base_name)
                        elif 'supabase/migrations' in rel_path.lower() or rel_path.endswith('.sql'):
                            matrix[t]['SQL'].append(base_name)
                        elif 'supabase/functions' in rel_path.lower() or 'functions/' in rel_path.lower():
                            matrix[t]['Edge Function'].append(base_name)
            except Exception as e:
                print(f"Error reading {rel_path}: {e}")
                
    return matrix

def generate_report(matrix):
    report = []
    report.append("# Comprehensive Project Database Matrix\n")
    report.append("This matrix maps every queried database table/collection to the structural components in the Flutter codebase and server infrastructure.\n")
    
    for t in TABLES:
        # Determine status
        status = "ACTIVE"
        if t in ('services', 'service_categories'):
            status = "LEGACY (Compatibility Only)"
        elif t == 'admin_profiles':
            status = "UNUSED (Deleted)"
            
        report.append(f"## Table: `{t}`")
        report.append(f"*   **Status**: **{status}**")
        
        # Print list of files under each component type
        for key in ['Repository', 'Controller', 'Widget', 'Screen', 'Service', 'Model', 'Binding', 'SQL', 'Edge Function']:
            files = list(set(matrix[t][key]))
            if files:
                report.append(f"*   **{key}**:")
                for f in sorted(files)[:8]: # Cap at 8 files per category
                    report.append(f"    *   `{f}`")
                if len(files) > 8:
                    report.append(f"    *   ... and {len(files)-8} more")
        report.append("")
        
    artifact_path = "C:/Users/ASUS/.gemini/antigravity-ide/brain/ca7213b7-3ae2-437b-8704-d00ceb9d9b96/final_table_usage_matrix.md"
    with open(artifact_path, "w", encoding="utf-8") as f:
        f.write("\n".join(report))
        
    print("Matrix report created successfully!")

if __name__ == "__main__":
    m = scan_files()
    generate_report(m)
