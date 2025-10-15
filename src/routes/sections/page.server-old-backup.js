// Sections page server load
import { redirect } from '@sveltejs/kit';
import { getSessionFromCookies, isAuthenticated, hasRole } from '../../lib/auth.js';
import { getAllSections } from '../../services/sectionService.js';

/** @type {import('./$types').PageServerLoad} */
export async function load({ request }) {
    const session = getSessionFromCookies(request.headers.get('cookie'));
    
    if (!isAuthenticated(session)) {
        throw redirect(302, '/login');
    }
    
    try {
        const sections = await getAllSections();
        
        return {
            session,
            sections
        };
    } catch (error) {
        console.error('Load sections error:', error);
        return {
            session,
            sections: [],
            error: 'Failed to load sections data'
        };
    }
}