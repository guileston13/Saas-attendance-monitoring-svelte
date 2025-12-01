// Logout page server action
import { redirect } from '@sveltejs/kit';
import { clearSessionCookie } from '../../lib/auth.js';

/** @type {import('./$types').PageServerLoad} */
export async function load({ cookies }) {
	// Clear session cookie using SvelteKit cookies API
	cookies.delete('session', { path: '/' });
	
	// Also clear using our custom function for redundancy
	const cookie = clearSessionCookie();
	
	throw redirect(302, '/login', {
		'Set-Cookie': cookie
	});
}