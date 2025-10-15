// Login page server actions
import { fail, redirect } from '@sveltejs/kit';
import { authenticateUser } from '../../services/authService.js';
import { createSessionCookie } from '../../lib/auth.js';

/** @type {import('./$types').Actions} */
export const actions = {
	default: async ({ request, cookies }) => {
		console.log('=== LOGIN ATTEMPT ===');
		
		const data = await request.formData();
		const email = data.get('email');
		const password = data.get('password');
		
		console.log('Email:', email);
		
		if (!email || !password) {
			return fail(400, {
				error: 'Email and password are required',
				email
			});
		}
		
		try {
			const user = await authenticateUser(email, password);
			
			if (!user) {
				return fail(400, {
					error: 'Invalid email or password',
					email
				});
			}
			
			console.log('Authentication successful, setting cookie...');
			
			// Set cookie using SvelteKit's cookies helper
			const sessionData = {
				userId: user.UserID,
				email: user.Email,
				role: user.Role,
				timestamp: Date.now()
			};
			
			const sessionToken = Buffer.from(JSON.stringify(sessionData)).toString('base64');
			
			cookies.set('session', sessionToken, {
				httpOnly: true,
				secure: false,
				sameSite: 'lax',
				maxAge: 24 * 60 * 60,
				path: '/'
			});
			
			console.log('Cookie set successfully');
			console.log('Session data:', sessionData);
			console.log('About to redirect to /dashboard');
			
			throw redirect(302, '/dashboard');
			
		} catch (error) {
			if (error.status === 302) {
				console.log('Redirect caught and re-throwing');
				// This is our redirect, re-throw it
				throw error;
			}
			
			console.error('Login error:', error);
			return fail(500, {
				error: 'An error occurred during login. Please try again.',
				email
			});
		}
	}
};