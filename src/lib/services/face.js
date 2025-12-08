// Face detection service - optimized for speed with WASM backend
// Uses @vladmandic/face-api for better performance (maintained fork)
// WASM backend is 2-3x faster than default WebGL/CPU

let faceapi = null;
let wasmLoaded = false;

// Standard dimensions for all face processing
const TARGET_WIDTH = 640;
const TARGET_HEIGHT = 480;

/**
 * Load face-api with WASM backend for faster inference
 */
async function loadFaceAPI() {
    if (faceapi) return faceapi;
    if (typeof window === 'undefined') {
        throw new Error('Face API can only be used in browser environment');
    }

    // Import modern face-api (vladmandic fork - maintained and optimized)
    const faceapiModule = await import('@vladmandic/face-api');
    faceapi = faceapiModule;

    // 🚀 Use WASM backend for 2-3x faster face detection
    // WASM files are served from /static/ folder (root path)
    if (faceapi.tf && !wasmLoaded) {
        try {
            const { setWasmPaths } = await import('@tensorflow/tfjs-backend-wasm');
            setWasmPaths('/'); // WASM files in static root (e.g., /tfjs-backend-wasm.wasm)

            // @ts-ignore - tf methods exist at runtime
            await faceapi.tf.setBackend('wasm');
            // @ts-ignore - tf methods exist at runtime
            await faceapi.tf.ready();
            wasmLoaded = true;
            // @ts-ignore - tf methods exist at runtime
            console.log('✅ Face API loaded with WASM backend:', faceapi.tf.getBackend());
        } catch (err) {
            console.warn('⚠️ WASM backend failed, using default:', err);
            // Fallback to default backend (WebGL or CPU)
        }
    }

    return faceapi;
}

let modelsLoaded = false;
let modelsLoading = false;

/**
 * Load TinyFaceDetector and recognition models
 * @param {Function} onProgress - Optional callback for progress updates
 */
export async function loadModels(onProgress) {
    if (modelsLoaded) return;
    if (modelsLoading) {
        // Wait for loading to complete
        while (modelsLoading) {
            await new Promise(resolve => setTimeout(resolve, 100));
        }
        return;
    }

    modelsLoading = true;
    const faceapiModule = await loadFaceAPI();
    const MODEL_URL = '/models';
    
    const models = ['tinyFaceDetector', 'faceLandmark68Net', 'faceRecognitionNet'];

    for (let i = 0; i < models.length; i++) {
        const modelName = models[i];
        await faceapiModule.nets[modelName].loadFromUri(MODEL_URL);
        const progress = ((i + 1) / models.length) * 100;
        if (onProgress) onProgress(progress);
        console.log(`📦 Loaded model: ${modelName} (${progress.toFixed(0)}%)`);
    }

    modelsLoaded = true;
    modelsLoading = false;
    console.log('✅ All face detection models loaded with WASM backend');
}

/**
 * Center-crop an image to target dimensions without stretching/compressing.
 * If the source is larger than target, it crops from center.
 * @param {HTMLVideoElement | HTMLImageElement | HTMLCanvasElement} source
 * @param {boolean} applyGrayscale - Optional grayscale for better TinyFace accuracy
 * @returns {HTMLCanvasElement} - Canvas with exactly 640x480 dimensions
 */
