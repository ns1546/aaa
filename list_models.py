import urllib.request
import json

url = 'https://api.groq.com/openai/v1/models'
api_key = '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'

req = urllib.request.Request(url, headers={
    'Authorization': f'Bearer {api_key}',
    'User-Agent': 'Mozilla/5.0'
})

try:
    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read().decode('utf-8'))
        for model in data.get('data', []):
            if 'vision' in model['id'].lower() or 'llama-3.2' in model['id'].lower():
                print(model['id'])
except Exception as e:
    print(f"Error: {e}")
