import os
import json
import sys
from datetime import datetime
import firebase_admin
from firebase_admin import credentials, firestore

FIREBASE_CERT_PATH = os.path.abspath(os.path.join(
    os.path.dirname(__file__), 
    '../credentials/serviceAccountKey.json'
))

def get_firestore_client():
    if os.path.exists(FIREBASE_CERT_PATH):
        cred = credentials.Certificate(FIREBASE_CERT_PATH)
        firebase_admin.initialize_app(cred)
    else:
        # Fallback to default search path
        fallback = os.path.abspath(os.path.join(os.path.dirname(__file__), '../serviceAccountKey.json'))
        if os.path.exists(fallback):
            cred = credentials.Certificate(fallback)
            firebase_admin.initialize_app(cred)
        else:
            try:
                firebase_admin.initialize_app()
            except Exception as e:
                print(f"Error: Firebase credentials not resolved. Detail: {e}")
                sys.exit(1)
    return firestore.client()

def get_type_name(val):
    if val is None:
        return "NULL"
    elif isinstance(val, bool):
        return "BOOLEAN"
    elif isinstance(val, int):
        return "NUMBER"
    elif isinstance(val, float):
        return "NUMBER"
    elif isinstance(val, str):
        return "STRING"
    elif isinstance(val, datetime):
        return "TIMESTAMP"
    elif isinstance(val, list):
        return "ARRAY"
    elif isinstance(val, dict):
        return "MAP"
    elif hasattr(val, 'latitude') and hasattr(val, 'longitude'):
        return "GEOPOINT"
    elif hasattr(val, 'path'):
        return "REFERENCE"
    return type(val).__name__.upper()

def convert_value(val):
    if isinstance(val, datetime):
        return val.isoformat()
    elif isinstance(val, list):
        return [convert_value(x) for x in val]
    elif isinstance(val, dict):
        return {k: convert_value(v) for k, v in val.items()}
    elif hasattr(val, 'latitude') and hasattr(val, 'longitude'):
        return {"latitude": val.latitude, "longitude": val.longitude}
    elif hasattr(val, 'path'):
        return val.path
    return val

def discover_relationship(col_name, field_name):
    # Standard inferred relationship rules
    relationships = {
        ("services", "category_id"): "service_categories.id",
        ("experiences", "category_id"): "categories.id",
        ("bookings", "user_id"): "users.id",
        ("bookings", "customer_id"): "customer_profiles.id",
        ("gallery", "booking_id"): "bookings.id",
        ("gallery", "service_id"): "services.id",
        ("gallery", "experience_id"): "experiences.id",
        ("inquiries", "user_id"): "users.id",
        ("leads", "customer_id"): "customer_profiles.id",
        ("quotations", "customer_id"): "customer_profiles.id",
        ("customer_quotes", "customer_id"): "customer_profiles.id",
        ("customer_leads", "customer_id"): "customer_profiles.id",
        ("customer_bookings", "customer_id"): "customer_profiles.id",
        ("customer_payments", "customer_id"): "customer_profiles.id",
        ("customer_payments", "booking_id"): "customer_bookings.id",
        ("customer_notifications", "customer_id"): "customer_profiles.id",
        ("customer_wishlist", "customer_id"): "customer_profiles.id",
        ("customer_wishlist", "experience_id"): "experiences.id",
        ("customer_documents", "customer_id"): "customer_profiles.id",
        ("customer_documents", "booking_id"): "customer_bookings.id",
        ("booking_gallery", "customer_id"): "customer_profiles.id",
        ("booking_gallery", "booking_id"): "customer_bookings.id",
        ("rebook_requests", "customer_id"): "customer_profiles.id",
        ("rebook_requests", "previous_booking_id"): "customer_bookings.id",
        ("customer_activity", "customer_id"): "customer_profiles.id",
        ("chat_messages", "room_id"): "chat_rooms.id",
        ("admins", "role_id"): "roles.id",
        ("role_permissions", "role_id"): "roles.id",
        ("role_permissions", "permission_id"): "permissions.id"
    }
    
    # Generic matches
    if (col_name, field_name) in relationships:
        return relationships[(col_name, field_name)]
    elif field_name == "category_id" or field_name == "categoryId":
        return "service_categories.id"
    elif field_name == "user_id" or field_name == "userId":
        return "users.id"
    elif field_name == "booking_id" or field_name == "bookingId":
        return "bookings.id"
    elif field_name == "role_id" or field_name == "roleId":
        return "roles.id"
    return None

