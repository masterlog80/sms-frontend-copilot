'use strict';

const http = require('http');
const fs   = require('fs');
const path = require('path');

const DATA_DIR    = process.env.DATA_DIR || '/data';
const PORT        = 3001;
const ALLOWED_KEYS = new Set(['bookmarks', 'settings']);

// Ensure the data directory exists
try {
    fs.mkdirSync(DATA_DIR, { recursive: true });
} catch (err) {
    console.error(`[storage] Failed to create data directory "${DATA_DIR}": ${err.message}`);
    process.exit(1);
}

function filePath(key) {
    return path.join(DATA_DIR, `${key}.json`);
}

function sendJSON(res, status, body) {
    const payload = JSON.stringify(body);
    res.writeHead(status, {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(payload)
    });
    res.end(payload);
}

const server = http.createServer((req, res) => {
    // Parse path: /storage/<key>
    const match = req.url.match(/^\/storage\/([^/?#]+)$/);
    if (!match) {
        return sendJSON(res, 404, { error: 'Not found' });
    }

    const key = match[1];
    if (!ALLOWED_KEYS.has(key)) {
        return sendJSON(res, 400, { error: 'Invalid key' });
    }

    if (req.method === 'GET') {
        const file = filePath(key);
        try {
            const data = fs.readFileSync(file, 'utf8');
            res.writeHead(200, {
                'Content-Type': 'application/json',
                'Content-Length': Buffer.byteLength(data)
            });
            return res.end(data);
        } catch (err) {
            if (err.code === 'ENOENT') {
                return sendJSON(res, 200, null);
            }
            return sendJSON(res, 500, { error: 'Read failed' });
        }
    }

    if (req.method === 'POST') {
        const MAX_BODY = 1024 * 1024; // 1 MB
        let body = '';
        let bodySize = 0;
        req.on('data', chunk => {
            bodySize += chunk.length;
            if (bodySize > MAX_BODY) {
                req.destroy();
                return sendJSON(res, 413, { error: 'Request body too large' });
            }
            body += chunk;
        });
        req.on('end', () => {
            try {
                // Validate JSON
                JSON.parse(body);
                fs.writeFileSync(filePath(key), body, 'utf8');
                return sendJSON(res, 200, { ok: true });
            } catch (err) {
                return sendJSON(res, 400, { error: 'Invalid JSON' });
            }
        });
        return;
    }

    return sendJSON(res, 405, { error: 'Method not allowed' });
});

server.listen(PORT, '0.0.0.0', () => {
    console.log(`[storage] listening on port ${PORT}, data dir: ${DATA_DIR}`);
});
