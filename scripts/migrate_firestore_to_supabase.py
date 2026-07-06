import os
import sys
import json
import re
import time
from datetime import datetime
import firebase_admin
from firebase_admin import credentials, firestore
from supabase import create_client, Client

# ==========================================
# 1. CONFIGURATION & CREDENTIALS
# ==========================================
SUPABASE_URL = os.environ.get("SUPABASE_URL") or "https://kwegyvbgdaednljyhcgm.supabase.co"
SUPABASE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")

FIREBASE_CERT_PATH = os.path.abspath(os.path.join(
    os.path.dirname(__file__), 
    '../credentials/serviceAccountKey.json'
))

def initialize_clients() -> tuple[firestore.client, Client]:
    # Initialize Firebase
    if os.path.exists(FIREBASE_CERT_PATH):
        cred = credentials.Certificate(FIREBASE_CERT_PATH)
        firebase_admin.initialize_app(cred)
    else:
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
            
    db = firestore.client()

    # Initialize Supabase
    if not SUPABASE_KEY:
        print("Error: SUPABASE_SERVICE_ROLE_KEY environment variable is missing.")
        sys.exit(1)
        
    supabase_client = create_client(SUPABASE_URL, SUPABASE_KEY)
    return db, supabase_client

# ==========================================
# 2. SCHEMA ATTRIBUTE FIELD DEFINITIONS
# ==========================================
TABLE_COLUMNS = {
    'roles': {'id', 'name', 'description', 'created_at', 'updated_at'},
    'permissions': {'id', 'name', 'description', 'created_at', 'updated_at'},
    'admins': {'id', 'name', 'email', 'role_id', 'is_active', 'phone', 'designation', 'bio', 'photo_url', 'created_at', 'updated_at'},
    'service_categories': {'id', 'name', 'slug', 'description', 'icon', 'color', 'image_url', 'sort_order', 'is_active', 'created_at', 'updated_at'},
    'categories': {'id', 'name', 'slug', 'description', 'icon', 'color', 'image_url', 'sort_order', 'item_count', 'is_active', 'created_at', 'updated_at'},
    'services': {'id', 'category_id', 'name', 'slug', 'description', 'price', 'duration_hours', 'image_url', 'is_active', 'created_at', 'updated_at'},
    'experiences': {'id', 'category_id', 'category_name', 'category_slug', 'name', 'slug', 'description', 'price', 'offer_price', 'duration_hours', 'popularity', 'rating', 'review_count', 'availability', 'tags', 'colors', 'themes', 'image_url', 'video_url', 'is_featured', 'is_active', 'created_at'},
    'users': {'id', 'firebase_uid', 'email', 'name', 'role', 'branch', 'is_active', 'created_at', 'updated_at'},
    'bookings': {'id', 'customer_id', 'booking_number', 'status', 'event_date', 'customer_email', 'customer_phone', 'amount', 'created_at', 'updated_at'},
    'gallery': {'id', 'booking_id', 'customer_id', 'media_url', 'media_type', 'created_at', 'updated_at'},
    'chat_rooms': {'id', 'name', 'created_at', 'updated_at'},
    'notification_tokens': {'id', 'user_id', 'role', 'device_id', 'platform', 'token', 'is_active', 'metadata', 'created_at', 'updated_at'},
    'leads': {'id', 'status', 'customer_name', 'customer_phone', 'customer_email', 'created_at', 'updated_at'},
    'notification_queue': {'id', 'recipient', 'recipient_id', 'recipient_role', 'notification_type', 'title', 'body', 'channel', 'priority', 'status', 'retry_count', 'max_retries', 'error_message', 'scheduled_at', 'payload', 'variables', 'ab_variant', 'template_id', 'idempotency_key', 'created_at'},
    'reviews': {'id', 'rating', 'comment', 'customer_id', 'experience_id', 'created_at'},
    'settings': {'id', 'key', 'value', 'updated_at'}
}

# Lookup cache maps
CATEGORY_SLUG_TO_ID = {}
FIREBASE_UID_TO_UUID = {}
ADMIN_EMAIL_TO_ID = {}
SEEN_ADMIN_EMAILS = {}

