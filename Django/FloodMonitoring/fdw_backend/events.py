import asyncio
import os
import uuid


class SensorEventBus:

    def __init__(self):
        self.clients = {}
        self._latest_payload = None

    def register(self):
        queue = asyncio.Queue()

        client_id = str(uuid.uuid4())[:8]

        self.clients[client_id] = queue

        print(
            f"[SSE] Client registered | "
            f"ID={client_id} | "
            f"PID={os.getpid()} | "
            f"Clients={len(self.clients)}"
        )

        self.print_clients()

        return client_id, queue

    def unregister(self, client_id):
        self.clients.pop(client_id, None)

        print(
            f"[SSE] Client unregistered | "
            f"ID={client_id} | "
            f"PID={os.getpid()} | "
            f"Clients={len(self.clients)}"
        )

        self.print_clients()

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

    def print_clients(self):
        print(
            f"[SSE] Active clients: "
            f"{list(self.clients.keys())}"
        )

    def get_latest(self):
        return self._latest_payload


sensor_bus = SensorEventBus()