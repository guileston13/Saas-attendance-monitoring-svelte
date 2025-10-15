import { handleRegister } from '../_faceApiHandler.js';

export async function POST({ request }) {
  return handleRegister(request);
}
