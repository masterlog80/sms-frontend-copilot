#!/bin/sh
set -e

CONFIG_FILE="/usr/share/nginx/html/config.js"

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

# Hand off to the default nginx entrypoint
exec nginx -g 'daemon off;'
