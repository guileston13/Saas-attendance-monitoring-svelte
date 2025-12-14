// Attendance page server logic - handles authentication and real data loading
import { redirect } from '@sveltejs/kit';
import { getSessionFromCookies, isAuthenticated, hasRole } from '../../lib/auth.js';
import { getAllSections } from '../../services/sectionService.js';
import { getTeacherSections, getTeacherSubjectsInSection } from '../../services/attendanceService.js';

/** @type {import('./$types').PageServerLoad} */
export async function load({ request, url }) {
	const session = getSessionFromCookies(request.headers.get('cookie'));
	
	if (!isAuthenticated(session)) {
		throw redirect(302, '/login');
	}
	
	// Only Admin and Teacher have access to attendance module
	if (!hasRole(session, ['Admin', 'Teacher'])) {
		throw redirect(302, '/dashboard');
	}
	
	try {
		// Get URL parameters for navigation state
		const selectedSectionId = url.searchParams.get('section');
		const selectedSubjectId = url.searchParams.get('subject');
		const selectedMonth = url.searchParams.get('month');
		const selectedYear = url.searchParams.get('year') || new Date().getFullYear().toString();
		
		// Load sections based on user role
		let availableSections = [];
		if (session.role === 'Admin') {
			availableSections = await getAllSections();
		} else if (session.role === 'Teacher') {
			if (session.teacherId) {
				availableSections = await getTeacherSections(session.teacherId);
				console.log(`Teacher ${session.teacherId} sections:`, availableSections.length);
			} else {
				console.warn('Teacher logged in but no teacherId in session');
			}
		}
		
		// Load subject counts for each section to display in cards
		for (const section of availableSections) {
			try {
				let sectionSubjects = [];
				if (session.role === 'Admin') {
					const { getSectionSubjects } = await import('../../services/sectionService.js');
					sectionSubjects = await getSectionSubjects(section.SectionID);
				} else if (session.role === 'Teacher' && session.teacherId) {
					sectionSubjects = await getTeacherSubjectsInSection(session.teacherId, section.SectionID);
				}
				section.subjectCount = sectionSubjects.length;
			} catch (error) {
				console.error(`Failed to load subjects for section ${section.SectionID}:`, error);
				section.subjectCount = 0;
			}
		}
		
		// Load subjects if a section is selected
		let availableSubjects = [];
		if (selectedSectionId) {
			if (session.role === 'Admin') {
				// Import and use the section service
				const { getSectionSubjects } = await import('../../services/sectionService.js');
				availableSubjects = await getSectionSubjects(parseInt(selectedSectionId));
			} else if (session.role === 'Teacher' && session.teacherId) {
				availableSubjects = await getTeacherSubjectsInSection(session.teacherId, parseInt(selectedSectionId));
			}
		}
		
		// Generate current section name for layout
		let currentSection = 'Attendance';
		if (selectedSectionId) {
			const section = availableSections.find(s => s.SectionID.toString() === selectedSectionId);
			if (section) {
				currentSection = `Attendance - ${section.SectionName}`;
			}
		}
		
		return {
			session: {
				...session,
				teacherId: session.teacherId || null
			},
			availableSections,
			availableSubjects,
			selectedSectionId,
			selectedSubjectId,
			selectedMonth,
			selectedYear,
			currentSection
		};
	} catch (error) {
		console.error('Attendance load error:', error);
		return {
			session,
			availableSections: [],
			availableSubjects: [],
			selectedSectionId: null,
			selectedSubjectId: null,
			selectedMonth: null,
			selectedYear: new Date().getFullYear().toString(),
			error: 'Failed to load attendance data',
			currentSection: 'Attendance'
		};
	}
}