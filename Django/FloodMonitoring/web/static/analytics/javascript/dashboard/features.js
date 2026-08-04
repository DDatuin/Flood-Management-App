function updateFeatureTables(sensor) {

    if (!sensor) return;

    const setValue = (id, value, suffix = "") => {

        const element = document.getElementById(id);

        if (!element) return;

        if (value === null || value === undefined) {
            element.textContent = "--";
            return;
        }

        const number = Number(value);

        element.textContent =
            Number.isFinite(number)
                ? `${number.toFixed(2)}${suffix}`
                : `${value}${suffix}`;

    };

    setValue("wlvl-now", sensor.wlvl_now, " cm");
    setValue("wlvl-lag-1", sensor.wlvl_lag_1, " cm");
    setValue("wlvl-lag-2", sensor.wlvl_lag_2, " cm");
    setValue("wlvl-lag-5", sensor.wlvl_lag_5, " cm");
    setValue("wlvl-lag-10", sensor.wlvl_lag_10, " cm");

    setValue("diff-lag-1", sensor.diff_lag_1, " cm");
    setValue("pct-change-lag-1", sensor.pct_change_lag_1, "%");
    setValue("slope-lag-t-10", sensor.slope_lag_10);

    setValue("rainfall-hr1", sensor.rainfall_hr1, " mm");
    setValue("rainfall-hr2", sensor.rainfall_hr2, " mm");
    setValue("rainfall-hr12", sensor.rainfall_hr12, " mm");
    setValue("rainfall-hr24", sensor.rainfall_hr24, " mm");

}