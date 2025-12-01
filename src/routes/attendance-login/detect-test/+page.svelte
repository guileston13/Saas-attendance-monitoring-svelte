<script>
  import { onMount, onDestroy } from 'svelte';

  let videoElement;
  let canvasElement;
  let stream = null;
  let isRunning = false;
  let detectionLoop = null;
  
  // Stats
  let fps = 0;
  let inferenceTime = 0;
  let faceCount = 0;
  let lastDetections = [];
  let errorMessage = '';
  
  // Settings
  let showLandmarks = true;
  let showLandmarks68 = false;
  let showBox = true;
  let showScore = true;
  let detectionInterval = 300; // ms between detections (MTCNN is slower)

  onMount(async () => {
    await startCamera();
  });

  onDestroy(() => {
    stopDetection();
    if (stream) {
      stream.getTracks().forEach(t => t.stop());
    }
  });

  async function startCamera() {
    try {
      stream = await navigator.mediaDevices.getUserMedia({
        video: { width: 640, height: 480, facingMode: 'user' }
      });
      videoElement.srcObject = stream;
      await videoElement.play();
      errorMessage = '';
    } catch (err) {
      errorMessage = `Camera error: ${err.message}`;
      console.error('Camera error:', err);
    }
  }

  function startDetection() {
    if (isRunning) return;
    isRunning = true;
    runDetectionLoop();
  }

  function stopDetection() {
    isRunning = false;
    if (detectionLoop) {
      clearTimeout(detectionLoop);
      detectionLoop = null;
    }
  }

  async function runDetectionLoop() {
    if (!isRunning) return;

    const startTime = performance.now();
    
    try {
      await detectFaces();
    } catch (err) {
      console.error('Detection error:', err);
      errorMessage = err.message;
    }

    const elapsed = performance.now() - startTime;
    fps = Math.round(1000 / Math.max(elapsed, detectionInterval));

    // Schedule next detection
    detectionLoop = setTimeout(runDetectionLoop, Math.max(0, detectionInterval - elapsed));
  }

  async function detectFaces() {
    if (!videoElement || videoElement.readyState < 2) return;

    // Capture frame from video
    const tempCanvas = document.createElement('canvas');
    tempCanvas.width = videoElement.videoWidth;
    tempCanvas.height = videoElement.videoHeight;
    const tempCtx = tempCanvas.getContext('2d');
    tempCtx.drawImage(videoElement, 0, 0);
    
    const imageData = tempCanvas.toDataURL('image/jpeg', 0.8);

    // Send to server
    const response = await fetch('/attendance-login/detect-test', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ image: imageData })
    });

    const result = await response.json();
    
    if (result.success) {
      lastDetections = result.detections;
      faceCount = result.count;
      inferenceTime = result.inferenceTime;
      errorMessage = '';
      drawDetections(result.detections, result.imageSize);
    } else {
      errorMessage = result.error || 'Detection failed';
    }
  }

  function drawDetections(detections, imageSize) {
    if (!canvasElement) return;
    const ctx = canvasElement.getContext('2d');

    const scaleX = canvasElement.width / imageSize.width;
    const scaleY = canvasElement.height / imageSize.height;

    ctx.clearRect(0, 0, canvasElement.width, canvasElement.height);

    detections.forEach(det => {
      const { box, landmarks, landmarks68, score } = det;
      const [x1, y1, x2, y2] = box;
      const x = x1 * scaleX;
      const y = y1 * scaleY;
      const w = (x2 - x1) * scaleX;
      const h = (y2 - y1) * scaleY;

      // Draw box
      if (showBox) {
        ctx.strokeStyle = score > 0.9 ? '#00ff00' : score > 0.7 ? '#ffff00' : '#ff0000';
        ctx.lineWidth = 3;
        ctx.strokeRect(x, y, w, h);

        ctx.fillStyle = score > 0.9 ? 'rgba(0,255,0,0.1)' : 'rgba(255,255,0,0.1)';
        ctx.fillRect(x, y, w, h);
      }

      // Draw score
      if (showScore) {
        ctx.fillStyle = '#00ff00';
        ctx.font = 'bold 16px Arial';
        ctx.fillText(`MTCNN: ${(score * 100).toFixed(1)}%`, x, y - 5);
      }

      // Draw 5-point landmarks
      if (showLandmarks && landmarks?.length === 5) {
        const colors = ['#ff0000', '#ff0000', '#00ff00', '#0000ff', '#0000ff'];
        const names = ['L Eye', 'R Eye', 'Nose', 'L Mouth', 'R Mouth'];
        landmarks.forEach(([lx, ly], i) => {
          const cx = lx * scaleX;
          const cy = ly * scaleY;
          ctx.beginPath();
          ctx.arc(cx, cy, 5, 0, 2 * Math.PI);
          ctx.fillStyle = colors[i];
          ctx.fill();
          
          // Label
          ctx.fillStyle = '#ffffff';
          ctx.font = '10px Arial';
          ctx.fillText(names[i], cx + 8, cy + 3);
        });

        // Eye line
        const [lx1, ly1] = landmarks[0];
        const [lx2, ly2] = landmarks[1];
        ctx.beginPath();
        ctx.moveTo(lx1 * scaleX, ly1 * scaleY);
        ctx.lineTo(lx2 * scaleX, ly2 * scaleY);
        ctx.strokeStyle = '#ffff00';
        ctx.lineWidth = 2;
        ctx.stroke();
      }

      // Draw full 68-point landmarks
      if (showLandmarks68 && landmarks68?.length === 68) {
        ctx.fillStyle = '#00ffff';
        landmarks68.forEach(([lx, ly]) => {
          const cx = lx * scaleX;
          const cy = ly * scaleY;
          ctx.beginPath();
          ctx.arc(cx, cy, 2, 0, 2 * Math.PI);
          ctx.fill();
        });

        // Connect jaw outline (points 0-16)
        ctx.beginPath();
        ctx.strokeStyle = '#00ffff';
        ctx.lineWidth = 1;
        for (let i = 0; i <= 16; i++) {
          const [lx, ly] = landmarks68[i];
          if (i === 0) ctx.moveTo(lx * scaleX, ly * scaleY);
          else ctx.lineTo(lx * scaleX, ly * scaleY);
        }
        ctx.stroke();

        // Connect eyebrows (17-21, 22-26)
        ctx.beginPath();
        for (let i = 17; i <= 21; i++) {
          const [lx, ly] = landmarks68[i];
          if (i === 17) ctx.moveTo(lx * scaleX, ly * scaleY);
          else ctx.lineTo(lx * scaleX, ly * scaleY);
        }
        ctx.stroke();

        ctx.beginPath();
        for (let i = 22; i <= 26; i++) {
          const [lx, ly] = landmarks68[i];
          if (i === 22) ctx.moveTo(lx * scaleX, ly * scaleY);
          else ctx.lineTo(lx * scaleX, ly * scaleY);
        }
        ctx.stroke();

        // Connect nose bridge (27-30)
        ctx.beginPath();
        for (let i = 27; i <= 30; i++) {
          const [lx, ly] = landmarks68[i];
          if (i === 27) ctx.moveTo(lx * scaleX, ly * scaleY);
          else ctx.lineTo(lx * scaleX, ly * scaleY);
        }
        ctx.stroke();

        // Connect nose bottom (31-35)
        ctx.beginPath();
        for (let i = 31; i <= 35; i++) {
          const [lx, ly] = landmarks68[i];
          if (i === 31) ctx.moveTo(lx * scaleX, ly * scaleY);
          else ctx.lineTo(lx * scaleX, ly * scaleY);
        }
        ctx.stroke();

        // Connect left eye (36-41)
        ctx.beginPath();
        for (let i = 36; i <= 41; i++) {
          const [lx, ly] = landmarks68[i];
          if (i === 36) ctx.moveTo(lx * scaleX, ly * scaleY);
          else ctx.lineTo(lx * scaleX, ly * scaleY);
        }
        ctx.closePath();
        ctx.stroke();

        // Connect right eye (42-47)
        ctx.beginPath();
        for (let i = 42; i <= 47; i++) {
          const [lx, ly] = landmarks68[i];
          if (i === 42) ctx.moveTo(lx * scaleX, ly * scaleY);
          else ctx.lineTo(lx * scaleX, ly * scaleY);
        }
        ctx.closePath();
        ctx.stroke();

        // Connect outer lip (48-59)
        ctx.beginPath();
        for (let i = 48; i <= 59; i++) {
          const [lx, ly] = landmarks68[i];
          if (i === 48) ctx.moveTo(lx * scaleX, ly * scaleY);
          else ctx.lineTo(lx * scaleX, ly * scaleY);
        }
        ctx.closePath();
        ctx.stroke();

        // Connect inner lip (60-67)
        ctx.beginPath();
        for (let i = 60; i <= 67; i++) {
          const [lx, ly] = landmarks68[i];
          if (i === 60) ctx.moveTo(lx * scaleX, ly * scaleY);
          else ctx.lineTo(lx * scaleX, ly * scaleY);
        }
        ctx.closePath();
        ctx.stroke();
      }
    });
  }

  function singleDetection() {
    detectFaces();
  }
