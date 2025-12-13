import fs from 'fs';
import path from 'path';
import * as faceapi from 'face-api.js';
import * as canvasPkg from 'canvas';
import { updateAttendanceRecord } from '../../../services/attendanceService.js';
import { executeQuery } from '../../../services/database.js';

const { Canvas, Image, ImageData } = canvasPkg;
// @ts-ignore
faceapi.env.monkeyPatch({ Canvas, Image, ImageData });

const PROJECT_ROOT = path.resolve(process.cwd());
const FACE_DIR = path.join(PROJECT_ROOT, 'static', 'face');
const DESC_DIR = path.join(PROJECT_ROOT, 'static', 'descriptors');
// Load models from the static assets directory so both client and server use the same files
const MODEL_PATH = path.join(PROJECT_ROOT, 'static', 'models');
const LOGS_FILE = path.join(PROJECT_ROOT, 'logs.txt');

if (!fs.existsSync(FACE_DIR)) fs.mkdirSync(FACE_DIR, { recursive: true });
if (!fs.existsSync(DESC_DIR)) fs.mkdirSync(DESC_DIR, { recursive: true });
if (!fs.existsSync(MODEL_PATH)) fs.mkdirSync(MODEL_PATH, { recursive: true });

// ============================================================================
// 🚀 FIX: No-cache headers to prevent stale responses
// ============================================================================
const NO_CACHE_HEADERS = {
  'Content-Type': 'application/json',
  'Cache-Control': 'no-store, no-cache, must-revalidate, max-age=0',
  'Pragma': 'no-cache',
  'Expires': '0'
};

// ============================================================================
// 🚀 PERFORMANCE OPTIMIZATION: In-memory descriptor cache
// ============================================================================
let descriptorCache = new Map(); // Map<studentId, {descriptors, metadata}>
let descriptorCacheLoadedAt = 0;
const DESCRIPTOR_CACHE_TTL = 5 * 60 * 1000; // 5 minutes cache TTL
let isLoadingDescriptorCache = false;

/**
 * Preload all student descriptors into memory cache
 * Eliminates per-request file I/O which is the main bottleneck
 */
async function preloadDescriptorCache() {
  if (isLoadingDescriptorCache) return;
  isLoadingDescriptorCache = true;
  
  const startTime = Date.now();
  try {
    const descFiles = fs.readdirSync(DESC_DIR).filter(f => f.endsWith('.json'));
    const newCache = new Map();
    
    for (const descFile of descFiles) {
      const studentId = descFile.replace('.json', '');
      const filePath = path.join(DESC_DIR, descFile);
      const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
      const descriptors = Array.isArray(data) ? data : data.descriptors;
      
      if (Array.isArray(descriptors)) {
        // Pre-convert descriptors to Float32Arrays for faster euclidean distance
        const optimizedDescriptors = descriptors.map(desc => {
          const arr = Array.isArray(desc) ? desc : Object.values(desc);
          return new Float32Array(arr);
        });
        
        newCache.set(studentId, {
          descriptors: optimizedDescriptors,
          firstName: data.firstName || '',
          lastName: data.surname || ''
        });
      }
    }
    
    descriptorCache = newCache;
    descriptorCacheLoadedAt = Date.now();
    console.log(`🚀 Descriptor cache loaded: ${newCache.size} students in ${Date.now() - startTime}ms`);
  } catch (error) {
    console.error('⚠️ Failed to preload descriptor cache:', error.message);
  } finally {
    isLoadingDescriptorCache = false;
  }
}

/**
 * Get cached descriptors, reloading if stale or empty
 */
async function getCachedDescriptors() {
  const now = Date.now();
  if (descriptorCache.size === 0 || (now - descriptorCacheLoadedAt) > DESCRIPTOR_CACHE_TTL) {
    await preloadDescriptorCache();
  }
  return descriptorCache;
}

/**
 * Add or update a student in the cache (call after registration)
 */
function updateStudentInCache(studentId, descriptors, firstName, lastName) {
  const optimizedDescriptors = descriptors.map(desc => {
    const arr = Array.isArray(desc) ? desc : Object.values(desc);
    return new Float32Array(arr);
  });
  descriptorCache.set(studentId, { descriptors: optimizedDescriptors, firstName, lastName });
  console.log(`🔄 Cache updated for student: ${studentId}`);
}

/**
 * Force full cache reload
 */
function invalidateDescriptorCache() {
  descriptorCache.clear();
  descriptorCacheLoadedAt = 0;
  console.log(`🔄 Descriptor cache invalidated`);
}

// ============================================================================
// 🚀 PERFORMANCE OPTIMIZATION: Schedule cache
// ============================================================================
let scheduleCache = new Map(); // Map<cacheKey, {schedules, loadedAt}>
const SCHEDULE_CACHE_TTL = 2 * 60 * 1000; // 2 minutes TTL

