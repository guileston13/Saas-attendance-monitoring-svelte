// Students API endpoints
import { json } from '@sveltejs/kit';
import { getSessionFromCookies, isAuthenticated, hasRole } from '../../../lib/auth.js';
import { 
    getAllStudents, 
    getStudentById, 
    createStudent, 
    updateStudent, 
    deleteStudent 
} from '../../../services/studentService.js';

/** @type {import('./$types').RequestHandler} */
export async function GET({ request }) {
    const session = getSessionFromCookies(request.headers.get('cookie'));
    
    if (!isAuthenticated(session)) {
        return json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    try {
        const students = await getAllStudents();
        return json({ students });
    } catch (error) {
        console.error('Get students error:', error);
        return json({ error: 'Failed to fetch students' }, { status: 500 });
    }
}

/** @type {import('./$types').RequestHandler} */
export async function POST({ request }) {
    const session = getSessionFromCookies(request.headers.get('cookie'));
    
    if (!isAuthenticated(session) || !hasRole(session, ['Admin', 'Teacher'])) {
        return json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    try {
        const data = await request.json();
        const { studentId, firstName, lastName, middleName, statusId, yearLevel } = data;
        
        if (!studentId || !firstName || !lastName || !statusId || !yearLevel) {
            return json({ error: 'Missing required fields' }, { status: 400 });
        }
        
        const result = await createStudent({
            studentId,
            firstName,
            lastName,
            middleName: middleName || null,
            statusId,
            yearLevel,
            userId: null
        });
        
        return json({ success: true, id: result.insertId });
    } catch (error) {
        console.error('Create student error:', error);
        
        if (error.code === 'ER_DUP_ENTRY') {
            return json({ error: 'Student ID already exists' }, { status: 400 });
        }
        
        return json({ error: 'Failed to create student' }, { status: 500 });
    }
}

/** @type {import('./$types').RequestHandler} */
export async function PUT({ request }) {
    const session = getSessionFromCookies(request.headers.get('cookie'));
    
    if (!isAuthenticated(session) || !hasRole(session, ['Admin', 'Teacher'])) {
        return json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    try {
        const data = await request.json();
        const { studentId, firstName, lastName, middleName, statusId, yearLevel } = data;
        
        if (!studentId || !firstName || !lastName || !statusId || !yearLevel) {
            return json({ error: 'Missing required fields' }, { status: 400 });
        }
        
        await updateStudent(studentId, {
            firstName,
            lastName,
            middleName: middleName || null,
            statusId,
            yearLevel
        });
        
        return json({ success: true });
    } catch (error) {
        console.error('Update student error:', error);
        return json({ error: 'Failed to update student' }, { status: 500 });
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
        const { studentId } = data;
        
        if (!studentId) {
            return json({ error: 'Student ID is required' }, { status: 400 });
        }
        
        await deleteStudent(studentId);
        return json({ success: true });
    } catch (error) {
        console.error('Delete student error:', error);
        return json({ error: 'Failed to delete student' }, { status: 500 });
    }
}