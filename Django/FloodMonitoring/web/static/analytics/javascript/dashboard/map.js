let sensorMap;

function initializeSensorMap() {

    if (sensorMap) return;

    sensorMap = new maplibregl.Map({
        container: "sensor-map",
        style: "https://tiles.openfreemap.org/styles/liberty",
        center: [121.061, 14.575],
        zoom: 15,
        interactive: false,
        attributionControl: false
    });

    sensorMap.on("load", () => {
        sensorMap.resize();
    });
}

function setSensorStatus(online) {

    const badge = document.getElementById("sensor-activity-status-badge");
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