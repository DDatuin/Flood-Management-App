let regressionChart = null;

function initializeMetricTabs() {

    console.log("Initializing metric tabs");

    const regressionTab = document.getElementById("regression-tab");
    const classificationTab = document.getElementById("classification-tab");

    const regressionPanel = document.getElementById("regression-panel");
    const classificationPanel = document.getElementById("classification-panel");

    initializeRegressionChart();

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

    regressionChart = new Chart(ctx, {

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

function updateMetrics(sensor) {

    if (!sensor || !sensor.metrics) return;

    updateRegressionMetrics(sensor.metrics.regression);

    updateClassificationMetrics(
        sensor.metrics.classification
    );

}

function updateRegressionMetrics(metrics) {

    if (!metrics?.summary) return;

    document.getElementById("rmse-val").textContent =
        Number(metrics.summary.rmse).toFixed(3);

    document.getElementById("mae-val").textContent =
        Number(metrics.summary.mae).toFixed(3);

    document.getElementById("mse-val").textContent =
        Number(metrics.summary.mse).toFixed(3);

    updateRegressionChart(metrics.history);

}

function updateRegressionChart(history) {

    if (!regressionChart || !history) return;

    regressionChart.data.labels =
        history.map(item =>
            new Date(item.timestamp).toLocaleTimeString("en-PH", {
                hour: "2-digit",
                minute: "2-digit"
            })
        );

    regressionChart.data.datasets[0].data =
        history.map(item => item.actual);

    regressionChart.data.datasets[1].data =
        history.map(item => item.predicted);

    regressionChart.data.datasets[2].data =
        history.map(item => item.abs_error);

    regressionChart.update("none");

}

function updateClassificationMetrics(metrics) {

    if (!metrics) return;

    const type =
        document.getElementById(
            "classification-type-dropdown"
        ).value;

    const matrix = metrics[type];

    updateConfusionMatrix(matrix);

}

function updateConfusionMatrix(matrix) {

    const table = document.getElementById(
        "confusion-matrix-table"
    );

    if (!table) return;

    table.innerHTML = "";

    if (!matrix || Object.keys(matrix).length === 0) {

        table.innerHTML =
            "<tr><td>No data available.</td></tr>";

        return;

    }

    const classes = new Set();

    Object.keys(matrix).forEach(actual => {

        classes.add(actual);

        Object.keys(matrix[actual]).forEach(predicted => {
            classes.add(predicted);
        });

    });

    const desiredOrder = [
        "NF",
        "PATV",
        "NPLV",
        "NPATV",
        "Safe",
        "Warning",
        "Danger"
    ];

    const labels = desiredOrder.filter(label =>
        classes.has(label)
    );

    // ---------- Header ----------

    const thead = document.createElement("thead");

    const headerRow = document.createElement("tr");

    headerRow.innerHTML =
        `<th>Actual \\ Predicted</th>`;

    labels.forEach(label => {

        const th = document.createElement("th");
        th.textContent = label;

        headerRow.appendChild(th);

    });

    thead.appendChild(headerRow);

    table.appendChild(thead);

    // ---------- Body ----------

    const tbody = document.createElement("tbody");

    labels.forEach(actual => {

        const tr = document.createElement("tr");

        const rowHeader = document.createElement("th");
        rowHeader.textContent = actual;

        tr.appendChild(rowHeader);

        labels.forEach(predicted => {

            const td = document.createElement("td");

            td.textContent =
                matrix[actual]?.[predicted] ?? 0;

            if (actual === predicted) {
                td.classList.add("confusion-correct");
            }

            tr.appendChild(td);

        });

        tbody.appendChild(tr);

    });

    table.appendChild(tbody);

}

const dropdown = document.getElementById(
    "classification-type-dropdown"
);

dropdown.addEventListener("change", () => {

    if (!latestPayload || !selectedSensorId) return;

    updateClassificationMetrics(
        latestPayload[selectedSensorId]
            .metrics.classification
    );

});