/**
 * Get cached schedule for a room on current day for a specific student
 */
async function getCachedScheduleForStudent(roomId, studentId) {
  const now = new Date();
  const dayOfWeek = now.getDay(); // 0=Sun, 1=Mon, ...
  const cacheKey = `room_${roomId}_day_${dayOfWeek}`;
  
  let roomSchedules = scheduleCache.get(cacheKey);
  
  // Check if cache is valid
  if (!roomSchedules || (Date.now() - roomSchedules.loadedAt) > SCHEDULE_CACHE_TTL) {
    // Cache miss or stale - reload schedules for this room/day
    const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    const dayColumn = dayNames[dayOfWeek];
    const startColumn = `${dayColumn}Start`;
    const endColumn = `${dayColumn}End`;
    
    // Simplified query - get all active schedules for this room today
    const query = `
      SELECT ss.SubjectID, ss.SectionID, ss.TeacherID, s.subject_name,
             se.StudentID,
             ss.${startColumn} AS StartTime,
             ss.${endColumn} AS EndTime
      FROM section_subjects ss
      JOIN subject_enrollments se ON ss.SectionID = se.SectionID AND ss.SubjectID = se.SubjectID
      JOIN subjects s ON ss.SubjectID = s.SubjectID
      WHERE ss.RoomID = ?
        AND se.Status = 'Active'
        AND ss.${dayColumn} = 1
    `;
    
    const schedules = await executeQuery(query, [roomId]);
    roomSchedules = { schedules, loadedAt: Date.now() };
    scheduleCache.set(cacheKey, roomSchedules);
    console.log(`🚀 Schedule cache loaded for room ${roomId}, day ${dayColumn}: ${schedules.length} entries`);
  }
  
  // Filter for this student and current time
  const currentTime = `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}:${String(now.getSeconds()).padStart(2, '0')}`;
  
  return roomSchedules.schedules.filter(s => {
    if (s.StudentID !== studentId) return false;
    if (!s.StartTime || !s.EndTime) return false;
    return currentTime >= s.StartTime && currentTime <= s.EndTime;
  });
}

// Preload caches on module load (server startup)
console.log('🚀 Starting performance optimizations...');
preloadDescriptorCache().catch(err => console.error('Descriptor preload failed:', err));

// ============================================================================
// 🚀 PERFORMANCE OPTIMIZATION: Per-device request deduplication
// Prevents multiple simultaneous recognition requests from the same device
// ============================================================================
const pendingRecognitions = new Map(); // Map<deviceSessionId, boolean>
const RECOGNITION_TIMEOUT = 10000; // 10 second timeout to auto-clear stuck requests

// ============================================================================
// 🚀 FIX: Per-student cooldown to prevent duplicate attendance (but allow different students)
// ============================================================================
const studentCooldowns = new Map(); // Map<studentId, timestamp>
const STUDENT_COOLDOWN_MS = 1500; // 1.5 seconds - same student can't trigger again this fast

/**
 * Log attendance record to logs.txt (async, non-blocking)
 * @param {Object} record - Attendance record data
 * @param {string} action - 'INSERT' or 'UPDATE'
 */
function logAttendanceRecord(record, action = 'INSERT') {
  try {
    const { id, student_id, subject_id, class_subject_id, section_id, attendance_date, login_time, status, recorded_by, recorded_at } = record;
    
    // Format the log entry (tab-separated)
    const logEntry = `${id || ''}\t${student_id}\t${subject_id}\t${class_subject_id || ''}\t${section_id}\t${attendance_date}\t${login_time || ''}\t${status || ''}\t${recorded_by}\t${recorded_at}\n`;
    
    // 🚀 OPTIMIZATION: Use async append instead of blocking read+write
    fs.appendFile(LOGS_FILE, logEntry, (err) => {
      if (err) console.error('⚠️ Failed to write to logs.txt:', err.message);
      else console.log(`📝 [${action}] Logged attendance for student ${student_id}`);
    });
  } catch (error) {
    console.error('⚠️ Failed to write to logs.txt:', error.message);
  }
}

let modelsLoaded = false;
let modelsLoading = false;

async function ensureModelsLoaded() {
  if (modelsLoaded) return;
  if (modelsLoading) {
    // Wait for loading to complete if already in progress
    while (modelsLoading) {
      await new Promise(resolve => setTimeout(resolve, 100));
    }
    return;
  }
  
  modelsLoading = true;
  const startTime = Date.now();
  try {
    // 🚀 TURBO: Load TinyFaceDetector for fast login + MTCNN for accurate registration
    await Promise.all([
      faceapi.nets.tinyFaceDetector.loadFromDisk(MODEL_PATH),  // Fast detection for login
      faceapi.nets.mtcnn.loadFromDisk(MODEL_PATH),              // Accurate detection for registration
      faceapi.nets.faceLandmark68Net.loadFromDisk(MODEL_PATH),
      faceapi.nets.faceRecognitionNet.loadFromDisk(MODEL_PATH),
    ]);
    console.log(`✅ TURBO: TinyFace + MTCNN + Landmarks + Recognition models loaded in ${Date.now() - startTime}ms`);
    modelsLoaded = true;
  } finally {
    modelsLoading = false;
  }
}

