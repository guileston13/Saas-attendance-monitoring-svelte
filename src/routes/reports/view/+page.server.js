// PDF Viewer page server
import { getSessionFromCookies, isAuthenticated } from '../../../lib/auth.js';
import { redirect } from '@sveltejs/kit';

/** @type {import('./$types').PageServerLoad} */
export async function load({ request, url }) {
    const session = getSessionFromCookies(request.headers.get('cookie'));
    
    if (!isAuthenticated(session)) {
        throw redirect(302, '/login');
    }
    
    return {
        session
    };
}
