import sqlite3
import os

db_paths = [
    r'E:\InvoBharat\db.sqlite',
    r'C:\Users\suyas\AppData\Roaming\com.example\invobharat\db.sqlite',
]

for db_path in db_paths:
    if not os.path.exists(db_path):
        continue
    print(f"\n==========================================")
    print(f"Inspecting Database: {db_path}")
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    
    tables = [t[0] for t in cur.execute("SELECT name FROM sqlite_master WHERE type='table';").fetchall()]
    if 'business_profiles' not in tables or 'invoices' not in tables:
        print("Database missing required tables, skipping.")
        conn.close()
        continue
        
    profiles = cur.execute("SELECT id, company_name FROM business_profiles;").fetchall()
    print(f"Business Profiles: {profiles}")
    
    if not profiles:
        print("No profiles found! Creating default profile...")
        cur.execute("""
            INSERT OR IGNORE INTO business_profiles (
                id, company_name, address, gstin, email, phone, state, color_value, 
                invoice_series, invoice_sequence, terms_and_conditions, default_notes, 
                currency_symbol, bank_name, account_no, ifsc_code, branch, pan
            ) VALUES ('default', 'My Business', '', '', '', '', 'Delhi', 4280391411, 'INV-', 49, '', '', '₹', '', '', '', '', '');
        """)
        conn.commit()
        profiles = [('default', 'My Business')]

    target_profile_id = profiles[0][0]
    print(f"Target Profile ID: {target_profile_id}")
    
    inv_profiles = set(t[0] for t in cur.execute("SELECT profile_id FROM invoices;").fetchall())
    print(f"Existing Invoice profile_ids: {inv_profiles}")
    
    # Update invoices to match target_profile_id
    cur.execute("UPDATE invoices SET profile_id = ? WHERE profile_id IS NULL OR profile_id = '' OR profile_id = 'default' OR profile_id != ?;", (target_profile_id, target_profile_id))
    cur.execute("UPDATE clients SET profile_id = ? WHERE profile_id IS NULL OR profile_id = '' OR profile_id = 'default' OR profile_id != ?;", (target_profile_id, target_profile_id))
    conn.commit()
    
    updated_inv_profiles = set(t[0] for t in cur.execute("SELECT profile_id FROM invoices;").fetchall())
    print(f"Updated Invoice profile_ids: {updated_inv_profiles}")
    print(f"Total Invoices: {cur.execute('SELECT COUNT(*) FROM invoices;').fetchone()[0]}")
    conn.close()
