import sqlite3

db_path = r'E:\InvoBharat\db.sqlite'
print(f"Connecting to {db_path}...")
conn = sqlite3.connect(db_path)
cur = conn.cursor()

print("--- Integrity Check ---")
integrity = cur.execute('PRAGMA integrity_check;').fetchall()
print(f"Integrity Check Result: {integrity}")

print("\n--- Foreign Key Check ---")
fk_check = cur.execute('PRAGMA foreign_key_check;').fetchall()
print(f"Foreign Key Errors: {fk_check}")

tables = [t[0] for t in cur.execute("SELECT name FROM sqlite_master WHERE type='table';").fetchall()]
print(f"\nTables present: {tables}")

for table in tables:
    count = cur.execute(f"SELECT COUNT(*) FROM `{table}`;").fetchone()[0]
    print(f"Table `{table}` row count: {count}")

print("\n--- Invoices ---")
invoices = cur.execute("SELECT id, invoice_no, profile_id, invoice_date FROM invoices;").fetchall()
for inv in invoices:
    print(inv)

print("\n--- Business Profiles ---")
profiles = cur.execute("SELECT id, company_name, invoice_series, invoice_sequence FROM business_profiles;").fetchall()
for p in profiles:
    print(p)

print("\n--- App Settings ---")
settings = cur.execute("SELECT key, value FROM app_settings;").fetchall()
for s in settings:
    print(s)

conn.close()
