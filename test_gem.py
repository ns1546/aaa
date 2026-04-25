import urllib.request
import urllib.error
import json
import base64

API_KEY = "AIzaSyBGTfEb9RlLLmOlAgDzApR0jYnuymTI7PU"
URL = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={API_KEY}"

# create a 1x1 pixel base64 image
b64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII="

payload = {
    "contents": [{
        "parts": [
            {"text": "What is this?"},
            {
                "inline_data": {
                    "mime_type": "image/png",
                    "data": b64
                }
            }
        ]
    }]
}

data = json.dumps(payload).encode('utf-8')
req = urllib.request.Request(URL, data=data, headers={'Content-Type': 'application/json'})

try:
    response = urllib.request.urlopen(req)
    print(response.read().decode('utf-8'))
except urllib.error.HTTPError as e:
    print(f"HTTPError: {e.code}")
    print(e.read().decode('utf-8'))
except Exception as e:
    print(e)
