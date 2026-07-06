import os
from supabase import create_client

SUPABASE_URL = "https://kwegyvbgdaednljyhcgm.supabase.co"
SUPABASE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY") or "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt3ZWd5dmJnZGFlZG5sanloY2dtIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MjY4NDk1MywiZXhwIjoyMDk4MjYwOTUzfQ.Jr8kBFix864HBflFzIn0ztXqSzx7qDU3z7huPV997YQ"
def check_table(supabase, name):
    try:
        res = (
            supabase
            .table(name)
            .select("*", count="exact")
            .limit(2)
            .execute()
        )

        print(f"\nTable: {name}")
        print(f"Total Rows: {res.count}")

        if res.data:
            print("Sample:")
            print(res.data[0])

    except Exception as e:
        print(f"{name}: {e}")

def main():
    supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

    for t in [
        "categories",
        "experiences",
        "service_categories",
        "services"
    ]:
        check_table(supabase, t)

if __name__ == "__main__":
    main()