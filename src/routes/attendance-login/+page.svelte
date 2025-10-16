<script>
  import { onMount } from "svelte";

  // UI state
  let showForm = false;
  let showFacePage = false;
  let showLoginPage = false;
  let showSettingsAuth = false;
  let showSettingsPage = false;

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
  let loginCamera = null;
  let loginMessage = "";
  let loginMessageColor = "black"; 
  let detectionInterval;
  let loginImageUrl = "";

  // Settings 🔧
  // for authentication
  let settingsUser = "";
  let settingsPass = "";
  let settingsError = "";
  // 🌐 Settings values
  let deviceName = "";
  let selectedSubject = "";
  let SERVER_URL = "/attendance-login/api";
  let subjectList = [];
  let roomList = [];
  if (typeof window !== "undefined") {
    deviceName = localStorage.getItem("deviceName") || "";
    selectedSubject = localStorage.getItem("selectedSubject") || "";
    SERVER_URL = localStorage.getItem("SERVER_URL") || "/attendance-login/api";
  }

  $: if (typeof window !== "undefined") {
    localStorage.setItem("deviceName", deviceName);
    localStorage.setItem("selectedSubject", selectedSubject);
    localStorage.setItem("SERVER_URL", SERVER_URL);
  }

  // On mount: auto-select EMEET USB webcam
  onMount(async () => {
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
        // If deviceName is not set, default to first room
        if (!deviceName && roomList.length > 0) {
          deviceName = roomList[0].RoomName;
        }
      }
    } catch (e) {
      console.error("Failed to fetch rooms", e);
    }

    // Fetch subject list from API
    try {
      const res = await fetch("/attendance-login/api/subjects");
      const data = await res.json();
      if (data.subjects) {
        subjectList = data.subjects;
        // If selectedSubject is not set, default to first subject
        if (!selectedSubject && subjectList.length > 0) {
          selectedSubject = subjectList[0].SubjectName;
        }
      }
    } catch (e) {
      console.error("Failed to fetch subjects", e);
    }
  });


  // -------------------------
  // QR scanner (html5-qrcode) - dynamic import so SSR doesn't break
  // -------------------------
  async function startScanner() {
    if (scannerActive) return;
    scannerActive = true;

    try {
      const { Html5Qrcode } = await import("html5-qrcode"); // dynamic import
      html5QrCode = new Html5Qrcode("qr-reader");

      // Always use the EMEET camera (already set in onMount)
      const cameraConfig = { deviceId: { exact: selectedCamera } };

      await html5QrCode.start(
        cameraConfig,
        { fps: 10, qrbox: 250 },
        (decodedText, decodedResult) => {
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
          // scan errors (you can keep this quiet or log)
        }
      );


      console.log("QR scanner started");
      scannerActive = true;
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

  // Take snapshot from video
  function takeSnapshot() {
    const ctx = canvas.getContext("2d");

    // target size for FaceAPI detection
    const TARGET_WIDTH = 640;
    const TARGET_HEIGHT = 480;

    canvas.width = TARGET_WIDTH;
    canvas.height = TARGET_HEIGHT;

    // draw scaled image from video
    ctx.drawImage(video, 0, 0, TARGET_WIDTH, TARGET_HEIGHT);

    return canvas.toDataURL("image/jpeg");
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
      console.log("Starting camera with selectedCamera:", selectedCamera);
      // use ideal to avoid failing if exact deviceId isn't usable
      const constraints = {
        video: {
          deviceId: faceCamera ? { exact: faceCamera } : { exact: selectedCamera },
          width: { ideal: 1280 },
          height: { ideal: 720 }
        }
      };
      stream = await navigator.mediaDevices.getUserMedia(constraints);
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
        overlayCanvas.style.zIndex = 10;
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
    if (!window.faceapi) {
      // @ts-ignore
      window.faceapi = await import('face-api.js');
    }
    // If you want to use a redirector, set modelUrl to '/facehandle.js' and handle requests in that file.
    // For standard usage, keep models in /static/models and use '/models' as the URL.
    const modelUrl = '/models'; // or '/facehandle.js' for advanced redirect
    await Promise.all([
      window.faceapi.nets.tinyFaceDetector.loadFromUri(modelUrl),
      window.faceapi.nets.faceLandmark68Net.loadFromUri(modelUrl)
    ]);
  }

  async function drawFaceBox() {
    if (!video || video.readyState !== 4) return;
    overlayCanvas.width = video.videoWidth;
    overlayCanvas.height = video.videoHeight;
    overlayCtx.clearRect(0, 0, overlayCanvas.width, overlayCanvas.height);

    // Detect face
    const detection = await window.faceapi.detectSingleFace(video, new window.faceapi.TinyFaceDetectorOptions()).withFaceLandmarks();
    if (detection) {
      const box = detection.detection.box;
      // Make the box smaller (e.g., 60% of original size) and move it to the left
      const scale = 0.6;
      const offsetX = -box.width * 0.2; // move left by 20% of original width
      const newWidth = box.width * scale;
      const newHeight = box.height * scale;
      const newX = box.x + offsetX;
      const newY = box.y + (box.height - newHeight) / 2;
      faceBox = { x: newX, y: newY, width: 20, height: 30 };
      // Draw rectangle
      overlayCtx.strokeStyle = '#00FF00';
      overlayCtx.lineWidth = 3;
      overlayCtx.strokeRect(100, 40, 120, 120);
      // Draw instruction
      overlayCtx.font = '24px Arial';
      overlayCtx.fillStyle = '#00FF00';
      faceInstruction = getFaceInstruction(faceStep);
      overlayCtx.fillText(faceInstruction, 100, 40 - 10);
    } else {
      faceBox = null;
      faceInstruction = getFaceInstruction(faceStep);
      overlayCtx.font = '24px Arial';
      overlayCtx.fillStyle = '#FF0000';
      overlayCtx.fillText('No face detected', 20, 40);
      overlayCtx.fillText(faceInstruction, 20, 70);
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

    while (faceStep <= 3) {
      let captured = false;
      console.log("🟢 Waiting for:", instructions[faceStep]);

      while (!captured) {
        const { orientation } = await checkOrientation();
        console.log("Orientation:", orientation);

        if (faceStep === 1 && orientation === "front") captured = true;
        if (faceStep === 2 && orientation === "right") captured = true;
        if (faceStep === 3 && orientation === "left") captured = true;

        if (captured) {
          const frame = takeSnapshot();
          capturedImages[`pic${faceStep}`] = frame;
          console.log(`✅ Auto captured step ${faceStep}`);
          faceStep++;
          await new Promise(res => setTimeout(res, 1500)); // pause before next step
        }

        await new Promise(res => setTimeout(res, 500)); // polling interval
      }
    }

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
    try {
      // Dynamically find EMEET camera id
      const devices = await navigator.mediaDevices.enumerateDevices();
      const emeetCam = devices.find(
        d => d.kind === "videoinput" && (d.label || "").toLowerCase().includes("emeet")
      );

      let constraints;
      if (emeetCam) {
        constraints = { video: { deviceId: { exact: emeetCam.deviceId } } };
      } else {
        console.warn("⚠ EMEET camera not found, falling back to default.");
        constraints = { video: true };
      }

      loginStream = await navigator.mediaDevices.getUserMedia(constraints);
      loginVideo.srcObject = loginStream;

      // Play may fail due to autoplay policy — catch but don’t treat as camera error
      loginVideo.play().catch(err => {
        console.warn("⚠ Video autoplay blocked, user interaction needed:", err);
      });

      loginCtx = loginCanvas.getContext("2d");

      if (detectionInterval) clearInterval(detectionInterval);
      detectionInterval = setInterval(sendFrameForDetection, 500);

    } catch (err) {
      console.error("Login camera error:", err);
      alert("❌ Could not start login camera at all");
      showLoginPage = false;
    }
  }

  async function sendFrameForDetection() {
    if (!loginCtx || !loginVideo.videoWidth) return;

    loginCanvas.width = loginVideo.videoWidth;
    loginCanvas.height = loginVideo.videoHeight;
    loginCtx.drawImage(loginVideo, 0, 0, loginCanvas.width, loginCanvas.height);

    const imageData = loginCanvas.toDataURL("image/png");

    try {
      const res = await fetch(`${SERVER_URL}/login-recognize`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ image: imageData, deviceName, selectedSubject })
      });

      const data = await res.json();

      // Directly set the recognition result
      loginMessage = data.message;
      loginMessageColor = data.message && data.message.includes("Welcome") ? "green" : "red";
      loginImageUrl = data.imageUrl || "";

      // Keep camera running for continuous recognition
    } catch (err) {
      console.error("Recognition error:", err);
      loginMessage = "❌ Error during recognition";
      loginMessageColor = "red";
      loginImageUrl = "";
      stopLoginCamera();
    }
  }
  function stopLoginCamera() {
    if (detectionInterval) {
      clearInterval(detectionInterval);
      detectionInterval = null;
    }
    if (loginStream) {
      loginStream.getTracks().forEach((t) => t.stop());
      loginStream = null;
    }
    if (loginVideo) loginVideo.srcObject = null;
  }

  function saveDeviceName() {
    localStorage.setItem("deviceName", deviceName);
    alert("✅ Device name saved!");
  }
  function openSettingsAuth() {
    showSettingsAuth = true;
  }
  function checkSettingsLogin() {
    const validUser = "admin";
    const validPass = "1234";
    if (settingsUser === validUser && settingsPass === validPass) {
      showSettingsAuth = false;
      showSettingsPage = true;
      settingsError = "";
    } else {
      settingsError = "Invalid username or password";
    }
  }
  function closeSettings() {
    showSettingsPage = false;
  }

