from rest_framework.decorators import api_view
from rest_framework.response import Response

from api.utils import build_avoid_polygons, clean_route_response
from .supabase.utils import get_latest_data_from_supabase, get_sensor_distance_from_supabase, get_sensor_history_from_supabase, get_sensor_radius_from_supabase
import requests, os


@api_view(['GET'])
def get_latest_data(request):

    """

    REQUEST:
    /api/latest-data/

    RESPONSE STRUCTURE:

    {
        "forecasts": {
            "SENS_001": {
                "datetime": "2026-04-21T10:15:00",
                "latlong": [14.60027, 121.00903],
                "wlvl_now": 42.5,
                "forecast": 45.2,
                "flood_cat": "npatv",
                .
                .
                .
            },
            "SENS_002": {
                "datetime": "2026-04-21T10:15:00",
                "latlong": [14.60001, 121.00919],
                "wlvl_now": 38.1,
                "forecast": 40.0,
                "flood_cat": "nplv",
                .
                .
                .
            }
        }
    }
    """

    latest_sensor_data = get_latest_data_from_supabase()

    result = {}

    for row in latest_sensor_data:
        sensor_id = row["sensor_id"]

        distance = get_sensor_distance_from_supabase(sensor_id)
        radius = get_sensor_radius_from_supabase(radius)

        prediction = row.get("prediction") or {}

        result[sensor_id] = {
            "datetime": row["timestamp"].isoformat() if hasattr(row["timestamp"], "isoformat") else row["timestamp"],
            "latlong": row.get("latlong"),
            "wlvl_now": row.get("wlvl_now"),
            "distance": distance,
            "radius": radius,
            "forecast": prediction.get("forecast"),
            "flood_cat": prediction.get("category"),
            "temperature": row.get("temperature"),
            "pressure": row.get("pressure"),
            "description": row.get("description"),
            "iconCode": row.get("icon_code")
        }

    return Response({"forecasts": result})



@api_view(['GET'])
def forward_geocode(request):

    """
    REQUEST:
    /api/location-search?q=<place_name>&viewbox=<optional>

    RESPONSE STRUCTURE:

    {
        "query": "Quezon City",
        "results": [
            {
                "lat": "14.6760",
                "lon": "121.0437",
                "display_name": "Quezon City, Metro Manila, Philippines",
                "address": {
                    "city": "Quezon City",
                    "state": "Metro Manila",
                    "country": "Philippines"
                }
            },
            {
                "lat": "...",
                "lon": "...",
                "display_name": "...",
                "address": { ... }
            }
        ]
    }
    """


    query = request.GET.get("q")
    viewbox = request.GET.get("viewbox")

    nominatim_email = os.getenv("NOMINATIM_EMAIL")

    if not query:
        return Response(
            {"error": "query parameter 'q' is required"},
            status=400
        )

    url = "https://nominatim.openstreetmap.org/search"

    params = {
        "q": query,
        "format": "json",
        "limit": 10,
        "addressdetails": 1,
    }

    if viewbox:
        params["viewbox"] = viewbox
        params["bounded"] = 1

    headers = {
        "User-Agent": f"Flood Detect Waze/1.0 ({nominatim_email})"
    }

    try:
        response = requests.get(url, params=params, headers=headers, timeout=10)
        response.raise_for_status()

        data = response.json()

        if not data:
            return Response({"error": "location not found"}, status=404)

        results = [
            {
                "lat": item.get("lat"),
                "lon": item.get("lon"),
                "display_name": item.get("display_name"),
                "address": item.get("address")
            }
            for item in data
        ]

        return Response({
            "query": query,
            "results": results
        })

    except Exception as e:
        return Response(
            {"error": str(e)},
            status=500
        )
    
@api_view(['GET'])
def get_sensor_history(request):

    sensor_id = request.GET.get('id')

    if not sensor_id:
        return Response({"success": False, "error": "Missing sensor id"}, status=400)

    result = get_sensor_history_from_supabase(sensor_id)

    return Response({
        "success": True,
        **result
    })

@api_view(['GET'])
def get_safe_route(request):

    start = request.GET.get("start")
    end = request.GET.get("end")
    vehicle = request.GET.get("vehicle", "driving-car")

    if not start or not end:
        return Response(
            {"error": "start and end are required"},
            status=400
        )

    try:
        start_lng, start_lat = map(float, start.split(","))
        end_lng, end_lat = map(float, end.split(","))

    except Exception:
        return Response(
            {"error": "invalid coordinates"},
            status=400
        )

    try:

        sensors = get_latest_data_from_supabase()

        avoid_sensors = [
            sensor for sensor in sensors
            if sensor.get("prediction", {}).get("category")
            in ["nplv", "npatv"]
        ]

        avoid_polygons = build_avoid_polygons(avoid_sensors)

        ors_url = (
            f"https://api.openrouteservice.org/v2/directions/{vehicle}/geojson"
        )

        payload = {
            "coordinates": [
                [start_lng, start_lat],
                [end_lng, end_lat]
            ]
        }

        if avoid_polygons:
            payload["options"] = {
                "avoid_polygons": {
                    "type": "MultiPolygon",
                    "coordinates": avoid_polygons
                }
            }

        headers = {
            "Authorization": os.getenv("ORS_API_KEY"),
            "Content-Type": "application/json"
        }

        response = requests.post(
            ors_url,
            json=payload,
            headers=headers,
            timeout=15
        )

        response.raise_for_status()

        cleaned = clean_route_response(response.json())

        return Response(cleaned)

    except Exception as e:
        return Response(
            {"error": str(e)},
            status=500
        )

    