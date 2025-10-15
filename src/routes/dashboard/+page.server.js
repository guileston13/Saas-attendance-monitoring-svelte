// Dashboard page server load - requires authentication
import { redirect } from '@sveltejs/kit';
import { getSessionFromCookies, isAuthenticated } from '../../lib/auth.js';
import { getAllSections } from '../../services/sectionService.js';
import { getAllStudents } from '../../services/studentService.js';
import { getAllTeachers } from '../../services/teacherService.js';
import { getAllSubjects } from '../../services/subjectService.js';

/** @type {import('./$types').PageServerLoad} */
export async function load({ request }) {
	const session = getSessionFromCookies(request.headers.get('cookie'));
	
	if (!isAuthenticated(session)) {
		throw redirect(302, '/login');
	}
	
	try {
		// Load dashboard data based on user role
		let dashboardData = { session };
		
		if (session.role === 'Admin') {
			const [sections, students, teachers, subjects] = await Promise.all([
				getAllSections(),
				getAllStudents(),
				getAllTeachers(),
				getAllSubjects()
			]);
			
			dashboardData = {
				...dashboardData,
				sections,
				students,
				teachers,
				subjects,
				stats: {
					totalSections: sections.length,
					totalStudents: students.length,
					totalTeachers: teachers.length,
					totalSubjects: subjects.length
				}
			};
		} else if (session.role === 'Teacher') {
			// For teachers, show their sections and subjects
			const sections = await getAllSections(); // In real app, filter by teacher
			dashboardData = {
				...dashboardData,
				sections: sections.slice(0, 5), // Limit for demo
				stats: {
					mySections: sections.length,
					myStudents: sections.reduce((total, section) => total + (section.StudentCount || 0), 0)
				}
			};
		} else if (session.role === 'Student') {
			// For students, show their enrolled sections
			const sections = await getAllSections(); // In real app, filter by student
			dashboardData = {
				...dashboardData,
				sections: sections.slice(0, 3), // Limit for demo
				stats: {
					enrolledSections: 3
				}
			};
		}
		
		return dashboardData;
	} catch (error) {
		console.error('Dashboard load error:', error);
		return {
			session,
			error: 'Unable to load dashboard data'
		};
	}
}