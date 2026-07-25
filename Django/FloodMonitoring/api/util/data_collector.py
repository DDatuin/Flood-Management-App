
from api.util.helpers.blynk_listener import fetch_blynk_data
from api.util.helpers.ingester import ingest_datapoints
from api.util.helpers.model_predictor.predictor import predict_batch
from api.utils import format_latest_sensor_data

from ..supabase.utils import push_blynk_data_to_supabase

from asgiref.sync import async_to_sync
from fdw_backend.events import sensor_bus

    
def run_data_collection_cycle():

    batch = fetch_blynk_data()

    if not batch:
        return False

    new_data_batch = ingest_datapoints(batch)

    forecast_data_batch = predict_batch(new_data_batch)
    
    push_blynk_data_to_supabase(forecast_data_batch, new_data_batch)

    #could add another guard clause here

    latest_sensor_data_formatted = format_latest_sensor_data()

    async_to_sync(sensor_bus.publish)({
        "type": "sensor_update",
        "data": latest_sensor_data_formatted
    })

    return True