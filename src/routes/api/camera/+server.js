// src/routes/api/camera/+server.js
import { _broadcast } from '../stream/+server.js';
import { json } from '@sveltejs/kit';

export async function POST({ request }) {
  const data = await request.json();
  console.log('📸 Received camera trigger:', data);

  if (data.action === 'start_camera') {
    _broadcast({ status: 'camera_started', device: data.device || 'all' });
    return json({ status: 'camera_started', device: data.device || 'all' });
  }
  if (data.action === 'stop_camera') {
    _broadcast({ status: 'camera_stopped', device: data.device || 'all' });
    return json({ status: 'camera_stopped', device: data.device || 'all' });
  }

  return json({ error: 'Unknown action' }, { status: 400 });
}
