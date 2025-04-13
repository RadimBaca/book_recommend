import os
import requests
import duckdb

# Environment variables
bucket_name = os.getenv("S3_BUCKET", "book-recomendation")
file_names = os.getenv("S3_FILES", "BX-Books.csv,BX-Book-Ratings.csv").split(',')
staging_table_names = os.getenv("STAGING_TABLE_NAMES", "Book,Rating").split(',')
encoding = os.getenv("S3_FILES_ENCODING", "cp1251")
output_dir = os.getenv("OUTPUT_DIR", "raw-data")
profile = os.getenv("PROFILE", "dev")

# Ensure output directory exists
os.makedirs(output_dir, exist_ok=True)

if profile == "dev":
    conn = duckdb.connect(f"reports/sources/books/book_rating.duckdb")
else:
    if profile == "prod":
        # TODO: connect to prod db (MotherDuck)
        conn = duckdb.connect(f"{profile}.duckdb")
    else:
        raise ValueError("Invalid profile")

# Download each file from S3 into raw-data folder
for file_name, staging_table_name in zip(file_names, staging_table_names):
    url = f"https://{bucket_name}.s3.amazonaws.com/{file_name}"
    output_path = os.path.join(output_dir, file_name)
    print(f"Downloading {url} to {output_path}...")
    response = requests.get(url)
    response.raise_for_status()
    with open(output_path, "wb") as f:
        f.write(response.content.decode(encoding).encode('utf-8'))
    print("Done.")

    # import data into duckdb

    conn.sql("CREATE SCHEMA IF NOT EXISTS staging")
    conn.sql(f"""
            CREATE OR REPLACE TABLE staging.{staging_table_name} as 
                select *, current_localtimestamp() ts, '{url}' source_url from read_csv('{output_path}',
                header = true,
                store_rejects = true,
                escape = '\\',
                rejects_table = '{staging_table_name}_reject_table',
                rejects_scan= '{staging_table_name}_scan_table'
            )
            """)
    
    conn.sql(f"""
            CREATE OR REPLACE TABLE staging.{staging_table_name}_reject_table as 
                from {staging_table_name}_reject_table
            """)

    print("Imported into DB.")



