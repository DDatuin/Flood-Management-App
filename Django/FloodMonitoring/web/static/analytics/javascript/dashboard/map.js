let sensorMap;
let sensorMarker = null;
let mapReady = false;

function initializeSensorMap() {

    if (sensorMap) return;

    sensorMap = new maplibregl.Map({
        container: "sensor-map",
        style: "https://tiles.openfreemap.org/styles/liberty",
        center: [121.01075955335006, 14.598202707389976],
        zoom: 15,
        interactive: false,
        attributionControl: false
    });

    sensorMap.on("load", () => {
        sensorMap.resize();

        sensorMap.addSource("sensor-radius", {
            type: "geojson",
            data: {
                type: "FeatureCollection",
                features: []
            }
        });

        sensorMap.addLayer({
            id: "sensor-radius-fill",
            type: "fill",
            source: "sensor-radius",
            paint: {
                "fill-color": "#2563eb",
                "fill-opacity": 0.18
            }
        });

        sensorMap.addLayer({
            id: "sensor-radius-outline",
            type: "line",
            source: "sensor-radius",
            paint: {
                "line-color": "#2563eb",
                "line-width": 2
            }
        });

        if (typeof renderSelectedSensor === "function") {
            mapReady = true;
            renderSelectedSensor();
        }
    });
}

function updateSensorMap(sensor) {

    if (!mapReady) return;

    const radiusSource = sensorMap.getSource("sensor-radius");

    if (!radiusSource) {
        return;
    }

    setSensorStatus(sensor.availability);

    console.log(sensor.datetime);
    updateLastUpdate(sensor.datetime);
    
    const [lat, lng] = sensor.latlong;

    const lngLat = [lng, lat];

    const radiusFeature = createCircle(
        lngLat,
        sensor.radius
    );

    radiusSource.setData({
        type: "FeatureCollection",
        features: [radiusFeature]
    });

    sensorMap.flyTo({
        center: lngLat,
        zoom: 17,
        duration: 750
    });

    if (!sensorMarker) {

        const markerElement = document.createElement("img");
        markerElement.src = "/static/assets/images/sensor_marker.png";
        markerElement.className = "sensor-marker";

        markerElement.style.width = "28px";
        markerElement.style.height = "28px";
        markerElement.style.objectFit = "contain";

        sensorMarker = new maplibregl.Marker({
            element: markerElement,
            anchor: "center"
        })
        .setLngLat(lngLat)
        .addTo(sensorMap);

    } else {

        sensorMarker.setLngLat(lngLat);

    }

}

function createCircle(center, radiusMeters, points = 256) {

    const [lng, lat] = center;

    const coords = [];

    const earthRadius = 6378137;

    const latRad = lat * Math.PI / 180;

    for (let i = 0; i <= points; i++) {

        const angle = (i / points) * Math.PI * 2;

        const dx = radiusMeters * Math.cos(angle);
        const dy = radiusMeters * Math.sin(angle);

        const newLat =
            lat + (dy / earthRadius) * (180 / Math.PI);

        const newLng =
            lng + (dx / (earthRadius * Math.cos(latRad))) * (180 / Math.PI);

        coords.push([newLng, newLat]);

    }

    return {
        type: "Feature",
        geometry: {
            type: "Polygon",
            coordinates: [coords]
        }
    };

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

function updateLastUpdate(timestamp) {

    console.log("updateLastUpdate:", timestamp);

    const element = document.getElementById("sensor-last-update");

    if (!element) return;

    if (!timestamp) {
        element.textContent = "--";
        return;
    }

    const date = new Date(timestamp);

    element.textContent = date.toLocaleString("en-PH", {
        month: "short",
        day: "numeric",
        year: "numeric",
        hour: "numeric",
        minute: "2-digit",
        second: "2-digit",
        hour12: true
    });

}