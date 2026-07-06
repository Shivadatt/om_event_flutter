import os
import re
from supabase import create_client

# Suppress warnings
import warnings
warnings.filterwarnings("ignore", category=UserWarning)

SUPABASE_URL = "https://kwegyvbgdaednljyhcgm.supabase.co"
SUPABASE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY") or "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt3ZWd5dmJnZGFlZG5sanloY2dtIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MjY4NDk1MywiZXhwIjoyMDk4MjYwOTUzfQ.Jr8kBFix864HBflFzIn0ztXqSzx7qDU3z7huPV997YQ"

LOCAL_IMAGES_DIR = "assets/images"

def get_best_local_image(storage_path):
    path_lower = storage_path.lower()
    if "chhathi" in path_lower or "chhathhi" in path_lower:
        return "Chhathhi.jpg"
    elif "baby" in path_lower or "shower" in path_lower:
        if "welcome" in path_lower:
            return "welcomebaby.jpg"
        return "babyshower.jpg"
    elif "birthday" in path_lower or "balloon" in path_lower or "blast" in path_lower:
        if "blast" in path_lower:
            return "BaloonBlast.jpg"
        return "birthday.jpg"
    elif "wedding" in path_lower or "rasam" in path_lower or "haldi" in path_lower or "mehndi" in path_lower:
        if "rasam" in path_lower or "vanarasam" in path_lower:
            return "Vanarasam.jpg"
        if "mehndi" in path_lower:
            return "mehndi.jpg"
        return "wedding-stage.jpg"
    elif "pyro" in path_lower or "smoke" in path_lower or "entry" in path_lower:
        if "pyro" in path_lower:
            return "Pyro.jpg"
        return "SmokeEntry.jpg"
    elif "proposal" in path_lower or "candle" in path_lower:
        return "proposal-candles.jpg"
    elif "corporate" in path_lower or "reception" in path_lower:
        return "luxury-reception.jpg"
    
    return "birthday.jpg"

def main():
    supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    print("Fetching experiences and gallery records to map image paths...")
    records = []
    
    # 1. Fetch experiences image URLs
    try:
        res = supabase.table("experiences").select("image_url").execute()
        records.extend([r["image_url"] for r in res.data if r.get("image_url")])
    except Exception as e:
        print(f"Error fetching experiences: {e}")
        
    # 2. Fetch gallery media URLs
    try:
        res = supabase.table("gallery").select("media_url").execute()
        records.extend([r["media_url"] for r in res.data if r.get("media_url")])
    except Exception as e:
        print(f"Error fetching gallery: {e}")

    # Deduplicate URLs
    urls = list(set(records))
    print(f"Found {len(urls)} unique storage URLs in database.")

    uploaded_count = 0
    for url in urls:
        if "storage/v1/object/public/gallery/" not in url:
            continue
            
        parts = url.split("storage/v1/object/public/gallery/")
        if len(parts) < 2:
            continue
        storage_path = parts[1]
        
        # Determine best local file matching this path
        local_filename = get_best_local_image(storage_path)
        local_path = os.path.join(LOCAL_IMAGES_DIR, local_filename)
        
        if not os.path.exists(local_path):
            continue
            
        # Upload to Supabase Storage
        try:
            print(f"Uploading '{local_filename}' -> '{storage_path}'...")
            with open(local_path, "rb") as f:
                file_data = f.read()
                
            mime_type = "image/jpeg"
            if local_filename.lower().endswith(".png"):
                mime_type = "image/png"
                
            supabase.storage.from_("gallery").upload(
                path=storage_path,
                file=file_data,
                file_options={"content-type": mime_type, "upsert": "true"}
            )
            uploaded_count += 1
        except Exception as e:
            # If it already exists or fails, try update
            try:
                supabase.storage.from_("gallery").update(
                    path=storage_path,
                    file=file_data,
                    file_options={"content-type": mime_type}
                )
                uploaded_count += 1
            except Exception as e2:
                print(f"Failed to upload/update '{storage_path}': {e2}")
            
    print(f"\nCompleted! Uploaded {uploaded_count} image files to Supabase Storage.")

if __name__ == "__main__":
    main()
