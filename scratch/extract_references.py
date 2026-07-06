import os
import re

PATTERNS = [
    # Dart / Javascript Supabase client queries
    r"\.from\(['\"]([a-zA-Z0-9_]+)['\"]\)",
    r"\.table\(['\"]([a-zA-Z0-9_]+)['\"]\)",
    r"rpc\(['\"]([a-zA-Z0-9_]+)['\"]",
    
    # Python supabase client
    r"\.table\(['\"]([a-zA-Z0-9_]+)['\"]\)",
]

SQL_PATTERNS = [
    # SQL query patterns (FROM, JOIN, INSERT INTO, UPDATE, ALTER TABLE, CREATE TABLE)
    r"(?:FROM|JOIN|INTO|UPDATE|TABLE)\s+public\.([a-zA-Z0-9_]+)",
    r"(?:FROM|JOIN|INTO|UPDATE|TABLE)\s+([a-zA-Z0-9_]+)",
]

IGNORE_WORDS = {
    'if', 'exists', 'select', 'where', 'and', 'or', 'not', 'null', 'true', 'false',
    'returning', 'values', 'set', 'by', 'on', 'asc', 'desc', 'limit', 'offset',
    'pg_tables', 'pg_publication', 'pg_publication_tables', 'pg_class', 'pg_namespace',
    'auth_user', 'django_migrations', 'django_content_type', 'auth_permission', 'auth_group'
}

def scan_files(root_dir):
    references = set()
    rpcs = set()
    
    for dirpath, _, filenames in os.walk(root_dir):
        # Skip build, fvm, git, idea folders
        if any(x in dirpath for x in ['.git', '.fvm', '.idea', '.dart_tool', 'build']):
            continue
            
        for fname in filenames:
            ext = os.path.splitext(fname)[1].lower()
            if ext not in ['.dart', '.js', '.py', '.sql']:
                continue
                
            fpath = os.path.join(dirpath, fname)
            try:
                with open(fpath, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                    
                # Scan table from/table methods
                for p in PATTERNS:
                    for m in re.finditer(p, content):
                        name = m.group(1)
                        if name.lower() not in IGNORE_WORDS:
                            if 'rpc' in p:
                                rpcs.add(name)
                            else:
                                references.add(name)
                                
                # Scan SQL table patterns for .sql files
                if ext == '.sql':
                    for p in SQL_PATTERNS:
                        for m in re.finditer(p, content, re.IGNORECASE):
                            name = m.group(1)
                            if name.lower() not in IGNORE_WORDS and not name.startswith('idx_') and not name.startswith('trg_') and not name.startswith('fn_'):
                                references.add(name)
            except Exception as e:
                print(f"Error reading {fpath}: {e}")
                
    return references, rpcs

def main():
    workspace = "d:\\om_event_python\\om_event"
    print("Scanning codebase for table references...")
    tables, rpcs = scan_files(workspace)
    
    print("\n--- DETECTED TABLES ---")
    for t in sorted(list(tables)):
        print(t)
        
    print("\n--- DETECTED RPCS ---")
    for r in sorted(list(rpcs)):
        print(r)

if __name__ == "__main__":
    main()
