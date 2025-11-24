// Teacher Subjects API - Get subjects assigned to a teacher
import { json } from '@sveltejs/kit';
import { getSessionFromCookies, isAuthenticated, hasRole } from '../../../../../lib/auth.js';
import { getTeacherSubjects } from '../../../../../services/reportService.js';

/** @type {import('./$types').RequestHandler} */
export async function GET({ request, params }) {
    const session = getSessionFromCookies(request.headers.get('cookie'));
    
    if (!isAuthenticated(session)) {
        return json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    try {
        const teacherId = parseInt(params.teacherId);
        
        if (!teacherId) {
            return json({ error: 'Teacher ID is required' }, { status: 400 });
        }
        
        // Check if user is the teacher or an admin
        const isOwnData = session.role === 'Teacher' && session.teacherId === teacherId;
        const isAdmin = hasRole(session, 'Admin');
        
        if (!isOwnData && !isAdmin) {
            return json({ error: 'Unauthorized to access this teacher\'s subjects' }, { status: 403 });
        }
        
        const subjects = await getTeacherSubjects(teacherId);
        
        return json({ 
            success: true,
            subjects,
            teacherId
        });
        
    } catch (error) {
        console.error('Error fetching teacher subjects:', error);
        return json({ error: 'Failed to fetch teacher subjects' }, { status: 500 });
    }
}
