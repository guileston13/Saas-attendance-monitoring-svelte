// static/facehandle.js
// This file acts as a redirector for face-api.js model requests.
// It serves as a compatibility layer if you need to dynamically redirect model requests.
// In SvelteKit/Vite, static assets in /static are served at the root URL (e.g., /models/...).
// If you want to customize model loading, you can use this file as a reference.

// Example usage in the browser (in +page.svelte):
// Instead of changing face-api.js, just set modelUrl = '/models';
// If you want to dynamically redirect, you can fetch('/facehandle.js?model=...')
// and proxy/serve the file as needed (advanced usage).

// For most cases, just put your models in /static/models and load with:
// faceapi.nets.tinyFaceDetector.loadFromUri('/models')
// faceapi.nets.faceLandmark68Net.loadFromUri('/models')

// This file is a placeholder for advanced routing if needed.
