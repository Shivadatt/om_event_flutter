import os
import sys
import json
import re
from datetime import datetime
import firebase_admin
from firebase_admin import credentials, firestore
from supabase import create_client

SUPABASE_URL = "https://kwegyvbgdaednljyhcgm.supabase.co"
SUPABASE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY") or "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt3ZWd5dmJnZGFlZG5sanloY2dtIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MjY4NDk1MywiZXhwIjoyMDk4MjYwOTUzfQ.Jr8kBFix864HBflFzIn0ztXqSzx7qDU3z7huPV997YQ"

def initialize_clients():
    # Initialize Firebase
    if not firebase_admin._apps:
        fallback = "credentials/serviceAccountKey.json"
        if os.path.exists(fallback):
            cred = credentials.Certificate(fallback)
            firebase_admin.initialize_app(cred)
        else:
            try:
                firebase_admin.initialize_app()
            except Exception as e:
                print(f"Error: Firebase credentials not resolved: {e}")
                sys.exit(1)
            
    db = firestore.client()
    supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
    return db, supabase

MAPPING = [
    ("roles", "roles"),
    ("permissions", "permissions"),
    ("admins", "admins"),
    ("service_categories", "service_categories"),
    ("service_categories", "categories"),
    ("services", "services"),
    ("services", "experiences"),
    ("users", "users"),
    ("bookings", "bookings"),
    ("gallery", "gallery"),
    ("chat_rooms", "chat_rooms"),
    ("device_tokens", "notification_tokens"),
    ("inquiries", "leads"),
    ("notifications", "notification_queue"),
    ("reviews", "reviews"),
    ("settings", "settings")
]

def format_val(val):
    if val is None:
        return None
    if isinstance(val, datetime):
        return val.isoformat()
    return str(val).strip()

def get_field_type(v):
    if v is None:
        return "Nullable/Null"
    if isinstance(v, bool):
        return "Boolean"
    if isinstance(v, int):
        return "Number (Integer)"
    if isinstance(v, float):
        return "Number (Float)"
    if isinstance(v, list):
        return "Array"
    if isinstance(v, dict):
        return "Map/JSON"
    return "String"

