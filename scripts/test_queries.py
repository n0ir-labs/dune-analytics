import os
import requests
import time
from dotenv import load_dotenv

# Load environment
load_dotenv('.env', override=True)
API_KEY = os.getenv('DUNE_API_KEY')

query_ids = [5967954, 5967953, 5967956, 5967951, 5967955, 5967952]
query_names = ['TVL Over Time', 'Unique Users', 'Protocol Fees', 'Positions by Pool', 'Daily Volume', 'Active Positions']

for query_id, name in zip(query_ids, query_names):
    print(f'\n{"="*60}')
    print(f'Testing: {name} (ID: {query_id})')
    print(f'{"="*60}')

    # Execute query
    exec_response = requests.post(
        f'https://api.dune.com/api/v1/query/{query_id}/execute',
        headers={'X-Dune-API-Key': API_KEY}
    )

    if exec_response.status_code != 200:
        print(f'❌ Execution failed: {exec_response.text}')
        continue

    execution_id = exec_response.json()['execution_id']
    print(f'⏳ Executing... (ID: {execution_id})')

    # Poll for results
    max_attempts = 30
    for attempt in range(max_attempts):
        time.sleep(2)

        status_response = requests.get(
            f'https://api.dune.com/api/v1/execution/{execution_id}/status',
            headers={'X-Dune-API-Key': API_KEY}
        )

        if status_response.status_code != 200:
            print(f'❌ Status check failed: {status_response.text}')
            break

        status = status_response.json()['state']

        if status == 'QUERY_STATE_COMPLETED':
            # Get results
            results_response = requests.get(
                f'https://api.dune.com/api/v1/execution/{execution_id}/results',
                headers={'X-Dune-API-Key': API_KEY}
            )

            if results_response.status_code == 200:
                result_data = results_response.json()
                rows = result_data['result']['rows']

                if len(rows) == 0:
                    print(f'⚠️  Query returned 0 rows (might be no data yet)')
                else:
                    print(f'✅ Success! Returned {len(rows)} row(s)')
                    print(f'First row: {rows[0]}')
            else:
                print(f'❌ Failed to get results: {results_response.text}')
            break
        elif status == 'QUERY_STATE_FAILED':
            print(f'❌ Query execution failed')
            break
        elif attempt == max_attempts - 1:
            print(f'⏱️  Timeout waiting for results')
            break
        else:
            print(f'   Status: {status}... waiting')

print(f'\n{"="*60}')
print('Test complete!')
