from rest_framework.decorators import api_view
from rest_framework.response import Response
from .supabase.utils import get_latest_data_from_supabase
import requests, os


@api_view(['GET'])
def get_latest_data(request):

    """
    RESPONSE STRUCTURE:

    {
        "forecasts": {
            "SENS_001": {
                "datetime": "2026-04-21T10:15:00",
                "latlong": [14.60027, 121.00903],
                "wlvl_now": 42.5,
                "forecast": 45.2,
                "flood_cat": "HIGH"
            },
            "SENS_002": {
                "datetime": "2026-04-21T10:15:00",
                "latlong": [14.60001, 121.00919],
                "wlvl_now": 38.1,
                "forecast": 40.0,
                "flood_cat": "MODERATE"
            }
        }
    }
    """

    latest_sensor_data = get_latest_data_from_supabase()

    result = {}

    for row in latest_sensor_data:
        sensor_id = row["sensor_id"]

        prediction = row.get("prediction") or {}

        result[sensor_id] = {
            "datetime": row["timestamp"].isoformat() if hasattr(row["timestamp"], "isoformat") else row["timestamp"],
            "latlong": row.get("latlong"),
            "wlvl_now": row.get("wlvl_now"),
            "forecast": prediction.get("forecast"),
            "flood_cat": prediction.get("category")
        }

    return Response({"forecasts": result})



@api_view(['GET'])
def forward_geocode(request):

    """
    REQUEST:
    /api/geocode?q=<place_name>&viewbox=<optional>

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