// 🚀 TinyFaceDetector options - FAST for login recognition (5-10x faster than MTCNN)
const tinyFaceOptions = new faceapi.TinyFaceDetectorOptions({
  inputSize: 416,       // 416 for better accuracy on server (can handle larger images)
  scoreThreshold: 0.5
});

// 🚀 Preload models at server startup
ensureModelsLoaded().catch(err => console.error('Model preload failed:', err));

function bufferFromBase64(base64) {
  return Buffer.from(base64.replace(/^data:image\/\w+;base64,/, ''), 'base64');
}

function imageFromBase64(base64) {
  return new Promise((resolve, reject) => {
    const img = new Image();
    img.onload = () => resolve(img);
    img.onerror = (err) => reject(err);

    // Ensure proper data URI
    const dataUri = base64.startsWith('data:image') ? base64 : `data:image/png;base64,${base64}`;
    img.src = dataUri;
  });
}

// MTCNN options - good for various face sizes
const mtcnnOptions = new faceapi.MtcnnOptions({
  minFaceSize: 20,  // Very low threshold for profile/side face detection
  scaleFactor: 0.709
});

// Standard face crop size for consistent descriptor extraction
const FACE_CROP_SIZE = 160;
const FACE_PADDING = 0.3; // 30% padding around detected face

/**
 * Crop face from image based on detection - SIMPLE SQUARE CROP
 * No rotation to avoid distortion, just extracts face region with padding
 * @param {Image} img - Source image
 * @param {Object} detection - face-api.js detection result
 * @returns {Canvas} - Cropped face canvas (square, no distortion)
 */
function cropAlignedFace(img, detection) {
  const box = detection.detection.box;
  
  // Make it square using the larger dimension
  const size = Math.max(box.width, box.height);
  const paddedSize = size * (1 + FACE_PADDING);
  
  // Calculate crop region centered on face
  const centerX = box.x + box.width / 2;
  const centerY = box.y + box.height / 2;
  
  // Source coordinates (with bounds checking)
  let srcX = Math.max(0, centerX - paddedSize / 2);
  let srcY = Math.max(0, centerY - paddedSize / 2);
  let srcW = paddedSize;
  let srcH = paddedSize;
  
  // Adjust if crop goes outside image bounds
  if (srcX + srcW > img.width) srcW = img.width - srcX;
  if (srcY + srcH > img.height) srcH = img.height - srcY;
  
  // Create output canvas (square)
  const canvas = new Canvas(FACE_CROP_SIZE, FACE_CROP_SIZE);
  const ctx = canvas.getContext('2d');
  
  // Fill with neutral gray (for any empty areas)
  ctx.fillStyle = '#808080';
  ctx.fillRect(0, 0, FACE_CROP_SIZE, FACE_CROP_SIZE);
  
  // Draw cropped face - maintain aspect ratio by using same scale for both dimensions
  const scale = FACE_CROP_SIZE / paddedSize;
  const destW = srcW * scale;
  const destH = srcH * scale;
  const destX = (FACE_CROP_SIZE - destW) / 2;
  const destY = (FACE_CROP_SIZE - destH) / 2;
  
  ctx.drawImage(img, srcX, srcY, srcW, srcH, destX, destY, destW, destH);
  
  return canvas;
}

/**
 * Extract descriptor from a cropped face image
 * @param {Canvas} croppedFace - Cropped face canvas
 * @returns {Float32Array} - Face descriptor
 */
async function extractDescriptorFromCrop(croppedFace) {
  // Detect face in cropped image and get descriptor
  const detection = await faceapi
    .detectSingleFace(croppedFace, mtcnnOptions)
    .withFaceLandmarks()
    .withFaceDescriptor();
  
  if (!detection) {
    return null;
  }
  
  return detection.descriptor;
}

/**
 * Simple face crop without rotation (faster, for login recognition)
 * @param {Image} img - Source image
 * @param {Object} box - Bounding box {x, y, width, height}
 * @returns {Canvas} - Cropped face canvas
 */
