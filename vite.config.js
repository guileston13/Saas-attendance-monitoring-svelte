// vite.config.js
import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
import path from 'path';

export default defineConfig({
  plugins: [sveltekit()],

  server: {
    host: true,  // listen on all interfaces
    port: 4173,
    allowedHosts: [
      'localhost',
      'desktop-r98pm6a.local',
      'raspberrypi.local', // add your Pi here
    ],
    fs: {
      allow: [
        'src',
        'node_modules',
        path.resolve(__dirname, 'models')
      ]
    }
  },

  preview: {
    host: true,
    port: 4173,
    allowedHosts: [
      'localhost',
      'desktop-r98pm6a.local',
      'raspberrypi.local', // add your Pi here
    ]
    // ✅ fs cannot go here
  }
});
