// API endpoint to update subject assignment in a section
import { getSessionFromCookies, isAuthenticated, hasRole } from '../../../../../../lib/auth.js';
import { executeQuery } from '../../../../../../services/database.js';
import { getSubjectEnrollments } from '../../../../../../services/sectionService.js';

export async function GET({ params }) {
	try {
		const sectionId = parseInt(params.id);
		const subjectId = parseInt(params.subjectId);
		
		if (isNaN(sectionId) || isNaN(subjectId)) {
			return new Response(JSON.stringify({ error: 'Invalid section or subject ID' }), {
				status: 400,
				headers: { 'Content-Type': 'application/json' }
			});
		}
		
		const students = await getSubjectEnrollments(sectionId, subjectId);
		return new Response(JSON.stringify(students), {
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

export async function PUT({ request, params }) {
	console.log('PUT request received for subject update:', params);
	const session = getSessionFromCookies(request.headers.get('cookie'));

	if (!isAuthenticated(session) || !hasRole(session, 'Admin')) {
		return new Response(JSON.stringify({ error: 'Unauthorized' }), {
			status: 401,
			headers: { 'Content-Type': 'application/json' }
		});
	}

	try {
		const sectionId = parseInt(params.id);
		const subjectId = parseInt(params.subjectId);
		const { RoomID, StartTime, EndTime, TeacherID } = await request.json();

		if (isNaN(sectionId) || isNaN(subjectId)) {
			return new Response(JSON.stringify({ error: 'Invalid section or subject ID' }), {
				status: 400,
				headers: { 'Content-Type': 'application/json' }
			});
		}

		// Update the subject assignment
		const query = `
			UPDATE section_subjects
			SET RoomID = ?, StartTime = ?, EndTime = ?, TeacherID = ?
			WHERE SectionID = ? AND SubjectID = ?
		`;

		const result = await executeQuery(query, [RoomID, StartTime, EndTime, TeacherID, sectionId, subjectId]);

		if (result.affectedRows === 0) {
			return new Response(JSON.stringify({ error: 'Subject assignment not found' }), {
				status: 404,
				headers: { 'Content-Type': 'application/json' }
			});
		}

		return new Response(JSON.stringify({
			success: true,
			message: 'Subject assignment updated successfully'
		}), {
			status: 200,
			headers: { 'Content-Type': 'application/json' }
		});
	} catch (error) {
		console.error('Error updating subject assignment:', error);
		return new Response(JSON.stringify({ error: 'Failed to update subject assignment' }), {
			status: 500,
			headers: { 'Content-Type': 'application/json' }
		});
	}
}