function simpleFaceCrop(img, box) {
  // Add padding
  const padX = box.width * FACE_PADDING;
  const padY = box.height * FACE_PADDING;
  
  const x = Math.max(0, box.x - padX);
  const y = Math.max(0, box.y - padY);
  const w = Math.min(img.width - x, box.width + 2 * padX);
  const h = Math.min(img.height - y, box.height + 2 * padY);
  
  const canvas = new Canvas(FACE_CROP_SIZE, FACE_CROP_SIZE);
  const ctx = canvas.getContext('2d');
  
  // Fill with neutral gray
  ctx.fillStyle = '#808080';
  ctx.fillRect(0, 0, FACE_CROP_SIZE, FACE_CROP_SIZE);
  
  // Draw cropped face scaled to standard size
  ctx.drawImage(img, x, y, w, h, 0, 0, FACE_CROP_SIZE, FACE_CROP_SIZE);
  
  return canvas;
}

/**
 * Pre-process image for better face detection
 * Applies contrast enhancement and normalization
 * @param {Image} img - Source image
 * @returns {Canvas} - Pre-processed canvas
 */
function preprocessImage(img) {
  const canvas = new Canvas(img.width, img.height);
  const ctx = canvas.getContext('2d');
  
  // Draw original image
  ctx.drawImage(img, 0, 0);
  
  // Get image data for processing
  const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
  const data = imageData.data;
  
  // Calculate histogram for contrast enhancement
  let minVal = 255, maxVal = 0;
  for (let i = 0; i < data.length; i += 4) {
    const gray = (data[i] + data[i + 1] + data[i + 2]) / 3;
    if (gray < minVal) minVal = gray;
    if (gray > maxVal) maxVal = gray;
  }
  
  // Apply contrast stretching (histogram equalization lite)
  const range = maxVal - minVal || 1;
  for (let i = 0; i < data.length; i += 4) {
    data[i] = ((data[i] - minVal) / range) * 255;     // R
    data[i + 1] = ((data[i + 1] - minVal) / range) * 255; // G
    data[i + 2] = ((data[i + 2] - minVal) / range) * 255; // B
    // Alpha unchanged
  }
  
  ctx.putImageData(imageData, 0, 0);
  return canvas;
}

