// Subjects API endpoints
import { json } from '@sveltejs/kit';
import { getSessionFromCookies, isAuthenticated, hasRole } from '../../../lib/auth.js';
import {
    getAllSubjects,
    getSubjectById,
    createSubject,
    updateSubject,
    deleteSubject
} from '../../../services/subjectService.js';

/** @type {import('./$types').RequestHandler} */
export async function GET({ request }) {
    const session = getSessionFromCookies(request.headers.get('cookie'));

    if (!isAuthenticated(session)) {
        return json({ error: 'Unauthorized' }, { status: 401 });
    }

    try {
        const subjects = await getAllSubjects();
        return json({ subjects });
    } catch (error) {
        console.error('Get subjects error:', error);
        return json({ error: 'Failed to fetch subjects' }, { status: 500 });
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
        const { subjectName, subjectCode, statusId } = data;

        if (!subjectName || !subjectCode || !statusId) {
            return json({ error: 'Missing required fields' }, { status: 400 });
        }

        const result = await createSubject({
            subjectName,
            subjectCode,
            statusId
        });

        return json({ success: true, id: result.insertId });
    } catch (error) {
        console.error('Create subject error:', error);

        if (error.code === 'ER_DUP_ENTRY') {
            return json({ error: 'Subject code already exists' }, { status: 400 });
        }

        return json({ error: 'Failed to create subject' }, { status: 500 });
    }
}

/** @type {import('./$types').RequestHandler} */
export async function PUT({ request }) {
    const session = getSessionFromCookies(request.headers.get('cookie'));

    console.log('PUT /api/subjects - Session:', session);

    if (!isAuthenticated(session) || !hasRole(session, 'Admin')) {
        console.log('PUT /api/subjects - Unauthorized');
        return json({ error: 'Unauthorized' }, { status: 401 });
    }

    try {
        const data = await request.json();
        console.log('PUT /api/subjects - Request data:', data);

        const { subjectId, subjectName, subjectCode, statusId } = data;

        if (!subjectId || !subjectName || !subjectCode || !statusId) {
            console.log('PUT /api/subjects - Missing required fields');
            return json({ error: 'Missing required fields' }, { status: 400 });
        }

        console.log('PUT /api/subjects - Updating subject:', subjectId);
        await updateSubject(subjectId, {
            subjectName,
            subjectCode,
            statusId
        });

        console.log('PUT /api/subjects - Update successful');
        return json({ success: true });
    } catch (error) {
        console.error('Update subject error:', error);
        console.error('Error details:', {
            message: error.message,
            code: error.code,
            stack: error.stack
        });

        if (error.code === 'ER_DUP_ENTRY') {
            return json({ error: 'Subject code already exists' }, { status: 400 });
        }

        return json({ error: 'Failed to update subject', details: error.message }, { status: 500 });
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
        const { subjectId } = data;

        if (!subjectId) {
            return json({ error: 'Subject ID is required' }, { status: 400 });
        }

        await deleteSubject(subjectId);
        return json({ success: true });
    } catch (error) {
        console.error('Delete subject error:', error);
        return json({ error: 'Failed to delete subject' }, { status: 500 });
    }
}