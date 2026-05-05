from django.urls import path
from .views import get_latest_data, forward_geocode

urlpatterns = [
    path('latest-data/', get_latest_data),
    path('location-search/', forward_geocode)
]