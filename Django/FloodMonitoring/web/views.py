from django.shortcuts import render

# Dashboard view
def dashboard_view(request):
    
    return render(request, "analytics/dashboard.html")