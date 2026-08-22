import asyncio
import json
import os

from django.http import StreamingHttpResponse

from fdw_backend.events import sensor_bus

async def latest_sensor_data_event_stream():

    client_id, queue = sensor_bus.register()

    print(
        f"[SSE] Client connected | "
        f"ID={client_id} | "
        f"PID={os.getpid()}"
    )

    try:

        latest = sensor_bus.get_latest()

        if latest:
            print(
                f"[SSE] Initial payload | "
                f"Client={client_id} | "
                f"Size={len(latest)} bytes"
            )

            yield f"data: {json.dumps(latest)}\n\n"

        while True:

            try:
                event = await asyncio.wait_for(
                    queue.get(),
                    timeout=15
                )

                print(
                    f"[SSE] Sending event | "
                    f"Client={client_id}"
                )

                yield f"data: {json.dumps(event)}\ns\n"

            except asyncio.TimeoutError:

                print(
                    f"[SSE] Heartbeat | "
                    f"Client={client_id}"
                )

                yield ": heartbeat\n\n"

    except asyncio.CancelledError:

        print(
            f"[SSE] Client cancelled | "
            f"ID={client_id} | "
            f"PID={os.getpid()}"
        )

        raise

    finally:

        sensor_bus.unregister(client_id)

async def sensor_stream(request):

    response = StreamingHttpResponse(
        latest_sensor_data_event_stream(),
        content_type = "text/event-stream"
    )

    response['Cache-Control'] = "no-cache"
    response["X-Accel-Buffering"] = "no"
    response["Connection"] = "keep-alive"

    return response