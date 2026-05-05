
from django.core.management.base import BaseCommand
from ..helpers.mqtt_listener import start_mqtt_listener
from ..helpers.ingester import ingest_datapoints_from_queue
from ..helpers.model_predictor.predictor import predict_batch
from ...supabase.utils import push_to_supabase
from queue import Queue
import threading, time

class Command(BaseCommand):

    help = "Background process for acquiring HiveMQ + OpenWeatherAPI data to log in Supabase and send to client/edge device"

    
    def handle(self, *args, **kwargs):

        msg_queue = Queue()

        self.stdout.write("Starting MQTT Listener thread...")

        thread = threading.Thread(target=start_mqtt_listener, args=(msg_queue,), daemon=True)
        thread.start()

        while True:
            

            if not msg_queue.empty():
                print("[MAIN] Received data from queue")
                print("[MAIN] Processing batch...")
                new_data_batch = ingest_datapoints_from_queue(msg_queue)
                print(f"[INGEST] Batch: {new_data_batch}")
                
                if new_data_batch:
                    print("[MODEL] Running prediction...")
                    forecast_data_batch = predict_batch(new_data_batch)
                    print(f"[MODEL] Prediction: {forecast_data_batch}")
                    push_to_supabase(forecast_data_batch, new_data_batch)
            else:
                time.sleep(0.05)