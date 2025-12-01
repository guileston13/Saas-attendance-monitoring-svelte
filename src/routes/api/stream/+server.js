// src/routes/api/stream/+server.js
let clients = [];

export async function GET({ request }) {
  return new Response(
    new ReadableStream({
      start(controller) {
        const encoder = new TextEncoder();

        const client = {
          write: (data) => {
            try {
              controller.enqueue(encoder.encode(data));
            } catch {}
          }
        };

        clients.push(client);

        // Keep connection alive
        const keepAlive = setInterval(() => client.write(':\n\n'), 15000);

        request.signal.addEventListener('abort', () => {
          clearInterval(keepAlive);
          clients = clients.filter(c => c !== client);
          try { controller.close(); } catch {}
        });
      }
    }),
    {
      headers: {
        'Content-Type': 'text/event-stream',
        'Cache-Control': 'no-cache',
        Connection: 'keep-alive'
      }
    }
  );
}

// Utility to broadcast messages
export function _broadcast(message) {
  const payload = JSON.stringify(message);
  for (const client of [...clients]) {
    try { client.write(`data: ${payload}\n\n`); } catch {
      clients = clients.filter(c => c !== client);
    }
  }
}
