import urllib.request
import json
API_KEY = "AIzaSyBGTfEb9RlLLmOlAgDzApR0jYnuymTI7PU"
URL = f"https://generativelanguage.googleapis.com/v1beta/models?key={API_KEY}"
try:
    response = urllib.request.urlopen(URL)
    data = json.loads(response.read().decode('utf-8'))
    for m in data['models']:
        print(m['name'])
except Exception as e:
    print(e)
