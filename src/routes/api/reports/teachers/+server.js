// API endpoint for fetching teachers for reports
import { json } from '@sveltejs/kit';
import { getSessionFromCookies, isAuthenticated } from '../../../../lib/auth.js';
import { getAllTeachersForReports } from '../../../../services/reportService.js';

/** @type {import('./$types').RequestHandler} */
export async function GET({ request }) {
    const session = getSessionFromCookies(request.headers.get('cookie'));
    
    if (!isAuthenticated(session)) {
        return json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    try {
        const teachers = await getAllTeachersForReports();
        
        return json({ 
            success: true,
            teachers 
        });
        
    } catch (error) {
        console.error('Error fetching teachers for reports:', error);
        return json({ 
            error: 'Failed to fetch teachers' 
        }, { status: 500 });
    }
}
