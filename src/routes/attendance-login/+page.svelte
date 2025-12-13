<script>
  import { onMount, onDestroy } from "svelte";
  import { loadModels, hasFacePresent, captureFrame } from '$lib/services/face.js';

  // 🎨 UI state for premium animations
  let isLoading = true;
  let loadingProgress = 0;
  let loadingText = 'Initializing...';
  let loadingFadeOut = false;
  let formVisible = false;
  let currentScreen = 'main'; // 'main', 'register', 'face', 'login', 'settings-auth', 'settings'

  // Original state variables
  let showForm = false;
  let showFacePage = false;
  let showLoginPage = false;
  let showSettingsAuth = false;
  let showSettingsPage = false;

  // 🎨 Animation state
  let scrollY = 0;
  let gradientOffset = 0;

  // QR scanner
  let scannerActive = false;
  let html5QrCode;

  // form fields
  let firstName = "";
  let middleInitial = "";
  let surname = "";
  let studentId = "";

  // saved temporarily (only sent after Save)
  let registrationData = {};

  // camera / capture
  let video;
  let canvas;
  let ctx;
  let stream;
  let cameras = [];
  let selectedCamera = "";
  let faceCamera = "";
  let faceStep = 1; // 1,2,3
  let capturedImages = { pic1: "", pic2: "", pic3: "" };

  let loginVideo;
  let loginCanvas;
  let loginCtx;
  let loginStream;
  let loginMessage = "";
  let loginMessageColor = "black";
  let detectionInterval;
  let loginImageUrl = "";
  
  // 🚀 TURBO: Message auto-clear timer (3 seconds)
  let messageClearTimer = null;
  const MESSAGE_DISPLAY_DURATION = 3000; // 3 seconds
  
  // 🚀 TURBO: Recognition cooldown to prevent duplicate triggers
  let recognitionCooldown = false;
  let lastRecognizedStudent = null;
  const RECOGNITION_COOLDOWN_MS = 4000; // 4 second cooldown after successful recognition
  
  // 🚀 FIX: Request tracking to prevent stale/cached responses
  let currentRequestId = 0; // Incremented for each request
  let cameraSessionActive = false; // Track if camera session is still active
  
  // 🔧 Camera state guard - prevent multiple simultaneous starts
  let isCameraActive = false;
  let isCameraStarting = false;

  // 🎯 Smart detection optimization variables
  let isDetectionPending = false;          // Prevent request queue buildup
  let consecutiveFailures = 0;              // Track failures for backoff
  let lastDetectionTime = 0;                // Throttle frames
  let lastSuccessTime = 0;                  // Track idle state
  let currentDetectionInterval = 500;       // 🚀 TURBO: Start at 500ms (like turnstyle)
  let consecutiveNoFace = 0;                // Track consecutive no-face detections
  let faceModelsLoaded = false;             // Track if WASM models are loaded
  
  // 🚀 TURBO Performance tuning constants (6x faster than before)
  const BASE_DETECTION_INTERVAL = 500;      // 500ms base interval (was 3000ms)
  const FAST_DETECTION_INTERVAL = 400;      // 400ms when face recently detected
  const SLOW_DETECTION_INTERVAL = 1500;     // 1.5s when idle (was 5000ms)
  const NO_FACE_THRESHOLD = 3;              // Switch to slow mode after 3 no-face detections
  const MIN_DETECTION_GAP = 350;            // Minimum 350ms between detections

  // Settings 🔧
  // for authentication
  let settingsUser = "";
  let settingsPass = "";
  let settingsError = "";
  // 🌐 Settings values
  let roomId = "";
  let SERVER_URL = "/attendance-login/api";
  let roomList = [];
  
  // 🔧 Unique device session ID - persisted in localStorage
  let deviceSessionId = "";
  
  // Generate unique device ID if not exists
  function getOrCreateDeviceId() {
    let storedId = localStorage.getItem("deviceSessionId");
    if (!storedId) {
      storedId = `device_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
      localStorage.setItem("deviceSessionId", storedId);
    }
    return storedId;
  }

  let eventSource;

  // 🎨 Loading animation sequence
  onMount(async () => {
    // 🔧 Initialize unique device session ID
    deviceSessionId = getOrCreateDeviceId();
    console.log(`🔧 Device Session ID: ${deviceSessionId}`);
    
    // Load settings from localStorage
    roomId = localStorage.getItem("roomId") || "";
    SERVER_URL = localStorage.getItem("SERVER_URL") || "/attendance-login/api";
    
    console.log(`🏠 Room ID: ${roomId} | Device: ${deviceSessionId}`);

    // Simulate loading sequence
    const loadingSteps = [
      { progress: 20, text: 'Loading settings...' },
      { progress: 40, text: 'Initializing camera...' },
      { progress: 60, text: 'Loading AI models...' },
      { progress: 80, text: 'Preparing interface...' },
      { progress: 100, text: 'Ready!' }
    ];

    for (const step of loadingSteps) {
      loadingProgress = step.progress;
      loadingText = step.text;
      await new Promise(resolve => setTimeout(resolve, 300));
    }

    // Fade out and show main screen
    loadingFadeOut = true;
    await new Promise(resolve => setTimeout(resolve, 800));
    isLoading = false;
    formVisible = true;
  });

  $: if (typeof window !== "undefined") {
    localStorage.setItem("roomId", roomId);
    localStorage.setItem("SERVER_URL", SERVER_URL);
  }

  // On mount: auto-select EMEET USB webcam
  onMount(async () => {
    // Check if mediaDevices is available
    if (!navigator.mediaDevices || !navigator.mediaDevices.enumerateDevices) {
      console.error("❌ navigator.mediaDevices not available. Make sure you're using HTTPS or localhost.");
      alert("Camera access requires HTTPS or localhost. Please check your connection.");
      return;
    }

    const devices = await navigator.mediaDevices.enumerateDevices();
    cameras = devices.filter(d => d.kind === "videoinput");

    // Find EMEET camera
    const emeetCam = cameras.find(cam =>
      (cam.label || "").toLowerCase().includes("emeet")
    );

    if (emeetCam) {
      selectedCamera = emeetCam.deviceId;
      faceCamera = emeetCam.deviceId;
      console.log("✅ EMEET camera selected:", emeetCam.label);
    } else {
      // fallback if EMEET not found
      selectedCamera = cameras[0]?.deviceId || "";
      faceCamera = selectedCamera;
      console.warn("⚠ EMEET camera not found, using default:", cameras[0]?.label);
    }

    // Fetch room list from API
    try {
      const res = await fetch("/attendance-login/api/rooms");
      const data = await res.json();
      if (data.rooms) {
        roomList = data.rooms;
        // If roomId is not set, default to first room
        if (!roomId && roomList.length > 0) {
          roomId = roomList[0].RoomID;
          localStorage.setItem("roomId", roomId);
        }
      }
    } catch (e) {
      console.error("Failed to fetch rooms", e);
    }
    
    // 🔧 Ensure deviceSessionId is set before SSE
    if (!deviceSessionId) {
      deviceSessionId = getOrCreateDeviceId();
    }

    eventSource = new EventSource("/api/stream");
    eventSource.onmessage = (event) => {
      console.log("📡 SSE message received:", event.data);
      try {
        const data = JSON.parse(event.data);
        
        // 🔧 IMPROVED: Use both roomId AND deviceSessionId for filtering
        const myRoomDevice = `room${roomId}`;
        const mySessionDevice = deviceSessionId;
        
        // Only react if message is for this device's room, session, or "all"
        if (data.device) {
          const targetDevice = data.device;
          const isForMe = targetDevice === 'all' || 
                          targetDevice === myRoomDevice || 
                          targetDevice === mySessionDevice ||
                          targetDevice === `device${roomId}`; // Legacy support
          
          if (!isForMe) {
            console.log(`📡 Ignoring SSE for ${targetDevice} (I am room:${roomId}, session:${deviceSessionId})`);
            return;
          }
        }

        if (data.status === "camera_started") {
          console.log(`🎥 Camera started for room ${roomId}!`);
          startLoginCamera();
        }

        if (data.status === "camera_stopped") {
          console.log(`🛑 Camera stopped for room ${roomId}!`);
          stopLoginCamera();
        }
      } catch (err) {
        console.warn("⚠️ Invalid SSE message:", event.data);
      }
    };
    eventSource.onerror = (err) => {
      console.error("⚠️ SSE connection error:", err);
    };
  });

  // Cleanup function
  onDestroy(() => {
    if (typeof window === 'undefined') return;
    if (eventSource) eventSource.close();
    // 🔧 Clean up camera on component destroy
    stopLoginCamera();
    window.removeEventListener('scroll', () => {});
  });

  // Save settings to localStorage when they change
  $: if (typeof window !== 'undefined' && roomId) {
    localStorage.setItem("roomId", roomId);
  }
  $: if (typeof window !== 'undefined' && SERVER_URL) {
    localStorage.setItem("SERVER_URL", SERVER_URL);
  }

  // 🎨 Screen transition functions
  function navigateTo(screen) {
    currentScreen = screen;
    formVisible = false;
    
    // Handle login screen - start camera
    if (screen === 'login') {
      showLoginPage = true;
      setTimeout(() => startLoginCamera(), 300);
    } else {
      showLoginPage = false;
    }
    
    // Handle settings auth screen
    if (screen === 'settings-auth') {
      showSettingsAuth = true;
    }
    
    // Handle settings screen
    if (screen === 'settings') {
      showSettingsPage = true;
      showSettingsAuth = false;
    }
    
    setTimeout(() => formVisible = true, 100);
  }

  function goBack() {
    // Clean up based on current screen
    if (currentScreen === 'login') {
      stopLoginCamera();
      showLoginPage = false;
    }
    if (currentScreen === 'settings-auth') {
      showSettingsAuth = false;
      settingsUser = "";
      settingsPass = "";
      settingsError = "";
    }
    if (currentScreen === 'settings') {
      showSettingsPage = false;
    }
    
    currentScreen = 'main';
    formVisible = false;
    setTimeout(() => formVisible = true, 100);
  }

  // -------------------------
  // -------------------------
  // QR scanner (html5-qrcode) - dynamic import so SSR doesn't break
  // -------------------------
  async function startScanner() {
    if (scannerActive) return;
    scannerActive = true;

    try {
      const { Html5Qrcode } = await import("html5-qrcode");
      html5QrCode = new Html5Qrcode("qr-reader");

      let cameraConfig;

      // FIX: If selectedCamera is undefined → fallback to automatic back camera
      if (selectedCamera) {
        cameraConfig = { deviceId: { exact: selectedCamera } };
      } else {
        cameraConfig = { facingMode: "environment" };
      }

      await html5QrCode.start(
        cameraConfig,
        {
          fps: 5,  // Slower for better detection
          qrbox: 350,  // Larger scan area
          // aspectRatio: 1.3333  // Remove fixed aspect ratio for better compatibility
        },
        (decodedText) => {
          console.log("QR scanned:", decodedText);

          try {
            fillFormFromQR(decodedText);
          } catch (err) {
            console.warn("QR parse problem:", err);
            alert("Scanned: " + decodedText);
          }

          stopScanner();
        },
        (errorMessage) => {
          // Only log occasional errors to avoid spam
          if (Math.random() < 0.01) {  // Log ~1% of errors
            console.warn("QR scanning error:", errorMessage);
          }
        }
      );

    } catch (err) {
      console.error("Could not start QR scanner:", err);
      alert("Could not start QR scanner: " + (err.message || err));
      scannerActive = false;
    }
  }



  async function stopScanner() {
    if (html5QrCode) {
      try {
        await html5QrCode.stop();
        html5QrCode.clear();
      } catch (err) {
        console.warn("Error stopping QR scanner:", err);
      }
    }
    scannerActive = false;
  }

  function fillFormFromQR(data) {
    // Example of the ID QR you showed:
    // "GERJEN MAE L. ESPINOSA 2022304979 BSET TN"
    // We'll be flexible: assume last tokens are numeric id, course, section,
    // take first 3 or 4 tokens for name pieces.
    const parts = data.trim().split(/\s+/);
    if (parts.length < 4) throw new Error("Invalid QR format");

    // find student number (student ID)
    const numericIndex = parts.findIndex(p => /^\d{4,}$/.test(p));
    if (numericIndex === -1) throw new Error("Student ID not found");

    const nameParts = parts.slice(0, numericIndex);
    const studentIdToken = parts[numericIndex]; // ← Student ID

    // Assign names
    if (nameParts.length >= 3) {
      firstName = nameParts.slice(0, -2).join(" ");
      middleInitial = nameParts[nameParts.length - 2].replace(".", "");
      surname = nameParts[nameParts.length - 1];
    } else if (nameParts.length === 2) {
      firstName = nameParts[0];
      middleInitial = "";
      surname = nameParts[1];
    } else {
      firstName = nameParts[0];
      middleInitial = "";
      surname = "";
    }

    // Student ID
    studentId = studentIdToken;

    console.log("Filled from QR:", { firstName, middleInitial, surname, studentId });
  }

  async function submitForm() {
    // Save form data locally, but don't call backend yet
    registrationData = {
      firstName,
      middleInitial,
      surname,
      studentId
    };

    // Move to face capture page
    currentScreen = 'face';
    showForm = false;
    showFacePage = true;

    // Reset canvas/context
    ctx = null;
    if (canvas) {
      canvas.width = 0;
      canvas.height = 0;
    }

    // Start camera and automatic capture
    setTimeout(() => startScan(), 300);
  }


  function resetForm() {
    firstName = "";
    middleInitial = "";
    surname = "";
    studentId = "";
    registrationData = {};
    capturedImages = { pic1: "", pic2: "", pic3: "" };
    faceStep = 1;
    showForm = false;
    showFacePage = false;
  }

  // Take snapshot from video - crops center to 640x480 without stretching
  function takeSnapshot() {
    const ctx = canvas.getContext("2d");

    // Output size (4:3)
    const TARGET_WIDTH = 640;
    const TARGET_HEIGHT = 480;
    
    canvas.width = TARGET_WIDTH;
    canvas.height = TARGET_HEIGHT;

    // Get video's native dimensions
    const videoWidth = video.videoWidth;
    const videoHeight = video.videoHeight;
    
    // Calculate crop region from center (no stretch, just crop/zoom)
    const targetAspect = TARGET_WIDTH / TARGET_HEIGHT; // 4:3 = 1.333
    const videoAspect = videoWidth / videoHeight;
    
    let srcX, srcY, srcWidth, srcHeight;
    
    if (videoAspect > targetAspect) {
      // Video is wider than target - crop left/right
      srcHeight = videoHeight;
      srcWidth = videoHeight * targetAspect;
      srcX = (videoWidth - srcWidth) / 2;
      srcY = 0;
    } else {
      // Video is taller than target - crop top/bottom
      srcWidth = videoWidth;
      srcHeight = videoWidth / targetAspect;
      srcX = 0;
      srcY = (videoHeight - srcHeight) / 2;
    }

    // Draw cropped center region - no stretching
    ctx.drawImage(video, srcX, srcY, srcWidth, srcHeight, 0, 0, TARGET_WIDTH, TARGET_HEIGHT);

    return canvas.toDataURL("image/jpeg", 0.9);
  }

  // 🎯 OPTIMIZED: Convert canvas to compressed JPEG for login - 320x240 for faster transfer
  function takeLoginSnapshot() {
    // 🚀 OPTIMIZATION: Reduced from 640x480 to 320x240 (75% less data)
    const TARGET_WIDTH = 320;
    const TARGET_HEIGHT = 240;
    
    loginCanvas.width = TARGET_WIDTH;
    loginCanvas.height = TARGET_HEIGHT;

    // Get video's native dimensions
    const videoWidth = loginVideo.videoWidth;
    const videoHeight = loginVideo.videoHeight;
    
    // Calculate crop region from center (no stretch, just crop/zoom)
    const targetAspect = TARGET_WIDTH / TARGET_HEIGHT; // 4:3 = 1.333
    const videoAspect = videoWidth / videoHeight;
    
    let srcX, srcY, srcWidth, srcHeight;
    
    if (videoAspect > targetAspect) {
      // Video is wider than target - crop left/right
      srcHeight = videoHeight;
      srcWidth = videoHeight * targetAspect;
      srcX = (videoWidth - srcWidth) / 2;
      srcY = 0;
    } else {
      // Video is taller than target - crop top/bottom
      srcWidth = videoWidth;
      srcHeight = videoWidth / targetAspect;
      srcX = 0;
      srcY = (videoHeight - srcHeight) / 2;
    }

    // Draw cropped center region - no stretching
    loginCtx.drawImage(loginVideo, srcX, srcY, srcWidth, srcHeight, 0, 0, TARGET_WIDTH, TARGET_HEIGHT);

    // 🚀 TURBO: Increased quality to 85% for better recognition (WASM handles larger images fast)
    return loginCanvas.toDataURL("image/jpeg", 0.85);
  }

  // 🎯 TURBO: Client-side face detection using new WASM-powered face service
  async function hasFaceDetected() {
    if (!faceModelsLoaded || !loginVideo || loginVideo.readyState !== 4) {
      return true; // If models not loaded, allow sending (fallback)
    }

    try {
      // 🚀 Use new face service with WASM backend (much faster)
      return await hasFacePresent(loginVideo);
    } catch (err) {
      console.warn("Face detection check error:", err);
      return true; // Fallback: allow sending if detection fails
    }
  }
  async function checkOrientation() {
    const frame = takeSnapshot();
  const res = await fetch(`${SERVER_URL}/check-face`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ image: frame })
    });
    return res.json(); // { orientation: "front" | "left" | "right" | "none" }
  }
  
  // -------------------------

  // Face camera functions
  // -------------------------
  let overlayCanvas;
  let overlayCtx;
  let faceDetectionInterval;
  let faceBox = null;
  let faceInstruction = '';

  async function startScan() {
    try {
      // Check if video element exists
      if (!video) {
        console.error("Video element not ready, retrying...");
        setTimeout(() => startScan(), 100);
        return;
      }
      
      // Check if mediaDevices is available
      if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
        throw new Error("Camera API not available. Please use HTTPS or localhost.");
      }

      console.log("Starting camera with selectedCamera:", selectedCamera);
      
      let retryCount = 0;
      let stream;
      
      // Try: Exact camera + exact resolution
      const attemptConfigurations = [
        {
          video: {
            deviceId: faceCamera ? { exact: faceCamera } : { exact: selectedCamera },
            width: { ideal: 1280 },
            height: { ideal: 720 }
          }
        },
        // Fallback: Exact camera, no resolution constraints
        {
          video: {
            deviceId: faceCamera ? { exact: faceCamera } : { exact: selectedCamera }
          }
        },
        // Fallback: Preferred camera (not exact), with resolution
        {
          video: {
            deviceId: faceCamera ? { ideal: faceCamera } : { ideal: selectedCamera },
            width: { ideal: 1280 },
            height: { ideal: 720 }
          }
        },
        // Fallback: Any camera with resolution
        {
          video: {
            width: { ideal: 1280 },
            height: { ideal: 720 }
          }
        },
        // Last resort: Any camera, any resolution
        {
          video: true
        }
      ];
      
      for (let config of attemptConfigurations) {
        try {
          console.log(`📹 Attempting camera config (attempt ${retryCount + 1}):`, config);
          stream = await navigator.mediaDevices.getUserMedia(config);
          console.log("✅ Camera started successfully with config:", config);
          break;
        } catch (err) {
          retryCount++;
          console.warn(`⚠️ Config attempt ${retryCount} failed:`, err.name);
          if (retryCount === attemptConfigurations.length) {
            throw err; // All attempts failed
          }
        }
      }
      
      if (!stream) {
        throw new Error("Failed to get camera stream");
      }
      
      video.srcObject = stream;
      await video.play();
      console.log("Camera started");
      // ensure ctx
      if (!ctx && canvas) ctx = canvas.getContext("2d");

      // Setup overlay canvas
      if (!overlayCanvas) {
        overlayCanvas = document.createElement('canvas');
        overlayCanvas.style.position = 'absolute';
        overlayCanvas.style.left = video.offsetLeft + 'px';
        overlayCanvas.style.top = video.offsetTop + 'px';
        overlayCanvas.width = video.videoWidth;
        overlayCanvas.height = video.videoHeight;
        overlayCanvas.style.pointerEvents = 'none';
        overlayCanvas.style.zIndex = "10";
        video.parentNode.insertBefore(overlayCanvas, video.nextSibling);
      }
      overlayCtx = overlayCanvas.getContext('2d');

      // Load face-api.js models (from /models)
      await loadFaceApiModels();

      // Start face detection overlay
      faceDetectionInterval = setInterval(drawFaceBox, 200);

      autoCaptureSequence();
    } catch (err) {
      console.error("Camera start error:", err);
      alert("Unable to access camera: " + (err.message || err));
    }
  }

  async function loadFaceApiModels() {
    // 🚀 TURBO: Use new WASM-powered face service for registration overlay
    // This loads @vladmandic/face-api with WASM backend
    try {
      await loadModels((progress) => {
        console.log(`📦 Face models loading: ${progress.toFixed(0)}%`);
      });
      faceModelsLoaded = true;
      console.log('✅ WASM face models loaded for registration');
      
      // Also set window.faceapi for drawFaceBox compatibility
      // @ts-ignore
      window.faceapi = await import('@vladmandic/face-api');
    } catch (err) {
      console.warn('⚠️ Failed to load WASM models, falling back to standard:', err);
      // Fallback to old face-api.js if WASM fails
      // @ts-ignore
      if (!window.faceapi) {
        // @ts-ignore
        window.faceapi = await import('face-api.js');
      }
      const modelUrl = '/models';
      await Promise.all([
        // @ts-ignore
        window.faceapi.nets.tinyFaceDetector.loadFromUri(modelUrl),
        // @ts-ignore
        window.faceapi.nets.faceLandmark68Net.loadFromUri(modelUrl)
      ]);
    }
  }

  async function drawFaceBox() {
    if (!video || video.readyState !== 4) return;
    
    // Size overlay to match video element's display size (1024x600)
    overlayCanvas.width = video.clientWidth;
    overlayCanvas.height = video.clientHeight;
    overlayCtx.clearRect(0, 0, overlayCanvas.width, overlayCanvas.height);

    // Calculate scale factors to align detection coordinates with display
    const scaleX = overlayCanvas.width / video.videoWidth;
    const scaleY = overlayCanvas.height / video.videoHeight;

    // Detect face
    // @ts-ignore
    const detection = await window.faceapi.detectSingleFace(video, new window.faceapi.TinyFaceDetectorOptions()).withFaceLandmarks();
    if (detection) {
      const box = detection.detection.box;
      
      // Scale coordinates to match display size
      const scaledX = box.x * scaleX;
      const scaledY = box.y * scaleY;
      const scaledWidth = box.width * scaleX;
      const scaledHeight = box.height * scaleY;
      
      faceBox = { x: scaledX, y: scaledY, width: scaledWidth, height: scaledHeight };
      
      // Draw rectangle around detected face
      overlayCtx.strokeStyle = '#00FF00';
      overlayCtx.lineWidth = 3;
      overlayCtx.strokeRect(scaledX, scaledY, scaledWidth, scaledHeight);
      
      // Draw instruction text above the face box
      overlayCtx.font = '24px Arial';
      overlayCtx.fillStyle = '#00FF00';
      faceInstruction = getFaceInstruction(faceStep);
      overlayCtx.fillText(faceInstruction, scaledX, scaledY - 10);
    } else {
      faceBox = null;
      faceInstruction = getFaceInstruction(faceStep);
      
      // Draw "no face detected" message in center
      overlayCtx.font = '24px Arial';
      overlayCtx.fillStyle = '#FF0000';
      const centerX = overlayCanvas.width / 2 - 100;
      const centerY = overlayCanvas.height / 2;
      overlayCtx.fillText('No face detected', centerX, centerY);
      overlayCtx.fillText(faceInstruction, centerX, centerY + 30);
    }
  }

  function getFaceInstruction(step) {
    if (step === 1) return 'Look straight ahead';
    if (step === 2) return 'Turn your face RIGHT';
    if (step === 3) return 'Turn your face LEFT';
    return '';
  }

  function cleanupOverlay() {
    if (faceDetectionInterval) clearInterval(faceDetectionInterval);
    if (overlayCanvas && overlayCanvas.parentNode) overlayCanvas.parentNode.removeChild(overlayCanvas);
    overlayCanvas = null;
    overlayCtx = null;
  }

  async function autoCaptureSequence() {
    const instructions = {
      1: "Look straight ahead",
      2: "Turn your face slightly to the RIGHT", 
      3: "Turn your face slightly to the LEFT"
    };

    const MAX_ATTEMPTS = 30; // Max attempts per step (about 6 seconds at 200ms intervals)
    const CHECK_INTERVAL = 200; // Check every 200ms for responsive capture

    for (let step = 1; step <= 3; step++) {
      faceStep = step;
      let captured = false;
      let attempts = 0;

      console.log(`🟢 Step ${step}: ${instructions[step]}`);

      while (!captured && attempts < MAX_ATTEMPTS) {
        attempts++;
        
        // Capture frame FIRST (real-time)
        const frame = takeSnapshot();
        
        // Immediately verify face is detected
        try {
          const res = await fetch(`${SERVER_URL}/check-face`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ image: frame })
          });
          const { orientation } = await res.json();
          
          if (orientation !== 'none') {
            // Face detected! Save THIS EXACT frame (no delay)
            capturedImages[`pic${step}`] = frame;
            console.log(`✅ Step ${step}: Face detected (${orientation}), captured immediately!`);
            captured = true;
            
            // Show success feedback briefly
            await new Promise(res => setTimeout(res, 500));
          } else {
            // No face detected, wait briefly and try again
            await new Promise(res => setTimeout(res, CHECK_INTERVAL));
          }
        } catch (err) {
          console.error("Check-face error:", err);
          await new Promise(res => setTimeout(res, CHECK_INTERVAL));
        }
      }

      if (!captured) {
        // Max attempts reached, capture current frame anyway
        const frame = takeSnapshot();
        capturedImages[`pic${step}`] = frame;
        console.log(`⚠️ Step ${step}: Timeout, capturing current frame`);
      }

      // Brief pause before next step instruction
      if (step < 3) {
        await new Promise(res => setTimeout(res, 800));
      }
    }

    faceStep = 4; // Mark as complete
    console.log("📸 All 3 images captured with real-time face verification");
    
    // After all 3 captured → register
    await saveData();
  }

  async function saveData() {
    if (!capturedImages.pic1 || !capturedImages.pic2 || !capturedImages.pic3) {
      alert("Please capture all 3 pictures.");
      return;
    }

    const payload = {...registrationData,images: capturedImages };

    console.log("Sending payload to server:", {
      ...registrationData,
      pic1Len: capturedImages.pic1.length,
      pic2Len: capturedImages.pic2.length,
      pic3Len: capturedImages.pic3.length
    });

    try {
  const res = await fetch(`${SERVER_URL}/register`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload)
      });

      console.log("Server response status:", res.status);

      const raw = await res.text(); // read full text (debugging)
      console.log("Server raw response:", raw);

      let result;
      try {
        result = JSON.parse(raw);
      } catch {
        result = {};
      }
      alert(result.message || "Saved successfully!");

      stopCamera();
      resetForm();
    } catch (err) {
      console.error("SaveData error:", err);
      alert("Failed to save: " + (err.message || err));
    }
  }
  function stopCamera() {
    if (stream) {
      stream.getTracks().forEach(t => t.stop());
      stream = null;
    }
    if (video) {
      video.srcObject = null;
    }
    cleanupOverlay();
  }
  
  async function startLoginCamera() {
    // 🔧 GUARD: Prevent multiple simultaneous camera starts
    if (isCameraActive || isCameraStarting) {
      console.log(`⚠️ Camera already ${isCameraActive ? 'active' : 'starting'}, ignoring duplicate start request`);
      return;
    }
    
    isCameraStarting = true;
    console.log(`📹 Starting login camera for Room: ${roomId}, Device: ${deviceSessionId}`);
    
    try {
      // Check if mediaDevices is available
      if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
        throw new Error("Camera API not available. Please use HTTPS or localhost.");
      }

      // Dynamically find EMEET camera id
      const devices = await navigator.mediaDevices.enumerateDevices();
      const emeetCam = devices.find(
        d => d.kind === "videoinput" && (d.label || "").toLowerCase().includes("emeet")
      );

      // 🎯 FIX: Progressive fallback strategy to avoid OverconstrainedError
      const attemptConfigurations = emeetCam
        ? [
            // Try: Exact EMEET camera with high resolution
            { video: { deviceId: { exact: emeetCam.deviceId }, width: { ideal: 1280 }, height: { ideal: 720 } } },
            // Fallback: Exact EMEET camera, no resolution constraints
            { video: { deviceId: { exact: emeetCam.deviceId } } },
            // Fallback: Prefer EMEET camera but not strict, high res
            { video: { deviceId: { ideal: emeetCam.deviceId }, width: { ideal: 1280 }, height: { ideal: 720 } } },
            // Fallback: Any camera with high resolution
            { video: { width: { ideal: 1280 }, height: { ideal: 720 } } },
            // Last resort: Any camera
            { video: true }
          ]
        : [
            // No EMEET found, try any camera with high resolution
            { video: { width: { ideal: 1280 }, height: { ideal: 720 } } },
            // Last resort: Any camera
            { video: true }
          ];

      let newLoginStream;
      let attemptNum = 0;
      
      for (let config of attemptConfigurations) {
        try {
          console.log(`📹 Login camera attempt ${attemptNum + 1}:`, config);
          newLoginStream = await navigator.mediaDevices.getUserMedia(config);
          console.log("✅ Login camera started with config:", config);
          break;
        } catch (err) {
          attemptNum++;
          console.warn(`⚠️ Login camera attempt ${attemptNum} failed:`, err.name);
          if (attemptNum === attemptConfigurations.length) {
            throw err; // All attempts failed
          }
        }
      }

      if (!newLoginStream) {
        throw new Error("Failed to get login camera stream");
      }

      // ✅ Assign to outer scope loginStream so stopLoginCamera() works
      loginStream = newLoginStream;
      loginVideo.srcObject = loginStream;

      // Play may fail due to autoplay policy — catch but don’t treat as camera error
      loginVideo.play().catch(err => {
        console.warn("⚠ Video autoplay blocked, user interaction needed:", err);
      });

      loginCtx = loginCanvas.getContext("2d");

      // 🚀 TURBO: Preload WASM face models for fast client-side detection
      if (!faceModelsLoaded) {
        console.log('🚀 Loading WASM face models...');
        try {
          await loadModels((progress) => {
            console.log(`📦 Face models: ${progress.toFixed(0)}%`);
          });
          faceModelsLoaded = true;
          console.log('✅ WASM face models ready - detection will be 2-3x faster');
        } catch (err) {
          console.warn('⚠️ WASM models failed, using fallback:', err);
        }
      }

      // Reset detection state
      isDetectionPending = false;
      consecutiveFailures = 0;
      consecutiveNoFace = 0;
      lastDetectionTime = 0;
      lastSuccessTime = Date.now();
      currentDetectionInterval = BASE_DETECTION_INTERVAL;

      if (detectionInterval) clearInterval(detectionInterval);
      // 🚀 TURBO: Start with 500ms interval (6x faster than before!)
      detectionInterval = setInterval(sendFrameForDetection, currentDetectionInterval);
      
      // 🔧 Mark camera as active
      isCameraActive = true;
      isCameraStarting = false;
      cameraSessionActive = true; // 🚀 FIX: Mark session as active for request tracking
      console.log(`✅ Camera active for Room: ${roomId}, TURBO interval: ${currentDetectionInterval}ms`);

    } catch (err) {
      console.error("Login camera error:", err);
      alert("❌ Could not start login camera at all");
      showLoginPage = false;
      isCameraStarting = false;
      isCameraActive = false;
    }
  }

  async function sendFrameForDetection() {
    // 🎯 GUARD 1: Prevent request queue buildup
    if (isDetectionPending) {
      console.log("⏳ Detection already pending, skipping frame...");
      return;
    }
    
    // 🚀 TURBO GUARD: Skip during cooldown period after successful recognition
    if (recognitionCooldown) {
      console.log(`⏳ Recognition cooldown active (last: ${lastRecognizedStudent}), skipping...`);
      return;
    }

    // 🎯 GUARD 2: Throttle frames - minimum gap between detections (TURBO mode)
    const now = Date.now();
    if (now - lastDetectionTime < MIN_DETECTION_GAP) {
      return;
    }

    // 🎯 GUARD 3: Idle timeout - if no success for 120 seconds, stop polling
    if (now - lastSuccessTime > 120000) {
      console.log("⏱️ Idle timeout reached (120s), stopping auto-detection");
      stopLoginCamera();
      loginMessage = "⏱️ Timeout: No face recognized in 2 minutes";
      loginMessageColor = "orange";
      return;
    }

    // 🎯 GUARD 4: Client-side face detection first (WASM-powered, very fast)
    const faceDetected = await hasFaceDetected();
    if (!faceDetected) {
      // 🚀 TURBO: Faster adaptive interval when no face detected
      consecutiveNoFace++;
      if (consecutiveNoFace >= NO_FACE_THRESHOLD) {
        // Switch to slow mode - no one is in front of camera
        currentDetectionInterval = SLOW_DETECTION_INTERVAL;
        if (detectionInterval) {
          clearInterval(detectionInterval);
          detectionInterval = setInterval(sendFrameForDetection, currentDetectionInterval);
        }
      }
      console.log(`👤 No face (WASM check) (${consecutiveNoFace}x), interval: ${currentDetectionInterval}ms`);
      return;
    }
    
    // Face detected - reset to TURBO fast mode
    if (consecutiveNoFace > 0) {
      consecutiveNoFace = 0;
      currentDetectionInterval = FAST_DETECTION_INTERVAL;
      if (detectionInterval) {
        clearInterval(detectionInterval);
        detectionInterval = setInterval(sendFrameForDetection, currentDetectionInterval);
      }
      console.log(`👤 Face detected (WASM)! TURBO mode: ${currentDetectionInterval}ms`);
    }

    if (!loginCtx || !loginVideo.videoWidth) return;

    // Mark as pending
    isDetectionPending = true;
    lastDetectionTime = now;

    // 🎯 IMPROVED: Use compressed JPEG instead of PNG
    const imageData = takeLoginSnapshot();
    
    // 🔧 DEBUG: Log the roomId being sent
    console.log(`🔍 Sending recognition request with roomId: ${roomId}, device: ${deviceSessionId}`);

    // 🚀 FIX: Track this request with a unique ID
    const thisRequestId = ++currentRequestId;
    
    try {
      const res = await fetch(`${SERVER_URL}/login-recognize`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ image: imageData, roomId, deviceSessionId, requestId: thisRequestId }),
        cache: "no-store" // 🚀 FIX: Prevent browser caching of recognition responses
      });

      // 🚀 FIX: Check if camera was stopped or newer request was sent while waiting
      if (!cameraSessionActive || thisRequestId !== currentRequestId) {
        console.log(`🚫 Ignoring stale response (request ${thisRequestId}, current ${currentRequestId}, active: ${cameraSessionActive})`);
        isDetectionPending = false;
        return;
      }

      const data = await res.json();

      // 🚀 GUARD: Ignore skipped responses (server already processing previous request)
      if (data.skipped) {
        console.log("⏳ Server skipped - already processing previous request");
        isDetectionPending = false;
        return;
      }

      // Successfully received response
      lastSuccessTime = Date.now();
      consecutiveFailures = 0;
      currentDetectionInterval = BASE_DETECTION_INTERVAL; // Reset to base interval

      // Directly set the recognition result
      loginMessage = data.message;
      loginMessageColor = data.message && data.message.includes("Welcome") ? "green" : "red";
      loginImageUrl = data.imageUrl || "";
      
      // 🚀 TURBO: Clear any existing timer and set new auto-clear timer
      if (messageClearTimer) clearTimeout(messageClearTimer);
      messageClearTimer = setTimeout(() => {
        loginMessage = "";
        loginImageUrl = "";
        messageClearTimer = null;
      }, MESSAGE_DISPLAY_DURATION);
      
      // 🚀 TURBO: Set cooldown after successful recognition to prevent rapid re-triggers
      if (data.message && data.message.includes("Welcome") && data.studentId) {
        recognitionCooldown = true;
        lastRecognizedStudent = data.studentId;
        setTimeout(() => {
          recognitionCooldown = false;
          lastRecognizedStudent = null;
        }, RECOGNITION_COOLDOWN_MS);
      }
      
      // Log timing if available
      if (data.timing) {
        console.log(`✅ Recognition response (${data.timing}ms server): ${data.message}`);
      } else {
        console.log("✅ Recognition response:", data.message);
      }

      // Keep camera running for continuous recognition
    } catch (err) {
      console.error("Recognition error:", err);
      
      // 🎯 IMPROVED: Exponential backoff on failures
      consecutiveFailures++;
      
      // Progressive delay: 2s → 4s → 8s → 16s (max)
      const maxInterval = 16000;
      currentDetectionInterval = Math.min(2000 * Math.pow(2, consecutiveFailures - 1), maxInterval);
      
      console.warn(`⚠️ Failure #${consecutiveFailures}, next interval: ${currentDetectionInterval}ms`);

      // Only show error after multiple failures
      if (consecutiveFailures > 3) {
        loginMessage = "❌ Server error. Retrying...";
        loginMessageColor = "red";
      }

      // Restart interval with new timing
      if (detectionInterval) clearInterval(detectionInterval);
      detectionInterval = setInterval(sendFrameForDetection, currentDetectionInterval);
      
      loginImageUrl = "";
    } finally {
      // Always mark as not pending when done
      isDetectionPending = false;
    }
  }
  function stopLoginCamera() {
    console.log(`🛑 Stopping camera for Room: ${roomId}`);
    
    // 🚀 FIX: Immediately mark session as inactive to reject pending responses
    cameraSessionActive = false;
    currentRequestId++; // Invalidate any pending requests
    
    if (detectionInterval) {
      clearInterval(detectionInterval);
      detectionInterval = null;
    }
    // 🚀 TURBO: Clear message timer on camera stop
    if (messageClearTimer) {
      clearTimeout(messageClearTimer);
      messageClearTimer = null;
    }
    if (loginStream) {
      loginStream.getTracks().forEach((t) => t.stop());
      loginStream = null;
    }
    if (loginVideo) loginVideo.srcObject = null;
    
    // 🔧 Reset camera state
    isCameraActive = false;
    isCameraStarting = false;
    
    // 🚀 TURBO: Reset recognition cooldown
    recognitionCooldown = false;
    lastRecognizedStudent = null;
    
    // 🚀 FIX: Clear the message box immediately when camera stops
    loginMessage = "";
    loginImageUrl = "";
    isDetectionPending = false;
  }

  function saveDeviceName() {
    localStorage.setItem("roomId", roomId);
    alert("✅ Room saved!");
  }
  function openSettingsAuth() {
    showSettingsAuth = true;
  }
  function checkSettingsLogin() {
    const validUser = "admin";
    const validPass = "1234";
    if (settingsUser === validUser && settingsPass === validPass) {
      navigateTo('settings');
      settingsError = "";
    } else {
      settingsError = "Invalid username or password";
    }
  }
  function closeSettings() {
    showSettingsPage = false;
  }

