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
const MODEL_PATH = path.join(PROJECT_ROOT, 'models');

if (!fs.existsSync(FACE_DIR)) fs.mkdirSync(FACE_DIR, { recursive: true });
if (!fs.existsSync(DESC_DIR)) fs.mkdirSync(DESC_DIR, { recursive: true });
if (!fs.existsSync(MODEL_PATH)) fs.mkdirSync(MODEL_PATH, { recursive: true });

let modelsLoaded = false;
async function ensureModelsLoaded() {
  if (!modelsLoaded) {
    await Promise.all([
      faceapi.nets.tinyFaceDetector.loadFromDisk(MODEL_PATH),
      faceapi.nets.faceLandmark68Net.loadFromDisk(MODEL_PATH),
      faceapi.nets.faceRecognitionNet.loadFromDisk(MODEL_PATH),
    ]);
    modelsLoaded = true;
  }
}

function bufferFromBase64(base64) {
  return Buffer.from(base64.replace(/^data:image\/\w+;base64,/, ''), 'base64');
}

function imageFromBase64(base64) {
  return new Promise((resolve, reject) => {
    const img = new Image();
    img.onload = () => resolve(img);
    img.onerror = (err) => reject(err);
    img.src = bufferFromBase64(base64);
  });
}

const tinyOptions = new faceapi.TinyFaceDetectorOptions({
  inputSize: 320,
  scoreThreshold: 0.5
});

