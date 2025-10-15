import os
import yaml
import requests
from dotenv import load_dotenv

# Load environment
load_dotenv('.env', override=True)
API_KEY = os.getenv('DUNE_API_KEY')

# Read queries.yml
queries_yml = os.path.join(os.path.dirname(__file__), '..', 'queries.yml')
with open(queries_yml, 'r', encoding='utf-8') as file:
    data = yaml.safe_load(file)

query_ids = data['query_ids']

for query_id in query_ids:
    # Find the corresponding SQL file
    queries_path = os.path.join(os.path.dirname(__file__), '..', 'queries')
    files = os.listdir(queries_path)
    found_files = [f for f in files if str(query_id) in f and f.endswith('.sql')]

    if not found_files:
        print(f'⚠️  No file found for query {query_id}')
        continue

    file_path = os.path.join(queries_path, found_files[0])

    # Read the SQL
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Extract clean SQL (skip comment headers)
    sql_lines = content.split('\n')
    sql_start = 0
    for i, line in enumerate(sql_lines):
        if line.strip() and not line.strip().startswith('--'):
            sql_start = i
            break

    clean_sql = '\n'.join(sql_lines[sql_start:])

    print(f'\nUpdating query {query_id} ({found_files[0]})...')

    # Update via API
    response = requests.patch(
        f'https://api.dune.com/api/v1/query/{query_id}',
        headers={
            'Content-Type': 'application/json',
            'X-Dune-API-Key': API_KEY
        },
        json={'query_sql': clean_sql}
    )

    if response.status_code == 200:
        print(f'✅ Updated successfully')
    else:
        print(f'❌ Failed: {response.status_code} - {response.text}')

print('\n🎉 Done pushing to Dune!')
