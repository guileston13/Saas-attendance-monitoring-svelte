// Redirect to login if not authenticated
import { redirect } from '@sveltejs/kit';

/** @type {import('./$types').PageServerLoad} */
export async function load() {
	throw redirect(302, '/login');
}