</script>

<div class="attendance-container">
  <!-- 🎨 Loading Screen -->
  {#if isLoading}
    <div class="loading-screen" class:fade-out={loadingFadeOut}>
      <!-- 🎨 Animated Background Gradient -->
      <div class="loading-bg" style="transform: translateY({gradientOffset}px)">
        <div class="gradient-orb orb-1"></div>
        <div class="gradient-orb orb-2"></div>
        <div class="gradient-orb orb-3"></div>
        <div class="gradient-orb orb-4"></div>
        <div class="gradient-orb orb-5"></div>
      </div>

      <!-- 🎨 Colorful Particles -->
      <div class="particles-container">
        {#each Array(25) as _, i}
          <div class="particle particle-{i % 5 + 1}" style="animation-delay: {i * 0.1}s; left: {Math.random() * 100}%; top: {Math.random() * 100}%"></div>
        {/each}
      </div>

      <!-- 🎨 Main Loading Content -->
      <div class="loading-content">
        <!-- 🎨 Animated Logo/Icon -->
        <div class="loading-logo">
          <div class="logo-icon">
            <svg class="face-icon" fill="none" stroke="url(#faceGradient)" viewBox="0 0 24 24">
              <defs>
                <linearGradient id="faceGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                  <stop offset="0%" stop-color="#3B82F6">
                    <animate attributeName="stop-color" values="#3B82F6;#A855F7;#22C55E;#F97316;#3B82F6" dur="3s" repeatCount="indefinite" />
                  </stop>
                  <stop offset="100%" stop-color="#A855F7">
                    <animate attributeName="stop-color" values="#A855F7;#22C55E;#F97316;#3B82F6;#A855F7" dur="3s" repeatCount="indefinite" />
                  </stop>
                </linearGradient>
              </defs>
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 2C13.1 2 14 2.9 14 4C14 5.1 13.1 6 12 6C10.9 6 10 5.1 10 4C10 2.9 10.9 2 12 2ZM21 9V7L15 1H5C3.89 1 3 1.89 3 3V21C3 22.11 3.89 23 5 23H19C20.11 23 21 22.11 21 21V9M19 9H14V4L19 9Z" />
            </svg>
            <div class="logo-pulse"></div>
          </div>
        </div>

        <!-- 🎨 Brand Text -->
        <div class="loading-brand">
          <h1 class="brand-main">Face Attendance</h1>
          <p class="brand-tagline">AI-Powered Recognition</p>
        </div>

        <!-- 🎨 Progress Section -->
        <div class="loading-progress">
          <div class="progress-bar">
            <div class="progress-fill" style="width: {loadingProgress}%"></div>
            <div class="progress-glow" style="width: {loadingProgress}%"></div>
            <div class="progress-shine"></div>
          </div>
          <div class="progress-text">{loadingText}</div>
          <div class="progress-percentage">{loadingProgress}%</div>
        </div>

        <!-- 🎨 Loading Dots Animation -->
        <div class="loading-dots">
          <div class="dot dot-1"></div>
          <div class="dot dot-2"></div>
          <div class="dot dot-3"></div>
        </div>
      </div>

      <!-- 🎨 Floating Geometric Shapes -->
      <div class="floating-shapes">
        <div class="shape shape-1"></div>
        <div class="shape shape-2"></div>
        <div class="shape shape-3"></div>
        <div class="shape shape-4"></div>
      </div>
    </div>
  {/if}

  <!-- 🎨 Main Application -->
  {#if !isLoading}
    <!-- 🎨 Animated Background -->
    <div class="animated-background" style="transform: translateY({gradientOffset}px)">
      <!-- 🎨 Gradient Orbs -->
      <div class="bg-orb orb-primary"></div>
      <div class="bg-orb orb-secondary"></div>
      <div class="bg-orb orb-accent"></div>
      <div class="bg-orb orb-purple"></div>

      <!-- 🎨 Floating Elements -->
      <div class="floating-elements">
        {#each Array(8) as _, i}
          <div class="floating-element element-{i % 4 + 1}" style="left: {15 + i * 10}%; animation-delay: {i * 0.5}s"></div>
        {/each}
      </div>
    </div>

    <!-- 🎨 Main Content Container -->
    <div class="content-wrapper">
      <!-- 🎨 Main Menu Screen -->
      {#if currentScreen === 'main'}
        <div class="screen-container" class:visible={formVisible}>
          <!-- 🎨 Brand Header -->
          <div class="brand-header">
            <div class="brand-icon">
              <svg class="school-icon" fill="none" stroke="url(#schoolGradient)" viewBox="0 0 24 24">
                <defs>
                  <linearGradient id="schoolGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%" stop-color="#3B82F6" />
                    <stop offset="50%" stop-color="#A855F7" />
                    <stop offset="100%" stop-color="#22C55E" />
                  </linearGradient>
                </defs>
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 14l9-5-9-5-9 5 9 5z M12 14l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14z" />
              </svg>
            </div>
            <h1 class="brand-title">School Attendance</h1>
            <p class="brand-subtitle">Smart face recognition system</p>
          </div>

          <!-- 🎨 Action Buttons -->
          <div class="action-buttons">
            <button class="action-btn login-btn" on:click={() => navigateTo('login')}>
              <div class="btn-icon">
                <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                </svg>
              </div>
              <div class="btn-content">
                <span class="btn-title">Face Login</span>
                <span class="btn-subtitle">AI-powered recognition</span>
              </div>
              <div class="btn-arrow">→</div>
            </button>

            <button class="action-btn register-btn" on:click={() => navigateTo('register')}>
              <div class="btn-icon">
                <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" />
                </svg>
              </div>
              <div class="btn-content">
                <span class="btn-title">Register Student</span>
                <span class="btn-subtitle">Create new profile</span>
              </div>
              <div class="btn-arrow">→</div>
            </button>
          </div>

          <!-- 🎨 Settings Button -->
          <button class="settings-fab" on:click={() => navigateTo('settings-auth')}>
            <svg class="settings-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
            </svg>
          </button>
        </div>
      {/if}

      <!-- 🎨 Registration Form -->
      {#if currentScreen === 'register'}
        <div class="form-container" class:visible={formVisible}>
          <!-- 🎨 Form Header -->
          <div class="form-header">
            <button class="back-button" on:click={goBack}>
              <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
              </svg>
            </button>
            <h2 class="form-title">Student Registration</h2>
            <p class="form-subtitle">Create your attendance profile</p>
          </div>

          <!-- 🎨 Glass Morphism Form -->
          <form class="glass-form" on:submit|preventDefault={submitForm}>
            <div class="form-grid">
              <!-- First Name -->
              <div class="input-group">
                <label class="input-label" for="firstName">First Name</label>
                <div class="input-wrapper">
                  <input
                    id="firstName"
                    type="text"
                    bind:value={firstName}
                    placeholder="Enter first name"
                    required
                    class="form-input"
                  />
                  <div class="input-glow"></div>
                </div>
              </div>

              <!-- Middle Initial -->
              <div class="input-group">
                <label class="input-label" for="middleInitial">Middle Initial</label>
                <div class="input-wrapper">
                  <input
                    id="middleInitial"
                    type="text"
                    bind:value={middleInitial}
                    placeholder="M.I."
                    maxlength="2"
                    class="form-input"
                  />
                  <div class="input-glow"></div>
                </div>
              </div>

              <!-- Surname -->
              <div class="input-group full-width">
                <label class="input-label" for="surname">Surname</label>
                <div class="input-wrapper">
                  <input
                    id="surname"
                    type="text"
                    bind:value={surname}
                    placeholder="Enter surname"
                    required
                    class="form-input"
                  />
                  <div class="input-glow"></div>
                </div>
              </div>

              <!-- Student ID -->
              <div class="input-group full-width">
                <label class="input-label" for="studentId">Student ID</label>
                <div class="input-wrapper">
                  <input
                    id="studentId"
                    type="text"
                    bind:value={studentId}
                    placeholder="Enter student ID"
                    required
                    class="form-input"
                  />
                  <div class="input-glow"></div>
                </div>
              </div>
            </div>

            <!-- 🎨 Action Buttons -->
            <div class="form-actions">
              <button type="submit" class="primary-btn">
                <span class="btn-text">Continue to Face Capture</span>
                <div class="btn-shine"></div>
              </button>

              <button type="button" class="secondary-btn" on:click={resetForm}>
                <span class="btn-text">Reset Form</span>
              </button>
            </div>

            <!-- 🎨 QR Scanner Section -->
            <div class="scanner-section">
              {#if !scannerActive}
                <button type="button" class="scanner-btn" on:click={startScanner}>
                  <svg class="scanner-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M12 12l3-3m-3 3l-3-3m-3 6h2.01M12 16v.01M12 12v4" />
                  </svg>
                  <span>Scan QR Code</span>
                </button>
              {:else}
                <button type="button" class="scanner-btn active" on:click={stopScanner}>
                  <span>Stop Scanner</span>
                </button>
              {/if}
            </div>

            <!-- 🎨 QR Reader -->
            <div id="qr-reader" class="qr-reader"></div>
          </form>
        </div>
      {/if}

      <!-- 🎨 Face Capture Screen -->
      {#if currentScreen === 'face'}
        <div class="face-container" class:visible={formVisible}>
          <div class="face-header">
            <button class="back-button" on:click={goBack}>
              <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
              </svg>
            </button>
            <h2 class="face-title">Face Capture</h2>
            <p class="face-subtitle">Step {faceStep} of 3</p>
          </div>

          <div class="face-content">
            <div class="camera-container">
              <video bind:this={video} autoplay muted playsinline class="face-video" width="1024" height="600"></video>
              <canvas bind:this={canvas} style="display:none"></canvas>

              <div class="face-instruction">
                <div class="instruction-icon">
                  {#if faceStep === 1}
                    <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z" />
                    </svg>
                  {:else if faceStep === 2}
                    <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16l-4-4m0 0l4-4m-4 4h18" />
                    </svg>
                  {:else if faceStep === 3}
                    <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 8l4 4m0 0l-4 4m4-4H3" />
                    </svg>
                  {/if}
                </div>
                <span class="instruction-text">
                  {#if faceStep === 1}
                    Look straight ahead
                  {:else if faceStep === 2}
                    Turn your face to the LEFT
                  {:else if faceStep === 3}
                    Turn your face to the RIGHT
                  {:else}
                    Processing complete!
                  {/if}
                </span>
              </div>
            </div>

            <div class="preview-container">
              {#if capturedImages.pic1}
                <div class="preview-item">
                  <img src={capturedImages.pic1} alt="Step 1" class="preview-image" />
                  <span class="preview-label">Front</span>
                </div>
              {/if}
              {#if capturedImages.pic2}
                <div class="preview-item">
                  <img src={capturedImages.pic2} alt="Step 2" class="preview-image" />
                  <span class="preview-label">Right</span>
                </div>
              {/if}
              {#if capturedImages.pic3}
                <div class="preview-item">
                  <img src={capturedImages.pic3} alt="Step 3" class="preview-image" />
                  <span class="preview-label">Left</span>
                </div>
              {/if}
            </div>

            {#if faceStep === 4}
              <div class="completion-message">
                <div class="completion-icon">✅</div>
                <h3>Face capture complete!</h3>
                <p>Your profile has been saved successfully.</p>
              </div>
            {/if}
          </div>
        </div>
      {/if}

  {#if showLoginPage}
    <div class="login-page">
      <!-- Full-screen video background -->
      <video bind:this={loginVideo} autoplay playsinline muted class="fullscreen-video"></video>
      <canvas bind:this={loginCanvas} style="display:none"></canvas>

      <!-- Overlay UI -->
      <div class="overlay-ui">
        
        <!-- 👇 Result message + thumbnail -->
        {#if loginMessage}
          <div class="message-container" style="--message-color: {loginMessageColor};">
            {#if loginImageUrl}
              <img src={loginImageUrl} alt="Recognized face" class="message-image" />
            {/if}
            <span>{loginMessage}</span>
          </div>
        {/if}
      </div>
    </div>
  {/if}

      <!-- 🎨 Settings Auth Screen -->
      {#if currentScreen === 'settings-auth'}
        <div class="auth-form-container" class:visible={formVisible}>
          <div class="auth-form-header">
            <button class="back-button" on:click={goBack}>
              <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
              </svg>
            </button>
            <h2 class="auth-form-title">Settings Access</h2>
            <p class="auth-form-subtitle">Enter admin credentials</p>
          </div>

          <form class="auth-glass-form" on:submit|preventDefault={checkSettingsLogin}>
            <div class="auth-input-group">
              <label class="auth-input-label" for="settingsUser">Username</label>
              <div class="auth-input-wrapper">
                <input
                  id="settingsUser"
                  type="text"
                  bind:value={settingsUser}
                  placeholder="Enter username"
                  class="auth-form-input"
                />
                <div class="auth-input-glow"></div>
              </div>
            </div>

            <div class="auth-input-group">
              <label class="auth-input-label" for="settingsPass">Password</label>
              <div class="auth-input-wrapper">
                <input
                  id="settingsPass"
                  type="password"
                  bind:value={settingsPass}
                  placeholder="Enter password"
                  class="auth-form-input"
                />
                <div class="auth-input-glow"></div>
              </div>
            </div>

            {#if settingsError}
              <div class="error-message">
                <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <span>{settingsError}</span>
              </div>
            {/if}

            <button type="submit" class="auth-submit-btn">
              <span class="btn-text">Access Settings</span>
              <div class="btn-shine"></div>
            </button>
          </form>
        </div>
      {/if}

      <!-- 🎨 Settings Screen -->
      {#if currentScreen === 'settings'}
        <div class="settings-container" class:visible={formVisible}>
          <div class="settings-header">
            <button class="back-button" on:click={goBack}>
              <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
              </svg>
            </button>
            <h2 class="settings-title">System Settings</h2>
            <p class="settings-subtitle">Configure attendance system</p>
          </div>

          <div class="settings-content">
            <form class="settings-form" on:submit|preventDefault={saveDeviceName}>
              <div class="settings-group">
                <label class="settings-label" for="roomId">Room</label>
                <div class="settings-select-wrapper">
                  <select id="roomId" bind:value={roomId} class="settings-select">
                    {#each roomList as room}
                      <option value={room.RoomID}>{room.RoomName}</option>
                    {/each}
                  </select>
                  <div class="select-arrow">▼</div>
                </div>
              </div>

              <div class="settings-group">
                <label class="settings-label" for="serverUrl">Server URL</label>
                <div class="settings-input-wrapper">
                  <input
                    id="serverUrl"
                    type="text"
                    bind:value={SERVER_URL}
                    class="settings-input"
                    placeholder="API endpoint URL"
                  />
                  <div class="settings-input-glow"></div>
                </div>
              </div>

              <button type="submit" class="settings-save-btn">
                <span class="btn-text">Save Settings</span>
                <div class="btn-shine"></div>
              </button>
            </form>
          </div>
        </div>
      {/if}
    </div>
  {/if}
</div>

<style>
  .screen {
    width: 740px;
    height: 990px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    z-index: 9999;
    opacity: 1;
    transition: opacity 0.8s cubic-bezier(0.4, 0, 0.2, 1);
  }

  .loading-screen.fade-out {
    opacity: 0;
    pointer-events: none;
  }

  .loading-bg {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    overflow: hidden;
  }

  .gradient-orb {
    position: absolute;
    border-radius: 50%;
    filter: blur(40px);
    opacity: 0.6;
    animation: float 6s ease-in-out infinite;
  }

  .orb-1 {
    width: 300px;
    height: 300px;
    background: linear-gradient(45deg, #ff6b6b, #ffa500);
    top: 10%;
    left: 10%;
    animation-delay: 0s;
  }

  .orb-2 {
    width: 250px;
    height: 250px;
    background: linear-gradient(45deg, #4ecdc4, #44a08d);
    top: 60%;
    right: 10%;
    animation-delay: 2s;
  }

  .orb-3 {
    width: 200px;
    height: 200px;
    background: linear-gradient(45deg, #a855f7, #7c3aed);
    bottom: 20%;
    left: 20%;
    animation-delay: 4s;
  }

  .orb-4 {
    width: 180px;
    height: 180px;
    background: linear-gradient(45deg, #22c55e, #16a34a);
    top: 30%;
    right: 30%;
    animation-delay: 1s;
  }

  .orb-5 {
    width: 220px;
    height: 220px;
    background: linear-gradient(45deg, #f97316, #ea580c);
    bottom: 10%;
    right: 20%;
    animation-delay: 3s;
  }

  @keyframes float {
    0%, 100% { transform: translateY(0px) rotate(0deg); }
    50% { transform: translateY(-20px) rotate(180deg); }
  }

  .particles-container {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    pointer-events: none;
  }

  .particle {
    position: absolute;
    border-radius: 50%;
    animation: particleFloat 8s ease-in-out infinite;
  }

  .particle-1 { background: rgba(255, 107, 107, 0.8); width: 8px; height: 8px; }
  .particle-2 { background: rgba(78, 205, 196, 0.8); width: 6px; height: 6px; }
  .particle-3 { background: rgba(168, 85, 247, 0.8); width: 10px; height: 10px; }
  .particle-4 { background: rgba(34, 197, 94, 0.8); width: 7px; height: 7px; }
  .particle-5 { background: rgba(249, 115, 22, 0.8); width: 9px; height: 9px; }

  @keyframes particleFloat {
    0%, 100% {
      transform: translateY(0px) scale(1);
      opacity: 0.8;
    }
    50% {
      transform: translateY(-100px) scale(1.2);
      opacity: 0.4;
    }
  }

  .loading-content {
    position: relative;
    z-index: 10;
    text-align: center;
    max-width: 400px;
    padding: 2rem;
  }

  .loading-logo {
    margin-bottom: 2rem;
  }

  .logo-icon {
    width: 80px;
    height: 80px;
    margin: 0 auto 1rem;
    position: relative;
  }

  .face-icon {
    width: 100%;
    height: 100%;
    animation: logoPulse 2s ease-in-out infinite;
  }

  .logo-pulse {
    position: absolute;
    top: -10px;
    left: -10px;
    right: -10px;
    bottom: -10px;
    border: 2px solid rgba(255, 255, 255, 0.3);
    border-radius: 50%;
    animation: logoPulse 2s ease-in-out infinite;
  }

  @keyframes logoPulse {
    0%, 100% {
      transform: scale(1);
      opacity: 0.5;
    }
    50% {
      transform: scale(1.1);
      opacity: 1;
    }
  }

  .loading-brand {
    margin-bottom: 3rem;
  }

  .brand-main {
    font-size: 2.5rem;
    font-weight: 700;
    color: white;
    margin: 0 0 0.5rem 0;
    text-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
    letter-spacing: -0.02em;
  }

  .brand-tagline {
    font-size: 1.1rem;
    color: rgba(255, 255, 255, 0.8);
    margin: 0;
    font-weight: 400;
  }

  .loading-progress {
    margin-bottom: 2rem;
  }

  .progress-bar {
    width: 100%;
    height: 6px;
    background: rgba(255, 255, 255, 0.2);
    border-radius: 3px;
    overflow: hidden;
    margin-bottom: 1rem;
    position: relative;
  }

  .progress-fill {
    height: 100%;
    background: linear-gradient(90deg, #ff6b6b, #ffa500, #4ecdc4, #a855f7, #22c55e);
    background-size: 200% 100%;
    animation: progressShine 2s ease-in-out infinite;
    transition: width 0.3s ease;
    border-radius: 3px;
  }

  .progress-glow {
    position: absolute;
    top: 0;
    left: 0;
    height: 100%;
    background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.4), transparent);
    animation: progressGlow 1.5s ease-in-out infinite;
  }

  .progress-shine {
    position: absolute;
    top: 0;
    left: -100%;
    width: 50%;
    height: 100%;
    background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.6), transparent);
    animation: progressShine 2s ease-in-out infinite;
  }

  @keyframes progressGlow {
    0%, 100% { opacity: 0; transform: translateX(-100%); }
    50% { opacity: 1; transform: translateX(0%); }
  }

  @keyframes progressShine {
    0% { left: -100%; }
    100% { left: 100%; }
  }

  .progress-text {
    color: white;
    font-size: 1.1rem;
    font-weight: 500;
    margin-bottom: 0.5rem;
  }

  .progress-percentage {
    color: rgba(255, 255, 255, 0.7);
    font-size: 0.9rem;
    font-weight: 400;
  }

  .loading-dots {
    display: flex;
    justify-content: center;
    gap: 8px;
  }

  .dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: white;
    animation: dotBounce 1.4s ease-in-out infinite;
  }

  .dot-1 { animation-delay: 0s; }
  .dot-2 { animation-delay: 0.2s; }
  .dot-3 { animation-delay: 0.4s; }

  @keyframes dotBounce {
    0%, 80%, 100% { transform: scale(0.8); opacity: 0.5; }
    40% { transform: scale(1); opacity: 1; }
  }

  .floating-shapes {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    pointer-events: none;
  }

  .shape {
    position: absolute;
    opacity: 0.1;
    animation: shapeFloat 10s ease-in-out infinite;
  }

  .shape-1 {
    top: 20%;
    left: 10%;
    width: 60px;
    height: 60px;
    background: #ff6b6b;
    clip-path: polygon(50% 0%, 0% 100%, 100% 100%);
    animation-delay: 0s;
  }

  .shape-2 {
    top: 70%;
    right: 15%;
    width: 40px;
    height: 40px;
    background: #4ecdc4;
    clip-path: polygon(25% 0%, 75% 0%, 100% 50%, 75% 100%, 25% 100%, 0% 50%);
    animation-delay: 3s;
  }

  .shape-3 {
    bottom: 30%;
    left: 70%;
    width: 50px;
    height: 50px;
    background: #a855f7;
    clip-path: polygon(50% 0%, 100% 50%, 50% 100%, 0% 50%);
    animation-delay: 6s;
  }

  .shape-4 {
    top: 50%;
    left: 80%;
    width: 35px;
    height: 35px;
    background: #22c55e;
    border-radius: 50%;
    animation-delay: 9s;
  }

  @keyframes shapeFloat {
    0%, 100% { transform: translateY(0px) rotate(0deg); }
    33% { transform: translateY(-30px) rotate(120deg); }
    50% { transform: translateY(-25px) rotate(180deg); }
    75% { transform: translateY(-75px) rotate(270deg); }
  }

  /* 🎨 Animated Background */
  .animated-background {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    z-index: 1;
    pointer-events: none;
  }

  .bg-orb {
    position: absolute;
    border-radius: 50%;
    filter: blur(60px);
    opacity: 0.3;
    animation: bgOrbFloat 8s ease-in-out infinite;
  }

  .orb-primary {
    width: 400px;
    height: 400px;
    background: linear-gradient(45deg, #3b82f6, #1d4ed8);
    top: -10%;
    left: -10%;
    animation-delay: 0s;
  }

  .orb-secondary {
    width: 300px;
    height: 300px;
    background: linear-gradient(45deg, #a855f7, #7c3aed);
    top: 60%;
    right: -5%;
    animation-delay: 2s;
  }

  .orb-accent {
    width: 250px;
    height: 250px;
    background: linear-gradient(45deg, #22c55e, #16a34a);
    bottom: -5%;
    left: 50%;
    animation-delay: 4s;
  }

  .orb-purple {
    width: 200px;
    height: 200px;
    background: linear-gradient(45deg, #f97316, #ea580c);
    top: 20%;
    right: 20%;
    animation-delay: 6s;
  }

  @keyframes bgOrbFloat {
    0%, 100% { transform: scale(1) rotate(0deg); }
    50% { transform: scale(1.1) rotate(180deg); }
  }

  .floating-elements {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
  }

  .floating-element {
    position: absolute;
    opacity: 0.1;
    animation: elementFloat 12s ease-in-out infinite;
  }

  .element-1 {
    width: 20px;
    height: 30px;
    background: #3b82f6;
    border-radius: 50% 50% 50% 0;
  }

  .element-2 {
    width: 15px;
    height: 40px;
    background: #a855f7;
    clip-path: polygon(50% 0%, 0% 100%, 100% 100%);
  }

  .element-3 {
    width: 25px;
    height: 25px;
    background: #22c55e;
    transform: rotate(45deg);
  }

  .element-4 {
    width: 18px;
    height: 18px;
    background: #f97316;
    border-radius: 50%;
  }

  @keyframes elementFloat {
    0%, 100% { transform: translateY(0px) rotate(0deg); }
    25% { transform: translateY(-50px) rotate(90deg); }
    50% { transform: translateY(-25px) rotate(180deg); }
    75% { transform: translateY(-75px) rotate(270deg); }
  }

  /* 🎨 Content Wrapper */
  .content-wrapper {
    position: relative;
    z-index: 10;
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 2rem;
    color: #0f172a; /* default main text color: dark for readability */
  }

  /* 🎨 Screen Container */
  .screen-container {
    width: 100%;
    max-width: 500px;
    opacity: 0;
    transform: translateY(30px);
    transition: all 0.8s cubic-bezier(0.4, 0, 0.2, 1);
  }

  .screen-container.visible {
    opacity: 1;
    transform: translateY(0);
  }

  /* 🎨 Brand Header */
  .brand-header {
    text-align: center;
    margin-bottom: 3rem;
  }

  .brand-icon {
    margin-bottom: 1.5rem;
  }

  .school-icon {
    width: 80px;
    height: 80px;
    margin: 0 auto;
  }

  .brand-title {
    font-size: 2.5rem;
    font-weight: 700;
    color: #0f172a;
    margin: 0 0 0.5rem 0;
    text-shadow: 0 2px 20px rgba(0, 0, 0, 0.3);
    letter-spacing: -0.02em;
  }

  .brand-subtitle {
    font-size: 1.1rem;
    color: rgba(15, 23, 42, 0.8);
    margin: 0;
    font-weight: 400;
  }

  /* 🎨 Action Buttons */
  .action-buttons {
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
    margin-bottom: 2rem;
  }

  .action-btn {
    display: flex;
    align-items: center;
    padding: 1.5rem;
    background: rgba(255, 255, 255, 0.15);
    backdrop-filter: blur(20px);
    border: 1px solid rgba(255, 255, 255, 0.2);
    border-radius: 1rem;
    color: #0f172a;
    text-decoration: none;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    cursor: pointer;
    position: relative;
    overflow: hidden;
  }

  .action-btn::before {
    content: '';
    position: absolute;
    top: 0;
    left: -100%;
    width: 100%;
    height: 100%;
    background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
    transition: left 0.5s;
  }

  .action-btn:hover::before {
    left: 100%;
  }

  .action-btn:hover {
    transform: translateY(-5px);
    box-shadow: 0 20px 40px rgba(0, 0, 0, 0.2);
    background: rgba(255, 255, 255, 0.25);
  }

  .btn-icon {
    width: 48px;
    height: 48px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-right: 1rem;
    background: rgba(255, 255, 255, 0.2);
    flex-shrink: 0;
  }

  .btn-content {
    flex: 1;
  }

  .btn-title {
    font-size: 1.25rem;
    font-weight: 600;
    margin: 0 0 0.25rem 0;
    display: block;
  }

  .btn-subtitle {
    font-size: 0.9rem;
    opacity: 0.8;
    margin: 0;
    display: block;
  }

  .btn-arrow {
    font-size: 1.5rem;
    font-weight: bold;
    opacity: 0.7;
    transition: all 0.3s ease;
  }

  .action-btn:hover .btn-arrow {
    opacity: 1;
    transform: translateX(5px);
  }

  .login-btn .btn-icon {
    background: linear-gradient(135deg, #3b82f6, #1d4ed8);
  }

  .register-btn .btn-icon {
    background: linear-gradient(135deg, #22c55e, #16a34a);
  }

  /* 🎨 Settings FAB */
  .settings-fab {
    position: fixed;
    bottom: 2rem;
    right: 2rem;
    width: 60px;
    height: 60px;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.15);
    backdrop-filter: blur(20px);
    border: 1px solid rgba(255, 255, 255, 0.2);
    color: #0f172a;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    z-index: 100;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
  }

  .settings-fab:hover {
    transform: scale(1.1) rotate(180deg);
    background: rgba(255, 255, 255, 0.25);
    box-shadow: 0 12px 40px rgba(0, 0, 0, 0.3);
  }

  .settings-icon {
    width: 24px;
    height: 24px;
  }

  /* 🎨 Form Containers */
  .form-container, .login-container, .auth-form-container, .settings-container {
    width: 100%;
    max-width: 500px;
    background: rgba(255, 255, 255, 0.15);
    backdrop-filter: blur(20px);
    border: 1px solid rgba(255, 255, 255, 0.2);
    border-radius: 1.5rem;
    padding: 2rem;
    box-shadow: 0 25px 50px rgba(0, 0, 0, 0.15);
    color: #0f172a; /* dark text for readability on light/white backgrounds */
    opacity: 0;
    transform: translateY(30px) scale(0.95);
    transition: all 0.6s cubic-bezier(0.4, 0, 0.2, 1);
  }

  .face-container {
    width: 100%;
    max-width: 1100px; /* Larger to accommodate 1024px video */
    background: rgba(255, 255, 255, 0.15);
    backdrop-filter: blur(20px);
    border: 1px solid rgba(255, 255, 255, 0.2);
    border-radius: 1.5rem;
    padding: 2rem;
    box-shadow: 0 25px 50px rgba(0, 0, 0, 0.15);
    color: #0f172a; /* dark text for readability on light/white backgrounds */
    opacity: 0;
    transform: translateY(30px) scale(0.95);
    transition: all 0.6s cubic-bezier(0.4, 0, 0.2, 1);
  }

  .form-container.visible, .face-container.visible, .login-container.visible,
  .auth-form-container.visible, .settings-container.visible {
    opacity: 1;
    transform: translateY(0) scale(1);
  }

  /* 🎨 Form Headers */
  .form-header, .face-header, .login-header, .auth-form-header, .settings-header {
    text-align: center;
    margin-bottom: 2rem;
    position: relative;
  }

  .back-button {
    position: absolute;
    left: 0;
    top: 50%;
    transform: translateY(-50%);
    width: 40px;
    height: 40px;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.1);
    border: 1px solid rgba(255, 255, 255, 0.2);
    color: #0f172a;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: all 0.3s ease;
  }

  .back-button:hover {
    background: rgba(255, 255, 255, 0.2);
    transform: translateY(-50%) scale(1.1);
  }

  .back-button svg {
    width: 20px;
    height: 20px;
  }

  .form-title, .face-title, .login-title, .auth-form-title, .settings-title {
    font-size: 1.75rem;
    font-weight: 700;
    color: #0f172a;
    margin: 0 0 0.5rem 0;
    text-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
  }

  .form-subtitle, .face-subtitle, .login-subtitle, .auth-form-subtitle, .settings-subtitle {
    font-size: 1rem;
    color: rgba(15, 23, 42, 0.8);
    margin: 0;
    font-weight: 400;
  }

  /* 🎨 Glass Form */
  .glass-form, .auth-glass-form {
    width: 100%;
  }

  .form-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1.5rem;
    margin-bottom: 2rem;
  }

  .input-group, .auth-input-group {
    display: flex;
    flex-direction: column;
  }

  .full-width {
    grid-column: 1 / -1;
  }

  .input-label, .auth-input-label {
    font-size: 0.9rem;
    font-weight: 500;
    color: rgba(15, 23, 42, 0.9);
    margin-bottom: 0.5rem;
    letter-spacing: 0.01em;
  }

  .input-wrapper, .auth-input-wrapper {
    position: relative;
    border-radius: 0.75rem;
    background: rgba(255, 255, 255, 0.1);
    border: 1px solid rgba(255, 255, 255, 0.2);
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    overflow: hidden;
  }

  .input-wrapper:focus-within, .auth-input-wrapper:focus-within {
    background: rgba(255, 255, 255, 0.15);
    border-color: rgba(255, 255, 255, 0.4);
    box-shadow: 0 0 0 3px rgba(255, 255, 255, 0.1);
    transform: translateY(-2px);
  }

  .form-input, .auth-form-input {
    width: 100%;
    padding: 1rem;
    background: transparent;
    border: none;
    color: #0f172a;
    font-size: 1rem;
    outline: none;
    font-family: inherit;
  }

  .form-input::placeholder, .auth-form-input::placeholder {
    color: rgba(15, 23, 42, 0.6);
  }

  .input-glow, .auth-input-glow {
    position: absolute;
    bottom: 0;
    left: 0;
    height: 2px;
    width: 0%;
    background: linear-gradient(90deg, #3b82f6, #a855f7, #22c55e);
    transition: width 0.3s ease;
  }

  .input-wrapper:focus-within .input-glow,
  .auth-input-wrapper:focus-within .auth-input-glow {
    width: 100%;
  }

  /* 🎨 Form Actions */
  .form-actions {
    display: flex;
    gap: 1rem;
    margin-bottom: 2rem;
  }

  .primary-btn, .auth-submit-btn {
    flex: 1;
    padding: 1rem 2rem;
    background: linear-gradient(135deg, #3b82f6, #a855f7);
    border: none;
    border-radius: 0.75rem;
    color: white;
    font-size: 1rem;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    position: relative;
    overflow: hidden;
    box-shadow: 0 4px 15px rgba(59, 130, 246, 0.3);
  }

  /* 🎨 QR Reader */
  .qr-reader {
    width: 100%;
    max-width: 300px;
    margin: 1rem auto 0;
    border-radius: 0.75rem;
    overflow: hidden;
    border: 1px solid rgba(255, 255, 255, 0.2);
  }

  /* 🎨 Face Capture */
  .face-content {
    width: 100%;
  }

  .camera-container {
    position: relative;
    margin-bottom: 2rem;
  }

  .face-video {
    width: 640px;
    height: 640px;
    border-radius: 1rem;
    border: 2px solid rgba(255, 255, 255, 0.2);
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
    /* Mirror the video horizontally for a natural webcam feel */
    transform: scaleX(-1);
  }

  .face-instruction {
    position: absolute;
    top: 1rem;
    left: 50%;
    transform: translateX(-50%);
    background: rgba(0, 0, 0, 0.8);
    backdrop-filter: blur(10px);
    border-radius: 0.75rem;
    padding: 1rem;
    display: flex;
    align-items: center;
    gap: 0.75rem;
    max-width: 90%; /* Prevent overflow on smaller screens */
  }

  .instruction-icon {
    width: 32px;
    height: 32px;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.2);
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }

  .instruction-icon svg {
    width: 18px;
    height: 18px;
    color: #0f172a;
  }

  .instruction-text {
    color: #0f172a;
    font-size: 0.9rem;
    font-weight: 500;
  }

  .preview-container {
    display: flex;
    justify-content: center;
    gap: 1rem;
    margin-bottom: 2rem;
    flex-wrap: wrap;
  }

  .preview-item {
    text-align: center;
  }

  .preview-image {
    width: 80px;
    height: 80px;
    border-radius: 0.75rem;
    object-fit: cover;
    border: 2px solid rgba(255, 255, 255, 0.3);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  }

  .preview-label {
    color: rgba(15, 23, 42, 0.8);
    font-size: 0.8rem;
    font-weight: 500;
    margin-top: 0.5rem;
  }

  .completion-message {
    text-align: center;
    padding: 2rem;
    background: rgba(34, 197, 94, 0.1);
    border: 1px solid rgba(34, 197, 94, 0.3);
    border-radius: 1rem;
  }

  .completion-message .completion-icon {
    font-size: 3rem;
    margin-bottom: 1rem;
    display: block;
  }

  .completion-message h3 {
    color: #0f172a;
    font-size: 1.25rem;
    font-weight: 600;
    margin: 0 0 0.5rem 0;
  }

  .completion-message p {
    color: rgba(15, 23, 42, 0.8);
    margin: 0;
  }

  /* 🎨 Login Camera */
  .camera-section {
    margin-bottom: 2rem;
  }

  .camera-wrapper {
    position: relative;
    margin-bottom: 1.5rem;
  }

  .login-video {
    width: 100%;
    max-width: 400px;
    height: auto;
    border-radius: 1rem;
    border: 2px solid rgba(255, 255, 255, 0.2);
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
  }

  .camera-overlay {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    pointer-events: none;
  }

  .scan-indicator {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    width: 200px;
    height: 150px;
    border: 2px solid rgba(59, 130, 246, 0.6);
    border-radius: 0.75rem;
    overflow: hidden;
  }

  .scan-line {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 2px;
    background: linear-gradient(90deg, transparent, #3b82f6, transparent);
    animation: scanMove 2s ease-in-out infinite;
  }

  @keyframes scanMove {
    0%, 100% { top: 0; opacity: 0; }
    50% { top: 100%; opacity: 1; }
  }

  .login-actions {
    display: flex;
    justify-content: center;
    margin-bottom: 2rem;
  }

  .scan-btn {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    padding: 1rem 2rem;
    background: linear-gradient(135deg, #3b82f6, #1d4ed8);
    border: none;
    border-radius: 0.75rem;
    color: white;
    font-size: 1rem;
    font-weight: 600;
    cursor: pointer;
  }
  video {
    width: 100%;
    max-width: 640px;
    border-radius: 8px;
  }

  .scan-icon {
    width: 20px;
    height: 20px;
  }

  /* 🎨 Recognition Result */
  .recognition-result {
    padding: 1.5rem;
    border-radius: 1rem;
    border: 1px solid;
    background: rgba(255, 255, 255, 0.05);
    backdrop-filter: blur(10px);
    display: flex;
    align-items: center;
    gap: 1rem;
    animation: resultSlideIn 0.5s cubic-bezier(0.4, 0, 0.2, 1);
  }

  .recognition-result.success {
    border-color: rgba(34, 197, 94, 0.5);
    background: rgba(34, 197, 94, 0.1);
  }

  .recognition-result.error {
    border-color: rgba(239, 68, 68, 0.5);
    background: rgba(239, 68, 68, 0.1);
  }

  @keyframes resultSlideIn {
    from {
      opacity: 0;
      transform: translateY(20px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  .result-image {
    width: 60px;
    height: 60px;
    border-radius: 0.75rem;
    object-fit: cover;
    border: 2px solid currentColor;
    flex-shrink: 0;
  }

  .result-content {
    flex: 1;
    display: flex;
    align-items: center;
    gap: 0.75rem;
  }

  .result-icon {
    width: 32px;
    height: 32px;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.2);
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }

  .result-text {
    flex: 1;
  }

  .result-message {
    color: #0f172a;
    font-size: 1rem;
    font-weight: 600;
    margin: 0;
    line-height: 1.4;
  }

  /* 🎨 Error Message */
  .error-message {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 1rem;
    background: rgba(239, 68, 68, 0.1);
    border: 1px solid rgba(239, 68, 68, 0.3);
    border-radius: 0.75rem;
    color: #fca5a5;
    font-size: 0.9rem;
    font-weight: 500;
    margin-bottom: 1rem;
  }

  .error-message svg {
    width: 18px;
    height: 18px;
    flex-shrink: 0;
  }

  /* 🎨 Settings Form */
  .settings-form {
    width: 100%;
  }

  .settings-group {
    margin-bottom: 1.5rem;
  }

  .settings-label {
    display: block;
    font-size: 0.9rem;
    font-weight: 500;
    color: rgba(15, 23, 42, 0.9);
    margin-bottom: 0.5rem;
  }

  .settings-select-wrapper, .settings-input-wrapper {
    position: relative;
  }

  .settings-select, .settings-input {
    width: 100%;
    padding: 1rem;
    background: rgba(255, 255, 255, 0.1);
    border: 1px solid rgba(255, 255, 255, 0.2);
    border-radius: 0.75rem;
    color: #0f172a;
    font-size: 1rem;
    outline: none;
    font-family: inherit;
    transition: all 0.3s ease;
  }

  .settings-select:focus, .settings-input:focus {
    background: rgba(255, 255, 255, 0.15);
    border-color: rgba(255, 255, 255, 0.4);
    box-shadow: 0 0 0 3px rgba(255, 255, 255, 0.1);
    transform: translateY(-2px);
  }

  .settings-select::placeholder, .settings-input::placeholder {
    color: rgba(15, 23, 42, 0.6);
  }

  .select-arrow {
    position: absolute;
    right: 1rem;
    top: 50%;
    transform: translateY(-50%);
    color: rgba(15, 23, 42, 0.6);
    pointer-events: none;
  }

  .settings-input-glow {
    position: absolute;
    bottom: 0;
    left: 0;
    height: 2px;
    width: 0%;
    background: linear-gradient(90deg, #3b82f6, #a855f7, #22c55e);
    transition: width 0.3s ease;
  }

  .settings-input-wrapper:focus-within .settings-input-glow {
    width: 100%;
  }

  .settings-save-btn {
    width: 100%;
    padding: 1rem 2rem;
    background: linear-gradient(135deg, #22c55e, #16a34a);
    border: none;
    border-radius: 0.75rem;
    color: white;
    font-size: 1rem;
    font-weight: 600;
    cursor: pointer;
    box-shadow: 0 4px 8px rgba(0,0,0,0.25);
    transition: background 0.2s, transform 0.2s;
    z-index: 1000;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.8rem;
    line-height: 1;
    padding: 0; 
    touch-action: manipulation;
  }
  .login-page {
    width: 100vw;
    height: 100vh;
    position: fixed;
    top: 0;
    left: 0;
    background: #000; /* Black background for video */
  }

  .fullscreen-video {
    /* occupy the entire viewport reliably */
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw !important;
    height: 100vh !important;
    margin: 0;
    padding: 0;
    /* mirror the video horizontally for a natural webcam feel */
    transform: scaleX(-1) !important;
    display: block;
    object-fit: cover;
    background-color: #000;
    /* override other generic video rules */
    border: none !important;
    max-width: none !important;
    border-radius: 0 !important;
    outline: none !important;
    box-shadow: none !important;
    z-index: 1;
  }

  .overlay-ui {
    position: absolute;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    z-index: 2;
    pointer-events: none; /* Allow interaction with video if needed */
  }

  .message-container {
    margin-top: 1rem;
    font-weight: bold;
    color: var(--message-color);
    display: flex;
    flex-direction: row;  /* Thumbnail on left, text on right */
    align-items: center;  /* Center vertically */
    gap: 10px;
    font-size: 1.5rem;
    background: rgba(255,255,255,0.9);
    padding: 10px;
    border-radius: 10px;
    border: 2px solid var(--message-color);
    pointer-events: auto; /* Allow interaction with message */
    position: absolute;
    bottom: 20px;
    left: 50%;
    transform: translateX(-50%);
  }

  .message-image {
    width: 80px;
    height: 80px; 
    border-radius: 8px;
    object-fit: cover;
    border: 3px solid var(--message-color);
  }
</style>