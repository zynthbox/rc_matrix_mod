.pragma library

/**
 * Normalize a value from [min, max] to [0, 1]
 */
function normalize(value, min, max) {
    if (max === min) return 0;
    return Math.max(0, Math.min(1, (value - min) / (max - min)));
}

/**
 * Denormalize a value from [0, 1] to [min, max]
 */
function denormalize(normalized, min, max) {
    return min + normalized * (max - min);
}

/**
 * Clamp a value between min and max
 */
function clamp(value, min, max) {
    return Math.max(min, Math.min(max, value));
}

/**
 * Format a numeric value to a fixed number of decimal places
 */
function formatValue(value, decimals) {
    return Number(value).toFixed(decimals !== undefined ? decimals : 2);
}

/**
 * Build a simple query string from an object of key/value pairs
 */
function buildQuery(params) {
    return Object.keys(params)
        .map(function(k) { return encodeURIComponent(k) + "=" + encodeURIComponent(params[k]); })
        .join("&");
}
