// Test script to check ONNX model loading and inference
import * as ort from 'onnxruntime-node';
import fs from 'fs';
import path from 'path';
import { createCanvas } from 'canvas';

const PROJECT_ROOT = path.resolve(process.cwd());
const MODEL_PATH = path.join(PROJECT_ROOT, 'models');
const RETINAFACE_MODEL = path.join(MODEL_PATH, 'det_10g.onnx');

async function testInference() {
  console.log("Testing RetinaFace inference...");

  try {
    const session = await ort.InferenceSession.create(RETINAFACE_MODEL);
    console.log("Model loaded");

    // Create a dummy 640x640 RGB image (all white)
    const canvas = createCanvas(640, 640);
    const ctx = canvas.getContext('2d');
    ctx.fillStyle = '#FFFFFF';
    ctx.fillRect(0, 0, 640, 640);

    // Preprocess like in the code
    const imageData = ctx.getImageData(0, 0, 640, 640);
    const { data } = imageData;
    const tensor = new Float32Array(3 * 640 * 640);
    const mean = [104, 117, 123]; // BGR mean

    for (let i = 0; i < 640 * 640; i++) {
      const idx = i * 4;
      tensor[0 * 640 * 640 + i] = data[idx + 2] - mean[0]; // B
      tensor[1 * 640 * 640 + i] = data[idx + 1] - mean[1]; // G
      tensor[2 * 640 * 640 + i] = data[idx] - mean[2];     // R
    }

    const inputTensor = new ort.Tensor('float32', tensor, [1, 3, 640, 640]);
    const feeds = { 'input.1': inputTensor };

    console.log("Running inference...");
    const results = await session.run(feeds);

    console.log("Output names:", Object.keys(results));
    for (const [name, tensor] of Object.entries(results)) {
      console.log(`${name}: shape [${tensor.dims}], type: ${tensor.type}`);
      if (tensor.dims.length <= 2 && tensor.data.length <= 20) {
        console.log(`  Values: [${Array.from(tensor.data).join(', ')}]`);
      } else if (tensor.dims.length <= 2) {
        console.log(`  Sample values: [${Array.from(tensor.data).slice(0, 10).join(', ')}]`);
      }
    }

  } catch (err) {
    console.error("Inference error:", err);
  }
}

testInference();