export function centerCropToCanvas(source, applyGrayscale = false) {
    const canvas = document.createElement('canvas');
    canvas.width = TARGET_WIDTH;
    canvas.height = TARGET_HEIGHT;
    const ctx = canvas.getContext('2d');
    if (!ctx) throw new Error('Could not get canvas context');

    // Get source dimensions
    let srcWidth, srcHeight;
    if (source instanceof HTMLVideoElement) {
        srcWidth = source.videoWidth;
        srcHeight = source.videoHeight;
    } else if (source instanceof HTMLImageElement) {
        srcWidth = source.naturalWidth || source.width;
        srcHeight = source.naturalHeight || source.height;
    } else {
        srcWidth = source.width;
        srcHeight = source.height;
    }

    // Calculate the scaling factor to fill the target (cover strategy)
    const scale = Math.max(TARGET_WIDTH / srcWidth, TARGET_HEIGHT / srcHeight);
    const scaledWidth = srcWidth * scale;
    const scaledHeight = srcHeight * scale;

    // Calculate crop offsets to center the image
    const offsetX = (scaledWidth - TARGET_WIDTH) / 2;
    const offsetY = (scaledHeight - TARGET_HEIGHT) / 2;

    // Draw the centered, cropped image
    ctx.drawImage(
        source,
        offsetX / scale, offsetY / scale, // Source position (in original coords)
        TARGET_WIDTH / scale, TARGET_HEIGHT / scale, // Source dimensions to extract
        0, 0, // Destination position
        TARGET_WIDTH, TARGET_HEIGHT // Destination dimensions
    );

    // Apply grayscale if requested (improves TinyFace accuracy in some conditions)
    if (applyGrayscale) {
        const imageData = ctx.getImageData(0, 0, TARGET_WIDTH, TARGET_HEIGHT);
        const data = imageData.data;
        for (let i = 0; i < data.length; i += 4) {
            const gray = data[i] * 0.299 + data[i + 1] * 0.587 + data[i + 2] * 0.114;
            data[i] = gray;     // R
            data[i + 1] = gray; // G
            data[i + 2] = gray; // B
            // Alpha stays the same
        }
        ctx.putImageData(imageData, 0, 0);
    }

    return canvas;
}

/**
 * Fast face detection using TinyFaceDetector with WASM backend
 * @param {HTMLImageElement | HTMLVideoElement | HTMLCanvasElement} imageElement
 * @param {boolean} useGrayscale - Optional grayscale preprocessing
 * @returns {Promise<Object|null>} - Detection result with landmarks and descriptor
 */
export async function detectFace(imageElement, useGrayscale = false) {
    if (!modelsLoaded) {
        throw new Error('Models not loaded. Call loadModels() first.');
    }

    const faceapiModule = await loadFaceAPI();

    // Pre-process: center-crop to 640x480 without distortion
    const processedCanvas = centerCropToCanvas(imageElement, useGrayscale);

    // 🚀 TinyFaceDetector with inputSize 320 (faster than 416)
    // scoreThreshold 0.5 balances speed and accuracy
    const detection = await faceapiModule
        .detectSingleFace(processedCanvas, new faceapiModule.TinyFaceDetectorOptions({
            inputSize: 320, // Smaller = faster (320 vs 416 default)
            scoreThreshold: 0.5
        }))
        .withFaceLandmarks()
        .withFaceDescriptor();

    return detection || null;
}

/**
 * Quick face presence check (no descriptor) - very fast
 * Used for client-side pre-filtering before sending to server
 * @param {HTMLVideoElement} videoElement
 * @returns {Promise<boolean>} - true if face detected
 */
export async function hasFacePresent(videoElement) {
    if (!modelsLoaded) {
        return true; // Fallback: assume face present if models not loaded
    }

    try {
        const faceapiModule = await loadFaceAPI();
        
        // 🚀 Ultra-fast detection: just check for face presence, no landmarks/descriptor
        const detection = await faceapiModule.detectSingleFace(
            videoElement,
            new faceapiModule.TinyFaceDetectorOptions({
                inputSize: 224, // Even smaller for quick check
                scoreThreshold: 0.4
            })
        );
        
        return !!detection;
    } catch (err) {
        console.warn('Face presence check error:', err);
        return true; // Fallback: assume face present on error
    }
}

/**
 * Get canvas data URL for server transmission
 * @param {HTMLVideoElement} videoElement
 * @param {number} quality - JPEG quality (0.0 to 1.0)
 * @returns {string} - Base64 data URL
 */
export function captureFrame(videoElement, quality = 0.85) {
    const canvas = centerCropToCanvas(videoElement, false);
    return canvas.toDataURL('image/jpeg', quality);
}

/**
 * Compare two face descriptors
 * @param {Float32Array} descriptor1
 * @param {Float32Array} descriptor2
 * @returns {number} - Euclidean distance (lower = more similar, < 0.6 is same person)
 */
export function compareDescriptors(descriptor1, descriptor2) {
    if (!descriptor1 || !descriptor2) return Infinity;
    
    let sum = 0;
    for (let i = 0; i < descriptor1.length; i++) {
        const diff = descriptor1[i] - descriptor2[i];
        sum += diff * diff;
    }
    return Math.sqrt(sum);
}

// Export for use in components
export { loadFaceAPI, TARGET_WIDTH, TARGET_HEIGHT };
