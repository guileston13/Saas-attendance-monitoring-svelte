// API endpoint for fetching attendance report data
import { json } from '@sveltejs/kit';
import { getSessionFromCookies, isAuthenticated, hasRole } from '../../../../lib/auth.js';
import { getAttendanceReportData } from '../../../../services/reportService.js';

/** @type {import('./$types').RequestHandler} */
export async function POST({ request }) {
    const session = getSessionFromCookies(request.headers.get('cookie'));
    
    if (!isAuthenticated(session)) {
        return json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    try {
        const data = await request.json();
        const { sectionId, subjectId, startDate, endDate, teacherId } = data;
        
        // Validate required fields
        if (!sectionId || !subjectId || !startDate || !endDate) {
            return json({ 
                error: 'Missing required fields: sectionId, subjectId, startDate, endDate' 
            }, { status: 400 });
        }
        
        // Validate date format (YYYY-MM-DD)
        const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
        if (!dateRegex.test(startDate) || !dateRegex.test(endDate)) {
            return json({ 
                error: 'Invalid date format. Use YYYY-MM-DD' 
            }, { status: 400 });
        }
        
        // Validate date range
        if (new Date(startDate) > new Date(endDate)) {
            return json({ 
                error: 'Start date must be before or equal to end date' 
            }, { status: 400 });
        }
        
        // Authorization check
        // Teachers can only view their own subjects
        if (session.role === 'Teacher' && teacherId && session.teacherId !== parseInt(teacherId)) {
            return json({ 
                error: 'You can only view reports for your own subjects' 
            }, { status: 403 });
        }
        
        // Fetch report data
        const result = await getAttendanceReportData(
            parseInt(sectionId),
            parseInt(subjectId),
            startDate,
            endDate,
            teacherId ? parseInt(teacherId) : null
        );
        
        return json(result);
        
    } catch (error) {
        console.error('Error generating attendance report:', error);
        return json({ 
            error: 'Failed to generate report',
            message: error.message 
        }, { status: 500 });
    }
}
