import os

appdata = r'C:\Users\suyas\AppData'
found = []
for root, dirs, files in os.walk(appdata):
    for file in files:
        if file.startswith('db.sqlite'):
            full_path = os.path.join(root, file)
            size = os.path.getsize(full_path)
            found.append((full_path, size))

print("Found DB SQLite files:")
for path, size in found:
    print(f"Path: {path} | Size: {size} bytes")
