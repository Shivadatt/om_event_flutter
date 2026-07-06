import socket
import os
import sys

def probe_port(host, port):
    try:
        with socket.create_connection((host, port), timeout=2):
            return True
    except OSError:
        return False

def main():
    print("Probing local ports...")
    ports = {
        "Supabase Kong API (54321)": 54321,
        "Supabase Postgres (54322)": 54322,
        "Firestore Emulator (8080)": 8080,
        "Firebase Auth Emulator (9099)": 9099,
        "PostgreSQL Default (5432)": 5432
    }
    
    for name, port in ports.items():
        open_status = probe_port("127.0.0.1", port)
        print(f"{name}: {'OPEN' if open_status else 'CLOSED'}")

    print("\nChecking System Environment Variables:")
    for k, v in os.environ.items():
        if "SUPABASE" in k or "FIREBASE" in k or "GOOGLE" in k:
            # Mask sensitive values
            masked = v[:10] + "..." if len(v) > 10 else v
            print(f"  {k}: {masked}")

if __name__ == "__main__":
    main()
