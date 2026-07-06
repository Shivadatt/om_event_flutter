import requests
import json

SUPABASE_URL = "https://kwegyvbgdaednljyhcgm.supabase.co"
ANON_KEY = "sb_publishable_bN91Or0DGzltjdDFB3b4zw_oosYJUa8"

TABLES = [
    'notification_tokens', 'notification_queue', 'notification_logs', 
    'notification_templates', 'notification_preferences', 'scheduled_notifications', 
    'delivery_events', 'dead_letter_notifications', 'users', 'bookings', 
    'leads', 'quotations', 'reviews', 'settings', 'admins', 'roles', 
    'permissions', 'service_categories', 'services', 'booking_gallery', 
    'chat_rooms', 'chat_messages', 'customer_activity', 'offers', 
    'customer_payments', 'contact_numbers'
]

def main():
    headers = {
        "apikey": ANON_KEY,
        "Authorization": f"Bearer {ANON_KEY}",
        "Content-Type": "application/json"
    }
    
    print("Auditing remote Supabase database tables...")
    existing = []
    missing = []
    errors = {}
    
    for table in TABLES:
        # Probe table existence using a simple REST call
        url = f"{SUPABASE_URL}/rest/v1/{table}?select=*&limit=1"
        try:
            response = requests.get(url, headers=headers)
            # A 200 OK or 406 (e.g. RLS restrict or empty select) means it exists in schema cache
            # A 404 Not Found (PGRST116 or similar) means table is missing
            if response.status_code in [200, 201, 204]:
                existing.append(table)
                print(f"Table '{table}': EXISTS (200)")
            elif response.status_code == 406:
                # 406 Not Acceptable or similar
                existing.append(table)
                print(f"Table '{table}': EXISTS (406)")
            elif response.status_code == 401:
                # 401 Unauthorized - meaning RLS is active but table exists
                existing.append(table)
                print(f"Table '{table}': EXISTS (401 RLS Active)")
            elif response.status_code == 404:
                body = response.json() if response.text else {}
                code = body.get("code")
                message = body.get("message", "")
                if code == "PGRST116":
                    # Row level check (maybe single missing), meaning table exists
                    existing.append(table)
                    print(f"Table '{table}': EXISTS (PGRST116)")
                elif "does not exist" in message or "Could not find the table" in message:
                    missing.append(table)
                    print(f"Table '{table}': MISSING")
                else:
                    existing.append(table)
                    print(f"Table '{table}': EXISTS ({response.status_code} - {message})")
            else:
                body = response.json() if response.text else {}
                message = body.get("message", "")
                print(f"Table '{table}': status {response.status_code} - {message}")
                if "does not exist" in message:
                    missing.append(table)
                else:
                    existing.append(table)
        except Exception as e:
            print(f"Table '{table}': connection error: {e}")
            errors[table] = str(e)
            
    print("\n--- RESULTS SUMMARY ---")
    print("Existing Tables:", len(existing), existing)
    print("Missing Tables:", len(missing), missing)

if __name__ == "__main__":
    main()
