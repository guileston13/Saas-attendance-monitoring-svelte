// Improved sections page with subject-based enrollment
import { redirect } from '@sveltejs/kit';
import { getSessionFromCookies, isAuthenticated, hasRole } from '../../lib/auth.js';
import { getAllSections, getSectionById, getSectionSubjects, createSection, updateSection, deleteSection } from '../../services/sectionService.js';
import { getAllSubjects } from '../../services/subjectService.js';
import { getAllTeachers } from '../../services/teacherService.js';
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
		
		// Load all sections
		const sections = await getAllSections();
		
		// If a section is selected, load its details
		if (selectedSectionId) {
			selectedSection = await getSectionById(parseInt(selectedSectionId));
			if (selectedSection) {
				sectionSubjects = await getSectionSubjects(parseInt(selectedSectionId));
			}
		}
		
		// Load subjects and teachers for admin operations
		let subjects = [];
		let teachers = [];
		let statuses = [];
		
		if (hasRole(session, 'Admin')) {
			[subjects, teachers, statuses] = await Promise.all([
				getAllSubjects(),
				getAllTeachers(),
				executeQuery('SELECT * FROM status ORDER BY StatusName')
			]);
		}
		
		return {
			session,
			sections,
			selectedSection,
			sectionSubjects,
			subjects,
			teachers,
			statuses,
			currentSection: selectedSection ? selectedSection.SectionName : 'Sections'
		};
	} catch (error) {
		console.error('Sections load error:', error);
		return {
			session,
			sections: [],
			selectedSection: null,
			sectionSubjects: [],
			subjects: [],
			teachers: [],
			statuses: [],
			error: 'Failed to load sections data',
			currentSection: 'Sections'
		};
	}
}

/** @type {import('./$types').Actions} */
export const actions = {
	createSection: async ({ request }) => {
		const session = getSessionFromCookies(request.headers.get('cookie'));
		
		if (!isAuthenticated(session) || !hasRole(session, 'Admin')) {
			return { success: false, error: 'Unauthorized' };
		}
		
		try {
			const data = await request.formData();
			const sectionName = data.get('sectionName');
			const statusId = data.get('statusId') || 1;
			
			if (!sectionName) {
				return { success: false, error: 'Section name is required' };
			}
			
			await createSection({ sectionName, statusId });
			return { success: true };
		} catch (error) {
			console.error('Create section error:', error);
			return { success: false, error: 'Failed to create section' };
		}
	},
	
	updateSection: async ({ request }) => {
		const session = getSessionFromCookies(request.headers.get('cookie'));
		
		if (!isAuthenticated(session) || !hasRole(session, 'Admin')) {
			return { success: false, error: 'Unauthorized' };
		}
		
		try {
			const data = await request.formData();
			const sectionId = parseInt(data.get('sectionId'));
			const sectionName = data.get('sectionName');
			const statusId = data.get('statusId');
			
			if (!sectionId || !sectionName) {
				return { success: false, error: 'Section ID and name are required' };
			}
			
			await updateSection(sectionId, { sectionName, statusId });
			return { success: true };
		} catch (error) {
			console.error('Update section error:', error);
			return { success: false, error: 'Failed to update section' };
		}
	},
	
	deleteSection: async ({ request }) => {
		const session = getSessionFromCookies(request.headers.get('cookie'));
		
		if (!isAuthenticated(session) || !hasRole(session, 'Admin')) {
			return { success: false, error: 'Unauthorized' };
		}
		
		try {
			const data = await request.formData();
			const sectionId = parseInt(data.get('sectionId'));
			
			if (!sectionId) {
				return { success: false, error: 'Section ID is required' };
			}
			
			await deleteSection(sectionId);
			return { success: true };
		} catch (error) {
			console.error('Delete section error:', error);
			return { success: false, error: 'Failed to delete section' };
		}
	}
};