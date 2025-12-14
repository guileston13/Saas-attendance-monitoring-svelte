// API endpoint for getting subjects in a section for attendance management
import { getSessionFromCookies, isAuthenticated, hasRole } from '../../../../../lib/auth.js';
import { getSectionSubjects } from '../../../../../services/sectionService.js';
import { getTeacherSubjectsInSection } from '../../../../../services/attendanceService.js';

export async function GET({ request, params }) {
    const session = getSessionFromCookies(request.headers.get('cookie'));
    
    console.log('GET /api/attendance/sections/[id] - Session:', {
        role: session?.role,
        teacherId: session?.teacherId,
        userId: session?.userId
    });

    if (!isAuthenticated(session) || !hasRole(session, ['Admin', 'Teacher'])) {
        return new Response(JSON.stringify({ error: 'Unauthorized' }), {
            status: 401,
            headers: { 'Content-Type': 'application/json' }
        });
    }

    try {
        const sectionId = parseInt(params.id);
        console.log('Section ID requested:', sectionId);
        
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
            console.log(`Admin subjects in section ${sectionId}:`, subjects.length);
        } else if (session.role === 'Teacher') {
            if (session.teacherId) {
                // Teacher can only see subjects they are assigned to in this section
                subjects = await getTeacherSubjectsInSection(session.teacherId, sectionId);
                console.log(`Teacher ${session.teacherId} subjects in section ${sectionId}:`, subjects.length, subjects);
            } else {
                console.warn('API: Teacher logged in but no teacherId in session');
                console.warn('Full session:', session);
            }
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