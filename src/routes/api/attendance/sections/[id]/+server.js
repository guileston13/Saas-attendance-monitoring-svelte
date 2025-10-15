// API endpoint for getting subjects in a section for attendance management
import { getSessionFromCookies, isAuthenticated, hasRole } from '../../../../../lib/auth.js';
import { getSectionSubjects } from '../../../../../services/sectionService.js';
import { getTeacherSubjectsInSection } from '../../../../../services/attendanceService.js';

export async function GET({ request, params }) {
    const session = getSessionFromCookies(request.headers.get('cookie'));

    if (!isAuthenticated(session) || !hasRole(session, ['Admin', 'Teacher'])) {
        return new Response(JSON.stringify({ error: 'Unauthorized' }), {
            status: 401,
            headers: { 'Content-Type': 'application/json' }
        });
    }

    try {
        const sectionId = parseInt(params.id);
        
        if (isNaN(sectionId)) {
            return new Response(JSON.stringify({ error: 'Invalid section ID' }), {
                status: 400,
                headers: { 'Content-Type': 'application/json' }
            });
        }

        let subjects = [];
        
        if (session.role === 'Admin') {
            // Admin can see all subjects in the section
            subjects = await getSectionSubjects(sectionId);
        } else if (session.role === 'Teacher') {
            // Teacher can only see subjects they are assigned to in this section
            subjects = await getTeacherSubjectsInSection(session.userId, sectionId);
        }

        return new Response(JSON.stringify({ 
            success: true, 
            subjects: subjects,
            sectionId: sectionId,
            userRole: session.role,
            totalSubjects: subjects.length
        }), {
            status: 200,
            headers: { 'Content-Type': 'application/json' }
        });
        
    } catch (error) {
        console.error('Error fetching subjects for attendance:', error);
        return new Response(JSON.stringify({ 
            error: 'Failed to fetch subjects',
            details: error.message 
        }), {
            status: 500,
            headers: { 'Content-Type': 'application/json' }
        });
    }
}