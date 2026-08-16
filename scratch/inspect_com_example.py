import sqlite3

db_path = r'C:\Users\suyas\AppData\Roaming\com.example\invobharat\db.sqlite'
print(f"Connecting to {db_path}...")
conn = sqlite3.connect(db_path)
cur = conn.cursor()

tables = [t[0] for t in cur.execute("SELECT name FROM sqlite_master WHERE type='table';").fetchall()]
print(f"Tables present in {db_path}: {tables}")

for table in tables:
    count = cur.execute(f"SELECT COUNT(*) FROM `{table}`;").fetchone()[0]
    print(f"Table `{table}` row count: {count}")
    if count > 0 and count < 100:
        rows = cur.execute(f"SELECT * FROM `{table}`;").fetchall()
        print(f"Sample rows in {table}: {rows[:5]}")

conn.close()
