import json

from django.http import StreamingHttpResponse

from fdw_backend.events import sensor_bus

async def latest_sensor_data_event_stream():

    async for event in sensor_bus.subscribe():
        yield f"data: {json.dumps(event)}\n\n"

async def sensor_stream(request):

    response = StreamingHttpResponse(
        latest_sensor_data_event_stream(),
        content_type = "text/event-stream"
    )

    response['Cache-Control'] = "no-cache"
    response['Connection'] = "keep-alive"

    return response