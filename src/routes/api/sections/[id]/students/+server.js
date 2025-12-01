// Section students API - manage students in a section
import { json } from '@sveltejs/kit';
import { getSessionFromCookies, isAuthenticated, hasRole } from '../../../../../lib/auth.js';
import { 
    getStudentsBySection,
    addStudentToSection,
    removeStudentFromSection,
    getAllStudents
} from '../../../../../services/studentService.js';

/** @type {import('./$types').RequestHandler} */
export async function GET({ params, request, url }) {
    const session = getSessionFromCookies(request.headers.get('cookie'));
    
    if (!isAuthenticated(session)) {
        return json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    const sectionId = parseInt(params.id);
    const action = url.searchParams.get('action');
    
    try {
        if (action === 'available') {
            // Get students not in this section for enrollment
            const [allStudents, enrolledStudents] = await Promise.all([
                getAllStudents(),
                getStudentsBySection(sectionId)
            ]);
            
            const enrolledIds = new Set(enrolledStudents.map(s => s.StudentID));
            const availableStudents = allStudents.filter(s => !enrolledIds.has(s.StudentID));
            
            return json({ students: availableStudents });
        } else {
            // Get students in this section
            const students = await getStudentsBySection(sectionId);
            return json({ students });
        }
    } catch (error) {
        console.error('Get section students error:', error);
        return json({ error: 'Failed to fetch students' }, { status: 500 });
    }
}

/** @type {import('./$types').RequestHandler} */
export async function POST({ params, request }) {
    const session = getSessionFromCookies(request.headers.get('cookie'));
    
    if (!isAuthenticated(session) || !hasRole(session, ['Admin', 'Teacher'])) {
        return json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    const sectionId = parseInt(params.id);
    
    try {
        const data = await request.json();
        const { studentId } = data;
        
        if (!studentId) {
            return json({ error: 'Student ID is required' }, { status: 400 });
        }
        
        await addStudentToSection(sectionId, studentId);
        return json({ success: true });
    } catch (error) {
        console.error('Add student to section error:', error);
        
        if (error.code === 'ER_DUP_ENTRY') {
            return json({ error: 'Student is already enrolled in this section' }, { status: 400 });
        }
        
        return json({ error: 'Failed to add student to section' }, { status: 500 });
    }
}

/** @type {import('./$types').RequestHandler} */
export async function DELETE({ params, request }) {
    const session = getSessionFromCookies(request.headers.get('cookie'));
    
    if (!isAuthenticated(session) || !hasRole(session, ['Admin', 'Teacher'])) {
        return json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    const sectionId = parseInt(params.id);
    
    try {
        const data = await request.json();
        const { studentId } = data;
        
        if (!studentId) {
            return json({ error: 'Student ID is required' }, { status: 400 });
        }
        
        await removeStudentFromSection(sectionId, studentId);
        return json({ success: true });
    } catch (error) {
        console.error('Remove student from section error:', error);
        return json({ error: 'Failed to remove student from section' }, { status: 500 });
    }
}