def main():
    db = get_firestore_client()
    
    # Pre-defined list to check + automatic discovery
    target_collections = [
        "admins", "bookings", "chat_rooms", "device_tokens", "gallery",
        "inquiries", "notifications", "permissions", "reviews", "roles",
        "service_categories", "services", "settings", "users"
    ]
    
    # Detect all root collections
    root_collections = [c.id for c in db.collections()]
    for rc in root_collections:
        if rc not in target_collections:
            target_collections.append(rc)
            
    schema_report = {}
    sample_data = {}
    
    print("Beginning Firestore Schema Discovery...")
    
    for col_name in target_collections:
        print(f"Scanning collection: {col_name}")
        col_ref = db.collection(col_name)
        docs = list(col_ref.stream())
        doc_count = len(docs)
        
        # Analyze fields across all docs
        fields_def = {}
        sample_docs = []
        
        # Pull 2 samples
        for doc in docs[:2]:
            sample_docs.append({
                "id": doc.id,
                "data": convert_value(doc.to_dict())
            })
            
        sample_data[col_name] = sample_docs
        
        # Perform schema analysis
        for doc in docs:
            doc_data = doc.to_dict()
            for key, val in doc_data.items():
                t_name = get_type_name(val)
                is_nullable = (val is None)
                
                if key not in fields_def:
                    fields_def[key] = {
                        "type": t_name,
                        "nullable": is_nullable,
                        "required": True,
                        "example": convert_value(val)
                    }
                else:
                    # Update nullable/type union
                    if is_nullable:
                        fields_def[key]["nullable"] = True
                    if fields_def[key]["type"] != t_name and t_name != "NULL":
                        fields_def[key]["type"] = f"{fields_def[key]['type']}|{t_name}"
                        
        # Mark missing fields as not required (since they don't appear in all documents)
        for key in fields_def.keys():
            in_all = True
            for doc in docs:
                if key not in doc.to_dict():
                    in_all = False
                    break
            fields_def[key]["required"] = in_all
            
        # Discover relationships
        relationships = []
        for field in fields_def.keys():
            rel = discover_relationship(col_name, field)
            if rel:
                relationships.append({
                    "field": field,
                    "target": rel
                })
                
        schema_report[col_name] = {
            "count": doc_count,
            "fields": fields_def,
            "relationships": relationships
        }
        
    # Write output files
    workspace_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    
    # 1. firestore_schema.json
    with open(os.path.join(workspace_root, "firestore_schema.json"), "w", encoding="utf-8") as f:
        json.dump(schema_report, f, indent=2)
        
    # 2. firestore_sample_data.json
    with open(os.path.join(workspace_root, "firestore_sample_data.json"), "w", encoding="utf-8") as f:
        json.dump(sample_data, f, indent=2)
        
    # 3. firestore_schema.md
    with open(os.path.join(workspace_root, "firestore_schema.md"), "w", encoding="utf-8") as f:
        f.write("# Firestore Catalog Schema Specification\n\n")
        for col_name, data in schema_report.items():
            f.write(f"## Collection: `{col_name}`\n")
            f.write(f"- **Document Count**: {data['count']}\n\n")
            f.write("### Fields Union\n")
            f.write("| Field Name | Type | Nullable | Required | Example Value |\n")
            f.write("| :--- | :--- | :--- | :--- |\n")
            for field, f_data in data["fields"].items():
                example_str = str(f_data["example"]) if f_data["example"] is not None else "null"
                if len(example_str) > 60:
                    example_str = example_str[:57] + "..."
                f.write(f"| `{field}` | {f_data['type']} | {f_data['nullable']} | {f_data['required']} | `{example_str}` |\n")
            
            if data["relationships"]:
                f.write("\n### Possible Foreign Keys\n")
                for r in data["relationships"]:
                    f.write(f"- `{r['field']}` &rarr; `{r['target']}`\n")
            f.write("\n")
            
    # 4. migration_mapping.md
    with open(os.path.join(workspace_root, "migration_mapping.md"), "w", encoding="utf-8") as f:
        f.write("# Firestore to Supabase Migration Mapping\n\n")
        f.write("| Firestore Collection | Supabase Table | Primary Key | Key Field Mappings |\n")
        f.write("| :--- | :--- | :--- | :--- |\n")
        for col_name in schema_report.keys():
            # Inferred target table and mapping
            target_table = col_name
            pk = "id"
            mappings = []
            
            # Map camelCase to snake_case
            fields = schema_report[col_name]["fields"].keys()
            for field in fields:
                snake = ''.join(['_' + c.lower() if c.isupper() else c for c in field]).lstrip('_')
                if snake != field:
                    mappings.append(f"`{field}` &rarr; `{snake}`")
                    
            mapping_str = ", ".join(mappings) if mappings else "Direct Match"
            f.write(f"| `{col_name}` | `public.{target_table}` | `{pk}` | {mapping_str} |\n")
            
    print("Schema Discovery complete. Reports successfully generated.")

if __name__ == "__main__":
    main()
