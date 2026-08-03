// Initialization
async function initializeDashboard() {

    console.log("Initializing dashboard...");

    initializeSensorMap();
    initializeAssessmentTabs();
    initializeMetricTabs();
    initializeSensorDropdown();

}

document.addEventListener("DOMContentLoaded", async () => {
    initializeDashboard();
    initializeSSE();
});