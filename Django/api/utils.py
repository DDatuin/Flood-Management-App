from datetime import datetime
import math

VEHICLE_PASSABLE = {
    "pedestrian": ["nf"],
    "bicycle": ["nf"],
    "motorcycle": ["nf", "patv"],
    "car": ["nf", "patv"],
    "truck": ["nf", "patv", "nplv"],
}

def closest_reading(target_time, rows):
    closest = None
    min_diff = float("inf")

    for row in rows:
        ts = datetime.fromisoformat(row["timestamp"])

        diff = abs((ts - target_time).total_seconds())

        if diff < min_diff:
            min_diff = diff
            closest = row

    return closest

def create_circle(lat, lng, radius_cm, points=64):
    earth = 6371000
    coords = []

    radius_m = radius_cm / 100

    for i in range(points + 1):
        angle = 2 * math.pi * i / points

        dx = radius_m * math.cos(angle)
        dy = radius_m * math.sin(angle)

        new_lat = lat + (dy / earth) * (180 / math.pi)
        new_lng = lng + (dx / earth) * (180 / math.pi) / math.cos(lat * math.pi / 180)

        coords.append([new_lng, new_lat])

    return coords

def build_avoid_polygons(sensor_rows, vehicle):
    
    polygons = []

    passable = VEHICLE_PASSABLE.get(
        vehicle,
        ["nf"]
    )

    for sensor in sensor_rows:

        prediction = sensor.get("prediction", {})

        flood_cat = prediction.get("category")

        if flood_cat in passable:
            continue

        latlong = sensor.get("latlong")
        radius = sensor.get("radius")

        if not latlong or not radius:
            continue

        lat, lng = latlong

        polygons.append([
            create_circle(lat, lng, radius)
        ])

    return polygons

def clean_route_response(geojson):

    feature = geojson["features"][0]

    geometry = feature["geometry"]

    summary = (
        feature.get("properties", {})
        .get("summary", {})
    )

    return {
        "success": True,

        "route": {
            "type": geometry["type"],
            "coordinates": geometry["coordinates"],
        },

        "summary": {
            "distance_meters": summary.get("distance"),
            "duration_seconds": summary.get("duration"),
        }
    }