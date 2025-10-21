import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
import path from 'path';

export default defineConfig({
  plugins: [
    sveltekit(),
    {
      name: 'client-ip-middleware',
      configureServer(server) {
        server.middlewares.use((req, res, next) => {
          if (!req.headers['x-forwarded-for']) {
            const clientIP = req.connection.remoteAddress || req.socket.remoteAddress;
            if (clientIP) req.headers['x-forwarded-for'] = clientIP.replace(/^::ffff:/, '');
          }
          next();
        });
      }
    }
  ],
  server: {
    host: true, // ✅ this makes Vite listen on 0.0.0.0 (all network interfaces)
    port: 5173, // optional, default is 5173
    fs: {
      allow: [
        'src',
        'node_modules',
        path.resolve(__dirname, 'models')
      ]
    },
    allowedHosts: [
      'milton-demonstrate-passed-compact.trycloudflare.com'
    ]
  }
});
