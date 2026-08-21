import random
import time
import requests

BLYNK_AUTH_TOKEN = "YOUR_BLYNK_AUTH_TOKEN"
DISTANCE_VPIN = "V0"

BLYNK_URL = "https://blynk.cloud/external/api/update"


def generate_distance():
    # Generate a random water/sensor reading in cm.
    return round(random.uniform(0, 67), 1)


def send_distance(distance):
    params = {
        "token": BLYNK_AUTH_TOKEN,
        DISTANCE_VPIN: distance,
    }

    try:
        response = requests.get(BLYNK_URL, params=params, timeout=10)

        if response.ok:
            print(f"[BLYNK] Sent distance: {distance} cm")
        else:
            print(
                f"[BLYNK] Failed ({response.status_code}): "
                f"{response.text}"
            )

    except requests.RequestException as e:
        print(f"[BLYNK] Connection error: {e}")


def main():
    print("Starting Blynk sensor simulator...")
    print("Press Ctrl+C to stop.\n")

    while True:
        distance = generate_distance()
        send_distance(distance)

        print("Waiting 60 seconds...\n")
        time.sleep(60)


if __name__ == "__main__":
    main()