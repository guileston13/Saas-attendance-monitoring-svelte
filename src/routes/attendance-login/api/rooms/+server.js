import { executeQuery } from '../../../../services/database.js';

export async function GET() {
  try {
    const rooms = await executeQuery('SELECT RoomID, RoomName FROM room');
    return new Response(JSON.stringify({ rooms }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: 'Failed to fetch rooms' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
}
