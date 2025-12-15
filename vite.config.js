// vite.config.js
import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
import fs from 'fs';
import path from 'path';

export default defineConfig({
  plugins: [sveltekit()],

  // Exclude model binary files from being processed as JS
  assetsInclude: ['**/*.onnx'],
  
  optimizeDeps: {
    exclude: ['face-api.js']
  },

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
      '10.136.35.91',
      '192.168.100.15',
      '192.168.56.1',
      '192.168.1.50',
      '192.168.1.49',
      '10.144.18.235',
      '192.168.100.115',
      '172.27.44.123'
    ],
    fs: {
      allow: [
        'src',
        'node_modules'
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
      '192.168.56.1',
      '192.168.100.15',
      '192.168.56.1',
      '172.27.44.123'
    ]
    // ✅ fs cannot go here
  }
});
