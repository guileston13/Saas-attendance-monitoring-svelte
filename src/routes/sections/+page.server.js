// Improved sections page with subject-based enrollment
import { redirect } from '@sveltejs/kit';
import { getSessionFromCookies, isAuthenticated, hasRole } from '../../lib/auth.js';
import { getAllSections, getSectionById, getSectionSubjects, createSection, updateSection, deleteSection, addSubjectToSection, addSubjectToSectionSimple, getSectionsByTeacher } from '../../services/sectionService.js';
import { getAllSubjects } from '../../services/subjectService.js';
import { getAllTeachers } from '../../services/teacherService.js';
import { getAllStudents, addStudentToSection, getStudentsBySection } from '../../services/studentService.js';
import { executeQuery } from '../../services/database.js';

/** @type {import('./$types').PageServerLoad} */
export async function load({ request, url }) {
	const session = getSessionFromCookies(request.headers.get('cookie'));

	if (!isAuthenticated(session)) {
		throw redirect(302, '/login');
	}

	// Check if user has access to sections
	if (!hasRole(session, ['Admin', 'Teacher'])) {
		throw redirect(302, '/dashboard');
	}

	try {
		const selectedSectionId = url.searchParams.get('section');
		let selectedSection = null;
		let sectionSubjects = [];

		// Load sections based on user role
		let sections = [];
		if (session.role === 'Admin') {
			sections = await getAllSections();
		} else if (session.role === 'Teacher') {
			if (session.teacherId) {
				// Teachers only see their assigned sections
				sections = await getSectionsByTeacher(session.teacherId);
				console.log(`Teacher ${session.teacherId} sections loaded:`, sections.length);
			} else {
				console.warn('Teacher logged in but no teacherId in session');
			}
		}

		// If a section is selected, load its details
		if (selectedSectionId) {
			selectedSection = await getSectionById(parseInt(selectedSectionId));
			if (selectedSection) {
				sectionSubjects = await getSectionSubjects(parseInt(selectedSectionId));
				
				// For teachers, filter subjects to only show their assigned ones
				if (session.role === 'Teacher' && session.teacherId) {
					sectionSubjects = sectionSubjects.filter(sub => 
						sub.TeacherID === session.teacherId ||
						sub.MondayTeacher === session.teacherId ||
						sub.TuesdayTeacher === session.teacherId ||
						sub.WednesdayTeacher === session.teacherId ||
						sub.ThursdayTeacher === session.teacherId ||
						sub.FridayTeacher === session.teacherId
					);
				}
			}
		}

		// Load subjects and teachers for admin operations
		let subjects = [];
		let teachers = [];
		let statuses = [];
		let rooms = [];
		let students = [];

		if (hasRole(session, 'Admin')) {
			[subjects, teachers, statuses, rooms, students] = await Promise.all([
				getAllSubjects(),
				getAllTeachers(),
				executeQuery('SELECT * FROM status ORDER BY StatusName'),
				executeQuery('SELECT RoomID, RoomName FROM room ORDER BY RoomName'),
				getAllStudents()
			]);
		}

		return {
			session: {
				...session,
				teacherId: session.teacherId || null
			},
			sections,
			selectedSection,
			sectionSubjects,
			subjects,
			teachers,
			statuses,
			rooms,
			students,
			currentSection: selectedSection ? selectedSection.SectionName : 'Sections'
		};
	} catch (error) {
		console.error('Sections load error:', error);
		return {
			session: {
				...session,
				teacherId: session.teacherId || null
			},
			sections: [],
			selectedSection: null,
			sectionSubjects: [],
			subjects: [],
			teachers: [],
			statuses: [],
			rooms: [],
			students: [],
			error: 'Failed to load sections data',
			currentSection: 'Sections'
		};
	}
}

