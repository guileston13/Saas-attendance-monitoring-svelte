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
        const [subjects, statusList, rooms] = await Promise.all([
            getAllSubjects(),
            executeQuery('SELECT * FROM status ORDER BY StatusName'),
            executeQuery('SELECT RoomID, RoomName FROM room ORDER BY RoomName')
        ]);
        
        return {
            session,
            subjects,
            statusList,
            rooms
        };
    } catch (error) {
        console.error('Load subjects error:', error);
        return {
            session,
            subjects: [],
            statusList: [],
            rooms: [],
            error: 'Failed to load subjects data'
        };
    }
}