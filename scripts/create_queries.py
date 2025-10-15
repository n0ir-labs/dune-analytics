import os
import yaml
from dotenv import load_dotenv
import glob
import requests

# Load environment
dotenv_path = os.path.join(os.path.dirname(__file__), '..', '.env')
load_dotenv(dotenv_path, override=True)

API_KEY = os.getenv('DUNE_API_KEY')

# Get all SQL files in queries folder
queries_path = os.path.join(os.path.dirname(__file__), '..', 'queries')
sql_files = glob.glob(os.path.join(queries_path, '*.sql'))

created_query_ids = []

for sql_file in sql_files:
    # Skip filler.txt
    if 'filler' in sql_file:
        continue

    # Read the SQL file
    with open(sql_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Extract query name from filename
    filename = os.path.basename(sql_file)
    query_name = filename.replace('___placeholder_', ' - ').replace('.sql', '').replace('_', ' ').title()

    # Remove the header comments to get clean SQL
    sql_lines = content.split('\n')
    sql_start = 0
    for i, line in enumerate(sql_lines):
        if line.strip() and not line.strip().startswith('--'):
            sql_start = i
            break

    clean_sql = '\n'.join(sql_lines[sql_start:])

    print(f'\nCreating query: {query_name}')
    print(f'File: {filename}')

    try:
        # Create the query using direct API call
        response = requests.post(
            'https://api.dune.com/api/v1/query',
            headers={
                'Content-Type': 'application/json',
                'X-Dune-API-Key': API_KEY
            },
            json={
                'name': query_name,
                'query_sql': clean_sql,
                'is_private': False
            }
        )

        if response.status_code == 200:
            query_id = response.json()['query_id']
            print(f'✅ Created! Query ID: {query_id}')
            print(f'   URL: https://dune.com/queries/{query_id}')

            created_query_ids.append(query_id)

            # Rename the file with actual query ID
            new_filename = filename.replace('placeholder_' + filename.split('placeholder_')[1].split('.')[0], str(query_id))
            new_filepath = os.path.join(queries_path, new_filename)
            os.rename(sql_file, new_filepath)
            print(f'   Renamed file to: {new_filename}')
        else:
            print(f'❌ Error: {response.status_code} - {response.text}')

    except Exception as e:
        print(f'❌ Error creating query: {str(e)}')

# Update queries.yml with the created query IDs
if created_query_ids:
    queries_yml_path = os.path.join(os.path.dirname(__file__), '..', 'queries.yml')
    with open(queries_yml_path, 'w', encoding='utf-8') as f:
        yaml.dump({'query_ids': created_query_ids}, f, default_flow_style=False)

    print(f'\n✅ Updated queries.yml with {len(created_query_ids)} query IDs')
    print(f'Query IDs: {created_query_ids}')

print('\n🎉 Done! All queries created on Dune.')