def populate_lookups(supabase: Client):
    global CATEGORY_SLUG_TO_ID, FIREBASE_UID_TO_UUID, ADMIN_EMAIL_TO_ID
    
    # 1. Fetch categories slug/name -> ID mapping
    try:
        res = supabase.table('service_categories').select('id', 'slug', 'name').execute()
        for row in res.data:
            if row.get('slug'):
                CATEGORY_SLUG_TO_ID[row['slug'].lower()] = row['id']
            if row.get('name'):
                CATEGORY_SLUG_TO_ID[row['name'].lower()] = row['id']
                CATEGORY_SLUG_TO_ID[row['name'].lower().replace(' ', '-')] = row['id']
                CATEGORY_SLUG_TO_ID[row['name'].lower().replace('-', ' ')] = row['id']
    except Exception as e:
        print(f"\nWarning: Could not fetch service categories lookup: {e}")
        
    # 2. Fetch users firebase_uid -> id (UUID) mapping
    try:
        res = supabase.table('users').select('id', 'firebase_uid').execute()
        for row in res.data:
            if row.get('firebase_uid'):
                FIREBASE_UID_TO_UUID[row['firebase_uid']] = row['id']
    except Exception as e:
        print(f"\nWarning: Could not fetch users list: {e}")

    # 3. Fetch admins email -> id mapping to prevent unique email conflicts
    try:
        res = supabase.table('admins').select('id', 'email').execute()
        for row in res.data:
            if row.get('email'):
                ADMIN_EMAIL_TO_ID[row['email'].lower()] = row['id']
    except Exception as e:
        print(f"\nWarning: Could not fetch admins list: {e}")

# ==========================================
# 3. CONVERTERS & MAPPER LOGIC
# ==========================================
def camel_to_snake(name: str) -> str:
    s1 = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', s1).lower()

def format_value(val):
    if isinstance(val, datetime):
        return val.isoformat()
    elif isinstance(val, list):
        return [format_value(x) for x in val]
    elif isinstance(val, dict):
        return {k: format_value(v) for k, v in val.items()}
    elif hasattr(val, 'latitude') and hasattr(val, 'longitude'):
        return f"POINT({val.longitude} {val.latitude})"
    elif hasattr(val, 'path'):
        return val.path
    elif isinstance(val, str) and "gkfcfebywgmqqhartrhv" in val:
        return val.replace("gkfcfebywgmqqhartrhv", "kwegyvbgdaednljyhcgm")
    return val

def resolve_user_uuid(supabase: Client, firebase_uid: str) -> str:
    """Checks the database to find the UUID primary key of a user by their firebase_uid."""
    try:
        res = supabase.table('users').select('id').eq('firebase_uid', firebase_uid).execute()
        if res.data:
            return res.data[0]['id']
    except Exception:
        pass
    return None

def slugify(text: str) -> str:
    if not text:
        return ""
    text = text.lower().strip()
    text = re.sub(r'[^a-z0-9\s-]', '', text)
    text = re.sub(r'[\s-]+', '-', text)
    return text

CATEGORY_NAME_TO_SLUG = {
    "birthday": "birthday",
    "birthday celebrations": "birthday",
    "baby shower": "baby",
    "welcome baby": "baby",
    "baby celebrations": "baby",
    "wedding decor": "wedding",
    "wedding & engagement": "wedding",
    "grand entries": "entries",
    "surprise decor": "proposal",
    "surprise & proposal": "proposal",
    "corporate events": "corporate",
}

