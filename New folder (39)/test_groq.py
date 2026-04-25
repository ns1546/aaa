import urllib.request
import json
import base64
import os

api_key = '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'
model = 'llama-3.2-90b-vision-preview'
url = 'https://api.groq.com/openai/v1/chat/completions'

# Let's download a small sample image.
image_url = 'https://picsum.photos/200/300'
req = urllib.request.Request(image_url, headers={'User-Agent': 'Mozilla/5.0'})
try:
    with urllib.request.urlopen(req) as response:
        image_data = response.read()
        base64_image = base64.b64encode(image_data).decode('utf-8')
    print("Successfully downloaded a dummy image.")
except Exception as e:
    print(f"Failed to get image: {e}")
    exit(1)

payload = {
    "model": model,
    "messages": [
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Analyze the attached image. Respond ONLY in valid JSON format using the following structure: {'smart_name': '...', 'description': '...', 'tags': ['...', '...'], 'lighting_quality': '8/10', 'sharpness': '9/10'}. Do NOT include any markdown formatting like ```json, just the raw JSON object."
                },
                {
                    "type": "image_url",
                    "image_url": {
                        "url": f"data:image/jpeg;base64,{base64_image}"
                    }
                }
            ]
        }
    ],
    "temperature": 0.1
}

req = urllib.request.Request(url, data=json.dumps(payload).encode('utf-8'), headers={
    'Content-Type': 'application/json',
    'Authorization': f'Bearer {api_key}',
    'User-Agent': 'Mozilla/5.0'
})

print(f"Calling Groq API with model: {model}...")
try:
    with urllib.request.urlopen(req) as response:
        response_body = response.read().decode('utf-8')
        data = json.loads(response_body)
        content = data['choices'][0]['message']['content'].strip()
        print("\n--- RAW RESPONSE ---")
        print(content)
        
        # Test JSON parsing exactly as the Dart app does
        if content.startswith('```json'):
            content = content[7:-3].strip()
        elif content.startswith('```'):
            content = content[3:-3].strip()
            
        parsed = json.loads(content)
        print("\n--- SUCCESSFULLY PARSED JSON ---")
        print(json.dumps(parsed, indent=2))
        
except urllib.error.HTTPError as e:
    resp_body = e.read().decode('utf-8')
    print(f"\nHTTP Error {e.code}:\n{resp_body}")
except Exception as e:
    print(f"\nError: {e}")