export async function handleCheckFace(request) {
  await ensureModelsLoaded();
  try {
    const { image } = await request.json();
    if (!image) return new Response(JSON.stringify({ orientation: 'none' }), { status: 200, headers: { 'Content-Type': 'application/json' } });

    const img = await imageFromBase64(image);
    const detection = await faceapi
      .detectSingleFace(img, tinyOptions)
      .withFaceLandmarks();

    if (!detection) return new Response(JSON.stringify({ orientation: 'none' }), { status: 200, headers: { 'Content-Type': 'application/json' } });

    const { landmarks } = detection;
    const nose = landmarks.getNose()[3];
    const leftEye = landmarks.getLeftEye()[0];
    const rightEye = landmarks.getRightEye()[3];

    const eyeDiff = rightEye.x - leftEye.x;
    const noseOffset = nose.x - (leftEye.x + eyeDiff / 2);

    let orientation = 'front';
    if (noseOffset > 15) orientation = 'left';
    if (noseOffset < -15) orientation = 'right';

    return new Response(JSON.stringify({ orientation }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    });
  } catch (err) {
    console.error(err);
    return new Response(JSON.stringify({ orientation: 'none' }), { status: 200, headers: { 'Content-Type': 'application/json' } });
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

    const descriptors = [];
    
    for (let i = 1; i <= 3; i++) {
      const img = await imageFromBase64(images[`pic${i}`]);
      const detection = await faceapi
        .detectSingleFace(img, tinyOptions)
        .withFaceLandmarks()
        .withFaceDescriptor();
      
      if (!detection) {
        return new Response(JSON.stringify({ message: `❌ No face detected in image ${i}` }), {
          status: 400,
          headers: { 'Content-Type': 'application/json' }
        });
      }
      
      descriptors.push(Array.from(detection.descriptor));
      
      // Save image
      const imageBuffer = bufferFromBase64(images[`pic${i}`]);
      fs.writeFileSync(path.join(FACE_DIR, `${studentId}_pic${i}.png`), imageBuffer);
    }
    
    // Save descriptors with student info
    const descriptorData = {
      studentId,
      firstName,
      middleInitial,
      surname,
      descriptors
    };
    fs.writeFileSync(descFile, JSON.stringify(descriptorData));
    
    return new Response(JSON.stringify({ message: '✅ Registration successful!' }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    });
  } catch (err) {
    console.error('Registration error:', err);
    return new Response(JSON.stringify({ message: '❌ Registration failed' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
}

export async function handleLoginRecognize(request) {
  await ensureModelsLoaded();
  try {
    const { image, deviceName, selectedSubject } = await request.json();
    
    if (!image) {
      return new Response(JSON.stringify({ message: '❌ No image provided' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    const img = await imageFromBase64(image);
    const detection = await faceapi
      .detectSingleFace(img, tinyOptions)
      .withFaceLandmarks()
      .withFaceDescriptor();
    
    if (!detection) {
      return new Response(JSON.stringify({ message: '❌ No face detected' }), {
        status: 200,
        headers: { 'Content-Type': 'application/json' }
      });
    }
    
    const queryDescriptor = detection.descriptor;
    let bestMatch = null;
    let bestDistance = Infinity;
    
    // Check all registered students
    const descFiles = fs.readdirSync(DESC_DIR).filter(f => f.endsWith('.json'));
    
    for (const descFile of descFiles) {
      const studentId = descFile.replace('.json', '');
      const data = JSON.parse(fs.readFileSync(path.join(DESC_DIR, descFile), 'utf8'));
      const descriptors = Array.isArray(data) ? data : data.descriptors;
      
      if (!Array.isArray(descriptors)) continue; // skip invalid files
      
      for (const desc of descriptors) {
        // Ensure descriptor is an array (handle both old object format and new array format)
        const descriptorArray = Array.isArray(desc) ? desc : Object.values(desc);
        const distance = faceapi.euclideanDistance(queryDescriptor, descriptorArray);
        if (distance < bestDistance) {
          bestDistance = distance;
          bestMatch = studentId;
        }
      }
    }
    
    if (bestMatch && bestDistance < 0.6) { // Threshold for match
      // Get student name from database
      let studentName = bestMatch; // fallback to ID if name lookup fails
      try {
        const studentRecord = await executeQuery('SELECT FirstName, LastName FROM students WHERE StudentID = ?', [bestMatch]);
        if (studentRecord && studentRecord.length > 0) {
          studentName = `${studentRecord[0].FirstName} ${studentRecord[0].LastName}`;

        }
      } catch (nameError) {
        console.error('Error fetching student name:', nameError);
        // Continue with ID as fallback
      }

      // Record attendance automatically when student is recognized
      try {
        // Query for sectionID
        const sectionQuery = await executeQuery('SELECT SectionID FROM section_subjects WHERE RoomID = ? AND SubjectID = ?', [deviceName, selectedSubject]);
        let sectionId = 1; // default
        if (sectionQuery.length > 0) {
          sectionId = sectionQuery[0].SectionID;
        } else {
          console.warn('No section found for RoomID:', deviceName, 'SubjectID:', selectedSubject);
        }

        await recordAttendance(bestMatch, selectedSubject, sectionId);
      } catch (attendanceError) {
        console.error('Attendance recording error:', attendanceError);
        // Don't fail the recognition if attendance recording fails
      }

      return new Response(JSON.stringify({ 
        message: `✅ Welcome back, ${studentName}!`,
        studentId: bestMatch,
        imageUrl: `/attendance-login/api/face/${bestMatch}_pic1.png`
      }), {
        status: 200,
        headers: { 'Content-Type': 'application/json' }
      });
    } else {
      return new Response(JSON.stringify({ message: '🚫 Stranger detected' }), {
        status: 200,
        headers: { 'Content-Type': 'application/json' }
      });
    }
  } catch (err) {
    console.error('Recognition error:', err);
    return new Response(JSON.stringify({ message: '❌ Recognition failed' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
}

/**
 * Record attendance for a recognized student
 * @param {string} studentId - The recognized student ID
 * @param {number} subjectId - The subject ID
 * @param {number} sectionId - The section ID
 */
async function recordAttendance(studentId, subjectId, sectionId) {
  try {
    // Get today's date in YYYY-MM-DD format
    const today = new Date().toISOString().split('T')[0];
    
    const recordedBy = 1; // Default teacher/user ID - you should make this configurable
    
    const result = await updateAttendanceRecord(studentId, subjectId, sectionId, today, 'Present', recordedBy);
    console.log(`✅ Attendance recorded for student ${studentId}:`, result);
    
    return result;
  } catch (error) {
    console.error('Failed to record attendance:', error);
    throw error;
  }
}