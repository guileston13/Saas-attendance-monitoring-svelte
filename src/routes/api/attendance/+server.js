// API endpoint for attendance data management
import { getSessionFromCookies, isAuthenticated, hasRole } from '../../../lib/auth.js';
import { 
    getAttendanceRecords, 
    getEnrolledStudentsForAttendance,
    getAttendanceStatistics,
    generateMonthlyAttendanceRecords,
    attendanceRecordsExist,
    updateAttendanceRecord,
    bulkUpdateAttendance
} from '../../../services/attendanceService.js';

// GET attendance records
export async function GET({ request, url }) {
    const session = getSessionFromCookies(request.headers.get('cookie'));

    if (!isAuthenticated(session) || !hasRole(session, ['Admin', 'Teacher'])) {
        return new Response(JSON.stringify({ error: 'Unauthorized' }), {
            status: 401,
            headers: { 'Content-Type': 'application/json' }
        });
    }

    try {
        const sectionId = parseInt(url.searchParams.get('sectionId'));
        const subjectId = parseInt(url.searchParams.get('subjectId'));
        const year = url.searchParams.get('year');
        const month = url.searchParams.get('month');
        const action = url.searchParams.get('action') || 'records';

        if (!sectionId || !subjectId || !year || !month) {
            return new Response(JSON.stringify({ 
                error: 'Missing required parameters: sectionId, subjectId, year, month' 
            }), {
                status: 400,
                headers: { 'Content-Type': 'application/json' }
            });
        }

        // TODO: Add teacher permission check - ensure teacher can only access their assigned subjects
        // This would require checking if the teacher is assigned to this section/subject

        let data;
        switch (action) {
            case 'records':
                // Get attendance records
                data = await getAttendanceRecords(sectionId, subjectId, year, month);
                break;
                
            case 'students':
                // Get enrolled students
                data = await getEnrolledStudentsForAttendance(sectionId, subjectId);
                break;
                
            case 'statistics':
                // Get attendance statistics
                data = await getAttendanceStatistics(sectionId, subjectId, year, month);
                break;
                
            case 'exists':
                // Check if records exist
                data = { exists: await attendanceRecordsExist(sectionId, subjectId, year, month) };
                break;
                
            default:
                return new Response(JSON.stringify({ error: 'Invalid action' }), {
                    status: 400,
                    headers: { 'Content-Type': 'application/json' }
                });
        }

        return new Response(JSON.stringify({ 
            success: true, 
            data: data,
            metadata: {
                sectionId,
                subjectId,
                year,
                month,
                action
            }
        }), {
            status: 200,
            headers: { 'Content-Type': 'application/json' }
        });
        
    } catch (error) {
        console.error('Error fetching attendance data:', error);
        return new Response(JSON.stringify({ 
            error: 'Failed to fetch attendance data',
            details: error.message 
        }), {
            status: 500,
            headers: { 'Content-Type': 'application/json' }
        });
    }
}

// POST attendance updates
export async function POST({ request }) {
    const session = getSessionFromCookies(request.headers.get('cookie'));

    if (!isAuthenticated(session) || !hasRole(session, ['Admin', 'Teacher'])) {
        return new Response(JSON.stringify({ error: 'Unauthorized' }), {
            status: 401,
            headers: { 'Content-Type': 'application/json' }
        });
    }

    try {
        const body = await request.json();
        const { action, ...data } = body;

        if (!action) {
            return new Response(JSON.stringify({ error: 'Action is required' }), {
                status: 400,
                headers: { 'Content-Type': 'application/json' }
            });
        }

        let result;
        switch (action) {
            case 'update':
                // Single attendance record update
                const { studentId, subjectId, sectionId, date, status } = data;
                
                if (!studentId || !subjectId || !sectionId || !date || !status) {
                    return new Response(JSON.stringify({ 
                        error: 'Missing required fields for update' 
                    }), {
                        status: 400,
                        headers: { 'Content-Type': 'application/json' }
                    });
                }
                
                result = await updateAttendanceRecord(
                    studentId, 
                    subjectId, 
                    sectionId, 
                    date, 
                    status, 
                    session.userId
                );
                break;
                
            case 'bulkUpdate':
                // Bulk attendance updates
                const { updates } = data;
                if (!Array.isArray(updates) || updates.length === 0) {
                    return new Response(JSON.stringify({ 
                        error: 'Updates array is required and must not be empty' 
                    }), {
                        status: 400,
                        headers: { 'Content-Type': 'application/json' }
                    });
                }
                
                // Add recordedBy to each update
                const updatesWithRecorder = updates.map(update => ({
                    ...update,
                    recordedBy: session.userId
                }));
                
                result = await bulkUpdateAttendance(updatesWithRecorder);
                break;
                
            case 'generate':
                // Generate monthly attendance records
                const { sectionId: genSectionId, subjectId: genSubjectId, year, month } = data;
                if (!genSectionId || !genSubjectId || !year || !month) {
                    return new Response(JSON.stringify({ 
                        error: 'Missing required fields for generation' 
                    }), {
                        status: 400,
                        headers: { 'Content-Type': 'application/json' }
                    });
                }
                
                result = await generateMonthlyAttendanceRecords(
                    genSectionId, 
                    genSubjectId, 
                    year, 
                    month, 
                    session.userId
                );
                break;
                
            default:
                return new Response(JSON.stringify({ error: 'Invalid action' }), {
                    status: 400,
                    headers: { 'Content-Type': 'application/json' }
                });
        }

        return new Response(JSON.stringify({ 
            success: true, 
            result: result,
            message: 'Attendance updated successfully'
        }), {
            status: 200,
            headers: { 'Content-Type': 'application/json' }
        });
        
    } catch (error) {
        console.error('Error updating attendance:', error);
        return new Response(JSON.stringify({ 
            error: 'Failed to update attendance',
            details: error.message 
        }), {
            status: 500,
            headers: { 'Content-Type': 'application/json' }
        });
    }
}