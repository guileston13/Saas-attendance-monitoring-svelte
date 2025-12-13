// Teachers API endpoints
import { json } from '@sveltejs/kit';
import { getSessionFromCookies, isAuthenticated, hasRole } from '../../../lib/auth.js';
import { 
    getAllTeachers, 
    getTeacherById, 
    createTeacher, 
    updateTeacher, 
    deleteTeacher,
    createTeacherWithUser
} from '../../../services/teacherService.js';

/** @type {import('./$types').RequestHandler} */
export async function GET({ request }) {
    const session = getSessionFromCookies(request.headers.get('cookie'));
    
    if (!isAuthenticated(session)) {
        return json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    try {
        const teachers = await getAllTeachers();
        return json({ teachers });
    } catch (error) {
        console.error('Get teachers error:', error);
        return json({ error: 'Failed to fetch teachers' }, { status: 500 });
    }
}

/** @type {import('./$types').RequestHandler} */
export async function POST({ request }) {
    const session = getSessionFromCookies(request.headers.get('cookie'));
    
    if (!isAuthenticated(session) || !hasRole(session, 'Admin')) {
        return json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    try {
        const data = await request.json();
        const { firstName, lastName, middleName, role, statusId, email } = data;
        
        if (!firstName || !lastName || !statusId) {
            return json({ error: 'Missing required fields' }, { status: 400 });
        }
        
        // Create teacher with optional user account if email is provided
        const result = await createTeacherWithUser({
            firstName,
            lastName,
            middleName: middleName || null,
            role: role || 'Teacher',
            statusId,
            email: email || null
        });
        
        return json({ success: true, id: result.teacherId });
    } catch (error) {
        console.error('Create teacher error:', error);
        return json({ error: error.message || 'Failed to create teacher' }, { status: 500 });
    }
}

/** @type {import('./$types').RequestHandler} */
export async function PUT({ request }) {
    const session = getSessionFromCookies(request.headers.get('cookie'));
    
    if (!isAuthenticated(session) || !hasRole(session, 'Admin')) {
        return json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    try {
        const data = await request.json();
        const { teacherId, firstName, lastName, middleName, role, statusId } = data;
        
        if (!teacherId || !firstName || !lastName || !statusId) {
            return json({ error: 'Missing required fields' }, { status: 400 });
        }
        
        await updateTeacher(teacherId, {
            firstName,
            lastName,
            middleName: middleName || null,
            role: role || 'Teacher',
            statusId
        });
        
        return json({ success: true });
    } catch (error) {
        console.error('Update teacher error:', error);
        return json({ error: 'Failed to update teacher' }, { status: 500 });
    }
}

/** @type {import('./$types').RequestHandler} */
export async function DELETE({ request }) {
    const session = getSessionFromCookies(request.headers.get('cookie'));
    
    if (!isAuthenticated(session) || !hasRole(session, 'Admin')) {
        return json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    try {
        const data = await request.json();
        const { teacherId } = data;
        
        if (!teacherId) {
            return json({ error: 'Teacher ID is required' }, { status: 400 });
        }
        
        await deleteTeacher(teacherId);
        return json({ success: true });
    } catch (error) {
        console.error('Delete teacher error:', error);
        return json({ error: 'Failed to delete teacher' }, { status: 500 });
    }
}