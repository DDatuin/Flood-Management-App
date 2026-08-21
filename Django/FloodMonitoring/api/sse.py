import json

from django.http import StreamingHttpResponse

from fdw_backend.events import sensor_bus

async def latest_sensor_data_event_stream():

    queue = sensor_bus.register()

    try:
        print(
            f"[SSE] Client connected | PID={os.getpid()}"
        )
        
        latest = sensor_bus.get_latest()

        if latest is not None:
            yield f"data: {json.dumps(latest)}\n\n"

        async for event in sensor_bus.subscribe():
            yield f"data: {json.dumps(event)}\n\n"
    finally:
        sensor_bus.unregister(queue)

async def sensor_stream(request):

    response = StreamingHttpResponse(
        latest_sensor_data_event_stream(),
        content_type = "text/event-stream"
    )

    response['Cache-Control'] = "no-cache"

    return response