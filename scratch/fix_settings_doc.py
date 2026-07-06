path = r"d:\om_event_python\om_event\lib\data\repositories\supabase_settings_repository.dart"

with open(path, "r", encoding="utf-8") as f:
    code = f.read()

# Replace .map((doc) { with .map((data) { to align with the renamed variables inside the map closure.
code = code.replace(".map((doc) {", ".map((data) {")

with open(path, "w", encoding="utf-8") as f:
    f.write(code)

print("Fixed settings repository parameters successfully!")
