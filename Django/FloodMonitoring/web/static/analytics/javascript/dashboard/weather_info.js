function updateWeather(sensor) {

    if (!sensor) return;

    const setText = (id, value) => {

        const element = document.getElementById(id);

        if (!element) return;

        element.textContent = value ?? "--";

    };

    setText(
        "weather-temperature",
        `${Number(sensor.temperature).toFixed(1)} °C`
    );

    setText(
        "weather-pressure",
        `${Number(sensor.pressure).toFixed(0)} hPa`
    );

    const descriptionElement =
        document.getElementById("weather-description");

    if (descriptionElement) {

        descriptionElement.textContent =
            (sensor.description ?? "--")
                .replace(/\b\w/g, letter => letter.toUpperCase());

    }

}