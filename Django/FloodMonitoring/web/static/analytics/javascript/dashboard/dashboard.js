// Initialization
async function initializeDashboard() {
    console.log("Initializing dashboard...");
    initializeSensorMap();
    initializeAssessmentTabs();
    initializeMetricTabs();
}

document.addEventListener("DOMContentLoaded", async () => {
    await initializeDashboard();
});