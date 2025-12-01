// Sections API endpoints
import { json } from '@sveltejs/kit';
import { getSessionFromCookies, isAuthenticated, hasRole } from '../../../lib/auth.js';
import { 
    getAllSections, 
    getSectionById, 
    createSection, 
    updateSection, 
    deleteSection,
    getSectionDetails
} from '../../../services/sectionService.js';

/** @type {import('./$types').RequestHandler} */
export async function GET({ request, url }) {
    const session = getSessionFromCookies(request.headers.get('cookie'));
    
    if (!isAuthenticated(session)) {
        return json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    try {
        const sectionId = url.searchParams.get('id');
        const details = url.searchParams.get('details') === 'true';
        
        if (sectionId && details) {
            // Get section details with subjects and students
            const sectionDetails = await getSectionDetails(parseInt(sectionId));
            const section = await getSectionById(parseInt(sectionId));
            return json({ section, details: sectionDetails });
        } else if (sectionId) {
            // Get single section
            const section = await getSectionById(parseInt(sectionId));
            return json({ section });
        } else {
            // Get all sections
            const sections = await getAllSections();
            return json({ sections });
        }
    } catch (error) {
        console.error('Get sections error:', error);
        return json({ error: 'Failed to fetch sections' }, { status: 500 });
    }
}

/** @type {import('./$types').RequestHandler} */
export async function POST({ request }) {
    const session = getSessionFromCookies(request.headers.get('cookie'));
    
    if (!isAuthenticated(session) || !hasRole(session, 'Admin')) {
        return json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    try {
        const data = await request.json();
        const { sectionName } = data;
        
        if (!sectionName) {
            return json({ error: 'Section name is required' }, { status: 400 });
        }
        
        const result = await createSection({ sectionName });
        return json({ success: true, id: result.insertId });
    } catch (error) {
        console.error('Create section error:', error);
        
        if (error.code === 'ER_DUP_ENTRY') {
            return json({ error: 'Section name already exists' }, { status: 400 });
        }
        
        return json({ error: 'Failed to create section' }, { status: 500 });
    }
}

/** @type {import('./$types').RequestHandler} */
export async function PUT({ request }) {
    const session = getSessionFromCookies(request.headers.get('cookie'));
    
    if (!isAuthenticated(session) || !hasRole(session, 'Admin')) {
        return json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    try {
        const data = await request.json();
        const { sectionId, sectionName } = data;
        
        if (!sectionId || !sectionName) {
            return json({ error: 'Section ID and name are required' }, { status: 400 });
        }
        
        await updateSection(sectionId, { sectionName });
        return json({ success: true });
    } catch (error) {
        console.error('Update section error:', error);
        
        if (error.code === 'ER_DUP_ENTRY') {
            return json({ error: 'Section name already exists' }, { status: 400 });
        }
        
        return json({ error: 'Failed to update section' }, { status: 500 });
    }
}

/** @type {import('./$types').RequestHandler} */
export async function DELETE({ request }) {
    const session = getSessionFromCookies(request.headers.get('cookie'));
    
    if (!isAuthenticated(session) || !hasRole(session, 'Admin')) {
        return json({ error: 'Unauthorized' }, { status: 401 });
    }
    
    try {
        const data = await request.json();
        const { sectionId } = data;
        
        if (!sectionId) {
            return json({ error: 'Section ID is required' }, { status: 400 });
        }
        
        await deleteSection(sectionId);
        return json({ success: true });
    } catch (error) {
        console.error('Delete section error:', error);
        return json({ error: 'Failed to delete section' }, { status: 500 });
    }
}