import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
import path from 'path';

export default defineConfig({
	plugins: [
		sveltekit(),
		// Plugin to set client IP header in development
		{
			name: 'client-ip-middleware',
			configureServer(server) {
				server.middlewares.use((req, res, next) => {
					// Set x-forwarded-for header with client IP for development
					if (!req.headers['x-forwarded-for']) {
						const clientIP = req.connection.remoteAddress || req.socket.remoteAddress;
						if (clientIP) {
							req.headers['x-forwarded-for'] = clientIP.replace(/^::ffff:/, ''); // Remove IPv6 prefix for IPv4
						}
					}
					next();
				});
			}
		}
	],
	server: {
		fs: {
			allow: [
				'src',
				'node_modules',
				// Add this line:
				path.resolve(__dirname, 'models')
			]
		},
		allowedHosts: [
			'milton-demonstrate-passed-compact.trycloudflare.com'
		]
	}
});