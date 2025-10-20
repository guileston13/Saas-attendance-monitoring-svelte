// Rooms API endpoints
import { getSessionFromCookies, isAuthenticated, hasRole } from '../../../lib/auth.js';
import { executeQuery } from '../../../services/database.js';

// GET /api/rooms - Get all rooms
export async function GET({ request }) {
	const session = getSessionFromCookies(request.headers.get('cookie'));

	if (!isAuthenticated(session) || !hasRole(session, ['Admin', 'Teacher'])) {
		return new Response(JSON.stringify({ error: 'Unauthorized' }), {
			status: 401,
			headers: { 'Content-Type': 'application/json' }
		});
	}

	try {
		const rooms = await executeQuery(`
			SELECT RoomID, RoomName
			FROM room
			ORDER BY RoomName
		`);

		return new Response(JSON.stringify({ rooms }), {
			status: 200,
			headers: { 'Content-Type': 'application/json' }
		});
	} catch (error) {
		console.error('Error fetching rooms:', error);
		return new Response(JSON.stringify({ error: 'Failed to fetch rooms' }), {
			status: 500,
			headers: { 'Content-Type': 'application/json' }
		});
	}
}

// POST /api/rooms - Create a new room
export async function POST({ request }) {
	const session = getSessionFromCookies(request.headers.get('cookie'));

	if (!isAuthenticated(session) || !hasRole(session, 'Admin')) {
		return new Response(JSON.stringify({ error: 'Unauthorized' }), {
			status: 401,
			headers: { 'Content-Type': 'application/json' }
		});
	}

	try {
		const { roomName } = await request.json();

		if (!roomName) {
			return new Response(JSON.stringify({ error: 'Room name is required' }), {
				status: 400,
				headers: { 'Content-Type': 'application/json' }
			});
		}

		const result = await executeQuery(
			'INSERT INTO room (RoomName) VALUES (?)',
			[roomName]
		);

		return new Response(JSON.stringify({
			success: true,
			message: 'Room created successfully',
			roomId: result.insertId
		}), {
			status: 201,
			headers: { 'Content-Type': 'application/json' }
		});
	} catch (error) {
		console.error('Error creating room:', error);
		return new Response(JSON.stringify({ error: 'Failed to create room' }), {
			status: 500,
			headers: { 'Content-Type': 'application/json' }
		});
	}
}