export async function handleCheckFace(request) {
  await ensureModelsLoaded();
  try {
    const { image } = await request.json();
    if (!image) return new Response(JSON.stringify({ orientation: 'none', detected: false }), { status: 200, headers: { 'Content-Type': 'application/json' } });

    const img = await imageFromBase64(image);
    
    // Pre-process image for better detection
    const processedImg = preprocessImage(img);
    
    // Try detection on pre-processed image first
    let detection = await faceapi
      .detectSingleFace(processedImg, mtcnnOptions)
      .withFaceLandmarks()
      .withFaceDescriptor();

    // If pre-processed detection fails, try original image
    if (!detection) {
      detection = await faceapi
        .detectSingleFace(img, mtcnnOptions)
        .withFaceLandmarks()
        .withFaceDescriptor();
    }

    if (!detection) {
      return new Response(JSON.stringify({ 
        orientation: 'none', 
        detected: false 
      }), { status: 200, headers: { 'Content-Type': 'application/json' } });
    }

    const { landmarks } = detection;
    const nose = landmarks.getNose()[3];
    const leftEye = landmarks.getLeftEye()[0];
    const rightEye = landmarks.getRightEye()[3];

    const eyeDiff = rightEye.x - leftEye.x;
    const noseOffset = nose.x - (leftEye.x + eyeDiff / 2);

    let orientation = 'front';
    if (noseOffset > 15) orientation = 'left';
    if (noseOffset < -15) orientation = 'right';

    return new Response(JSON.stringify({ 
      orientation,
      detected: true,
      confidence: detection.detection.score
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    });
  } catch (err) {
    console.error(err);
    return new Response(JSON.stringify({ orientation: 'none', detected: false }), { status: 200, headers: { 'Content-Type': 'application/json' } });
  }
}

export async function handleRegister(request) {
  await ensureModelsLoaded();
  try {
    const { firstName, middleInitial, surname, studentId, images } = await request.json();
    
    if (!firstName || !surname || !studentId || !images) {
      return new Response(JSON.stringify({ message: '❌ Missing required fields' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    // Check if student ID is valid (e.g., exists in the database)
    const studentRecord = await executeQuery('SELECT * FROM students WHERE StudentID = ?', [studentId]);
    if (!studentRecord || studentRecord.length === 0) {
      return new Response(JSON.stringify({ message: '❌ Invalid student ID - student not found in database' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    // Check if already registered
    const descFile = path.join(DESC_DIR, `${studentId}.json`);
    if (fs.existsSync(descFile)) {
      return new Response(JSON.stringify({ message: '❌ Student already registered' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    // ========== PHASE 1: SAVE ALL IMAGES FIRST ==========
    console.log(`\n🔵 PHASE 1: Saving ${studentId}'s images...`);
    const savedImagePaths = [];
    
    for (let i = 1; i <= 3; i++) {
      const imageData = images[`pic${i}`];
      
      console.log(`📷 Image ${i}: received ${imageData ? imageData.length : 0} bytes`);
      
      if (!imageData || imageData.length < 100) {
        console.warn(`⚠️ Image ${i} is empty or too small, skipping`);
        continue;
      }
      
      const img = await imageFromBase64(imageData);
      console.log(`📐 Image ${i} loaded: ${img.width}x${img.height}`);
      
      // Save the original image
      const imgCanvas = new Canvas(img.width, img.height);
      const ctx = imgCanvas.getContext('2d');
      ctx.drawImage(img, 0, 0);
      const imgBuffer = imgCanvas.toBuffer('image/png');
      const imagePath = path.join(FACE_DIR, `${studentId}_pic${i}.png`);
      fs.writeFileSync(imagePath, imgBuffer);
      savedImagePaths.push({ index: i, path: imagePath });
      console.log(`💾 Saved original image: ${studentId}_pic${i}.png`);
    }
    
    if (savedImagePaths.length === 0) {
      return new Response(JSON.stringify({ message: '❌ No valid images received' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      });
    }
    
    console.log(`✅ Phase 1 complete: ${savedImagePaths.length} images saved\n`);

    // ========== PHASE 2: LOAD SAVED IMAGES, CROP FACES, EXTRACT DESCRIPTORS ==========
    console.log(`🟢 PHASE 2: Processing saved images for ${studentId}...`);
    const descriptors = [];
    
    for (const { index, path: imagePath } of savedImagePaths) {
      console.log(`\n🔍 Processing saved image ${index}...`);
      
      // Load the saved image from disk
      const imageBuffer = fs.readFileSync(imagePath);
      const img = await new Promise((resolve, reject) => {
        const image = new Image();
        image.onload = () => resolve(image);
        image.onerror = reject;
        image.src = imageBuffer;
      });
      
      // Pre-process image for better detection
      const processedImg = preprocessImage(img);
      
      // Try detection on pre-processed image first
      let detection = await faceapi
        .detectSingleFace(processedImg, mtcnnOptions)
        .withFaceLandmarks()
        .withFaceDescriptor();

      // If pre-processed detection fails, try original image
      if (!detection) {
        console.log(`🔄 Pre-processed detection failed, trying original...`);
        detection = await faceapi
          .detectSingleFace(img, mtcnnOptions)
          .withFaceLandmarks()
          .withFaceDescriptor();
      }

      if (!detection) {
        console.warn(`⚠️ No face detected in saved image ${index}`);
        continue;
      }
      
      console.log(`✅ Face detected in image ${index}, confidence: ${detection.detection.score.toFixed(3)}`);
      
      // 🎯 CROP THE FACE - this removes background for better accuracy
      const croppedFace = cropAlignedFace(img, detection);
      
      // Save the cropped face image for reference
      const croppedBuffer = croppedFace.toBuffer('image/png');
      const croppedPath = path.join(FACE_DIR, `${studentId}_pic${index}_cropped.png`);
      fs.writeFileSync(croppedPath, croppedBuffer);
      console.log(`💾 Saved cropped face: ${studentId}_pic${index}_cropped.png (${FACE_CROP_SIZE}x${FACE_CROP_SIZE})`);
      
      // Extract descriptor from the CROPPED face (no background interference)
      const croppedDescriptor = await extractDescriptorFromCrop(croppedFace);
      
      if (croppedDescriptor) {
        descriptors.push(Array.from(croppedDescriptor));
        console.log(`✅ Image ${index}: Cropped face descriptor extracted (high accuracy)`);
      } else {
        // Fallback to original detection descriptor
        descriptors.push(Array.from(detection.descriptor));
        console.log(`⚠️ Image ${index}: Using original descriptor (fallback)`);
      }
    }

    if (descriptors.length === 0) {
      return new Response(JSON.stringify({ message: '❌ No faces detected in any saved image' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      });
    }
    
    console.log(`\n✅ Phase 2 complete: ${descriptors.length} descriptors extracted from cropped faces`);

    // Save descriptors with student info
    const descriptorData = {
      studentId,
      firstName,
      middleInitial,
      surname,
      descriptors,
      registeredAt: new Date().toISOString(),
      imageCount: savedImagePaths.length,
      descriptorCount: descriptors.length
    };
    fs.writeFileSync(descFile, JSON.stringify(descriptorData, null, 2));
    
    // 🚀 OPTIMIZATION: Update cache immediately after registration
    updateStudentInCache(studentId, descriptors, firstName, surname);
    
    console.log(`🎉 Registration complete for ${studentId}: ${descriptors.length} face descriptors saved\n`);
    
    return new Response(JSON.stringify({ 
      message: `✅ Registration successful! ${descriptors.length} face descriptors saved.` 
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    });
  } catch (err) {
    console.error('Registration error:', err);
    return new Response(JSON.stringify({ message: '❌ Registration failed: ' + err.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
}

export async function handleLoginRecognize(request) {
  const requestStartTime = Date.now();
  await ensureModelsLoaded();
  
  try {
    const { image, roomId, deviceSessionId } = await request.json();
    
    // 🔧 DEBUG: Log incoming request info
    console.log(`📡 Recognition request from device: ${deviceSessionId || 'unknown'}, roomId: ${roomId}`);
    
    // 🚀 GUARD: Check if this device already has a pending recognition request
    const deviceKey = deviceSessionId || `room_${roomId}`;
    if (pendingRecognitions.get(deviceKey)) {
      console.log(`⏳ Recognition already pending for device ${deviceKey}, skipping...`);
      return new Response(JSON.stringify({ 
        message: '⏳ Processing previous request...',
        skipped: true 
      }), {
        status: 200,
        headers: NO_CACHE_HEADERS
      });
    }
    
    // Mark this device as having a pending request
    pendingRecognitions.set(deviceKey, true);
    
    // Safety timeout to auto-clear stuck requests
    const timeoutId = setTimeout(() => {
      if (pendingRecognitions.get(deviceKey)) {
        console.log(`⚠️ Recognition timeout for device ${deviceKey}, clearing...`);
        pendingRecognitions.delete(deviceKey);
      }
    }, RECOGNITION_TIMEOUT);
    
    // Wrap the rest in try-finally to ensure we clear the pending flag
    try {
    
      if (!image) {
        return new Response(JSON.stringify({ message: '❌ No image provided' }), {
          status: 400,
          headers: NO_CACHE_HEADERS
        });
      }
      
      if (!roomId) {
        return new Response(JSON.stringify({ message: '❌ Room not configured' }), {
          status: 400,
          headers: NO_CACHE_HEADERS
        });
      }

    const imgDecodeStart = Date.now();
    const img = await imageFromBase64(image);
    console.log(`⏱️ Image decode: ${Date.now() - imgDecodeStart}ms`);
    
    // 🚀 TURBO: Use TinyFaceDetector for FAST login detection (5-10x faster than MTCNN)
    const detectionStart = Date.now();
    const detection = await faceapi
      .detectSingleFace(img, tinyFaceOptions)
      .withFaceLandmarks()
      .withFaceDescriptor();
    console.log(`⏱️ TURBO Face detection: ${Date.now() - detectionStart}ms`);
    
    if (!detection) {
      return new Response(JSON.stringify({ message: '❌ No face detected' }), {
        status: 200,
        headers: NO_CACHE_HEADERS
      });
    }
    
    console.log(`🔍 Login: Face detected with confidence ${detection.detection.score.toFixed(3)}`);
    
    // 🎯 CROP THE FACE for better matching accuracy (same as registration)
    const croppedFace = cropAlignedFace(img, detection);
    const croppedDescriptor = await extractDescriptorFromCrop(croppedFace);
    
    // Use cropped descriptor if available, fallback to original
    const queryDescriptor = croppedDescriptor || detection.descriptor;
    console.log(`🔍 Login: Using ${croppedDescriptor ? 'cropped face' : 'original'} descriptor for matching`);
    
    /**
     * 🔥 TURBO: Fast squared distance (no sqrt needed for comparison)
     */
    function fastDistance(a, b) {
      let sum = 0;
      for (let i = 0; i < a.length; i++) {
        const d = a[i] - b[i];
        sum += d * d;
      }
      return sum; // squared distance
    }

    /**
     * 🔥 TURBO: Quick reject using first 8 dimensions only
     * If partial distance already exceeds bestSoFar, reject immediately
     */
    function quickReject(a, b, bestSoFar) {
      let s = 0;
      for (let i = 0; i < 8; i++) {
        const d = a[i] - b[i];
        s += d * d;
        if (s > bestSoFar) return true; // reject student immediately
      }
      return false;
    }

    /**
     * 🔥 TURBO: Full distance with early exit
     */
    function fastDistanceEarly(a, b, threshold) {
      let sum = 0;
      for (let i = 0; i < a.length; i++) {
        const d = a[i] - b[i];
        sum += d * d;
        if (sum > threshold) return Infinity; // early exit if already worse than best
      }
      return sum;
    }

    let bestMatch = null;
    let bestDistance = Infinity;

    // 🚀 TURBO: Use cached descriptors + fast distance functions
    const matchingStart = Date.now();
    const cachedDescriptors = await getCachedDescriptors();
    
    for (const [studentId, studentData] of cachedDescriptors) {
      let studentMin = Infinity;
      
      for (const desc of studentData.descriptors) {
        // 🔥 Quick reject using first 8 dimensions
        if (quickReject(queryDescriptor, desc, studentMin)) continue;
        
        // 🔥 Full distance with early exit
        const dist = fastDistanceEarly(queryDescriptor, desc, studentMin);
        
        if (dist < studentMin) {
          studentMin = dist;
          if (dist < bestDistance) {
            bestDistance = dist;
            bestMatch = studentId;
          }
        }
      }
    }
    
    console.log(`⚡ TURBO matching (${cachedDescriptors.size} students): ${Date.now() - matchingStart}ms`);

    console.log('✅ Recognition bestMatch:', bestMatch, 'bestDistance:', bestDistance);

    if (bestMatch && bestDistance < 0.25) { // Threshold for match (tuned lower)
      
      // 🚀 FIX: Check per-student cooldown to prevent duplicate attendance
      const now = Date.now();
      const lastSeen = studentCooldowns.get(bestMatch);
      if (lastSeen && (now - lastSeen) < STUDENT_COOLDOWN_MS) {
        const timeLeft = Math.ceil((STUDENT_COOLDOWN_MS - (now - lastSeen)) / 1000);
        console.log(`⏳ Student ${bestMatch} in cooldown (${timeLeft}s left), skipping duplicate`);
        return new Response(JSON.stringify({ 
          message: `⏳ Please wait ${timeLeft}s before scanning again`,
          skipped: true,
          cooldown: true
        }), {
          status: 200,
          headers: NO_CACHE_HEADERS
        });
      }
      
      // Update cooldown for this student
      studentCooldowns.set(bestMatch, now);
      // Auto-cleanup old cooldowns after 5 minutes
      setTimeout(() => studentCooldowns.delete(bestMatch), 5 * 60 * 1000);
      
      // Get student name from database or cache
      let studentName = bestMatch; // fallback to ID if name lookup fails
      const cachedStudent = descriptorCache.get(bestMatch);
      if (cachedStudent && cachedStudent.firstName) {
        studentName = `${cachedStudent.firstName} ${cachedStudent.lastName}`.trim();
      }
      if (studentName === bestMatch) {
        // Fallback to database if not in cache
        try {
          const studentRecord = await executeQuery('SELECT FirstName, LastName FROM students WHERE StudentID = ?', [bestMatch]);
          if (studentRecord && studentRecord.length > 0) {
            studentName = `${studentRecord[0].FirstName} ${studentRecord[0].LastName}`;
          }
        } catch (nameError) {
          console.error('Error fetching student name:', nameError);
        }
      }

      let subjectName = 'Unknown Subject'; // Default value
      let attendanceRecorded = false;

      // Record attendance automatically when student is recognized
      try {
        // 🚀 OPTIMIZATION: Use cached schedule instead of complex query
        const scheduleStart = Date.now();
        const scheduleResults = await getCachedScheduleForStudent(roomId, bestMatch);
        console.log(`⏱️ Schedule lookup: ${Date.now() - scheduleStart}ms`);
        
        console.log("hello bestMatch: =>", bestMatch);
        console.log("hello roomId: =>", roomId);
        console.log('📅 Schedule query result:', scheduleResults);
        
        if (scheduleResults.length === 0) {
          console.log(`⏱️ Total request time: ${Date.now() - requestStartTime}ms`);
          return new Response(JSON.stringify({ 
            message: `⚠️ No class scheduled for ${studentName} in this room at current time`,
            studentId: bestMatch,
            timing: Date.now() - requestStartTime
          }), {
            status: 200,
            headers: NO_CACHE_HEADERS
          });
        }
        
        const { SubjectID, SectionID, TeacherID, subject_name, StartTime } = scheduleResults[0];
        subjectName = subject_name; // Update the variable
        
        console.log(`📚 Auto-detected: ${subject_name} (Subject ID: ${SubjectID}, Section: ${SectionID})`);
        
        // Record attendance with the auto-detected subject and start time
        await recordAttendance(bestMatch, SubjectID, SectionID, TeacherID, StartTime);
        attendanceRecorded = true;
        console.log(`✅ Attendance recorded successfully for ${studentName}`);
        console.log(`⏱️ Total request time: ${Date.now() - requestStartTime}ms`);
      } catch (attendanceError) {
        console.error('Attendance recording error:', attendanceError);
        // Continue with recognition but note that attendance wasn't recorded
        return new Response(JSON.stringify({ 
          message: `⚠️ ${studentName} recognized but attendance recording failed: ${attendanceError.message}`,
          studentId: bestMatch,
          subjectName: subjectName,
          imageUrl: `/attendance-login/api/face/${bestMatch}_pic1.png`,
          error: 'attendance_failed',
          timing: Date.now() - requestStartTime
        }), {
          status: 200,
          headers: NO_CACHE_HEADERS
        });
      }

        
        return new Response(JSON.stringify({ 
          message: `✅ Welcome, ${studentName}! Marked present for ${subjectName}`,
          studentId: bestMatch,
          subjectName: subjectName,
          imageUrl: `/attendance-login/api/face/${bestMatch}_pic1.png`,
          attendanceRecorded: attendanceRecorded
        }), {
          status: 200,
          headers: NO_CACHE_HEADERS
        });
    } else {
      return new Response(JSON.stringify({ message: '🚫 Stranger detected' }), {
        status: 200,
        headers: NO_CACHE_HEADERS
      });
    }
    
    } finally {
      // 🚀 GUARD: Always clear the pending flag when done
      clearTimeout(timeoutId);
      pendingRecognitions.delete(deviceKey);
      console.log(`✅ Cleared pending flag for device ${deviceKey}`);
    }
    
  } catch (err) {
    console.error('Recognition error:', err);
    return new Response(JSON.stringify({ message: '❌ Recognition failed' }), {
      status: 500,
      headers: NO_CACHE_HEADERS
    });
  }
}

/**
 * Record attendance for a recognized student with login time
 * @param {string} studentId - The recognized student ID
 * @param {number|string} subjectId - The subject ID
 * @param {number|string} sectionId - The section ID
 * @param {number|string} teacherId - The teacher ID (recorded_by)
 * @param {string} startTime - Class start time (HH:MM:SS)
 */
export async function recordAttendance(studentId, subjectId, sectionId, teacherId, startTime) {
  try {
    // Ensure IDs are numbers
    const subId = Number(subjectId);
    const secId = Number(sectionId);
    const teachId = Number(teacherId) || 1; // default to 1 if not provided

    if (isNaN(subId) || isNaN(secId)) {
      throw new Error(`Invalid numeric value for subjectId or sectionId: ${subjectId}, ${sectionId}`);
    }

    // Get current time in HH:MM:SS format
    const now = new Date();
    
    // Get today's date in YYYY-MM-DD format (Local time, not UTC)
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');
    const today = `${year}-${month}-${day}`;
    
    const loginTime = `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}:${String(now.getSeconds()).padStart(2, '0')}`;

    // Calculate if student is late (more than 15 minutes after start time)
    let status = 'Present';
    if (startTime) {
      // Parse times
      const [startHour, startMin] = startTime.split(':').map(Number);
      const [loginHour, loginMin] = loginTime.split(':').map(Number);
      
      // Convert to minutes since midnight
      const startMinutes = startHour * 60 + startMin;
      const loginMinutes = loginHour * 60 + loginMin;
      
      // Calculate difference in minutes
      const minutesLate = loginMinutes - startMinutes;
      
      // If more than 15 minutes late, mark as Late (if supported) or Present with note
      if (minutesLate > 15) {
        status = 'Late'; // Note: Requires database migration to add 'Late' to ENUM
        console.log(`⏰ Student is ${minutesLate} minutes late`);
      }
    }

    // Insert or update attendance record with login_time and status
    const query = `
      INSERT INTO attendance_records 
      (student_id, subject_id, section_id, attendance_date, login_time, status, recorded_by)
      VALUES (?, ?, ?, ?, ?, ?, ?)
      ON DUPLICATE KEY UPDATE 
        login_time = VALUES(login_time),
        status = VALUES(status),
        recorded_at = CURRENT_TIMESTAMP
    `;

    const result = await executeQuery(query, [studentId, subId, secId, today, loginTime, status, teachId]);
    
    // Determine if it was INSERT or UPDATE based on affectedRows
    // affectedRows = 1 means INSERT, affectedRows = 2 means UPDATE (with ON DUPLICATE KEY)
    const action = result.affectedRows === 1 ? 'INSERT' : 'UPDATE';
    
    // Get the record ID (insertId for new records, or query for updated records)
    let recordId = result.insertId;
    if (!recordId || recordId === 0) {
      // It was an update, fetch the existing record ID
      const existingRecord = await executeQuery(
        `SELECT id FROM attendance_records WHERE student_id = ? AND subject_id = ? AND section_id = ? AND attendance_date = ?`,
        [studentId, subId, secId, today]
      );
      if (existingRecord.length > 0) {
        recordId = existingRecord[0].id;
      }
    }
    
    // Log to logs.txt
    const nowTimestamp = new Date().toISOString().replace('T', ' ').substring(0, 19);
    logAttendanceRecord({
      id: recordId,
      student_id: studentId,
      subject_id: subId,
      class_subject_id: null,
      section_id: secId,
      attendance_date: today,
      login_time: loginTime,
      status: status,
      recorded_by: teachId,
      recorded_at: nowTimestamp
    }, action);

    console.log(`✅ Attendance recorded for student ${studentId} at ${loginTime} - Status: ${status}`);
    return { success: true, loginTime, status };
  } catch (error) {
    console.error('⚠️ Failed to record attendance:', error.message);
    throw error;
  }
}
