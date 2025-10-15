import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
import path from 'path';

export default defineConfig({
	plugins: [sveltekit()],
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
			'hurricane-limiting-skilled-wooden.trycloudflare.com'
		]
	}
});