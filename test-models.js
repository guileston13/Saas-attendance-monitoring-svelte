// Test script to check ONNX model loading
import * as ort from 'onnxruntime-node';
import fs from 'fs';
import path from 'path';

const PROJECT_ROOT = path.resolve(process.cwd());
const MODEL_PATH = path.join(PROJECT_ROOT, 'models');
const RETINAFACE_MODEL = path.join(MODEL_PATH, 'det_10g.onnx');
const ARCFACE_MODEL = path.join(MODEL_PATH, 'w600k_r50.onnx');

async function testModels() {
  console.log("Testing model loading...");

  try {
    // Check if files exist
    console.log("Checking RetinaFace model:", fs.existsSync(RETINAFACE_MODEL));
    console.log("Checking ArcFace model:", fs.existsSync(ARCFACE_MODEL));

    // Try loading RetinaFace
    console.log("Loading RetinaFace...");
    const retinaSession = await ort.InferenceSession.create(RETINAFACE_MODEL);
    console.log("RetinaFace loaded successfully");
    console.log("Input names:", retinaSession.inputNames);
    console.log("Output names:", retinaSession.outputNames);

    // Try loading ArcFace
    console.log("Loading ArcFace...");
    const arcSession = await ort.InferenceSession.create(ARCFACE_MODEL);
    console.log("ArcFace loaded successfully");
    console.log("Input names:", arcSession.inputNames);
    console.log("Output names:", arcSession.outputNames);

  } catch (err) {
    console.error("Model loading error:", err);
  }
}

testModels();