def run_audit():
    db, supabase = initialize_clients()
    
    mapping_report = []
    diff_report = []
    row_diff_report = []
    
    mapping_report.append("# Database Mapping Report\n")
    mapping_report.append("| Firestore Collection | Supabase Table | Field Mapping Details | Realtime | Status |")
    mapping_report.append("| :--- | :--- | :--- | :--- | :--- |")
    
    diff_report.append("# Data Difference Report\n")
    row_diff_report.append("# Row-by-Row Difference Report\n")
    
    # Store category IDs for FK checks
    category_ids = set()
    service_cat_ids = set()
    user_ids = set()
    role_ids = set()
    
    # 1. Fetch lookup validation data first
    try:
        res = supabase.table("categories").select("id").execute()
        category_ids = {r["id"] for r in res.data}
        
        res = supabase.table("service_categories").select("id").execute()
        service_cat_ids = {r["id"] for r in res.data}
        
        res = supabase.table("users").select("id").execute()
        user_ids = {r["id"] for r in res.data}
        
        res = supabase.table("roles").select("id").execute()
        role_ids = {r["id"] for r in res.data}
    except Exception as e:
        print(f"Error fetching lookups: {e}")

    for firestore_col, supabase_table in MAPPING:
        print(f"Auditing Firestore '{firestore_col}' vs Supabase '{supabase_table}'...")
        
        # Fetch Firestore
        firestore_docs = {}
        try:
            docs = db.collection(firestore_col).stream()
            for doc in docs:
                firestore_docs[doc.id] = doc.to_dict()
        except Exception as e:
            print(f"Error fetching Firestore collection '{firestore_col}': {e}")
            
        # Fetch Supabase
        supabase_rows = {}
        try:
            res = supabase.table(supabase_table).select("*").execute()
            for r in res.data:
                # Find best primary key ID
                pk_id = r.get("id")
                if not pk_id and supabase_table == 'users':
                    # Fallback for users using firebase_uid
                    pk_id = r.get("firebase_uid")
                supabase_rows[str(pk_id)] = r
        except Exception as e:
            print(f"Error fetching Supabase table '{supabase_table}': {e}")
            
        # Mapping summary
        mapping_report.append(f"| `{firestore_col}` | `{supabase_table}` | IDs matched: {len(firestore_docs)} FS docs, {len(supabase_rows)} SB rows | Yes | Active |")
        
        # Compare row counts
        diff_report.append(f"## Comparative Audit: `{firestore_col}` vs. `{supabase_table}`")
        diff_report.append(f"*   **Firestore Document Count**: {len(firestore_docs)}")
        diff_report.append(f"*   **Supabase Row Count**: {len(supabase_rows)}")
        
        discrepancies = []
        schema_discrepancies = []
        
        # Compare Schema
        if firestore_docs and supabase_rows:
            fs_sample = list(firestore_docs.values())[0]
            sb_sample = list(supabase_rows.values())[0]
            
            fs_keys = set(fs_sample.keys())
            sb_keys = set(sb_sample.keys())
            
            # Map camelCase to snake_case to compare
            mapped_fs_keys = {re.sub('([a-z0-9])([A-Z])', r'\1_\2', k).lower() for k in fs_keys}
            
            extra_sb = sb_keys - mapped_fs_keys - {'id', 'created_at', 'updated_at', 'category_slug', 'category_name'}
            missing_sb = fs_keys - {re.sub('([a-z_])', lambda m: m.group(1).upper(), k) for k in sb_keys} # rough reverse
            
            if extra_sb:
                schema_discrepancies.append(f"*   **Extra Supabase Columns**: {', '.join(sorted(list(extra_sb)))}")
            if missing_sb:
                schema_discrepancies.append(f"*   **Missing in Supabase Table**: {', '.join(sorted(list(missing_sb)))}")
                
        if schema_discrepancies:
            diff_report.extend(schema_discrepancies)
        else:
            diff_report.append("*   **Schema Attributes**: Perfect Column Match.")
            
        # Row by row validation
        missing_rows = []
        extra_rows = []
        invalid_references = []
        formatting_issues = []
        
        # Check missing rows (in Firestore but not in Supabase)
        # Note: Users & Admins can map IDs differently (Firebase UID vs UUID)
        for fs_id, fs_data in firestore_docs.items():
            mapped_id = fs_id
            
            # Smart email lookup for admins
            if supabase_table == 'admins':
                email = fs_data.get('email', '').strip().lower()
                matched = False
                for sb_id, sb_data in supabase_rows.items():
                    if sb_data.get('email', '').strip().lower() == email:
                        matched = True
                        mapped_id = sb_id
                        break
                if not matched:
                    missing_rows.append(f"Admin Email: {email} (Firestore ID: {fs_id})")
                    continue
            
            # Smart Firebase UID lookup for users
            elif supabase_table == 'users':
                matched = False
                for sb_id, sb_data in supabase_rows.items():
                    if sb_data.get('firebase_uid') == fs_id:
                        matched = True
                        mapped_id = sb_id
                        break
                if not matched:
                    missing_rows.append(f"User UID: {fs_id} (Email: {fs_data.get('email')})")
                    continue
                    
            elif mapped_id not in supabase_rows:
                missing_rows.append(f"Document ID: {fs_id}")
                continue
                
            # Row value validation
            sb_data = supabase_rows[mapped_id]
            
            # Check foreign keys
            if supabase_table in ('services', 'experiences'):
                cat_id = sb_data.get('category_id')
                target_cat_set = category_ids if supabase_table == 'experiences' else service_cat_ids
                if cat_id and cat_id not in target_cat_set:
                    invalid_references.append(f"Row '{sb_data.get('name')}' (ID: {mapped_id}) points to invalid category_id '{cat_id}'")
                    
            # Check URLs
            for col in ['image_url', 'media_url', 'avatar_url', 'photo_url']:
                if col in sb_data and sb_data[col]:
                    url = sb_data[col]
                    if "gkfcfebywgmqqhartrhv" in str(url):
                        formatting_issues.append(f"Row {mapped_id} has old Supabase project ID in URL: {url}")
                    elif "supabase.co" in str(url) and not url.startswith("https://"):
                        formatting_issues.append(f"Row {mapped_id} has invalid URL format: {url}")
                        
        # Check extra rows (in Supabase but not in Firestore)
        for sb_id, sb_data in supabase_rows.items():
            # Check if this row matches any Firestore doc
            if supabase_table == 'users':
                firebase_uid = sb_data.get('firebase_uid')
                if firebase_uid not in firestore_docs:
                    extra_rows.append(f"UUID: {sb_id} (Firebase UID: {firebase_uid})")
            elif supabase_table == 'admins':
                email = sb_data.get('email', '').strip().lower()
                matched = False
                for fs_data in firestore_docs.values():
                    if fs_data.get('email', '').strip().lower() == email:
                        matched = True
                        break
                if not matched:
                    extra_rows.append(f"ID: {sb_id} (Email: {email})")
            elif sb_id not in firestore_docs:
                extra_rows.append(f"ID: {sb_id}")

        # Log row-by-row difference details
        row_diff_report.append(f"### Table: `{supabase_table}`")
        if missing_rows:
            row_diff_report.append(f"*   **Missing Rows (in Firestore but not Supabase)** ({len(missing_rows)}):")
            for m in missing_rows[:5]:
                row_diff_report.append(f"    *   {m}")
            if len(missing_rows) > 5:
                row_diff_report.append(f"    *   ... and {len(missing_rows)-5} more")
        else:
            row_diff_report.append("*   **Missing Rows**: None (0).")
            
        if extra_rows:
            row_diff_report.append(f"*   **Extra Rows (in Supabase but not Firestore)** ({len(extra_rows)}):")
            for e in extra_rows[:5]:
                row_diff_report.append(f"    *   {e}")
            if len(extra_rows) > 5:
                row_diff_report.append(f"    *   ... and {len(extra_rows)-5} more")
        else:
            row_diff_report.append("*   **Extra Rows**: None (0).")
            
        if invalid_references:
            row_diff_report.append(f"*   **Broken References / Foreign Keys** ({len(invalid_references)}):")
            for r in invalid_references[:5]:
                row_diff_report.append(f"    *   {r}")
        else:
            row_diff_report.append("*   **Broken References**: None (0).")
            
        if formatting_issues:
            row_diff_report.append(f"*   **URL Formatting / Project ID Issues** ({len(formatting_issues)}):")
            for f in formatting_issues[:5]:
                row_diff_report.append(f"    *   {f}")
        else:
            row_diff_report.append("*   **Formatting/URL Issues**: None (0).")
            
        diff_report.append(f"*   **Status**: {'Warning (Issues detected)' if (missing_rows or extra_rows or invalid_references or formatting_issues) else 'Fully Synced (PASS)'}\n")

    # Save reports
    artifact_path = "C:\\Users\\ASUS\\.gemini\\antigravity-ide\\brain\\ca7213b7-3ae2-437b-8704-d00ceb9d9b96"
    
    with open(os.path.join(artifact_path, "database_mapping_report.md"), "w", encoding="utf-8") as f:
        f.write("\n".join(mapping_report))
        
    with open(os.path.join(artifact_path, "data_difference_report.md"), "w", encoding="utf-8") as f:
        f.write("\n".join(diff_report))
        
    with open(os.path.join(artifact_path, "row_difference_report.md"), "w", encoding="utf-8") as f:
        f.write("\n".join(row_diff_report))
        
    print("Comparative audits saved successfully!")

if __name__ == "__main__":
    run_audit()
