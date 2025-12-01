// Face-API.js MTCNN Detection Test API
// Returns detection data (box, landmarks, score) for visualization

import fs from 'fs';
import path from 'path';
import * as faceapi from 'face-api.js';
import * as canvasPkg from 'canvas';

const { Canvas, Image, ImageData } = canvasPkg;
// @ts-ignore
faceapi.env.monkeyPatch({ Canvas, Image, ImageData });

const PROJECT_ROOT = path.resolve(process.cwd());
const MODEL_PATH = path.join(PROJECT_ROOT, 'models');

let modelsLoaded = false;

async function ensureModelsLoaded() {
  if (!modelsLoaded) {
    console.log("🔄 [DetectTest] Loading face-api.js models...");
    
    if (!fs.existsSync(path.join(MODEL_PATH, 'mtcnn_model-weights_manifest.json'))) {
      throw new Error(`MTCNN model not found in: ${MODEL_PATH}`);
    }
    
    await Promise.all([
      faceapi.nets.mtcnn.loadFromDisk(MODEL_PATH),
      faceapi.nets.faceLandmark68Net.loadFromDisk(MODEL_PATH),
      faceapi.nets.faceRecognitionNet.loadFromDisk(MODEL_PATH),
    ]);
    
    console.log("✅ [DetectTest] face-api.js models loaded (MTCNN + Landmarks + Recognition)");
    modelsLoaded = true;
  }
}

function imageFromBase64(base64) {
  return new Promise((resolve, reject) => {
    const img = new Image();
    img.onload = () => resolve(img);
    img.onerror = (err) => reject(err);
    const dataUri = base64.startsWith('data:image') ? base64 : `data:image/png;base64,${base64}`;
    img.src = dataUri;
  });
}

const mtcnnOptions = new faceapi.MtcnnOptions({
  minFaceSize: 100,
  scaleFactor: 0.709
});

export async function POST({ request }) {
  try {
    await ensureModelsLoaded();
    
    const { image } = await request.json();
    if (!image) {
      return new Response(JSON.stringify({ success: false, error: 'No image provided' }), { 
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      });
    }
    
    const img = await imageFromBase64(image);
    
    const inferenceStart = performance.now();
    
    // Detect faces using MTCNN with landmarks
    const detections = await faceapi
      .detectAllFaces(img, mtcnnOptions)
      .withFaceLandmarks();
    
    const inferenceTime = performance.now() - inferenceStart;
    
    console.log(`🔍 [DetectTest] Found ${detections.length} face(s) in ${inferenceTime.toFixed(2)}ms`);
    
    // Format detections for frontend
    const formattedDetections = detections.map(det => {
      const box = det.detection.box;
      const landmarks = det.landmarks;
      
      // Get key landmark points
      const leftEye = landmarks.getLeftEye();
      const rightEye = landmarks.getRightEye();
      const nose = landmarks.getNose();
      const mouth = landmarks.getMouth();
      const jaw = landmarks.getJawOutline();
      
      // Calculate eye centers
      const leftEyeCenter = {
        x: leftEye.reduce((sum, p) => sum + p.x, 0) / leftEye.length,
        y: leftEye.reduce((sum, p) => sum + p.y, 0) / leftEye.length
      };
      const rightEyeCenter = {
        x: rightEye.reduce((sum, p) => sum + p.x, 0) / rightEye.length,
        y: rightEye.reduce((sum, p) => sum + p.y, 0) / rightEye.length
      };
      
      return {
        score: det.detection.score,
        box: [box.x, box.y, box.x + box.width, box.y + box.height],
        // 5-point landmarks (similar to RetinaFace format)
        landmarks: [
          [leftEyeCenter.x, leftEyeCenter.y],   // Left eye center
          [rightEyeCenter.x, rightEyeCenter.y], // Right eye center
          [nose[3].x, nose[3].y],               // Nose tip
          [mouth[0].x, mouth[0].y],             // Left mouth corner
          [mouth[6].x, mouth[6].y]              // Right mouth corner
        ],
        // Full 68-point landmarks
        landmarks68: landmarks.positions.map(p => [p.x, p.y])
      };
    });
    
    return new Response(JSON.stringify({
      success: true,
      detections: formattedDetections,
      count: formattedDetections.length,
      inferenceTime: Math.round(inferenceTime),
      imageSize: { width: img.width, height: img.height },
      model: 'face-api.js MTCNN'
    }), {
      headers: { 'Content-Type': 'application/json' }
    });
  } catch (error) {
    console.error('❌ [DetectTest] Error:', error);
    return new Response(JSON.stringify({ success: false, error: error.message }), { 
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
}
