// API endpoint to get enrolled students for a specific subject in a section
import { getSessionFromCookies, isAuthenticated, hasRole } from '../../../../../../lib/auth.js';
import { getSubjectEnrollments } from '../../../../../../services/sectionService.js';

export async function GET({ request, params }) {
	const session = getSessionFromCookies(request.headers.get('cookie'));

	if (!isAuthenticated(session)) {
		return new Response(JSON.stringify({ error: 'Unauthorized' }), {
			status: 401,
			headers: { 'Content-Type': 'application/json' }
		});
	}

	try {
		const sectionId = parseInt(params.id);
		const subjectId = parseInt(params.subjectId);

		if (isNaN(sectionId) || isNaN(subjectId)) {
			return new Response(JSON.stringify({ error: 'Invalid section or subject ID' }), {
				status: 400,
				headers: { 'Content-Type': 'application/json' }
			});
		}

		// Use the service function to get enrolled students
		const students = await getSubjectEnrollments(sectionId, subjectId);

		return new Response(JSON.stringify({ students }), {
			status: 200,
			headers: { 'Content-Type': 'application/json' }
		});
	} catch (error) {
		console.error('Error fetching enrolled students:', error);
		return new Response(JSON.stringify({ error: 'Failed to fetch enrolled students' }), {
			status: 500,
			headers: { 'Content-Type': 'application/json' }
		});
	}
}