/** @type {import('./$types').Actions} */
export const actions = {
	createSection: async ({ request }) => {
		const session = getSessionFromCookies(request.headers.get('cookie'));

		if (!isAuthenticated(session) || !hasRole(session, ['Admin', 'Teacher'])) {
			return { type: 'error', error: 'Unauthorized' };
		}

		try {
			const data = await request.formData();
			const sectionName = data.get('sectionName');
			const statusId = data.get('statusId') || 1;

			if (!sectionName) {
				return { type: 'error', error: 'Section name is required' };
			}

			// Create the section
			const result = await createSection({ sectionName, statusId });
			const newSectionId = result.insertId;
			console.log(`[createSection] Created section ${newSectionId}: ${sectionName}`);

			// Auto-add all existing subjects to the new section (simple insert, no schedule)
			const allSubjects = await getAllSubjects();
			console.log(`[createSection] Found ${allSubjects.length} subjects to add`);
			
			let addedCount = 0;
			for (const subject of allSubjects) {
				try {
					await addSubjectToSectionSimple(newSectionId, subject.SubjectID);
					addedCount++;
					console.log(`[createSection] Added subject ${subject.SubjectID} (${subject.subject_name}) to section ${newSectionId}`);
				} catch (subjectError) {
					console.error(`[createSection] Failed to add subject ${subject.SubjectID} to section ${newSectionId}:`, subjectError.message);
				}
			}
			
			console.log(`[createSection] Successfully added ${addedCount}/${allSubjects.length} subjects to section ${newSectionId}`);

			return { type: 'success', data: { sectionId: newSectionId, sectionName } };
		} catch (error) {
			console.error('Create section error:', error);
			return { type: 'error', error: 'Failed to create section' };
		}
	},

	updateSection: async ({ request }) => {
		const session = getSessionFromCookies(request.headers.get('cookie'));

		if (!isAuthenticated(session) || !hasRole(session, 'Admin')) {
			return { type: 'error', error: 'Unauthorized' };
		}

		try {
			const data = await request.formData();
			const sectionId = parseInt(data.get('sectionId'));
			const sectionName = data.get('sectionName');
			const statusId = data.get('statusId');

			if (!sectionId || !sectionName) {
				return { type: 'error', error: 'Section ID and name are required' };
			}

			await updateSection(sectionId, { sectionName, statusId });
			return { type: 'success' };
		} catch (error) {
			console.error('Update section error:', error);
			return { type: 'error', error: 'Failed to update section' };
		}
	},

	deleteSection: async ({ request }) => {
		const session = getSessionFromCookies(request.headers.get('cookie'));

		if (!isAuthenticated(session) || !hasRole(session, 'Admin')) {
			return { type: 'error', error: 'Unauthorized' };
		}

		try {
			const data = await request.formData();
			const sectionId = parseInt(data.get('sectionId'));

			if (!sectionId) {
				return { type: 'error', error: 'Section ID is required' };
			}

			await deleteSection(sectionId);
			return { type: 'success' };
		} catch (error) {
			console.error('Delete section error:', error);
			return { type: 'error', error: 'Failed to delete section' };
		}
	},

	addSubject: async ({ request }) => {
		const session = getSessionFromCookies(request.headers.get('cookie'));

		if (!isAuthenticated(session) || !hasRole(session, 'Admin')) {
			return { type: 'error', error: 'Unauthorized' };
		}

		try {
			const data = await request.formData();
			const sectionId = parseInt(data.get('sectionId'));
			const subjectId = parseInt(data.get('subjectId'));
			const teacherId = data.get('teacherId') || null;
			const roomId = data.get('roomId') || null;
			const startTime = data.get('startTime') || null;
			const endTime = data.get('endTime') || null;
			const monday = data.get('monday') === 'on' ? 1 : 0;
			const tuesday = data.get('tuesday') === 'on' ? 1 : 0;
			const wednesday = data.get('wednesday') === 'on' ? 1 : 0;
			const thursday = data.get('thursday') === 'on' ? 1 : 0;
			const friday = data.get('friday') === 'on' ? 1 : 0;
			const saturday = data.get('saturday') === 'on' ? 1 : 0;

			// Parse per-day schedule with teachers and rooms
			const schedule = {
				monday: { 
					start: data.get('mondayStart') || null, 
					end: data.get('mondayEnd') || null,
					teacher: data.get('mondayTeacher') || null,
					room: data.get('mondayRoom') || null
				},
				tuesday: { 
					start: data.get('tuesdayStart') || null, 
					end: data.get('tuesdayEnd') || null,
					teacher: data.get('tuesdayTeacher') || null,
					room: data.get('tuesdayRoom') || null
				},
				wednesday: { 
					start: data.get('wednesdayStart') || null, 
					end: data.get('wednesdayEnd') || null,
					teacher: data.get('wednesdayTeacher') || null,
					room: data.get('wednesdayRoom') || null
				},
				thursday: { 
					start: data.get('thursdayStart') || null, 
					end: data.get('thursdayEnd') || null,
					teacher: data.get('thursdayTeacher') || null,
					room: data.get('thursdayRoom') || null
				},
				friday: { 
					start: data.get('fridayStart') || null, 
					end: data.get('fridayEnd') || null,
					teacher: data.get('fridayTeacher') || null,
					room: data.get('fridayRoom') || null
				},
				saturday: { 
					start: data.get('saturdayStart') || null, 
					end: data.get('saturdayEnd') || null,
					teacher: data.get('saturdayTeacher') || null,
					room: data.get('saturdayRoom') || null
				}
			};

			if (!sectionId || !subjectId) {
				return { type: 'error', error: 'Section ID and Subject ID are required' };
			}

			await addSubjectToSection(sectionId, subjectId, teacherId, roomId, startTime, endTime, monday, tuesday, wednesday, thursday, friday, saturday, schedule);
			return { type: 'success' };
		} catch (error) {
			console.error('Add subject error:', error);
			console.error('Add subject error details:', {
				message: error.message,
				code: error.code,
				errno: error.errno,
				sqlMessage: error.sqlMessage
			});
			// Return more specific error message
			if (error.code === 'ER_DUP_ENTRY') {
				return { type: 'error', error: 'This subject is already added to this section' };
			}
			return { type: 'error', error: 'Failed to add subject: ' + (error.sqlMessage || error.message) };
		}
	},

	updateSectionSubject: async ({ request }) => {
		const session = getSessionFromCookies(request.headers.get('cookie'));

		if (!isAuthenticated(session) || !hasRole(session, 'Admin')) {
			return { type: 'error', error: 'Unauthorized' };
		}

		try {
			const data = await request.formData();
			const sectionId = parseInt(data.get('sectionId'));
			const subjectId = parseInt(data.get('subjectId'));
			const teacherId = data.get('teacherId') || null;
			const roomId = data.get('roomId') || null;
			const startTime = data.get('startTime') || null;
			const endTime = data.get('endTime') || null;
			const monday = data.get('monday') === 'on' ? 1 : 0;
			const tuesday = data.get('tuesday') === 'on' ? 1 : 0;
			const wednesday = data.get('wednesday') === 'on' ? 1 : 0;
			const thursday = data.get('thursday') === 'on' ? 1 : 0;
			const friday = data.get('friday') === 'on' ? 1 : 0;
			const saturday = data.get('saturday') === 'on' ? 1 : 0;

			// Parse per-day schedule with teachers and rooms
			const schedule = {
				monday: { 
					start: data.get('mondayStart') || null, 
					end: data.get('mondayEnd') || null,
					teacher: data.get('mondayTeacher') || null,
					room: data.get('mondayRoom') || null
				},
				tuesday: { 
					start: data.get('tuesdayStart') || null, 
					end: data.get('tuesdayEnd') || null,
					teacher: data.get('tuesdayTeacher') || null,
					room: data.get('tuesdayRoom') || null
				},
				wednesday: { 
					start: data.get('wednesdayStart') || null, 
					end: data.get('wednesdayEnd') || null,
					teacher: data.get('wednesdayTeacher') || null,
					room: data.get('wednesdayRoom') || null
				},
				thursday: { 
					start: data.get('thursdayStart') || null, 
					end: data.get('thursdayEnd') || null,
					teacher: data.get('thursdayTeacher') || null,
					room: data.get('thursdayRoom') || null
				},
				friday: { 
					start: data.get('fridayStart') || null, 
					end: data.get('fridayEnd') || null,
					teacher: data.get('fridayTeacher') || null,
					room: data.get('fridayRoom') || null
				},
				saturday: { 
					start: data.get('saturdayStart') || null, 
					end: data.get('saturdayEnd') || null,
					teacher: data.get('saturdayTeacher') || null,
					room: data.get('saturdayRoom') || null
				}
			};

			if (!sectionId || !subjectId) {
				return { type: 'error', error: 'Section ID and Subject ID are required' };
			}

			const { updateSectionSubject } = await import('../../services/sectionService.js');
			await updateSectionSubject(sectionId, subjectId, teacherId, roomId, startTime, endTime, monday, tuesday, wednesday, thursday, friday, saturday, schedule);
			return { type: 'success' };
		} catch (error) {
			console.error('Update section subject error:', error);
			return { type: 'error', error: 'Failed to update subject' };
		}
	},

	enrollStudents: async ({ request }) => {
		const session = getSessionFromCookies(request.headers.get('cookie'));

		if (!isAuthenticated(session) || !hasRole(session, 'Admin')) {
			return { type: 'error', error: 'Unauthorized' };
		}

		try {
			const data = await request.formData();
			const sectionId = parseInt(data.get('sectionId'));
			const subjectId = parseInt(data.get('subjectId'));
			const studentIds = data.get('studentIds');

			if (!sectionId || !subjectId || !studentIds) {
				return { type: 'error', error: 'Section ID, Subject ID, and student IDs are required' };
			}

			const studentIdArray = JSON.parse(studentIds);

			// Import the enrollment function
			const { enrollStudentInSubject } = await import('../../services/sectionService.js');

			let successCount = 0;
			let failCount = 0;
			let failReasons = [];

			for (const studentId of studentIdArray) {
				try {
					await enrollStudentInSubject(sectionId, subjectId, studentId);
					successCount++;
				} catch (error) {
					console.warn(`Student ${studentId} enrollment failed:`, error.message);
					failCount++;
					// Collect unique failure reasons
					if (!failReasons.includes(error.message)) {
						failReasons.push(error.message);
					}
				}
			}

			// Build a more descriptive message
			let message = '';
			if (successCount > 0 && failCount === 0) {
				message = `Successfully enrolled ${successCount} student(s)`;
			} else if (successCount > 0 && failCount > 0) {
				message = `Enrolled ${successCount} student(s). ${failCount} failed: ${failReasons.join('; ')}`;
			} else if (successCount === 0 && failCount > 0) {
				message = `Failed to enroll ${failCount} student(s): ${failReasons.join('; ')}`;
			}

			return {
				type: 'success',
				data: {
					message,
					successCount,
					failCount,
					failReasons
				}
			};
		} catch (error) {
			console.error('Enroll students error:', error);
			return { type: 'error', error: 'Failed to enroll students' };
		}
	},

	unenrollStudent: async ({ request }) => {
		const session = getSessionFromCookies(request.headers.get('cookie'));

		if (!isAuthenticated(session) || !hasRole(session, 'Admin')) {
			return { type: 'error', error: 'Unauthorized' };
		}

		try {
			const data = await request.formData();
			const sectionId = parseInt(data.get('sectionId'));
			const subjectId = parseInt(data.get('subjectId'));
			const studentId = data.get('studentId');

			if (!sectionId || !subjectId || !studentId) {
				return { type: 'error', error: 'Section ID, Subject ID, and student ID are required' };
			}

			// Import the unenrollment function
			const { unenrollStudentFromSubject } = await import('../../services/sectionService.js');

			await unenrollStudentFromSubject(sectionId, subjectId, studentId);

			return { type: 'success', data: { message: 'Student unenrolled successfully' } };
		} catch (error) {
			console.error('Unenroll student error:', error);
			return { type: 'error', error: 'Failed to unenroll student' };
		}
	}
};