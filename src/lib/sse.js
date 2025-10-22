// src/lib/sse.js
export let clients = [];
export let lastEvent = null;

export function broadcastToClients(message) {
  lastEvent = message;
  const payload = JSON.stringify(message);
  for (const client of [...clients]) {
    try {
      client.write(`data: ${payload}\n\n`);
    } catch (err) {
      clients = clients.filter(c => c !== client);
    }
  }
}
