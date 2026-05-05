from datetime import datetime, timezone
from collections import deque
import queue

from .preprocessor import engineer_features_for_sensor, engineer_features_for_weather_api
from .weather_fetcher import get_rainfall_from_api
from .model_predictor.classifier import find_category

WL_LOG_QUEUE_SIZE = 11
RF_LOG_QUEUE_SIZE = 24
water_level_readings = {}
rainfall_readings = {}
last_logged_hour = {}

def flatten_datapoints(msg_queue: queue.Queue):

    print(f"[INGEST] Flattening datapoints...")
    flattened_datapoints = []

    while True:
        try:
            microcontroller = msg_queue.get_nowait()

        except queue.Empty:
            break

        current_timestamp = datetime.now()
        mcu_id = microcontroller['mcu_id']

        for sensor_connected in microcontroller['readings']:
            sensor_id = sensor_connected['sensor_id']
            water_level = sensor_connected['water_level']
            latlong = sensor_connected['latlong']

            if sensor_id not in water_level_readings:
                water_level_readings[sensor_id] = deque(maxlen=WL_LOG_QUEUE_SIZE)
            water_level_readings[sensor_id].append(water_level)

            flattened_datapoints.append({
                "mcu_id": mcu_id,
                "datetime": current_timestamp,
                "sensor_id": sensor_id,
                "water_level": water_level,
                "latlong": latlong,
                "wlvl_now_category": find_category(water_level)
            })

            print(f"[INGEST] Sensor {sensor_id} flattened...")

        print(f"[INGEST] Queue item flattened...")

    print(f"[INGEST] Returning flattened item...")
    return flattened_datapoints


def ingest_datapoints_from_queue(msg_queue: queue.Queue):

    datapoint_batch = flatten_datapoints(msg_queue)
    processed_batch = []

    print(f"[INGEST] Processing each sensor reading...")

    for datapoint in datapoint_batch:

        now = datetime.now()
        current_hour = now.replace(minute=0, second=0, microsecond=0)
        sensor_id = datapoint['sensor_id']

        flood_features = engineer_features_for_sensor(water_level_readings[sensor_id])
    
        if sensor_id not in last_logged_hour or last_logged_hour[sensor_id] != current_hour:

            rainfall = get_rainfall_from_api(datapoint['latlong'])

            if sensor_id not in rainfall_readings:
                    rainfall_readings[sensor_id] = deque(maxlen=RF_LOG_QUEUE_SIZE)
            rainfall_readings[sensor_id].append((current_hour, rainfall))
            last_logged_hour[sensor_id] = current_hour

        weather_features = engineer_features_for_weather_api(rainfall_readings.get(sensor_id, []))
        processed_batch.append({
            'timestamp': datetime.now(timezone.utc).isoformat(),
            'mcu_id': datapoint['mcu_id'],
            'sensor_id': sensor_id,
            'latlng':datapoint['latlong'],
            'wlvl_now_category': datapoint['wlvl_now_category'],
            'wlvl_now': flood_features['wlvl_now'],
            'wlvl_lag_1': flood_features['wlvl_lag_1'],
            'wlvl_lag_2': flood_features['wlvl_lag_2'],
            'wlvl_lag_5': flood_features['wlvl_lag_5'],
            'wlvl_lag_10': flood_features['wlvl_lag_10'],
            'diff_lag_1': flood_features['diff_lag_1'],
            'pct_change_lag_1': flood_features['pct_change_lag_1'],
            'slope_lag_10': flood_features['slope_lag_10'],
            'rainfall_hr1': weather_features['rainfall_hr1'],
            'rainfall_hr2': weather_features['rainfall_hr2'],
            'rainfall_hr12': weather_features['rainfall_hr12'],
            'rainfall_hr24': weather_features['rainfall_hr24']
        })

        print(f"[INGEST] Sensor reading processed...")

    print(f"[INGEST] Returning processed readings...")
    return processed_batch