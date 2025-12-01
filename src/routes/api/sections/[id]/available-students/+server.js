// API endpoint to get available students for a specific subject in a section
import { getSessionFromCookies, isAuthenticated, hasRole } from '../../../../../lib/auth.js';
import { getAvailableStudentsForSubject } from '../../../../../services/sectionService.js';

export async function GET({ request, params, url }) {
	const session = getSessionFromCookies(request.headers.get('cookie'));
	
	if (!isAuthenticated(session)) {
		return new Response(JSON.stringify({ error: 'Unauthorized' }), {
			status: 401,
			headers: { 'Content-Type': 'application/json' }
		});
	}
	
	try {
		const sectionId = parseInt(params.id);
		const subjectId = parseInt(url.searchParams.get('subjectId'));
		
		if (isNaN(sectionId) || isNaN(subjectId)) {
			return new Response(JSON.stringify({ error: 'Invalid section or subject ID' }), {
				status: 400,
				headers: { 'Content-Type': 'application/json' }
			});
		}
		
		// Use the service function to get available students for the specific subject
		const students = await getAvailableStudentsForSubject(sectionId, subjectId);
		
		return new Response(JSON.stringify({ students }), {
			status: 200,
			headers: { 'Content-Type': 'application/json' }
		});
	} catch (error) {
		console.error('Error fetching available students:', error);
		return new Response(JSON.stringify({ error: 'Failed to fetch available students' }), {
			status: 500,
			headers: { 'Content-Type': 'application/json' }
		});
	}
}