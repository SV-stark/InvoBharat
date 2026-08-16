import sqlite3
import json
import re

db_path = r'E:\InvoBharat\db.sqlite'
conn = sqlite3.connect(db_path)
cur = conn.cursor()

print("--- Inspecting Invoices in E:\\InvoBharat\\db.sqlite ---")
invoices = cur.execute("SELECT id, invoice_no, profile_id FROM invoices;").fetchall()
print(f"Total Invoices: {len(invoices)}")

# Find max numeric sequence from existing invoice numbers
max_seq = 1
prefixes = {}

for inv in invoices:
    no = inv[1]
    match = re.search(r'(\d+)$', no)
    if match:
        num = int(match.group(1))
        if num > max_seq:
            max_seq = num

print(f"Calculated Max Sequence Number: {max_seq}")
next_seq = max_seq + 1
print(f"Setting Next Sequence Number to: {next_seq}")

# Check business_profiles table
profiles = cur.execute("SELECT * FROM business_profiles;").fetchall()
print(f"Existing Profiles: {profiles}")

cols = [c[1] for c in cur.execute("PRAGMA table_info(business_profiles);").fetchall()]
print(f"Columns in business_profiles: {cols}")

if not profiles:
    cols_str = ", ".join(cols)
    placeholders = ", ".join(["?"] * len(cols))
    
    # Map values according to actual columns
    val_map = {
        'id': 'default',
        'company_name': 'My Business',
        'companyName': 'My Business',
        'address': '',
        'gstin': '',
        'email': '',
        'phone': '',
        'state': 'Delhi',
        'invoice_series': 'INV-',
        'invoiceSeries': 'INV-',
        'invoice_sequence': next_seq,
        'invoiceSequence': next_seq,
        'color_value': 4280391411,
        'colorValue': 4280391411,
        'bank_name': '',
        'account_no': '',
        'ifsc_code': '',
        'branch': '',
    }
    
    vals = [val_map.get(col, '') for col in cols]
    cur.execute(f"INSERT INTO business_profiles ({cols_str}) VALUES ({placeholders});", vals)
    print("Inserted default profile record into business_profiles!")
else:
    cur.execute("UPDATE business_profiles SET invoice_sequence = ?;", (next_seq,))
    print(f"Updated business_profiles sequence to {next_seq}!")

# Update or insert app_settings
cur.execute("CREATE TABLE IF NOT EXISTS app_settings (key TEXT PRIMARY KEY, value TEXT);")
series_json = json.dumps([{"prefix": "INV-", "sequence": next_seq}])
cur.execute("INSERT OR REPLACE INTO app_settings (key, value) VALUES ('series_list_default', ?);", (series_json,))

conn.commit()
print("Database repair & sequence sync complete!")
conn.close()
