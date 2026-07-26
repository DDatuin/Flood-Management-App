import asyncio


class SensorEventBus:

    def __init__(self):
        self.clients = set()
        self._latest_payload = None

    async def subscribe(self):
        queue = asyncio.Queue()
        self.clients.add(queue)

        try:
            while True:
                yield await queue.get()
                
        finally:
            self.clients.remove(queue)

    async def publish(self, event):
        self._latest_payload = event

        for queue in self.clients:
            await queue.put(event)

    def get_latest(self):
        return self._latest_payload

sensor_bus = SensorEventBus()