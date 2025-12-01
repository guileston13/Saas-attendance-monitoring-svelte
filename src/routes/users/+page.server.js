// Users page server load
import { redirect } from '@sveltejs/kit';
import { getSessionFromCookies, isAuthenticated, hasRole } from '../../lib/auth.js';
import { executeQuery } from '../../services/database.js';

/** @type {import('./$types').PageServerLoad} */
export async function load({ request }) {
	const session = getSessionFromCookies(request.headers.get('cookie'));
	
	if (!isAuthenticated(session) || !hasRole(session, 'Admin')) {
		throw redirect(302, '/dashboard');
	}
	
	try {
		// Get all users with their details
		const users = await executeQuery(`
			SELECT 
				u.UserID,
				u.Email,
				u.Role,
				u.StatusID,
				s.StatusName,
				u.CreatedAt,
				u.UpdatedAt,
				CASE 
					WHEN u.Role = 'Student' THEN CONCAT(st.FirstName, ' ', st.LastName)
					WHEN u.Role = 'Teacher' THEN CONCAT(t.FirstName, ' ', t.LastName)
					ELSE 'System Admin'
				END as FullName
			FROM users u
			LEFT JOIN status s ON u.StatusID = s.StatusID
			LEFT JOIN students st ON u.UserID = st.UserID
			LEFT JOIN teachers t ON u.UserID = t.UserID
			ORDER BY u.CreatedAt DESC
		`);
		
		// Get status options
		const statuses = await executeQuery('SELECT * FROM status ORDER BY StatusName');
		
		return {
			session,
			users,
			statuses,
			currentSection: 'User Management'
		};
	} catch (error) {
		console.error('Users load error:', error);
		return {
			session,
			users: [],
			statuses: [],
			error: 'Failed to load users data',
			currentSection: 'User Management'
		};
	}
}