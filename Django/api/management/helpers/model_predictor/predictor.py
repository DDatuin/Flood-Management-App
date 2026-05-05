import pandas as pd

from .classifier import find_category
from .model_loader import get_model

FEATURE_ORDER = [
    "rainfall_hr1",
    "rainfall_hr2",
    "rainfall_hr12",
    "rainfall_hr24",
    "wlvl_now",
    "wlvl_lag_1",
    "wlvl_lag_2",
    "wlvl_lag_5",
    "wlvl_lag_10",
    "diff_lag_1",
    "pct_change_lag_1",
    "slope_lag_10",
]


def predict_batch(datapoint_batch):
    model = get_model()

    df = pd.DataFrame(datapoint_batch)

    # -----------------------------
    # Ensure all required features exist
    # -----------------------------
    for col in FEATURE_ORDER:
        if col not in df.columns:
            df[col] = 0.0

    # -----------------------------
    # Keep ONLY model features (important safety step)
    # -----------------------------
    X = df.reindex(columns=FEATURE_ORDER)

    # -----------------------------
    # Force numeric conversion safely
    # -----------------------------
    X = X.apply(pd.to_numeric, errors="coerce").fillna(0.0)

    # -----------------------------
    # Predict
    # -----------------------------
    preds = model.predict(X)

    # -----------------------------
    # Build response
    # -----------------------------
    forecast_json = []

    for i, dp in enumerate(datapoint_batch):
        prediction = float(preds[i])

        forecast_json.append({
            "timestamp": dp["timestamp"],
            "sensor_id": dp["sensor_id"],
            "latlng": dp["latlng"],
            "wlvl_now": dp["wlvl_now"],
            "forecast": prediction,
            "forecast_category": find_category(prediction)
        })

    return forecast_json