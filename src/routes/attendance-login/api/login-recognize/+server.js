import { handleLoginRecognize } from '../_faceApiHandler.js';

export async function POST({ request }) {
  return handleLoginRecognize(request);
}
