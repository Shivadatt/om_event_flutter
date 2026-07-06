import os
import sys

def main():
    print("Python Executable:", sys.executable)
    print("Current Directory:", os.getcwd())
    
    # Try importing firebase_admin
    try:
        import firebase_admin
        from firebase_admin import credentials, firestore
        print("firebase_admin is installed.")
    except ImportError:
        print("firebase_admin is not installed. Attempting to install...")
        import subprocess
        subprocess.check_call([sys.executable, "-m", "pip", "install", "firebase-admin", "supabase", "requests"])
        import firebase_admin
        from firebase_admin import credentials, firestore
        print("firebase_admin successfully installed.")

    # Check for serviceAccountKey
    cert_options = [
        "serviceAccountKey.json",
        "../serviceAccountKey.json",
        "functions/serviceAccountKey.json",
    ]
    found_cert = None
    for opt in cert_options:
        if os.path.exists(opt):
            found_cert = os.path.abspath(opt)
            print(f"Found credential cert at: {found_cert}")
            break
            
    if not found_cert:
        print("No serviceAccountKey.json found. Will try Default Application Credentials.")
        
    try:
        if found_cert:
            cred = credentials.Certificate(found_cert)
            firebase_admin.initialize_app(cred)
        else:
            # Let it try default credentials or environment
            firebase_admin.initialize_app()
        db = firestore.client()
        print("Firebase Admin SDK initialized successfully!")
        
        # List all collections
        collections = db.collections()
        col_names = [col.id for col in collections]
        print("Found Firestore Collections:", col_names)
        
        for col_name in col_names:
            docs = list(db.collection(col_name).limit(5).stream())
            print(f"Collection '{col_name}': {len(docs)} documents (sample checked)")
            
    except Exception as e:
        print("Error connecting to Firestore:", str(e))
        print("Attempting local Firestore emulator probe...")
        # Check if FIRESTORE_EMULATOR_HOST is set
        emulator_host = os.environ.get("FIRESTORE_EMULATOR_HOST")
        print("FIRESTORE_EMULATOR_HOST:", emulator_host)

if __name__ == "__main__":
    main()
