import asyncio
import os


class SensorEventBus:

    def __init__(self):
        self.clients = set()
        self._latest_payload = None

    def register(self):
        queue = asyncio.Queue()
        self.clients.add(queue)
        return queue

    def unregister(self, queue):
        self.clients.discard(queue)

    async def publish(self, event):
        print(
            f"[SSE] Publishing event | "
            f"PID={os.getpid()} | "
            f"Clients={len(self.clients)}"
        )
        
        self._latest_payload = event

        for queue in list(self.clients):
            await queue.put(event)

    def get_latest(self):
        return self._latest_payload

sensor_bus = SensorEventBus()