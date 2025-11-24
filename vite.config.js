// vite.config.js
import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
import fs from 'fs';
import path from 'path';

export default defineConfig({
  plugins: [sveltekit()],

  server: {
    host: true,  // listen on all interfaces
    port: 4173,
    https: {
      key: fs.readFileSync('./localhost+1-key.pem'),
      cert: fs.readFileSync('./localhost+1.pem')
    },
    allowedHosts: [
      'localhost',
      'desktop-r98pm6a.local',
      'raspberrypi.local', // add your Pi here
      '172.27.44.17',
      '172.27.44.73',
      '172.27.44.213',
      '10.136.35.91'
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
    https: {
      key: fs.readFileSync('./localhost+1-key.pem'),
      cert: fs.readFileSync('./localhost+1.pem')
    },
    allowedHosts: [
      'localhost',
      'desktop-r98pm6a.local',
      'raspberrypi.local', // add your Pi here
      '172.27.44.17',
      '172.27.44.73',
      '172.27.44.213',
      '10.136.35.91',
      '192.168.56.1'
    ]
    // ✅ fs cannot go here
  }
});
