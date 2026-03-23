FROM nginx:alpine

# Install Node.js (for the built-in storage server)
RUN apk add --no-cache nodejs

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy application files
COPY app /usr/share/nginx/html

# Copy storage server
COPY storage/server.js /storage/server.js

# Create the data directory (overridden by the bind-mount at runtime)
RUN mkdir -p /data

# Copy and set up the entrypoint script
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Expose port 80
EXPOSE 80

CMD ["/docker-entrypoint.sh"]
