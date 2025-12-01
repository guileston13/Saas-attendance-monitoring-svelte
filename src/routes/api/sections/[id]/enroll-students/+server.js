// API endpoint to enroll students in a subject
import { getSessionFromCookies, isAuthenticated, hasRole } from '../../../../../lib/auth.js';
import { enrollStudentInSubject } from '../../../../../services/sectionService.js';

export async function POST({ request, params }) {
	const session = getSessionFromCookies(request.headers.get('cookie'));

	if (!isAuthenticated(session) || !hasRole(session, ['Admin', 'Teacher'])) {
		return new Response(JSON.stringify({ error: 'Unauthorized' }), {
			status: 401,
			headers: { 'Content-Type': 'application/json' }
		});
	}

	try {
		const sectionId = parseInt(params.id);
		const { subjectId, studentIds } = await request.json();

		if (isNaN(sectionId) || !subjectId || !Array.isArray(studentIds)) {
			return new Response(JSON.stringify({ error: 'Invalid data' }), {
				status: 400,
				headers: { 'Content-Type': 'application/json' }
			});
		}

		// Enroll each student individually using the service function
		let successCount = 0;
		let errors = [];

		for (const studentId of studentIds) {
			try {
				await enrollStudentInSubject(sectionId, subjectId, studentId);
				successCount++;
			} catch (error) {
				console.error(`Error enrolling student ${studentId}:`, error);
				errors.push(`Failed to enroll student ${studentId}`);
			}
		}

		return new Response(JSON.stringify({ 
			success: true, 
			enrolled: successCount,
			errors: errors.length > 0 ? errors : undefined
		}), {
			status: 200,
			headers: { 'Content-Type': 'application/json' }
		});
	} catch (error) {
		console.error('Error enrolling students:', error);
		return new Response(JSON.stringify({ error: 'Failed to enroll students' }), {
			status: 500,
			headers: { 'Content-Type': 'application/json' }
		});
	}
}