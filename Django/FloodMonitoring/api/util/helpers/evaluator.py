
from api.supabase.utils import get_latest_logged_prediction_for_sensor_from_supabase, get_vehicle_thresholds_from_supabase

def get_severity(water_level):

    severity_ranges = get_vehicle_thresholds_from_supabase()
    severities = {}

    for threshold in severity_ranges:

        vehicle = threshold["vehicle_type"].lower()

        if water_level <= threshold["safe_max"]:
            severity = "Safe"

        elif water_level <= threshold["warning_max"]:
            severity = "Warning"

        else:
            severity = "Danger"

        severities[vehicle] = severity

    return severities

def evaluate_model_accuracy(new_data_batch):

    metric_evaluation_json = []

    for dp in new_data_batch:

        sensor_id = dp["sensor_id"]

        last_prediction = get_latest_logged_prediction_for_sensor_from_supabase(sensor_id)

        if last_prediction is None:
            continue

        prediction_id = last_prediction["id"]
        prediction = last_prediction["forecast"]

        actual = dp["wlvl_now"]

        error = abs(prediction - actual)
        sqr_error = error ** 2

        forecast_severity = get_severity(prediction)
        actual_severity = get_severity(actual)

        metric_evaluation_json.append({
            #identifiers for database pushing
            "sensor_id": sensor_id,
            "timestamp": dp["timestamp"],

            #actual data to be logged in the Accuracy table
            "prediction_id": prediction_id, #prediction id here from previous timestep
            "abs_error": error, #error of prediction from actual water level
            "sqr_error": sqr_error, #squared error of prediction from actual water level
            "pedestrian_severity_forecasted": forecast_severity["pedestrian"], #forecast flood height severity for pedestrians
            "pedestrian_severity_actual": actual_severity["pedestrian"], #actual flood height severity for pedestrians
            "bicycle_severity_forecasted": forecast_severity["bicycle"], #forecast flood height severity for bikes
            "bicycle_severity_actual": actual_severity["bicycle"], #actual flood height severity for bikes
            "motor_severity_forecasted": forecast_severity["motorcycle"], #forecast flood height severity for motor
            "motor_severity_actual": actual_severity["motorcycle"], #actual flood height severity for motor
            "car_severity_forecasted": forecast_severity["car"], #forecast flood height severity for car
            "car_severity_actual": actual_severity["car"], #actual flood height severity for car
            "truck_severity_forecasted": forecast_severity["truck"], #forecast flood height severity for truck
            "truck_severity_actual": actual_severity["truck"], #actual flood height severity for truck
        })

    return metric_evaluation_json