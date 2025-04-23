import requests
import json

# Retrieve data from Memory server
response = requests.post(
    'http://localhost:3002',
    json={
        'jsonrpc': '2.0',
        'method': 'tools/call',
        'params': {
            'name': 'memory_retrieve',
            'arguments': {
                'key': 'data'
            }
        },
        'id': 1
    }
)

data = response.json()['result']['memory_value']
print(f"Retrieved: {data}")
