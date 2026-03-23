#!/bin/sh
set -e

CONFIG_FILE="/usr/share/nginx/html/config.js"
API_LOG_CONF="/etc/nginx/api-log.conf"

if [ -n "$PASSWORD_UI" ]; then
    # Generate a SHA-256 hash of the password to avoid storing plaintext
    PASSWORD_HASH=$(echo -n "$PASSWORD_UI" | sha256sum | cut -d' ' -f1)
    cat > "$CONFIG_FILE" <<EOF
window.APP_CONFIG = {
    passwordEnabled: true,
    passwordHash: "${PASSWORD_HASH}"
};
EOF
    echo "[entrypoint] UI password protection enabled."
else
    cat > "$CONFIG_FILE" <<EOF
window.APP_CONFIG = {
    passwordEnabled: false,
    passwordHash: null
};
EOF
    echo "[entrypoint] UI password protection disabled (PASSWORD_UI not set)."
fi

# Configure API request/response logging based on DEBUG_LEVEL (NO | INFO | DEBUG)
DEBUG_LEVEL="${DEBUG_LEVEL:-NO}"
case "$DEBUG_LEVEL" in
    NO)
        cat > "$API_LOG_CONF" <<'EOF'
# API debug logging disabled (DEBUG_LEVEL=NO)
access_log off;
EOF
        echo "[entrypoint] API debug logging disabled (DEBUG_LEVEL=NO)."
        ;;
    INFO)
        cat > "$API_LOG_CONF" <<'EOF'
# API info logging enabled (DEBUG_LEVEL=INFO)
access_log /proc/1/fd/1 api_info;
EOF
        echo "[entrypoint] API info logging enabled (DEBUG_LEVEL=INFO): method, URL, status, timing."
        ;;
    DEBUG)
        cat > "$API_LOG_CONF" <<'EOF'
# API debug logging enabled (DEBUG_LEVEL=DEBUG)
access_log /proc/1/fd/1 api_debug;
EOF
        echo "[entrypoint] API debug logging enabled (DEBUG_LEVEL=DEBUG): full request body and response status."
        ;;
    *)
        cat > "$API_LOG_CONF" <<'EOF'
# API debug logging disabled (invalid DEBUG_LEVEL value)
access_log off;
EOF
        echo "[entrypoint] WARNING: Unknown DEBUG_LEVEL '${DEBUG_LEVEL}' (expected NO, INFO, or DEBUG). Defaulting to NO."
        ;;
esac

# Start the storage server in the background, forwarding output to nginx's stdout/stderr
node /storage/server.js >/proc/1/fd/1 2>/proc/1/fd/2 &

# Hand off to the default nginx entrypoint
exec nginx -g 'daemon off;'
