import json
import os

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
            payload = f"data: {json.dumps(latest)}\n\n"

            print(
                f"[SSE] Initial payload size: {len(payload)} bytes"
            )

            yield payload

        while True:
            event = await queue.get()

            payload = f"data: {json.dumps(event)}\n\n"

            print(
                f"[SSE] Sending event: {len(payload)} bytes"
            )

            yield payload
    finally:
        sensor_bus.unregister(queue)

async def sensor_stream(request):

    response = StreamingHttpResponse(
        latest_sensor_data_event_stream(),
        content_type = "text/event-stream"
    )

    response['Cache-Control'] = "no-cache"
    response["X-Accel-Buffering"] = "no"
    response["Connection"] = "keep-alive"

    return response