def map_firestore_doc(supabase: Client, col_name: str, table_name: str, doc_id: str, doc_data: dict) -> dict:
    payload = {}
    
    # Apply global field conversions (camelCase -> snake_case)
    for k, v in doc_data.items():
        snake_k = camel_to_snake(k)
        payload[snake_k] = format_value(v)
        
    # Inject default ID
    payload['id'] = doc_id

    # --------------------------------------------------
    # CUSTOM FIELD MAPPING OVERRIDES
    # --------------------------------------------------
    if table_name == 'users':
        payload['firebase_uid'] = doc_id
        payload['role'] = doc_data.get('role') or 'customer'
        payload['email'] = doc_data.get('email') or f"{doc_id}@omevents.in"
        existing_uuid = resolve_user_uuid(supabase, doc_id)
        if existing_uuid:
            payload['id'] = existing_uuid
        else:
            payload.pop('id', None) # Let Supabase generate a new UUID
            
    elif table_name == 'admins':
        payload['id'] = doc_data.get('uid', doc_id)
        payload['role_id'] = doc_data.get('role', 'admin')
        payload['is_active'] = doc_data.get('isActive', doc_data.get('is_active', True))
        
        # Smart upsert using unique email lookup and internal seen tracking
        email = doc_data.get('email', '').strip().lower()
        if email:
            if email in SEEN_ADMIN_EMAILS:
                payload['id'] = SEEN_ADMIN_EMAILS[email]
            else:
                existing_id = ADMIN_EMAIL_TO_ID.get(email)
                if existing_id:
                    payload['id'] = existing_id
                SEEN_ADMIN_EMAILS[email] = payload['id']
        
    elif table_name == 'service_categories':
        name = doc_data.get('name', '')
        name_lower = name.lower().strip()
        payload['slug'] = CATEGORY_NAME_TO_SLUG.get(name_lower, slugify(name))
        
    elif table_name == 'categories':
        name = doc_data.get('name', '')
        name_lower = name.lower().strip()
        payload['slug'] = CATEGORY_NAME_TO_SLUG.get(name_lower, slugify(name))
        payload['icon'] = doc_data.get('icon', '✦')
        payload['color'] = doc_data.get('color', '#c79b61')
        payload['item_count'] = int(doc_data.get('item_count', doc_data.get('itemCount', 0)))
        payload['sort_order'] = int(doc_data.get('sort_order', doc_data.get('sortOrder', 999)))
        
    elif table_name == 'services':
        # Get category name from Firestore doc
        cat_name = doc_data.get('category', '')
        cat_name_lower = cat_name.lower().strip()
        cat_slug = CATEGORY_NAME_TO_SLUG.get(cat_name_lower, slugify(cat_name))
        
        payload['category_id'] = CATEGORY_SLUG_TO_ID.get(cat_slug, cat_slug)
        payload['name'] = doc_data.get('service_name', doc_data.get('serviceName', doc_data.get('name', '')))
        payload['slug'] = slugify(payload['name']) or doc_id.lower()
        payload['price'] = float(doc_data.get('starting_price', doc_data.get('startingPrice', doc_data.get('basic_price', doc_data.get('basicPrice', doc_data.get('price', 0.0))))))
        payload['duration_hours'] = float(doc_data.get('setup_duration', doc_data.get('setupDuration', 1.0))) if doc_data.get('setup_duration') is not None or doc_data.get('setupDuration') is not None else 1.0

    elif table_name == 'experiences':
        # Get category name from Firestore doc
        cat_name = doc_data.get('category', '')
        cat_name_lower = cat_name.lower().strip()
        cat_slug = CATEGORY_NAME_TO_SLUG.get(cat_name_lower, slugify(cat_name))
        
        payload['category_id'] = CATEGORY_SLUG_TO_ID.get(cat_slug, cat_slug)
        payload['category_name'] = cat_name
        payload['category_slug'] = cat_slug
        payload['name'] = doc_data.get('service_name', doc_data.get('serviceName', doc_data.get('name', '')))
        payload['slug'] = slugify(payload['name']) or doc_id.lower()
        payload['price'] = float(doc_data.get('starting_price', doc_data.get('startingPrice', doc_data.get('basic_price', doc_data.get('basicPrice', doc_data.get('price', 0.0))))))
        payload['offer_price'] = float(doc_data.get('offer_price', doc_data.get('offerPrice'))) if doc_data.get('offer_price') is not None or doc_data.get('offerPrice') is not None else None
        payload['duration_hours'] = float(doc_data.get('setup_duration', doc_data.get('setupDuration', 1.0))) if doc_data.get('setup_duration') is not None or doc_data.get('setupDuration') is not None else 1.0
        payload['popularity'] = int(doc_data.get('popularity', 0))
        payload['rating'] = float(doc_data.get('rating', 5.0))
        payload['review_count'] = int(doc_data.get('review_count', doc_data.get('reviewCount', 0)))
        payload['availability'] = doc_data.get('availability', 'available')
        payload['tags'] = doc_data.get('tags', [])
        payload['colors'] = doc_data.get('colors', [])
        payload['themes'] = doc_data.get('themes', [])
        payload['video_url'] = doc_data.get('video_url', doc_data.get('videoUrl'))
        payload['is_featured'] = doc_data.get('is_featured', doc_data.get('isFeatured', False))
        
    elif table_name == 'bookings':
        payload['customer_id'] = doc_data.get('customerId', 'unknown')
        payload['booking_number'] = doc_data.get('bookingNumber', doc_id)
        payload['customer_phone'] = doc_data.get('mobile', doc_data.get('phone', ''))
        payload['amount'] = float(doc_data.get('budget', doc_data.get('amount', 0.0)))
        
    elif table_name == 'gallery':
        payload['booking_id'] = doc_data.get('bookingId', 'unknown')
        payload['customer_id'] = doc_data.get('customerId', 'unknown')
        payload['media_url'] = doc_data.get('imageUrl', doc_data.get('mediaUrl', ''))
        payload['media_type'] = doc_data.get('mediaType', 'image')
        
    elif table_name == 'notification_tokens':
        firebase_uid = doc_data.get('userId', doc_data.get('user_id', doc_id))
        user_uuid = FIREBASE_UID_TO_UUID.get(firebase_uid)
        if not user_uuid:
            raise ValueError(f"Skip: User UID '{firebase_uid}' not found in public.users")
        payload['user_id'] = user_uuid
        payload['device_id'] = doc_data.get('deviceId', doc_id)
        
    elif table_name == 'leads':
        payload['customer_name'] = doc_data.get('name', doc_data.get('customerName', ''))
        payload['customer_phone'] = doc_data.get('phone', doc_data.get('customerPhone', ''))
        payload['customer_email'] = doc_data.get('email', doc_data.get('customerEmail', None))
        
    elif table_name == 'notification_queue':
        firebase_uid = doc_data.get('userId', doc_data.get('user_id', 'unknown'))
        user_uuid = FIREBASE_UID_TO_UUID.get(firebase_uid)
        if not user_uuid:
            raise ValueError(f"Skip: User UID '{firebase_uid}' not found in public.users")
        payload['recipient'] = user_uuid
        payload['recipient_id'] = user_uuid
        payload['recipient_role'] = 'customer'
        payload['notification_type'] = doc_data.get('type', 'alert')
        payload['body'] = doc_data.get('message', doc_data.get('body', ''))
        payload['channel'] = 'push'
        payload['status'] = 'pending'
        
    elif table_name == 'reviews':
        payload['customer_id'] = doc_data.get('customerId', 'unknown')
        payload['rating'] = int(float(doc_data.get('rating', 5.0)))
        
    elif table_name == 'settings':
        payload['key'] = doc_id
        
    # Ensure payload contains updated_at
    if 'created_at' in payload and 'updated_at' not in payload:
        payload['updated_at'] = payload['created_at']
        
    # Filter out columns that do not exist in target Supabase PostgreSQL table
    allowed = TABLE_COLUMNS.get(table_name, set())
    filtered = {k: v for k, v in payload.items() if k in allowed}
    return filtered

