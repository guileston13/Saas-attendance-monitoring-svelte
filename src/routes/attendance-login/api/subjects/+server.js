import { executeQuery } from '../../../../services/database.js';

export async function GET() {
  try {
    const subjects = await executeQuery('SELECT SubjectID, SubjectName FROM subjects');
    return new Response(JSON.stringify({ subjects }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: 'Failed to fetch subjects' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
}