FROM node:22-alpine

WORKDIR /app

COPY package.json ./
COPY server.js ./

# Create the data directory (overridden by the mounted volume at runtime)
RUN mkdir -p /data

EXPOSE 3001

CMD ["node", "server.js"]
