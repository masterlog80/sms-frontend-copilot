// Default config for local development (no Docker).
// In the container this file is overwritten by docker-entrypoint.sh
// based on the PASSWORD_UI environment variable.
window.APP_CONFIG = {
    passwordEnabled: false,
    passwordHash: null
};
