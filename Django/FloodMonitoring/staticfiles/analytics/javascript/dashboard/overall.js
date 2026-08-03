
function updateOverallAnalytics(overall) {

    if (!overall) return;

    document.getElementById("overall-total-sensors").textContent = overall.total_sensors ?? "-";
    document.getElementById("overall-active-sensors").textContent = overall.active_sensors ?? "-";
    document.getElementById("overall-offline-sensors").textContent = overall.offline_sensors ?? "-";
    document.getElementById("overall-rmse").textContent = `${Number(overall.rmse ?? 0).toFixed(3)} cm`;
    document.getElementById("overall-mse").textContent = `${Number(overall.mse ?? 0).toFixed(3)} cm`;
    document.getElementById("overall-mae").textContent = `${Number(overall.mae ?? 0).toFixed(3)} cm`;

}