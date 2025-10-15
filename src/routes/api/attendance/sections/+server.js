// API endpoint for getting sections accessible for attendance management
import { getSessionFromCookies, isAuthenticated, hasRole } from '../../../../lib/auth.js';
import { getAllSections } from '../../../../services/sectionService.js';
import { getTeacherSections } from '../../../../services/attendanceService.js';

export async function GET({ request }) {
    const session = getSessionFromCookies(request.headers.get('cookie'));

    if (!isAuthenticated(session) || !hasRole(session, ['Admin', 'Teacher'])) {
        return new Response(JSON.stringify({ error: 'Unauthorized' }), {
            status: 401,
            headers: { 'Content-Type': 'application/json' }
        });
    }

    try {
        let sections = [];
        
        if (session.role === 'Admin') {
            // Admin can see all sections
            sections = await getAllSections();
        } else if (session.role === 'Teacher') {
            // Teacher can only see sections they are assigned to
            sections = await getTeacherSections(session.userId);
        }

        return new Response(JSON.stringify({ 
            success: true, 
            sections: sections,
            userRole: session.role,
            totalSections: sections.length
        }), {
            status: 200,
            headers: { 'Content-Type': 'application/json' }
        });
        
    } catch (error) {
        console.error('Error fetching sections for attendance:', error);
        return new Response(JSON.stringify({ 
            error: 'Failed to fetch sections',
            details: error.message 
        }), {
            status: 500,
            headers: { 'Content-Type': 'application/json' }
        });
    }
}