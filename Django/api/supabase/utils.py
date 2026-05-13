from datetime import datetime, timedelta, timezone
from collections import defaultdict

from api.utils import closest_reading

from .client import supabase

def push_to_supabase(forecast_data_batch, new_data_batch):
    for sensor_row, prediction_row in zip(new_data_batch, forecast_data_batch):
        row_id = log_sensor_and_api_data(sensor_row)
        log_ml_prediction(prediction_row, row_id)


def log_sensor_and_api_data(row_data):

    table = supabase.table('SENSOR_AND_API_DATA')
    data = {
        "mcu_id": row_data['mcu_id'],
        "sensor_id": row_data['sensor_id'],
        "timestamp": row_data['timestamp'],
        "wlvl_now": row_data['wlvl_now'],
        "wlvl_lag_t-1": row_data['wlvl_lag_1'],
        "wlvl_lag_t-2": row_data['wlvl_lag_2'],
        "wlvl_lag_t-5": row_data['wlvl_lag_5'],
        "wlvl_lag_t-10": row_data['wlvl_lag_10'],
        "diff_lag_t-1": row_data['diff_lag_1'],
        "pct_change_lag_t-1": row_data['pct_change_lag_1'],
        "slope_lag_t-10": row_data['slope_lag_10'],
        "rainfall_hr1": row_data['rainfall_hr1'],
        "rainfall_hr2": row_data['rainfall_hr2'],
        "rainfall_hr12": row_data['rainfall_hr12'],
        "rainfall_hr24": row_data['rainfall_hr24'],
        "wlvl_now_category": row_data['wlvl_now_category'],
        "temperature": row_data['weather_info']['temperature'],
        "description": row_data['weather_info']['description'],
        "pressure": row_data['weather_info']['pressure'],
        "icon_code": row_data['weather_info']['iconCode']
    }
    response = table.insert(data).execute()

    inserted_row = response.data[0]['id']
    return inserted_row

def log_ml_prediction(row_data, foreign_id):
    table = supabase.table('PREDICTIONS')
    data = {
        "data_id": foreign_id,
        "forecast": row_data['forecast'],
        "category": row_data['forecast_category']
    }

    response = table.insert(data).execute()

    return response.data

def get_latest_data_from_supabase():

    sensor_response = supabase.table("SENSOR_AND_API_DATA") \
        .select("*") \
        .order("timestamp", desc=True) \
        .execute()

    rows = sensor_response.data

    latest_per_sensor = {}

    for row in rows:
        sensor_id = row["sensor_id"]

        if sensor_id not in latest_per_sensor:
            latest_per_sensor[sensor_id] = row

    latest_rows = list(latest_per_sensor.values())

    prediction_response = supabase.table("PREDICTIONS") \
        .select("*") \
        .execute()

    predictions = prediction_response.data

    prediction_map = {
        p["data_id"]: p for p in predictions
    }

    result = []

    for row in latest_rows:
        sensor_id = row["sensor_id"]
        row_id = row["id"]

        result.append({
            **row,
            "prediction": prediction_map.get(row_id)
        })

    return result

def get_sensor_distance_from_supabase(sensor_id):

    response = (
        supabase
        .table("SENSORS")
        .select("distance")
        .eq("sensor_id", sensor_id)
        .single()
        .execute()
    )

    data = response.data
    
    if data:
        return data["distance"]
    return None

def get_sensor_radius_from_supabase(sensor_id):

    response = (
        supabase
        .table("SENSORS")
        .select("radius")
        .eq("sensor_id", sensor_id)
        .single()
        .execute()
    )

    data = response.data
    
    if data:
        return data["radius"]
    return None

def get_sensor_location_from_supabase(sensor_id):

    response = (
        supabase.table("SENSORS")
        .select("latitude, longitude")
        .eq("sensor_id", sensor_id)
        .single()
        .execute()
    )

    data = response.data

    return [data["latitude"], data["longitude"]]




def get_sensor_history_from_supabase(sensor_id):

    now = datetime.now(timezone.utc)
    past_24h = now - timedelta(hours=24)

    response = (
        supabase.table("SENSOR_AND_API_DATA")
        .select("timestamp, wlvl_now")
        .eq("sensor_id", sensor_id)
        .gte("timestamp", past_24h.isoformat())
        .lte("timestamp", now.isoformat())
        .execute()
    )

    rows = response.data

    hour_marks = [
        now - timedelta(hours=i)
        for i in range(24)
    ]

    hourlyData = []
    labels = []

    for i, target in enumerate(reversed(hour_marks)):
        match = closest_reading(target, rows)

        if match:
            hourlyData.append({
                "x": i,
                "y": match["wlvl_now"]
            })
            labels.append(target.strftime("%H:00"))

    return {
        "hourlyData": hourlyData,
        "labels": labels
    }
    
