import os
import json
import sys
import firebase_admin
from firebase_admin import credentials, firestore

FIREBASE_CERT_PATH = os.path.abspath(
    os.path.join(
        os.path.dirname(__file__),
        "../credentials/serviceAccountKey.json"
    )
)
def main():
    print("Using Firebase key:")
    print(FIREBASE_CERT_PATH)
    print("Exists:", os.path.exists(FIREBASE_CERT_PATH))
    if os.path.exists(FIREBASE_CERT_PATH):
        cred = credentials.Certificate(FIREBASE_CERT_PATH)
        firebase_admin.initialize_app(cred)
    else:
        try:
            firebase_admin.initialize_app()
        except Exception as e:
            print("Error: Firebase credentials not resolved.")
            print("Please set GOOGLE_APPLICATION_CREDENTIALS or place serviceAccountKey.json in the project root.")
            print(f"Detail: {e}")
            sys.exit(1)
            
    db = firestore.client()
    
    collections = [
        "admins",
        "bookings",
        "chat_rooms",
        "device_tokens",
        "gallery",
        "inquiries",
        "notifications",
        "permissions",
        "reviews",
        "roles",
        "service_categories",
        "services",
        "settings",
        "users"
    ]
    
    counts = {}
    total = 0
    
    print("=====================================")
    print("FIRESTORE COLLECTION COUNTS")
    print("=====================================")
    
    for col in collections:
        try:
            # Attempt optimized aggregation count
            try:
                count_query = db.collection(col).count()
                result = count_query.get()
                count_val = result[0][0].value
            except AttributeError:
                # Fallback to document references list (no payload download)
                docs = db.collection(col).list_documents()
                count_val = sum(1 for _ in docs)
                
            counts[col] = count_val
            total += count_val
            print(f"{col:<20} : {count_val}")
        except Exception as e:
            counts[col] = -1
            print(f"{col:<20} : ERROR ({e})")
            
    print(f"\nTotal Documents: {total}")
    
    # Save reports
    workspace_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    
    json_path = os.path.join(workspace_root, "firestore_counts.json")
    with open(json_path, "w") as f:
        json.dump({"counts": counts, "total": total}, f, indent=2)
        
    md_path = os.path.join(workspace_root, "firestore_counts.md")
    with open(md_path, "w") as f:
        f.write("# Firestore Collection Counts Report\n\n")
        f.write("```\n")
        f.write("=====================================\n")
        f.write("FIRESTORE COLLECTION COUNTS\n")
        f.write("=====================================\n\n")
        for col, val in counts.items():
            f.write(f"{col:<20} : {val if val != -1 else 'ERROR'}\n")
        f.write(f"\nTotal Documents: {total}\n")
        f.write("=====================================\n")
        f.write("```\n")

if __name__ == "__main__":
    main()
