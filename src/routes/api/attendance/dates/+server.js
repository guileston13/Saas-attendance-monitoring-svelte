// Attendance Dates API - Get filtered dates for a subject based on schedule
import { json } from '@sveltejs/kit';
import { getSessionFromCookies, isAuthenticated, hasRole } from '../../../../lib/auth.js';
import { getSubjectAttendanceDates, getSubjectSchedule } from '../../../../services/attendanceService.js';

/** @type {import('./$types').RequestHandler} */
export async function GET({ request, url }) {
    const session = getSessionFromCookies(request.headers.get('cookie'));
    
    if (!isAuthenticated(session) || !hasRole(session, ['Admin', 'Teacher'])) {
        return json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    try {
        const sectionId = parseInt(url.searchParams.get('sectionId'));
        const subjectId = parseInt(url.searchParams.get('subjectId'));
        const year = url.searchParams.get('year');
        const month = url.searchParams.get('month');
        
        if (!sectionId || !subjectId || !year || !month) {
            return json({ 
                error: 'Missing required parameters: sectionId, subjectId, year, month' 
            }, { status: 400 });
        }
        
        // Get subject schedule info
        const schedule = await getSubjectSchedule(sectionId, subjectId);
        
        if (!schedule) {
            return json({ 
                error: 'No schedule found for this subject' 
            }, { status: 404 });
        }
        
        // Get filtered dates
        const dates = await getSubjectAttendanceDates(sectionId, subjectId, year, month);
        
        return json({ 
            success: true,
            dates,
            schedule,
            metadata: {
                sectionId,
                subjectId,
                year,
                month,
                totalDates: dates.length
            }
        });
        
    } catch (error) {
        console.error('Error fetching attendance dates:', error);
        return json({ 
            error: 'Failed to fetch attendance dates',
            details: error.message 
        }, { status: 500 });
    }
}
