import { createServer } from 'node:http';

// Bind to loopback only; accessible via localhost:4318 from the same machine.
const HOST = '127.0.0.1';
const PORT = 4318;
const MAX_BODY_BYTES = 10 * 1024 * 1024; // 10 MB

const server = createServer((req, res) => {
  if (req.method === 'POST' && req.url === '/v1/logs') {
    const contentType = req.headers['content-type'] || '';
    if (!contentType.includes('application/json')) {
      res.writeHead(415, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: 'Unsupported Media Type: expected application/json' }));
      return;
    }

    let body = '';
    let bodyBytes = 0;
    req.on('data', (chunk) => {
      bodyBytes += chunk.length;
      if (bodyBytes > MAX_BODY_BYTES) {
        req.destroy();
        res.writeHead(413, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Payload Too Large' }));
        return;
      }
      body += chunk.toString();
    });
    req.on('end', () => {
      if (res.headersSent) return;
      try {
        const payload = JSON.parse(body);
        console.log('Received logs:', JSON.stringify(payload, null, 2));
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ partialSuccess: {} }));
      } catch {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Invalid JSON' }));
      }
    });
  } else {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Not Found' }));
  }
});

server.listen(PORT, HOST, () => {
  console.log(`OTLP logs endpoint listening on http://${HOST}:${PORT}/v1/logs`);
});
