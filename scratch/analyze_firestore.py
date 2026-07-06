import os
import re

lib_dir = r"d:\om_event_python\om_event\lib"
patterns = {
    "collection": r"\.collection\(",
    "stream": r"\.snapshots\(",
    "batch": r"\.batch\(",
    "transaction": r"\.runTransaction\(|\.transaction\(",
    "get": r"\.get\(",
    "set": r"\.set\(",
    "update": r"\.update\(",
    "delete": r"\.delete\("
}

results = {k: [] for k in patterns}

for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith(".dart"):
            filepath = os.path.join(root, file).replace("\\", "/")
            with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
                lines = f.readlines()
                for idx, line in enumerate(lines):
                    line_num = idx + 1
                    for name, pat in patterns.items():
                        if re.search(pat, line):
                            results[name].append({
                                "file": filepath,
                                "line": line_num,
                                "content": line.strip()
                            })

# Output to a report file
output_path = r"d:\om_event_python\om_event\scratch\firestore_analysis.txt"
with open(output_path, "w", encoding="utf-8") as out:
    for category, items in results.items():
        out.write(f"=== CATEGORY: {category.upper()} (Count: {len(items)}) ===\n")
        for item in items:
            out.write(f"{item['file']}:{item['line']}: {item['content']}\n")
        out.write("\n")

print("Analysis completed successfully. Output saved to scratch/firestore_analysis.txt")
