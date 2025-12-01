// Individual room API endpoints
import { getSessionFromCookies, isAuthenticated, hasRole } from '../../../../lib/auth.js';
import { executeQuery } from '../../../../services/database.js';

// GET /api/rooms/[id] - Get a specific room
export async function GET({ params, request }) {
	const session = getSessionFromCookies(request.headers.get('cookie'));

	if (!isAuthenticated(session) || !hasRole(session, ['Admin', 'Teacher'])) {
		return new Response(JSON.stringify({ error: 'Unauthorized' }), {
			status: 401,
			headers: { 'Content-Type': 'application/json' }
		});
	}

	try {
		const roomId = parseInt(params.id);

		if (isNaN(roomId)) {
			return new Response(JSON.stringify({ error: 'Invalid room ID' }), {
				status: 400,
				headers: { 'Content-Type': 'application/json' }
			});
		}

		const rooms = await executeQuery(`
			SELECT RoomID, RoomName
			FROM room
			WHERE RoomID = ?
		`, [roomId]);

		if (rooms.length === 0) {
			return new Response(JSON.stringify({ error: 'Room not found' }), {
				status: 404,
				headers: { 'Content-Type': 'application/json' }
			});
		}

		return new Response(JSON.stringify({ room: rooms[0] }), {
			status: 200,
			headers: { 'Content-Type': 'application/json' }
		});
	} catch (error) {
		console.error('Error fetching room:', error);
		return new Response(JSON.stringify({ error: 'Failed to fetch room' }), {
			status: 500,
			headers: { 'Content-Type': 'application/json' }
		});
	}
}

// PUT /api/rooms/[id] - Update a specific room
export async function PUT({ params, request }) {
	const session = getSessionFromCookies(request.headers.get('cookie'));

	if (!isAuthenticated(session) || !hasRole(session, 'Admin')) {
		return new Response(JSON.stringify({ error: 'Unauthorized' }), {
			status: 401,
			headers: { 'Content-Type': 'application/json' }
		});
	}

	try {
		const roomId = parseInt(params.id);
		const { roomName } = await request.json();

		if (isNaN(roomId)) {
			return new Response(JSON.stringify({ error: 'Invalid room ID' }), {
				status: 400,
				headers: { 'Content-Type': 'application/json' }
			});
		}

		if (!roomName) {
			return new Response(JSON.stringify({ error: 'Room name is required' }), {
				status: 400,
				headers: { 'Content-Type': 'application/json' }
			});
		}

		const result = await executeQuery(
			'UPDATE room SET RoomName = ? WHERE RoomID = ?',
			[roomName, roomId]
		);

		if (result.affectedRows === 0) {
			return new Response(JSON.stringify({ error: 'Room not found' }), {
				status: 404,
				headers: { 'Content-Type': 'application/json' }
			});
		}

		return new Response(JSON.stringify({
			success: true,
			message: 'Room updated successfully'
		}), {
			status: 200,
			headers: { 'Content-Type': 'application/json' }
		});
	} catch (error) {
		console.error('Error updating room:', error);
		return new Response(JSON.stringify({ error: 'Failed to update room' }), {
			status: 500,
			headers: { 'Content-Type': 'application/json' }
		});
	}
}

// DELETE /api/rooms/[id] - Delete a specific room
export async function DELETE({ params, request }) {
	const session = getSessionFromCookies(request.headers.get('cookie'));

	if (!isAuthenticated(session) || !hasRole(session, 'Admin')) {
		return new Response(JSON.stringify({ error: 'Unauthorized' }), {
			status: 401,
			headers: { 'Content-Type': 'application/json' }
		});
	}

	try {
		const roomId = parseInt(params.id);

		if (isNaN(roomId)) {
			return new Response(JSON.stringify({ error: 'Invalid room ID' }), {
				status: 400,
				headers: { 'Content-Type': 'application/json' }
			});
		}

		// Check if room is being used in section_subjects
		const usageCheck = await executeQuery(
			'SELECT COUNT(*) as count FROM section_subjects WHERE RoomID = ?',
			[roomId]
		);

		if (usageCheck[0].count > 0) {
			return new Response(JSON.stringify({
				error: 'Cannot delete room that is assigned to subjects'
			}), {
				status: 400,
				headers: { 'Content-Type': 'application/json' }
			});
		}

		const result = await executeQuery('DELETE FROM room WHERE RoomID = ?', [roomId]);

		if (result.affectedRows === 0) {
			return new Response(JSON.stringify({ error: 'Room not found' }), {
				status: 404,
				headers: { 'Content-Type': 'application/json' }
			});
		}

		return new Response(JSON.stringify({
			success: true,
			message: 'Room deleted successfully'
		}), {
			status: 200,
			headers: { 'Content-Type': 'application/json' }
		});
	} catch (error) {
		console.error('Error deleting room:', error);
		return new Response(JSON.stringify({ error: 'Failed to delete room' }), {
			status: 500,
			headers: { 'Content-Type': 'application/json' }
		});
	}
}