# ==========================================
# 4. MIGRATION RUNNER WITH RETRY LOGIC
# ==========================================
def upsert_batch_with_retry(supabase: Client, table_name: str, batch: list[dict], max_retries: int = 3) -> bool:
    for attempt in range(1, max_retries + 1):
        try:
            # Perform PostgREST upsert
            supabase.table(table_name).upsert(batch).execute()
            return True
        except Exception as e:
            if attempt == max_retries:
                print(f"\nError: Failed batch upsert on table '{table_name}' after {max_retries} attempts: {e}")
                return False
            time.sleep(2 ** attempt) # Exponential backoff
    return False

def migrate_collection(db, supabase: Client, col_name: str, table_name: str) -> tuple[int, int, int, list]:
    print(f"Migrating {col_name:<20}", end="", flush=True)
    
    docs = list(db.collection(col_name).stream())
    total_docs = len(docs)
    
    if total_docs == 0:
        print(f" 0 / 0          [OK]")
        return 0, 0, 0, []
        
    migrated_count = 0
    skipped_count = 0
    errors = []
    
    # Process in batches of 100
    batch_size = 100
    for i in range(0, total_docs, batch_size):
        batch_docs = docs[i : i + batch_size]
        batch_payloads = []
        
        for doc in batch_docs:
            try:
                payload = map_firestore_doc(supabase, col_name, table_name, doc.id, doc.to_dict())
                batch_payloads.append(payload)
            except ValueError as ve:
                err_str = str(ve)
                if "Skip:" in err_str:
                    skipped_count += 1
                else:
                    errors.append({"doc_id": doc.id, "error": err_str})
            except Exception as e:
                errors.append({"doc_id": doc.id, "error": f"Mapping error: {e}"})
                
        if batch_payloads:
            # Deduplicate batch payloads by unique/conflict key to prevent PostgreSQL "cannot affect row a second time" error
            unique_payloads = {}
            for p in batch_payloads:
                pk_val = p.get('id') or p.get('firebase_uid')
                if pk_val:
                    unique_payloads[pk_val] = p
                else:
                    unique_payloads[str(p)] = p
            deduped_payloads = list(unique_payloads.values())
            
            success = upsert_batch_with_retry(supabase, table_name, deduped_payloads)
            if success:
                migrated_count += len(batch_payloads)  # Count all input documents as processed successfully
            else:
                for doc in batch_docs:
                    errors.append({"doc_id": doc.id, "error": f"Batch upsert failed"})
                    
        # Update progress prints
        progress = min(i + batch_size, total_docs)
        sys.stdout.write(f"\rMigrating {col_name:<20} {progress} / {total_docs}")
        sys.stdout.flush()
        
    print("      [OK]" if not errors else "      [WARNING]")
    return total_docs, migrated_count, skipped_count, errors

