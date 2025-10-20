// Rooms page server load
import { redirect } from '@sveltejs/kit';
import { getSessionFromCookies, isAuthenticated, hasRole } from '../../lib/auth.js';
import { executeQuery } from '../../services/database.js';

/** @type {import('./$types').PageServerLoad} */
export async function load({ request }) {
	const session = getSessionFromCookies(request.headers.get('cookie'));

	if (!isAuthenticated(session)) {
		throw redirect(302, '/login');
	}

	// Check if user has access to rooms
	if (!hasRole(session, ['Admin', 'Teacher'])) {
		throw redirect(302, '/dashboard');
	}

	try {
		// Load all rooms (rooms table doesn't have status column)
		const rooms = await executeQuery(`
			SELECT RoomID, RoomName
			FROM room
			ORDER BY RoomName
		`);

		return {
			session,
			rooms
		};
	} catch (error) {
		console.error('Rooms load error:', error);
		return {
			session,
			rooms: [],
			error: 'Failed to load rooms data'
		};
	}
}