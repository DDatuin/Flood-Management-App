let eventSource = null;

function initializeSSE() {

    if (eventSource) {
        eventSource.close();
    }

    eventSource = new EventSource("/api/stream/sensors-channel/");

    eventSource.onopen = () => {
        console.log("[SSE] Connected");
    };

    eventSource.onmessage = (event) => {
        updateDashboard(JSON.parse(event.data));
    };

    eventSource.onerror = (err) => {
        console.warn("[SSE] Connection lost.", err);
    };

}