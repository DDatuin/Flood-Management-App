import requests
import os
import time
import threading
from datetime import datetime

def get_rainfall_from_api(latlong):
    url = "https://api.openweathermap.org/data/2.5/weather"
    params = {
        "lat": latlong[0],
        "lon": latlong[1],
        "appid": os.getenv("OPENWEATHER_KEY"),
        "units": "metric"
    }

    response = requests.get(url, params=params, timeout=10)
    response.raise_for_status()

    print("[WEATHER] response acquired: ", response)

    json_response = response.json()

    hourly_rainfall = json_response.get('rain', {}).get('1h', 0.00)

    return hourly_rainfall
