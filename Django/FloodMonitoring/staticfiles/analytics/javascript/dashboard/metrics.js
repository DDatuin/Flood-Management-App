function initializeMetricTabs() {

    console.log("Initializing metric tabs");

    const regressionTab = document.getElementById("regression-tab");
    const classificationTab = document.getElementById("classification-tab");

    const regressionPanel = document.getElementById("regression-panel");
    const classificationPanel = document.getElementById("classification-panel");

    initializeRegressionChart();
    initializeConfusionMatrix();

    regressionTab.addEventListener("click", () => {

        regressionTab.classList.add("analytics-tab-active");
        classificationTab.classList.remove("analytics-tab-active");

        regressionPanel.classList.add("active");
        classificationPanel.classList.remove("active");

    });

    classificationTab.addEventListener("click", () => {

        classificationTab.classList.add("analytics-tab-active");
        regressionTab.classList.remove("analytics-tab-active");

        classificationPanel.classList.add("active");
        regressionPanel.classList.remove("active");

    });

}

function initializeRegressionChart() {

    console.log("Creating regression chart");

    const ctx = document.getElementById("regression-chart");

    console.log(ctx);

    if (!ctx) return;

    new Chart(ctx, {

        type: "line",

        data: {

            labels: [
                "-45m",
                "-40m",
                "-35m",
                "-30m",
                "-25m",
                "-20m",
                "-15m",
                "-10m",
                "-5m",
                "Now"
            ],

            datasets: [

                {
                    label: "Actual",
                    data: [20, 25, 30, 45, 58, 64, 72, 81, 87, 91],
                    borderColor: "#2563eb",
                    backgroundColor: "#2563eb",
                    borderWidth: 3,
                    pointRadius: 2,
                    tension: .35
                },

                {
                    label: "Predicted",
                    data: [21, 24, 32, 44, 60, 63, 73, 79, 88, 90],
                    borderColor: "#22c55e",
                    backgroundColor: "#22c55e",
                    borderDash: [6,6],
                    borderWidth: 3,
                    pointRadius: 2,
                    tension: .35
                },

                {
                    label: "Absolute Error",
                    data: [1,1,2,1,2,1,1,2,1,1],
                    borderColor: "#ef4444",
                    backgroundColor: "#ef4444",
                    borderWidth: 2,
                    pointRadius: 2,
                    tension: .35
                }

            ]

        },

        options: {

            responsive: true,
            maintainAspectRatio: false,

            plugins: {

                legend: {
                    position: "top"
                }

            },

            scales: {

                y: {
                    beginAtZero: true,
                    title: {
                        display: true,
                        text: "Water Level (cm)"
                    }
                }

            }

        }

    });

}

function initializeConfusionMatrix() {

    const ctx = document.getElementById("confusion-matrix");

    if (!ctx) return;

    new Chart(ctx, {

        type: "bar",

        data: {

            labels: [
                "NF",
                "PATV",
                "NPLV",
                "NPATV"
            ],

            datasets: [

                {
                    label: "Correct",
                    data: [97,94,96,95],
                    backgroundColor: "#22c55e"
                },

                {
                    label: "Misclassified",
                    data: [3,6,4,5],
                    backgroundColor: "#ef4444"
                }

            ]

        },

        options: {

            responsive: true,
            maintainAspectRatio: false,

            plugins: {

                legend: {
                    position: "top"
                }

            },

            scales: {

                x: {
                    stacked: true
                },

                y: {

                    stacked: true,

                    max: 100,

                    title: {
                        display: true,
                        text: "Predictions (%)"
                    }

                }

            }

        }

    });

}