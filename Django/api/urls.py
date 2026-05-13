from django.urls import path
from .views import get_latest_data, forward_geocode, get_safe_route, get_sensor_history

urlpatterns = [
    path('latest-data/', get_latest_data),
    path('location-search/', forward_geocode),
    path('get-history/', get_sensor_history),
    path('get-route/', get_safe_route)
]