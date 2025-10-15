// Register page server actions
import { fail, redirect } from '@sveltejs/kit';
import { registerUser } from '../../services/authService.js';

/** @type {import('./$types').Actions} */
export const actions = {
	default: async ({ request }) => {
		const data = await request.formData();
		const studentId = data.get('studentId');
		const firstName = data.get('firstName');
		const lastName = data.get('lastName');
		const middleName = data.get('middleName');
		const yearLevel = data.get('yearLevel');
		const email = data.get('email');
		const password = data.get('password');
		const confirmPassword = data.get('confirmPassword');
		
		// Validation
		if (!studentId || !firstName || !lastName || !yearLevel || !email || !password) {
			return fail(400, {
				error: 'All required fields must be filled',
				studentId, firstName, lastName, middleName, yearLevel, email
			});
		}
		
		if (password !== confirmPassword) {
			return fail(400, {
				error: 'Passwords do not match',
				studentId, firstName, lastName, middleName, yearLevel, email
			});
		}
		
		if (password.length < 6) {
			return fail(400, {
				error: 'Password must be at least 6 characters long',
				studentId, firstName, lastName, middleName, yearLevel, email
			});
		}
		
		try {
			await registerUser({
				email,
				password,
				firstName,
				lastName,
				middleName,
				studentId,
				yearLevel
			});
			
			// Redirect to login page with success message
			throw redirect(302, '/login');
			
		} catch (error) {
			console.error('Registration error:', error);
			
			// Check for duplicate key error
			if (error.code === 'ER_DUP_ENTRY') {
				if (error.message.includes('Email')) {
					return fail(400, {
						error: 'Email address is already registered',
						studentId, firstName, lastName, middleName, yearLevel, email
					});
				} else if (error.message.includes('StudentID')) {
					return fail(400, {
						error: 'Student ID is already registered',
						studentId, firstName, lastName, middleName, yearLevel, email
					});
				}
			}
			
			return fail(500, {
				error: 'An error occurred during registration. Please try again.',
				studentId, firstName, lastName, middleName, yearLevel, email
			});
		}
	}
};