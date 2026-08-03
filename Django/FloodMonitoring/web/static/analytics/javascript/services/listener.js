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
        console.log("[SSE] Message", event.data);
        try {

            const payload = JSON.parse(event.data);

            console.log(payload.data);

            updateDashboard(payload.data);

        } catch(err) {

            console.error(err);

        }
    };

    eventSource.onerror = (err) => {
        console.warn("[SSE] Connection lost.", err);
    };

}