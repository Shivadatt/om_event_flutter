import os
import re

directories = [
    r"d:\om_event_python\om_event\lib\data\models",
    r"d:\om_event_python\om_event\lib\domain\entities"
]
output_path = r"d:\om_event_python\om_event\scratch\model_fields.txt"

with open(output_path, "w", encoding="utf-8") as out:
    for folder in directories:
        out.write(f"==================================================\n")
        out.write(f"=== DIRECTORY: {os.path.basename(folder)} ===\n")
        out.write(f"==================================================\n\n")
        for file in os.listdir(folder):
            if file.endswith(".dart"):
                filepath = os.path.join(folder, file)
                out.write(f"=== FILE: {file} ===\n")
                with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
                    content = f.read()
                    classes = re.findall(r"class\s+(\w+)", content)
                    out.write(f"Classes: {', '.join(classes)}\n")
                    
                    # Search for final variable declarations
                    fields = re.findall(r"final\s+([\w<>\?,]+)\s+(\w+)\s*;", content)
                    for ftype, fname in fields:
                        out.write(f"  Field: {fname} ({ftype})\n")
                    out.write("\n")

print("Updated fields extraction completed. Output saved to scratch/model_fields.txt")