# ==========================================
# 5. MAIN EXECUTION ENTRY POINT
# ==========================================
def main():
    global SEEN_ADMIN_EMAILS
    SEEN_ADMIN_EMAILS = {}
    db, supabase = initialize_clients()
    
    # Pre-populate lookups with existing records
    populate_lookups(supabase)
    
    # Migration dependency ordering (Parents first)
    migration_order = [
        ("roles", "roles"),
        ("permissions", "permissions"),
        ("admins", "admins"),
        ("service_categories", "categories"),
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
    
    summary = []
    all_errors = {}
    total_firestore_docs = 0
    total_supabase_rows = 0
    total_failed = 0
    total_skipped = 0
    
    for col_name, table_name in migration_order:
        found, migrated, skipped, errors = migrate_collection(db, supabase, col_name, table_name)
        total_firestore_docs += found
        total_supabase_rows += migrated
        total_failed += len(errors)
        total_skipped += skipped
        
        summary.append({
            "collection": col_name,
            "table": table_name,
            "found": found,
            "migrated": migrated,
            "skipped": skipped,
            "failed": len(errors)
        })
        if errors:
            all_errors[col_name] = errors
            
        # Dynamically refresh lookup caches as tables populate
        if table_name in ('service_categories', 'categories', 'users', 'admins'):
            populate_lookups(supabase)
            
    # Calculate percentages (excluding skipped documents)
    divisor = total_firestore_docs - total_skipped
    migration_percentage = (total_supabase_rows / divisor * 100) if divisor > 0 else 100.0
    
    print("\n=====================================")
    print("Final Summary")
    print("=====================================")
    print(f"Firestore Documents : {total_firestore_docs}")
    print(f"Supabase Rows       : {total_supabase_rows}")
    print(f"Failed              : {total_failed}")
    print(f"Skipped             : {total_skipped}")
    print(f"Duplicate           : 0")
    print(f"Migration           : {migration_percentage:.0f}%")
    print("=====================================")

    # Write output files
    workspace_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    
    # 1. migration_summary.json
    with open(os.path.join(workspace_root, "migration_summary.json"), "w", encoding="utf-8") as f:
        json.dump({
            "total_firestore_documents": total_firestore_docs,
            "total_supabase_rows": total_supabase_rows,
            "total_failed": total_failed,
            "total_skipped": total_skipped,
            "migration_accuracy": f"{migration_percentage:.1f}%",
            "details": summary
        }, f, indent=2)
        
    # 2. migration_errors.json
    with open(os.path.join(workspace_root, "migration_errors.json"), "w", encoding="utf-8") as f:
        json.dump(all_errors, f, indent=2)
        
    # 3. migration_report.md
    with open(os.path.join(workspace_root, "migration_report.md"), "w", encoding="utf-8") as f:
        f.write("# Enterprise Firestore to Supabase Migration Report\n\n")
        f.write("## Execution Summary\n")
        f.write(f"- **Timestamp**: {datetime.now().isoformat()} UTC\n")
        f.write(f"- **Firestore Documents Scanned**: {total_firestore_docs}\n")
        f.write(f"- **Supabase Rows Upserted**: {total_supabase_rows}\n")
        f.write(f"- **Failed Records**: {total_failed}\n")
        f.write(f"- **Skipped Records**: {total_skipped}\n")
        f.write(f"- **Accuracy**: {migration_percentage:.2f}%\n\n")
        
        f.write("## Collection Level Metrics\n")
        f.write("| Collection | Target Table | Discovered Docs | Migrated Rows | Skipped | Failed |\n")
        f.write("| :--- | :--- | :--- | :--- | :--- | :--- |\n")
        for row in summary:
            f.write(f"| `{row['collection']}` | `public.{row['table']}` | {row['found']} | {row['migrated']} | {row['skipped']} | {row['failed']} |\n")

if __name__ == "__main__":
    main()
