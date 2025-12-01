// Test face detection with a real image
import * as ort from 'onnxruntime-node';
import fs from 'fs';
import path from 'path';
import { createCanvas, loadImage } from 'canvas';

const PROJECT_ROOT = path.resolve(process.cwd());
const MODEL_PATH = path.join(PROJECT_ROOT, 'models');
const RETINAFACE_MODEL = path.join(MODEL_PATH, 'det_10g.onnx');

// Copy the functions from _faceApiHandler.js
function preprocessForRetinaFace(img, inputSize = 640) {
  // Calculate scale to fit image into inputSize x inputSize
  const scale = Math.min(inputSize / img.width, inputSize / img.height);
  const newW = Math.round(img.width * scale);
  const newH = Math.round(img.height * scale);

  // Create padded canvas
  const canvas = createCanvas(inputSize, inputSize);
  const ctx = canvas.getContext('2d');
  ctx.fillStyle = '#000';
  ctx.fillRect(0, 0, inputSize, inputSize);
  ctx.drawImage(img, 0, 0, newW, newH);

  const imageData = ctx.getImageData(0, 0, inputSize, inputSize);
  const { data } = imageData;

  // Convert to BGR float tensor with mean subtraction
  const tensor = new Float32Array(3 * inputSize * inputSize);
  const mean = [104, 117, 123]; // BGR mean for RetinaFace

  for (let i = 0; i < inputSize * inputSize; i++) {
    const idx = i * 4;
    tensor[0 * inputSize * inputSize + i] = data[idx + 2] - mean[0]; // B
    tensor[1 * inputSize * inputSize + i] = data[idx + 1] - mean[1]; // G
    tensor[2 * inputSize * inputSize + i] = data[idx] - mean[2];     // R
  }

  return { tensor, scale, originalWidth: img.width, originalHeight: img.height };
}

function postprocessRetinaFace(outputs, scale, scoreThreshold = 0.5) {
  // RetinaFace det_10g.onnx outputs:
  // 448: [12800,1] - scores for small anchors
  // 451: [12800,4] - bboxes for small anchors
  // 454: [12800,10] - landmarks for small anchors
  // 471: [3200,1] - scores for medium anchors
  // 474: [3200,4] - bboxes for medium anchors
  // 477: [3200,10] - landmarks for medium anchors
  // 494: [800,1] - scores for large anchors
  // 497: [800,4] - bboxes for large anchors
  // 500: [800,10] - landmarks for large anchors

  const outputMap = {
    scores: ['448', '471', '494'],
    bboxes: ['451', '474', '497'],
    landmarks: ['454', '477', '500']
  };

  let allDetections = [];

  // Process each scale
  for (let scaleIdx = 0; scaleIdx < outputMap.scores.length; scaleIdx++) {
    const scoreKey = outputMap.scores[scaleIdx];
    const bboxKey = outputMap.bboxes[scaleIdx];
    const landmarkKey = outputMap.landmarks[scaleIdx];

    if (!outputs[scoreKey] || !outputs[bboxKey]) continue;

    const scores = outputs[scoreKey].data;
    const bboxes = outputs[bboxKey].data;
    const landmarks = outputs[landmarkKey] ? outputs[landmarkKey].data : null;

    // Process each detection in this scale
    for (let i = 0; i < scores.length; i++) {
      const score = scores[i];
      if (score < scoreThreshold) continue;

      // Decode bbox (x1, y1, x2, y2) - these might already be in pixel coordinates
      const x1 = bboxes[i * 4] / scale;
      const y1 = bboxes[i * 4 + 1] / scale;
      const x2 = bboxes[i * 4 + 2] / scale;
      const y2 = bboxes[i * 4 + 3] / scale;

      // Extract landmarks if available
      let lm = [];
      if (landmarks) {
        for (let j = 0; j < 5; j++) {
          lm.push({
            x: landmarks[i * 10 + j * 2] / scale,
            y: landmarks[i * 10 + j * 2 + 1] / scale
          });
        }
      }

      allDetections.push({
        box: { x: x1, y: y1, width: x2 - x1, height: y2 - y1 },
        landmarks: lm,
        score: score
      });
    }
  }

  if (allDetections.length === 0) return null;

  // Return the detection with highest score
  allDetections.sort((a, b) => b.score - a.score);
  return allDetections[0];
}

async function detectFace(img) {
  console.log(`🔍 Detecting face in image: ${img.width}x${img.height}`);

  const { tensor, scale } = preprocessForRetinaFace(img, 640);
  console.log(`📏 Preprocessed to 640x640, scale: ${scale}`);

  const session = await ort.InferenceSession.create(RETINAFACE_MODEL);
  const inputName = session.inputNames[0];
  const inputTensor = new ort.Tensor('float32', tensor, [1, 3, 640, 640]);

  const feeds = {};
  feeds[inputName] = inputTensor;

  console.log("🧠 Running RetinaFace inference...");
  const results = await session.run(feeds);

  console.log(`📊 Got ${Object.keys(results).length} outputs from RetinaFace`);
  const detection = postprocessRetinaFace(results, scale);

  if (detection) {
    console.log(`✅ Face detected: score=${detection.score.toFixed(3)}, box=${JSON.stringify(detection.box)}, landmarks=${detection.landmarks.length}`);
  } else {
    console.log("❌ No face detected");
  }

  return detection;
}

async function testWithImage() {
  try {
    // Create a test image with a face-like pattern
    const canvas = createCanvas(640, 480);
    const ctx = canvas.getContext('2d');

    // Fill with skin tone
    ctx.fillStyle = '#DEB887';
    ctx.fillRect(0, 0, 640, 480);

    // Draw a simple face-like oval
    ctx.fillStyle = '#F5DEB3';
    ctx.beginPath();
    ctx.ellipse(320, 240, 80, 100, 0, 0, 2 * Math.PI);
    ctx.fill();

    // Draw eyes
    ctx.fillStyle = '#000000';
    ctx.beginPath();
    ctx.ellipse(300, 220, 5, 5, 0, 0, 2 * Math.PI);
    ctx.fill();
    ctx.beginPath();
    ctx.ellipse(340, 220, 5, 5, 0, 0, 2 * Math.PI);
    ctx.fill();

    // Draw mouth
    ctx.beginPath();
    ctx.arc(320, 260, 10, 0, Math.PI);
    ctx.stroke();

    const img = canvas;
    await detectFace(img);

  } catch (err) {
    console.error("Test error:", err);
  }
}

testWithImage();