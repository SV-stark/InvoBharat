import json

path = r'C:\Users\suyas\AppData\Roaming\com.example\invobharat\shared_preferences.json'
with open(path, 'r', encoding='utf-8') as f:
    data = json.load(f)

print("--- Business Profiles in SharedPrefs ---")
profiles_raw = data.get('flutter.business_profiles_list', '[]')
if isinstance(profiles_raw, str):
    profiles = json.loads(profiles_raw)
else:
    profiles = profiles_raw

for p in profiles:
    print("Profile:", p)

print("\n--- Invoices in SharedPrefs ---")
invoices_raw = data.get('flutter.invoices_list', '[]')
if isinstance(invoices_raw, str):
    invoices = json.loads(invoices_raw)
else:
    invoices = invoices_raw

print(f"Total Invoices in JSON: {len(invoices)}")
for inv in invoices:
    if isinstance(inv, str):
        inv_map = json.loads(inv)
    else:
        inv_map = inv
    print(f"ID: {inv_map.get('id')} | InvoiceNo: {inv_map.get('invoiceNo')} | Date: {inv_map.get('invoiceDate')}")
