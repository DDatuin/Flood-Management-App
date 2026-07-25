import json
import requests

URL = "http://127.0.0.1:8000/api/stream/sensors-channel/"

print("Connecting to SSE...")

with requests.get(URL, stream=True) as response:
    print(f"Connected! Status: {response.status_code}")

    for line in response.iter_lines(decode_unicode=True):
        if not line:
            continue

        print(line)

        if line.startswith("data: "):
            payload = json.loads(line[6:])

            print("\n===== EVENT RECEIVED =====")
            print(json.dumps(payload, indent=4))