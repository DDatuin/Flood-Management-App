function initializeAssessmentTabs() {

    const currentTab = document.getElementById("current-tab");
    const forecastTab = document.getElementById("forecast-tab");

    const currentPanel = document.getElementById("current-panel");
    const forecastPanel = document.getElementById("forecast-panel");

    currentTab.addEventListener("click", () => {

        currentTab.classList.add("analytics-tab-active");
        forecastTab.classList.remove("analytics-tab-active");

        currentPanel.classList.add("active");
        forecastPanel.classList.remove("active");

    });

    forecastTab.addEventListener("click", () => {

        forecastTab.classList.add("analytics-tab-active");
        currentTab.classList.remove("analytics-tab-active");

        forecastPanel.classList.add("active");
        currentPanel.classList.remove("active");

    });

}

function updateAssessment(sensor) {

    if (!sensor) return;

    updateAssessmentCard(
        "current",
        sensor.wlvl_now,
        sensor.flood_cat_now
    );

    updateAssessmentCard(
        "forecast",
        sensor.forecast,
        sensor.flood_cat
    );

    updateVehicleStatuses(
        "current",
        sensor.current_severity
    );

    updateVehicleStatuses(
        "forecast",
        sensor.forecast_severity
    );

}

function updateAssessmentCard(prefix, level, category) {

    const valueElement =
        document.getElementById(`${prefix}-assessment-value`);

    const categoryElement =
        document.getElementById(`${prefix}-assessment-category`);

    const cardElement =
        document.getElementById(`${prefix}-assessment-card`);

    if (!valueElement || !categoryElement || !cardElement) return;

    valueElement.textContent =
        Number(level ?? 0).toFixed(2);

    const categoryKey = (category ?? "").toLowerCase();

    const categoryMap = {
        nf: "No Flood",
        patv: "Passable to All Types of Vehicles (PATV)",
        nplv: "Not Passable to Light Vehicles (NPLV)",
        npatv: "Not Passable to All Types of Vehicles (NPATV)"
    };

    categoryElement.textContent =
        categoryMap[categoryKey] ?? "-";

    cardElement.className =
        `assessment-card ${categoryKey}`;

    categoryElement.className =
        `assessment-mmda-category ${categoryKey}`;
}

function updateVehicleStatuses(prefix, statuses) {

    Object.entries(statuses).forEach(([vehicle, status]) => {

        const badge =
            document.getElementById(`${prefix}-${vehicle}-status`);

        if (!badge) return;

        badge.textContent =
            status.charAt(0).toUpperCase() + status.slice(1);

        badge.className =
            `vehicle-badge ${status.toLowerCase()}`;

    });

}