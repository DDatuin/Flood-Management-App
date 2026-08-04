function updateSensorInfo(sensor) {

    if (!sensor) return;

    const setText = (id, value) => {

        const element = document.getElementById(id);

        if (!element) return;

        element.textContent = value ?? "--";

    };

    setText(
        "sensor-id",
        selectedSensorId
    );

    setText(
        "sensor-location",
        sensor.location_name
    );

    if (Array.isArray(sensor.latlong)) {

        const [lat, lng] = sensor.latlong;

        setText(
            "sensor-coordinates",
            `${lat.toFixed(8)}, ${lng.toFixed(8)}`
        );

    }

    setText(
        "sensor-ground-distance",
        `${Number(sensor.ground_distance).toFixed(2)} cm`
    );

    setText(
        "sensor-radius",
        `${Number(sensor.radius).toFixed(0)} m`
    );

    updateSensorInfoStatus(sensor.availability);

}

function updateSensorInfoStatus(online) {

    const badge = document.getElementById("sensor-info-status");

    if (!badge) return;

    const text = badge.querySelector(".sensor-activity-text");

    badge.classList.remove("online", "offline");

    if (online) {

        badge.classList.add("online");
        text.textContent = "Online";

    } else {

        badge.classList.add("offline");
        text.textContent = "Offline";

    }

}