import asyncio
import os
import uuid


class SensorEventBus:

    def __init__(self):
        self.clients = {}
        self._latest_payload = None

    def register(self):
        client_id = uuid.uuid4().hex[:8]
        queue = asyncio.Queue()

        self.clients[client_id] = queue

        print(
            f"[SSE] Client registered | "
            f"ID={client_id} | "
            f"PID={os.getpid()} | "
            f"Clients={len(self.clients)}"
        )

        print(
            f"[SSE] Active clients: {list(self.clients.keys())}"
        )

        return client_id, queue

    def unregister(self, client_id):
        removed = self.clients.pop(client_id, None)

        print(
            f"[SSE] Client unregistered | "
            f"ID={client_id} | "
            f"Removed={removed is not None} | "
            f"PID={os.getpid()} | "
            f"Clients={len(self.clients)}"
        )

        print(
            f"[SSE] Active clients: {list(self.clients.keys())}"
        )

    async def publish(self, event):

        print(
            f"[SSE] Publishing event | "
            f"PID={os.getpid()} | "
            f"Clients={len(self.clients)}"
        )

        self._latest_payload = event

        for client_id, queue in list(self.clients.items()):

            print(
                f"[SSE] Sending event | "
                f"Client={client_id}"
            )

            await queue.put(event)

    def get_latest(self):
        return self._latest_payload


sensor_bus = SensorEventBus()