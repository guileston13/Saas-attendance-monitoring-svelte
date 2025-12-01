// API endpoint to remove a student from a subject
import { getSessionFromCookies, isAuthenticated, hasRole } from '../../../../../../../lib/auth.js';
import { unenrollStudentFromSubject } from '../../../../../../../services/sectionService.js';

export async function DELETE({ request, params }) {
	const session = getSessionFromCookies(request.headers.get('cookie'));

	if (!isAuthenticated(session) || !hasRole(session, ['Admin', 'Teacher'])) {
		return new Response(JSON.stringify({ error: 'Unauthorized' }), {
			status: 401,
			headers: { 'Content-Type': 'application/json' }
		});
	}

	try {
		const sectionId = parseInt(params.id);
		const subjectId = parseInt(params.subjectId);
		const studentId = params.studentId; // Keep as string since it might be alphanumeric

		if (isNaN(sectionId) || isNaN(subjectId) || !studentId) {
			return new Response(JSON.stringify({ error: 'Invalid IDs' }), {
				status: 400,
				headers: { 'Content-Type': 'application/json' }
			});
		}

		// Use the service function to remove the student from the subject
		await unenrollStudentFromSubject(sectionId, subjectId, studentId);

		return new Response(JSON.stringify({ success: true }), {
			status: 200,
			headers: { 'Content-Type': 'application/json' }
		});
	} catch (error) {
		console.error('Error removing student:', error);
		return new Response(JSON.stringify({ error: 'Failed to remove student' }), {
			status: 500,
			headers: { 'Content-Type': 'application/json' }
		});
	}
}