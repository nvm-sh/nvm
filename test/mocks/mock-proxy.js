// A minimal forward proxy for testing nvm's Proxy-Authorization support
// (see the "nvm_download" fast test). It requires no dependencies beyond
// Node.js core modules.
//
// Usage: node mock-proxy.js <expected-proxy-authorization> <port-file>
//
// - Listens on 127.0.0.1 on an OS-assigned free port (port 0) and writes
//   the assigned port to <port-file> once the listener is bound, so the
//   test can discover it.
// - Answers plain HTTP (absolute-form) requests and CONNECT requests whose
//   Proxy-Authorization header is missing or differs from
//   <expected-proxy-authorization> with "407 Proxy Authentication Required".
// - Forwards accepted absolute-form requests to the origin they name and
//   streams the origin's response back to the client; the
//   Proxy-Authorization header is not forwarded to the origin.
// - Tunnels accepted CONNECT requests to the requested host and port.
'use strict';

const fs = require('fs');
const http = require('http');
const net = require('net');

const [expectedProxyAuth, portFile] = process.argv.slice(2);
if (!expectedProxyAuth || !portFile) {
  console.error('usage: node mock-proxy.js <expected-proxy-authorization> <port-file>');
  process.exit(2);
}

function proxyAuthOk(req) {
  return req.headers['proxy-authorization'] === expectedProxyAuth;
}

function deny(client) {
  const head = 'HTTP/1.1 407 Proxy Authentication Required\r\n'
    + 'Proxy-Authenticate: Basic realm="mock-proxy"\r\n'
    + 'Connection: close\r\n'
    + 'Content-Length: 0\r\n'
    + '\r\n';
  if (client.writeHead) {
    // A plain HTTP request: res.writeHead already sets the headers.
    client.writeHead(407, {
      'Proxy-Authenticate': 'Basic realm="mock-proxy"',
      'Connection': 'close',
      'Content-Length': '0',
    });
    client.end();
  } else {
    // A CONNECT request: write the raw response on the socket.
    client.end(head);
  }
}

const server = http.createServer((req, res) => {
  if (!proxyAuthOk(req)) {
    deny(res);
    return;
  }
  // The request line of a proxied plain HTTP request carries the absolute
  // origin URL (e.g. "http://127.0.0.1/get").
  let target;
  try {
    target = new URL(req.url);
  } catch (err) {
    res.writeHead(400, { 'Content-Type': 'text/plain' });
    res.end('Bad Request: expected an absolute-form URL');
    return;
  }
  const headers = Object.assign({}, req.headers, { host: target.host });
  delete headers['proxy-authorization'];
  delete headers['proxy-connection'];
  const upstream = http.request({
    protocol: target.protocol,
    hostname: target.hostname,
    port: target.port || (target.protocol === 'https:' ? 443 : 80),
    method: req.method,
    path: target.pathname + target.search,
    headers,
  }, (upstreamRes) => {
    res.writeHead(upstreamRes.statusCode || 502, upstreamRes.headers);
    upstreamRes.pipe(res);
  });
  upstream.on('error', (err) => {
    res.writeHead(502, { 'Content-Type': 'text/plain' });
    res.end(`Bad Gateway: ${err.message}`);
  });
  req.pipe(upstream);
});

server.on('connect', (req, clientSocket, head) => {
  if (!proxyAuthOk(req)) {
    deny(clientSocket);
    return;
  }
  const [host, port] = req.url.split(':');
  const upstream = net.connect(Number(port) || 443, host, () => {
    clientSocket.write('HTTP/1.1 200 Connection Established\r\n\r\n');
    if (head && head.length) {
      upstream.write(head);
    }
    upstream.pipe(clientSocket);
    clientSocket.pipe(upstream);
  });
  upstream.on('error', () => {
    clientSocket.end('HTTP/1.1 502 Bad Gateway\r\nConnection: close\r\nContent-Length: 0\r\n\r\n');
  });
});

server.on('clientError', (err, socket) => {
  console.error(`mock proxy: client error: ${err.message}`);
  socket.end('HTTP/1.1 400 Bad Request\r\nConnection: close\r\nContent-Length: 0\r\n\r\n');
});

server.on('error', (err) => {
  console.error(`mock proxy: ${err.message}`);
  process.exit(1);
});

server.listen(0, '127.0.0.1', () => {
  const port = server.address().port;
  fs.writeFileSync(portFile, `${port}\n`);
  console.log(`mock proxy listening on port ${port}`);
});
