import sqlite3
import json
import shutil
import os

db_path = r'E:\InvoBharat\db.sqlite'
print(f"Syncing {db_path}...")
conn = sqlite3.connect(db_path)
cur = conn.cursor()

# Get profile id
profiles = cur.execute("SELECT id FROM business_profiles;").fetchall()
if profiles:
    profile_id = profiles[0][0]
    key = f"series_list_{profile_id}"
    new_val = json.dumps([{"prefix": "INV-", "sequence": 7}])
    cur.execute("INSERT OR REPLACE INTO app_settings (key, value) VALUES (?, ?);", (key, new_val))
    cur.execute("UPDATE business_profiles SET invoice_sequence = 7 WHERE id = ?;", (profile_id,))
    conn.commit()
    print("Successfully updated workspace db.sqlite series sequence to 7!")

conn.close()

dest_dir = r'C:\Users\suyas\AppData\Roaming\com.example\invobharat'
os.makedirs(dest_dir, exist_ok=True)
dest_path = os.path.join(dest_dir, 'db.sqlite')
shutil.copy2(db_path, dest_path)
print(f"Successfully copied synced database to {dest_path}!")
