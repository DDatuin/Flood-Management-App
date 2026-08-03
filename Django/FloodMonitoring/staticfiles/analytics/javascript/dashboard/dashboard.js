// Initialization
function initializeDashboard() {
    console.log("Initializing dashboard...");
    initializeSensorMap();
    initializeAssessmentTabs();
    initializeMetricTabs();
    
}

// SSE-driven updates
function updateDashboard(payload) {
    updateOverallAnalytics(payload.overall);
    updateAssessment(payload.sensor);
    updateFeatureTables(payload.sensor);
    updateWeather(payload.sensor);
    updateMetrics(payload.sensor);
    updateSensorInfo(payload.sensor);
    updateMap(payload.sensor);
}

document.addEventListener("DOMContentLoaded", async () => {
    initializeDashboard();
    initializeSSE();
});