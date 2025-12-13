// Users page server load
import { redirect, fail } from '@sveltejs/kit';
import { getSessionFromCookies, isAuthenticated, hasRole } from '../../lib/auth.js';
import { executeQuery } from '../../services/database.js';
import bcrypt from 'bcryptjs';

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
		
		// Get unassigned teachers (teachers without a UserID linked)
		const unassignedTeachers = await executeQuery(`
			SELECT TeacherID, FirstName, LastName, MiddleName
			FROM teachers 
			WHERE UserID IS NULL AND StatusID = 1
			ORDER BY LastName, FirstName
		`);
		
		return {
			session,
			users,
			statuses,
			unassignedTeachers,
			currentSection: 'User Management'
		};
	} catch (error) {
		console.error('Users load error:', error);
		return {
			session,
			users: [],
			statuses: [],
			unassignedTeachers: [],
			error: 'Failed to load users data',
			currentSection: 'User Management'
		};
	}
}

/** @type {import('./$types').Actions} */
export const actions = {
	create: async ({ request }) => {
		const cookieHeader = request.headers.get('cookie');
		const session = getSessionFromCookies(cookieHeader);
		
		if (!isAuthenticated(session) || !hasRole(session, 'Admin')) {
			return fail(401, { error: 'Unauthorized' });
		}
		
		const data = await request.formData();
		const email = data.get('email');
		const password = data.get('password');
		const role = data.get('role');
		const statusId = data.get('statusId');
		const teacherId = data.get('teacherId'); // Optional: link to existing teacher
		
		if (!email || !password || !role || !statusId) {
			return fail(400, { error: 'Missing required fields' });
		}
		
		try {
			// Check if email already exists
			const existing = await executeQuery('SELECT UserID FROM users WHERE Email = ?', [email]);
			if (existing.length > 0) {
				return fail(400, { error: 'Email already exists' });
			}
			
			// Hash password
			const hashedPassword = await bcrypt.hash(password, 10);
			
			// Create user
			const result = await executeQuery(
				'INSERT INTO users (Email, Password, Role, StatusID) VALUES (?, ?, ?, ?)',
				[email, hashedPassword, role, statusId]
			);
			
			// If role is Teacher and a teacher was selected, link them
			if (role === 'Teacher' && teacherId && result.insertId) {
				await executeQuery(
					'UPDATE teachers SET UserID = ? WHERE TeacherID = ?',
					[result.insertId, teacherId]
				);
			}
			
			return { success: true };
		} catch (error) {
			console.error('Create user error:', error);
			return fail(500, { error: 'Failed to create user' });
		}
	},
	
	update: async ({ request }) => {
		const cookieHeader = request.headers.get('cookie');
		const session = getSessionFromCookies(cookieHeader);
		
		if (!isAuthenticated(session) || !hasRole(session, 'Admin')) {
			return fail(401, { error: 'Unauthorized' });
		}
		
		const data = await request.formData();
		const userId = data.get('userId');
		const email = data.get('email');
		const role = data.get('role');
		const statusId = data.get('statusId');
		const password = data.get('password');
		const teacherId = data.get('teacherId'); // Optional: link to existing teacher
		
		if (!userId || !email || !role || !statusId) {
			return fail(400, { error: 'Missing required fields' });
		}
		
		try {
			// If password is provided, hash it and update
			if (password && password.trim() !== '') {
				const hashedPassword = await bcrypt.hash(password, 10);
				await executeQuery(
					'UPDATE users SET Email = ?, Password = ?, Role = ?, StatusID = ? WHERE UserID = ?',
					[email, hashedPassword, role, statusId, userId]
				);
			} else {
				// Update without changing password
				await executeQuery(
					'UPDATE users SET Email = ?, Role = ?, StatusID = ? WHERE UserID = ?',
					[email, role, statusId, userId]
				);
			}
			
			// If role is Teacher and a teacher was selected, link them
			if (role === 'Teacher' && teacherId) {
				await executeQuery(
					'UPDATE teachers SET UserID = ? WHERE TeacherID = ?',
					[userId, teacherId]
				);
			}
			
			return { success: true };
		} catch (error) {
			console.error('Update user error:', error);
			return fail(500, { error: 'Failed to update user' });
		}
	}
};