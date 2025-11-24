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
      faceapi.nets.mtcnn.loadFromDisk(MODEL_PATH),
      faceapi.nets.faceLandmark68Net.loadFromDisk(MODEL_PATH),
      faceapi.nets.faceRecognitionNet.loadFromDisk(MODEL_PATH),
    ]);
    console.log("✅ MTCNN + Landmarks + Recognition models loaded");
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

    // Ensure proper data URI
    const dataUri = base64.startsWith('data:image') ? base64 : `data:image/png;base64,${base64}`;
    img.src = dataUri;
  });
}

const mtcnnOptions = new faceapi.MtcnnOptions({
  minFaceSize: 100,
  scaleFactor: 0.709
});

export async function handleCheckFace(request) {
  await ensureModelsLoaded();
  try {
    const { image } = await request.json();
    if (!image) return new Response(JSON.stringify({ orientation: 'none' }), { status: 200, headers: { 'Content-Type': 'application/json' } });

    const img = await imageFromBase64(image);
    const detection = await faceapi
      .detectSingleFace(img, mtcnnOptions)
      .withFaceLandmarks()
      .withFaceDescriptor();

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
        .detectSingleFace(img, mtcnnOptions)
        .withFaceLandmarks()
        .withFaceDescriptor();

      if (!detection) {
        console.warn(`⚠️ No face detected in image ${i}, skipping`);
        continue; // skip rather than returning 400 immediately
      }

      descriptors.push(Array.from(detection.descriptor));
      const imageBuffer = bufferFromBase64(images[`pic${i}`]);
      fs.writeFileSync(path.join(FACE_DIR, `${studentId}_pic${i}.png`), imageBuffer);
    }

    if (descriptors.length === 0) {
      return new Response(JSON.stringify({ message: '❌ No faces detected in any image' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    console.log(images.pic1.substring(0, 50)); // should start with data:image/png;base64
    
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
    const { image, roomId } = await request.json();
    
    if (!image) {
      return new Response(JSON.stringify({ message: '❌ No image provided' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      });
    }
    
    if (!roomId) {
      return new Response(JSON.stringify({ message: '❌ Room not configured' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    const img = await imageFromBase64(image);
    const detection = await faceapi
      .detectSingleFace(img, mtcnnOptions)
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

    // Check all registered students (compute per-student minimum distance)
    const descFiles = fs.readdirSync(DESC_DIR).filter(f => f.endsWith('.json'));

    for (const descFile of descFiles) {
      const studentId = descFile.replace('.json', '');
      const data = JSON.parse(fs.readFileSync(path.join(DESC_DIR, descFile), 'utf8'));
      const descriptors = Array.isArray(data) ? data : data.descriptors;
      if (!Array.isArray(descriptors)) continue;

      // compute the minimum distance for this student
      let studentMin = Infinity;
      for (const desc of descriptors) {
        const descriptorArray = Array.isArray(desc) ? desc : Object.values(desc);
        const distance = faceapi.euclideanDistance(queryDescriptor, descriptorArray);
        if (distance < studentMin) studentMin = distance;
      }

      // debug: log per-student min distance (can be removed in production)
      console.log(`🔎 student ${studentId} minDistance=${studentMin}`);

      if (studentMin < bestDistance) {
        bestDistance = studentMin;
        bestMatch = studentId;
      }
    }

    console.log('✅ Recognition bestMatch:', bestMatch, 'bestDistance:', bestDistance);

    if (bestMatch && bestDistance < 0.5) { // Threshold for match (tuned lower)
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

      let subjectName = 'Unknown Subject'; // Default value
      let attendanceRecorded = false;

      // Record attendance automatically when student is recognized
      try {
        // 🎯 AUTO-DETECT SUBJECT: Query based on room + time + enrollment + day of week
        const scheduleQuery = await executeQuery(`
          SELECT ss.SubjectID, ss.SectionID, ss.TeacherID, s.subject_name,
            CASE DAYOFWEEK(CURDATE())
              WHEN 2 THEN ss.MondayStart
              WHEN 3 THEN ss.TuesdayStart
              WHEN 4 THEN ss.WednesdayStart
              WHEN 5 THEN ss.ThursdayStart
              WHEN 6 THEN ss.FridayStart
            END AS StartTime,
            CASE DAYOFWEEK(CURDATE())
              WHEN 2 THEN ss.MondayEnd
              WHEN 3 THEN ss.TuesdayEnd
              WHEN 4 THEN ss.WednesdayEnd
              WHEN 5 THEN ss.ThursdayEnd
              WHEN 6 THEN ss.FridayEnd
            END AS EndTime
          FROM section_subjects ss
          JOIN subject_enrollments se ON ss.SectionID = se.SectionID 
                                        AND ss.SubjectID = se.SubjectID
          JOIN subjects s ON ss.SubjectID = s.SubjectID
          WHERE se.StudentID = ?
            AND se.Status = 'Active'
            AND ss.RoomID = ?
            AND CASE DAYOFWEEK(CURDATE())
              WHEN 2 THEN ss.Monday = 1
              WHEN 3 THEN ss.Tuesday = 1
              WHEN 4 THEN ss.Wednesday = 1
              WHEN 5 THEN ss.Thursday = 1
              WHEN 6 THEN ss.Friday = 1
            END
            AND CURTIME() BETWEEN 
              CASE DAYOFWEEK(CURDATE())
                WHEN 2 THEN ss.MondayStart
                WHEN 3 THEN ss.TuesdayStart
                WHEN 4 THEN ss.WednesdayStart
                WHEN 5 THEN ss.ThursdayStart
                WHEN 6 THEN ss.FridayStart
              END
            AND
              CASE DAYOFWEEK(CURDATE())
                WHEN 2 THEN ss.MondayEnd
                WHEN 3 THEN ss.TuesdayEnd
                WHEN 4 THEN ss.WednesdayEnd
                WHEN 5 THEN ss.ThursdayEnd
                WHEN 6 THEN ss.FridayEnd
              END
          LIMIT 1
        `, [bestMatch, roomId]);
        console.log("hello bestMatch: =>",bestMatch);
        console.log("hello roomId: =>",roomId);
        console.log('📅 Schedule query result:', scheduleQuery);
        if (scheduleQuery.length === 0) {
          return new Response(JSON.stringify({ 
            message: `⚠️ No class scheduled for ${studentName} in this room at current time`,
            studentId: bestMatch
          }), {
            status: 200,
            headers: { 'Content-Type': 'application/json' }
          });
        }
        
        const { SubjectID, SectionID, TeacherID, subject_name, StartTime } = scheduleQuery[0];
        subjectName = subject_name; // Update the variable
        
        console.log(`📚 Auto-detected: ${subject_name} (Subject ID: ${SubjectID}, Section: ${SectionID})`);
        
        // Record attendance with the auto-detected subject and start time
        await recordAttendance(bestMatch, SubjectID, SectionID, TeacherID, StartTime);
        attendanceRecorded = true;
        console.log(`✅ Attendance recorded successfully for ${studentName}`);
      } catch (attendanceError) {
        console.error('Attendance recording error:', attendanceError);
        // Continue with recognition but note that attendance wasn't recorded
        return new Response(JSON.stringify({ 
          message: `⚠️ ${studentName} recognized but attendance recording failed: ${attendanceError.message}`,
          studentId: bestMatch,
          subjectName: subjectName,
          imageUrl: `/attendance-login/api/face/${bestMatch}_pic1.png`,
          error: 'attendance_failed'
        }), {
          status: 200,
          headers: { 'Content-Type': 'application/json' }
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

    await executeQuery(query, [studentId, subId, secId, today, loginTime, status, teachId]);

    console.log(`✅ Attendance recorded for student ${studentId} at ${loginTime} - Status: ${status}`);
    return { success: true, loginTime, status };
  } catch (error) {
    console.error('⚠️ Failed to record attendance:', error.message);
    throw error;
  }
}