</script>

<svelte:head>
  <title>Face-API.js MTCNN Detection Test</title>
</svelte:head>

<div class="container">
  <h1>🔍 Face-API.js MTCNN Detection Test</h1>
  <p class="subtitle">Testing face detection with MTCNN model, bounding boxes, and 68-point landmarks</p>

  {#if errorMessage}
    <div class="error">{errorMessage}</div>
  {/if}

  <div class="video-container">
    <video bind:this={videoElement} autoplay playsinline muted></video>
    <canvas bind:this={canvasElement} width="640" height="480"></canvas>
  </div>

  <div class="controls">
    <button class="btn primary" on:click={startDetection} disabled={isRunning}>
      ▶️ Start Detection
    </button>
    <button class="btn secondary" on:click={stopDetection} disabled={!isRunning}>
      ⏹️ Stop
    </button>
    <button class="btn" on:click={singleDetection}>
      📸 Single Detection
    </button>
  </div>

  <div class="settings">
    <h3>Display Options</h3>
    <label>
      <input type="checkbox" bind:checked={showBox} /> Show Bounding Box
    </label>
    <label>
      <input type="checkbox" bind:checked={showLandmarks} /> Show 5-Point Landmarks
    </label>
    <label>
      <input type="checkbox" bind:checked={showLandmarks68} /> Show 68-Point Landmarks
    </label>
    <label>
      <input type="checkbox" bind:checked={showScore} /> Show Score
    </label>
    <label>
      Detection Interval: 
      <input type="range" min="100" max="1000" step="50" bind:value={detectionInterval} />
      {detectionInterval}ms
    </label>
  </div>

  <div class="stats">
    <h3>📊 Statistics</h3>
    <div class="stat-grid">
      <div class="stat">
        <span class="label">Faces Detected:</span>
        <span class="value">{faceCount}</span>
      </div>
      <div class="stat">
        <span class="label">Inference Time:</span>
        <span class="value">{inferenceTime}ms</span>
      </div>
      <div class="stat">
        <span class="label">FPS:</span>
        <span class="value">~{fps}</span>
      </div>
      <div class="stat">
        <span class="label">Status:</span>
        <span class="value {isRunning ? 'running' : ''}">{isRunning ? '🟢 Running' : '⚪ Stopped'}</span>
      </div>
    </div>
  </div>

  {#if lastDetections.length > 0}
    <div class="detections-info">
      <h3>🎯 Detection Details (MTCNN)</h3>
      {#each lastDetections as det, i}
        <div class="detection-card">
          <h4>Face #{i + 1}</h4>
          <p><strong>Score:</strong> {(det.score * 100).toFixed(2)}%</p>
          <p><strong>Box:</strong> x1={det.box[0].toFixed(0)}, y1={det.box[1].toFixed(0)}, x2={det.box[2].toFixed(0)}, y2={det.box[3].toFixed(0)}</p>
          {#if det.landmarks && det.landmarks.length === 5}
            <p><strong>5-Point Landmarks:</strong></p>
            <ul class="landmarks-list">
              <li>👁️ Left Eye: ({det.landmarks[0][0].toFixed(0)}, {det.landmarks[0][1].toFixed(0)})</li>
              <li>👁️ Right Eye: ({det.landmarks[1][0].toFixed(0)}, {det.landmarks[1][1].toFixed(0)})</li>
              <li>👃 Nose: ({det.landmarks[2][0].toFixed(0)}, {det.landmarks[2][1].toFixed(0)})</li>
              <li>👄 Left Mouth: ({det.landmarks[3][0].toFixed(0)}, {det.landmarks[3][1].toFixed(0)})</li>
              <li>👄 Right Mouth: ({det.landmarks[4][0].toFixed(0)}, {det.landmarks[4][1].toFixed(0)})</li>
            </ul>
          {/if}
          {#if det.landmarks68}
            <p><strong>68-Point Landmarks:</strong> ✓ Available</p>
          {/if}
        </div>
      {/each}
    </div>
  {/if}

  <div class="diagram">
    <h3>📐 Face-API.js MTCNN Pipeline</h3>
    <pre>
┌─────────────────┐
│  Webcam Frame   │
│   (640x480)     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│    face-api.js  │
│     (MTCNN)     │
│                 │
│ Multi-task CNN  │
│ 3-stage cascade │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│    Outputs:     │
│ • Bounding Box  │
│ • 68 Landmarks  │
│ • Confidence    │
└─────────────────┘
    </pre>
  </div>

  <div class="model-info">
    <h3>📦 Model Information</h3>
    <table>
      <tr><td><strong>Model:</strong></td><td>MTCNN (Multi-task Cascaded CNN)</td></tr>
      <tr><td><strong>Library:</strong></td><td>face-api.js v0.22.2</td></tr>
      <tr><td><strong>Landmarks:</strong></td><td>68-point facial landmarks</td></tr>
      <tr><td><strong>Min Face Size:</strong></td><td>100px</td></tr>
      <tr><td><strong>Scale Factor:</strong></td><td>0.709</td></tr>
    </table>
  </div>
</div>

<style>
  .container {
    max-width: 900px;
    margin: 0 auto;
    padding: 20px;
    font-family: system-ui, -apple-system, sans-serif;
  }

  h1 {
    color: #7c3aed;
    margin-bottom: 5px;
  }

  .subtitle {
    color: #6b7280;
    margin-bottom: 20px;
  }

  .error {
    background: #fee2e2;
    color: #dc2626;
    padding: 10px 15px;
    border-radius: 8px;
    margin-bottom: 15px;
  }

  .video-container {
    position: relative;
    width: 640px;
    height: 480px;
    background: #1f2937;
    border-radius: 12px;
    overflow: hidden;
    margin-bottom: 20px;
  }

  video {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    object-fit: cover;
    transform: scaleX(-1);
  }

  canvas {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    transform: scaleX(-1);
    pointer-events: none;
  }

  .controls {
    display: flex;
    gap: 10px;
    margin-bottom: 20px;
  }

  .btn {
    padding: 10px 20px;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    font-size: 14px;
    font-weight: 500;
    transition: all 0.2s;
  }

  .btn.primary {
    background: #7c3aed;
    color: white;
  }

  .btn.primary:hover:not(:disabled) {
    background: #6d28d9;
  }

  .btn.secondary {
    background: #dc2626;
    color: white;
  }

  .btn.secondary:hover:not(:disabled) {
    background: #b91c1c;
  }

  .btn:not(.primary):not(.secondary) {
    background: #e5e7eb;
    color: #374151;
  }

  .btn:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }

  .settings {
    background: #f3f4f6;
    padding: 15px 20px;
    border-radius: 12px;
    margin-bottom: 20px;
  }

  .settings h3 {
    margin-top: 0;
    margin-bottom: 10px;
    font-size: 14px;
    color: #374151;
  }

  .settings label {
    display: block;
    margin: 8px 0;
    color: #4b5563;
    font-size: 14px;
  }

  .settings input[type="checkbox"] {
    margin-right: 8px;
  }

  .settings input[type="range"] {
    margin: 0 10px;
    vertical-align: middle;
  }

  .stats {
    background: #f9fafb;
    padding: 15px 20px;
    border-radius: 12px;
    margin-bottom: 20px;
    border: 1px solid #e5e7eb;
  }

  .stats h3 {
    margin-top: 0;
    margin-bottom: 15px;
  }

  .stat-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
    gap: 15px;
  }

  .stat {
    background: white;
    padding: 12px;
    border-radius: 8px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
  }

  .stat .label {
    display: block;
    font-size: 12px;
    color: #6b7280;
    margin-bottom: 4px;
  }

  .stat .value {
    font-size: 18px;
    font-weight: 600;
    color: #1f2937;
  }

  .stat .value.running {
    color: #7c3aed;
  }

  .detections-info {
    background: #ede9fe;
    padding: 15px 20px;
    border-radius: 12px;
    margin-bottom: 20px;
    border: 1px solid #c4b5fd;
  }

  .detections-info h3 {
    margin-top: 0;
    color: #5b21b6;
  }

  .detection-card {
    background: white;
    padding: 15px;
    border-radius: 8px;
    margin-bottom: 10px;
    box-shadow: 0 1px 2px rgba(0,0,0,0.05);
  }

  .detection-card h4 {
    margin: 0 0 10px 0;
    color: #7c3aed;
  }

  .detection-card p {
    margin: 5px 0;
    font-size: 14px;
    color: #374151;
  }

  .landmarks-list {
    margin: 5px 0;
    padding-left: 20px;
    font-size: 13px;
    color: #4b5563;
  }

  .landmarks-list li {
    margin: 3px 0;
  }

  .diagram {
    background: #1f2937;
    padding: 20px;
    border-radius: 12px;
    color: #9ca3af;
    margin-bottom: 20px;
  }

  .diagram h3 {
    margin-top: 0;
    color: white;
  }

  .diagram pre {
    font-family: 'Consolas', 'Monaco', monospace;
    font-size: 13px;
    line-height: 1.4;
    color: #a78bfa;
    margin: 0;
    white-space: pre;
  }

  .model-info {
    background: #faf5ff;
    padding: 15px 20px;
    border-radius: 12px;
    border: 1px solid #e9d5ff;
  }

  .model-info h3 {
    margin-top: 0;
    color: #7c3aed;
  }

  .model-info table {
    width: 100%;
    border-collapse: collapse;
  }

  .model-info td {
    padding: 8px 0;
    border-bottom: 1px solid #e9d5ff;
  }

  .model-info td:first-child {
    width: 40%;
    color: #6b7280;
  }
</style>
