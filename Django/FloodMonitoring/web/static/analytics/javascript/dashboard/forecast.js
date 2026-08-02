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