import asyncio


class SensorEventBus:

    def __init__(self):
        self.clients = set()

    async def subscribe(self):
        queue = asyncio.Queue()
        self.clients.add(queue)

        try:
            while True:
                yield await queue.get()
                
        finally:
            self.clients.remove(queue)

    async def publish(self, event):

        for queue in self.clients:
            await queue.put(event)

sensor_bus = SensorEventBus()