</script>

<div class="screen">
  {#if !showForm && !showFacePage && !showLoginPage && !showSettingsAuth && !showSettingsPage}
    <div class="main-buttons">
      <button class="big-btn" on:click={() => { showLoginPage = true; startLoginCamera(); }}>
        Login
      </button>
    </div>

    <div class="bottom-button">
      <button class="big-btn" on:click={() => showForm = true}>
        Register
      </button>
    </div>

    <button class="settings-btn" on:click={openSettingsAuth}>
      <span class="gear">⚙️</span>
    </button>
  {/if}

  {#if showForm}
    <!-- Registration form -->
    <form class="form" on:submit|preventDefault={submitForm}>
      <label>
        First Name:
        <input type="text" bind:value={firstName} required />
      </label>

      <label>
        Middle Initial:
        <input type="text" maxlength="2" bind:value={middleInitial} />
      </label>

      <label>
        Surname:
        <input type="text" bind:value={surname} required />
      </label>

      <label>
        Student ID:
        <input type="text" bind:value={studentId} required />
      </label>

      <label>
        Device Name:
        <select bind:value={deviceName}>
          {#each roomList as room}
            <option value={room.RoomName}>{room.RoomName}</option>
          {/each}
        </select>
      </label>

      <div class="actions">
        <button type="submit" class="submit-btn">Submit</button>
        <button type="button" class="cancel-btn" on:click={resetForm}>
          Cancel
        </button>
      </div>

      <div class="scanner-actions">
        {#if !scannerActive}
          <button type="button" class="scan-btn" on:click={startScanner}>
            📷 Scan QR
          </button>
        {:else}
          <button type="button" class="stop-btn" on:click={stopScanner}>
            ✖ Stop Scanner
          </button>
        {/if}
      </div>

      <div id="qr-reader" class="qr-reader"></div>
    </form>
  {/if}

  {#if showFacePage}
    <div class="face-page" style="position:relative;">
      <h2>Face Capture Step {faceStep} for {registrationData.firstName} {registrationData.surname}</h2>
      <!-- Live camera -->
      <div style="position:relative;display:inline-block;">
        <video bind:this={video} autoplay muted playsinline class="live-video"></video>
        <!-- Overlay canvas will be inserted dynamically -->
      </div>
      <canvas bind:this={canvas} style="display:none"></canvas>
      <div class="preview">
        {#if capturedImages.pic1}
          <img src={capturedImages.pic1} width="150" alt="Step 1" />
        {/if}
        {#if capturedImages.pic2}
          <img src={capturedImages.pic2} width="150" alt="Step 2" />
        {/if}
        {#if capturedImages.pic3}
          <img src={capturedImages.pic3} width="150" alt="Step 3" />
        {/if}
      </div>
      <!-- Final status only -->
      {#if faceStep === 4}
        <p style="font-weight: bold; color: green; font-size: 1.2rem;">
          ✅ Face capture complete — data saved automatically
        </p>
      {/if}
    </div>
  {/if}

  {#if showLoginPage}
    <div class="login-page">
      <h2>Login with Face Recognition</h2>
      <!-- svelte-ignore a11y_media_has_caption -->
      <video bind:this={loginVideo} autoplay playsinline muted class="border rounded w-96 h-72"></video>
      <canvas bind:this={loginCanvas} style="display:none"></canvas>

      <!-- 👇 Result message + thumbnail -->
      {#if loginMessage}
        <div style="margin-top: 1rem; font-weight: bold; color: {loginMessageColor}; display:flex; align-items:center; gap:10px; font-size: 1.5rem; background: rgba(255,255,255,0.9); padding: 10px; border-radius: 10px; border: 2px solid {loginMessageColor};">
          {#if loginImageUrl}
            <img src={loginImageUrl} alt="Recognized face" style="width:80px; height:80px; border-radius:8px; object-fit:cover; border:3px solid {loginMessageColor};" />
          {/if}
          <span>{loginMessage}</span>
        </div>
      {/if}
    </div>
  {/if}

  {#if showSettingsAuth}
    <div class="settings-auth">
      <h2>Settings Login</h2>
      <input type="text" placeholder="Username" bind:value={settingsUser} />
      <input type="password" placeholder="Password" bind:value={settingsPass} />
      {#if settingsError}
        <p style="color:red;">{settingsError}</p>
      {/if}
      <div class="actions">
        <button on:click={checkSettingsLogin}>Enter</button>
        <button on:click={() => showSettingsAuth = false}>Cancel</button>
      </div>
    </div>
  {/if}

  {#if showSettingsPage}
    <div class="settings-page">
      <h2>⚙ Settings</h2>
      <p>Here you can configure admin or system settings.</p>
      <label>
        Device Name:
        <select bind:value={deviceName}>
          {#each roomList as room}
            <option value={room.RoomID}>{room.RoomName}</option>
          {/each}
        </select>
      </label>
      <label>
        Subject:
        <select bind:value={selectedSubject}>
          {#each subjectList as subject}
            <option value={subject.SubjectID}>{subject.SubjectName}</option>
          {/each}
        </select>
      </label>
      <label>
        Server URL:
        <input type="text" bind:value={SERVER_URL} />
      </label>
      <button on:click={closeSettings}>Back</button>
    </div>
  {/if}

</div>

<style>
  .screen {
    width: 600px;
    height: 1024px;
    display: flex;
    flex-direction: column; 
    align-items: center;
    justify-content: center;
    background: #f9f9f9;
  }

  .big-btn {
    font-size: 2rem;
    margin: 10px 0; 
    padding: 20px 40px;
    border: none;
    border-radius: 12px;
    background: #0077cc;
    color: white;
    cursor: pointer;
  }

  .form {
    display: flex;
    flex-direction: column;
    gap: 20px;
    width: 80%;
    max-width: 500px;
  }

  label {
    font-size: 1.2rem;
    display: flex;
    flex-direction: column;
  }

  input {
    padding: 12px;
    font-size: 1.2rem;
    border: 1px solid #ccc;
    border-radius: 8px;
  }

  select {
    padding: 12px;
    font-size: 1.2rem;
    border: 1px solid #ccc;
    border-radius: 8px;
    background: white;
    cursor: pointer;
  }

  .actions {
    display: flex;
    justify-content: space-between;
    gap: 10px;
  }

  .submit-btn {
    flex: 1;
    background: #28a745;
    color: white;
    border: none;
    padding: 15px;
    border-radius: 8px;
    font-size: 1.2rem;
    cursor: pointer;
  }

  .cancel-btn {
    flex: 1;
    background: #dc3545;
    color: white;
    border: none;
    padding: 15px;
    border-radius: 8px;
    font-size: 1.2rem;
    cursor: pointer;
  }

  .scanner-actions {
    margin-top: 10px;
    display: flex;
    justify-content: center;
  }

  .scan-btn {
    background: #0077cc;
    color: white;
    border: none;
    padding: 12px 20px;
    border-radius: 8px;
    font-size: 1rem;
    cursor: pointer;
  }

  .stop-btn {
    background: #ff9800;
    color: white;
    border: none;
    padding: 12px 20px;
    border-radius: 8px;
    font-size: 1rem;
    cursor: pointer;
  }

  .qr-reader {
    width: 100%;
    max-width: 400px;
    margin-top: 1rem;
    transform: scaleX(-1); /* mirrors horizontally */
    border: 2px solid #0077cc;
    border-radius: 8px;
  }

  .face-page {
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  video {
    width: 480px;
    border: 2px solid #0077cc;
    border-radius: 8px;
    transform: scaleX(-1); /* mirrors horizontally */
    margin-top: 1rem;
  }

  .preview img {
    max-width: 300px;
    border: 2px solid #0077cc;
    border-radius: 8px;
    margin-top: 10px;
  }

  button {
    margin: 1rem 0;
    padding: 12px 24px;
    font-size: 1.2rem;
    border-radius: 8px;
    border: none;
    background: #0077cc;
    color: white;
    cursor: pointer;
  }
  .login-result {
    margin-top: 20px;
    display: flex;
    align-items: center;
    gap: 12px;
    background: rgba(255,255,255,0.9);
    padding: 15px;
    border-radius: 10px;
    border: 2px solid green;
  }

  .login-result img {
    width: 80px;
    height: 80px;
    border-radius: 8px;
    object-fit: cover;
    border: 3px solid #ccc;
  }

  .login-message {
    font-size: 1.5rem;
    font-weight: bold;
  }

  video {
    width: 100%;
    max-width: 480px;
    border-radius: 8px;
  }
  .live-video {
    width: 320px;      /* or whatever size you want */
    border: 2px solid #000;
    border-radius: 8px;
  }

  .settings-auth, .settings-page {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    width: 100%;
    max-width: 400px;
    background: #fff;
    padding: 2rem;
    border-radius: 10px;
    box-shadow: 0 0 10px rgba(0,0,0,0.1);
    margin-top: 2rem;
  }
  .settings-auth input {
    width: 100%;
    padding: 10px;
    margin: 8px 0;
    font-size: 1rem;
  }
  .settings-page input {
    width: 100%;
    padding: 10px;
    font-size: 1rem;
    margin-top: 0.5rem;
  }
  .settings-page label {
    width: 100%;
    font-size: 1.1rem;
    margin-bottom: 1rem;
  }
  .settings-btn {
    position: absolute;
    bottom: 200px; 
    right: 30px;        
    width: 50px;
    height: 50px;
    font-size: 1.6rem;
    border: none;
    border-radius: 50%;
    background-color: #444;
    color: white;
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
  .settings-btn:hover {
    background-color: #222;
    transform: rotate(30deg);
  }
  .gear {
    display: inline-block;
    transform: translate(1px, 0px);
  }
</style>
