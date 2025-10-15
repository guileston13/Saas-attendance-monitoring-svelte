// Students page server load
import { redirect } from '@sveltejs/kit';
import { getSessionFromCookies, isAuthenticated, hasRole } from '../../lib/auth.js';
import { getAllStudents } from '../../services/studentService.js';
import { executeQuery } from '../../services/database.js';

/** @type {import('./$types').PageServerLoad} */
export async function load({ request }) {
    const session = getSessionFromCookies(request.headers.get('cookie'));
    
    if (!isAuthenticated(session)) {
        throw redirect(302, '/login');
    }
    
    if (!hasRole(session, ['Admin', 'Teacher'])) {
        throw redirect(302, '/dashboard');
    }
    
    try {
        const [students, statusList] = await Promise.all([
            getAllStudents(),
            executeQuery('SELECT * FROM status ORDER BY StatusName')
        ]);
        
        return {
            session,
            students,
            statusList
        };
    } catch (error) {
        console.error('Load students error:', error);
        return {
            session,
            students: [],
            statusList: [],
            error: 'Failed to load students data'
        };
    }
}