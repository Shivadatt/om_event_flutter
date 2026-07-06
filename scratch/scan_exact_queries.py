import os
import re

PATTERNS = [
    r"\.from\(['\"]services['\"]\)",
    r"\.from\(['\"]service_categories['\"]\)",
    r"\.from\(['\"]items['\"]\)",
    r"\.from\(['\"]customers['\"]\)"
]

def scan_queries():
    workspace = "d:\\om_event_python\\om_event"
    scan_dirs = ["lib", "supabase", "scripts", "functions"]
    
    matches = []
    
    for s_dir in scan_dirs:
        target_dir = os.path.join(workspace, s_dir)
        if not os.path.exists(target_dir):
            continue
            
        for dirpath, _, filenames in os.walk(target_dir):
            # Skip core/services/ and build/fvm paths
            if any(x in dirpath for x in ['.git', '.fvm', '.idea', '.dart_tool', 'build', 'node_modules', 'lib/core/services']):
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
                        # Skip comments
                        clean_line = line.strip()
                        if clean_line.startswith("//") or clean_line.startswith("#") or clean_line.startswith("--"):
                            continue
                            
                        for p in PATTERNS:
                            if re.search(p, line):
                                matches.append((rel_path, idx, clean_line))
                except Exception as e:
                    print(f"Error reading {rel_path}: {e}")
                    
    return matches

if __name__ == "__main__":
    m = scan_queries()
    print(f"Matches count: {len(m)}")
    for item in m:
        print(f"{item[0]}:{item[1]} -> {item[2]}")
