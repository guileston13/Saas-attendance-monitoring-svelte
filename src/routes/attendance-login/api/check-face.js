import { handleCheckFace } from './_faceApiHandler.js';

export async function POST({ request }) {
  return handleCheckFace(request);
}
