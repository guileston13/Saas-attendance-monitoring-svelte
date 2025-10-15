// Subjects page server load
import { redirect } from '@sveltejs/kit';
import { getSessionFromCookies, isAuthenticated, hasRole } from '../../lib/auth.js';
import { getAllSubjects } from '../../services/subjectService.js';
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
        const [subjects, statusList] = await Promise.all([
            getAllSubjects(),
            executeQuery('SELECT * FROM status ORDER BY StatusName')
        ]);
        
        return {
            session,
            subjects,
            statusList
        };
    } catch (error) {
        console.error('Load subjects error:', error);
        return {
            session,
            subjects: [],
            statusList: [],
            error: 'Failed to load subjects data'
        };
    }
}