import { json } from '@sveltejs/kit';
import { getSectionSubjects } from '../../../../../services/sectionService.js';

export async function GET({ params }) {
	try {
		const sectionId = parseInt(params.id);
		
		if (isNaN(sectionId)) {
			return json({ error: 'Invalid section ID' }, { status: 400 });
		}
		
		const subjects = await getSectionSubjects(sectionId);
		return json(subjects);
	} catch (error) {
		console.error('Error fetching section subjects:', error);
		return json({ error: 'Failed to fetch subjects' }, { status: 500 });
	}
}
