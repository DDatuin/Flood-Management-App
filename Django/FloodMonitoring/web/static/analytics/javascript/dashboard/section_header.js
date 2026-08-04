let latestPayload = null;
let selectedSensorId = null;

function updateSectionHeader(payload) {

    const select = document.getElementById("sensor-select");
    if (!select) return;

    const sensorIds = Object.keys(payload)
        .filter(id => id !== "overall")
        .sort();

    const currentIds =
        [...select.options].map(o => o.value);

    const idsChanged =
        currentIds.length !== sensorIds.length ||
        !currentIds.every((id, i) => id === sensorIds[i]);

    if (idsChanged) {

        const previous = selectedSensorId;

        select.innerHTML = "";

        sensorIds.forEach(id => {

            const option = document.createElement("option");
            option.value = id;
            option.textContent = id;
            select.appendChild(option);

        });

        if (previous && sensorIds.includes(previous)) {
            select.value = previous;
        } else {
            select.selectedIndex = 0;
        }
    }

    selectedSensorId = select.value;
}

function initializeSensorDropdown() {

    const select = document.getElementById("sensor-select");

    if (!select) return;

    select.addEventListener("change", () => {

        selectedSensorId = select.value;

        renderSelectedSensor();

    });

}

function renderSelectedSensor() {

    console.log("latestPayload", latestPayload);
    console.log("selectedSensorId", selectedSensorId);

    if (!latestPayload || !selectedSensorId) return;

    const sensor = latestPayload[selectedSensorId];

    if (!sensor) return;

    updateSensorMap(sensor);
    updateAssessment(sensor);
    updateFeatureTables(sensor);
    updateSensorInfo(sensor);
    updateWeather(sensor);
    updateMetrics(sensor);

}

function updateDashboard(payload) {

    latestPayload = payload;

    updateOverallAnalytics(payload.overall);
    updateSectionHeader(payload);

    console.log(selectedSensorId);

    renderSelectedSensor();

}