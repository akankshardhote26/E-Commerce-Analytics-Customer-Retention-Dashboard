
import sqlite3
import sys
from pathlib import Path

import pandas as pd

SQL_DIR = Path(__file__).resolve().parent
DB_PATH = SQL_DIR / "ecommerce.db"


def main():
    if len(sys.argv) != 2:
        print("Usage: python3 sql/run_sql.py <query_filename.sql>")
        sys.exit(1)

    query_name = sys.argv[1]
    query_path = SQL_DIR / query_name

    if not query_path.is_file() or query_path.suffix != ".sql":
        print(f"SQL file not found: {query_name}")
        sys.exit(1)

    if not DB_PATH.is_file():
        print("Database not found. Run load_database.py first.")
        sys.exit(1)

    query = query_path.read_text(encoding="utf-8")

    with sqlite3.connect(DB_PATH) as conn:
        result = pd.read_sql_query(query, conn)

    print(f"\nANALYSIS: {query_path.stem.replace('_', ' ').upper()}")
    print("=" * 65)
    print(result.to_string(index=False))


if __name__ == "__main__":
    main()
