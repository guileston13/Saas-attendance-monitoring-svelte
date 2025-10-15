// Teachers page server load
import { redirect } from '@sveltejs/kit';
import { getSessionFromCookies, isAuthenticated, hasRole } from '../../lib/auth.js';
import { getAllTeachers } from '../../services/teacherService.js';
import { executeQuery } from '../../services/database.js';

/** @type {import('./$types').PageServerLoad} */
export async function load({ request }) {
    const session = getSessionFromCookies(request.headers.get('cookie'));
    
    if (!isAuthenticated(session)) {
        throw redirect(302, '/login');
    }
    
    if (!hasRole(session, 'Admin')) {
        throw redirect(302, '/dashboard');
    }
    
    try {
        const [teachers, statusList] = await Promise.all([
            getAllTeachers(),
            executeQuery('SELECT * FROM status ORDER BY StatusName')
        ]);
        
        return {
            session,
            teachers,
            statusList
        };
    } catch (error) {
        console.error('Load teachers error:', error);
        return {
            session,
            teachers: [],
            statusList: [],
            error: 'Failed to load teachers data'
        };
    }
}