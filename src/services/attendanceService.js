// Attendance service - handles attendance CRUD operations and real-time data management
import { executeQuery } from './database.js';

/**
 * Convert a date to YYYY-MM-DD format without timezone issues
 * @param {Date|string} date - Date object or string
 * @returns {string} Date in YYYY-MM-DD format
 */
function formatDateString(date) {
    if (typeof date === 'string') {
        // If it's already a string, check if it's in YYYY-MM-DD format
        if (/^\d{4}-\d{2}-\d{2}$/.test(date)) {
            return date;
        }
    }
    
    if (date instanceof Date) {
        // Use local date components to avoid timezone issues
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    }
    
    // Try to parse as date if it's a string
    const parsed = new Date(date);
    if (!isNaN(parsed.getTime())) {
        const year = parsed.getFullYear();
        const month = String(parsed.getMonth() + 1).padStart(2, '0');
        const day = String(parsed.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    }
    
    return date; // Return as-is if we can't parse it
}

/**
 * Get attendance records for a specific section, subject, and month
 * @param {number} sectionId - Section ID
 * @param {number} subjectId - Subject ID  
 * @param {string} year - Year (YYYY)
 * @param {string} month - Month (MM)
 * @returns {Promise<Object>} Attendance data grouped by student and date
 */
export async function getAttendanceRecords(sectionId, subjectId, year, month) {
    const startDate = `${year}-${month.padStart(2, '0')}-01`;
    const endDate = `${year}-${month.padStart(2, '0')}-31`;
    
    const query = `
        SELECT 
            ar.student_id,
            ar.attendance_date,
            ar.status,
            ar.recorded_by,
            ar.recorded_at,
            s.FirstName,
            s.LastName,
            s.MiddleName,
            s.YearLevel
        FROM attendance_records ar
        JOIN students s ON ar.student_id = s.StudentID
        WHERE ar.section_id = ? 
        AND ar.subject_id = ?
        AND ar.attendance_date BETWEEN ? AND ?
        ORDER BY s.LastName, s.FirstName, ar.attendance_date
    `;
    
    const records = await executeQuery(query, [sectionId, subjectId, startDate, endDate]);
    
    // Group records by student
    const attendanceData = {};
    records.forEach(record => {
        if (!attendanceData[record.student_id]) {
            attendanceData[record.student_id] = {
                student: {
                    StudentID: record.student_id,
                    FirstName: record.FirstName,
                    LastName: record.LastName,
                    MiddleName: record.MiddleName,
                    YearLevel: record.YearLevel
                },
                attendance: {}
            };
        }
        
        const dateStr = formatDateString(record.attendance_date);
        attendanceData[record.student_id].attendance[dateStr] = {
            status: record.status.toLowerCase(),
            recordedBy: record.recorded_by,
            recordedAt: record.recorded_at
        };
    });
    
    return attendanceData;
}

/**
 * Get all students enrolled in a section and subject
 * @param {number} sectionId - Section ID
 * @param {number} subjectId - Subject ID
 * @returns {Promise<Array>} Array of enrolled students
 */
export async function getEnrolledStudentsForAttendance(sectionId, subjectId) {
    const query = `
        SELECT DISTINCT
            s.StudentID,
            s.FirstName,
            s.LastName,
            s.MiddleName,
            s.YearLevel,
            s.StatusID
        FROM students s
        JOIN subject_enrollments se ON s.StudentID = se.StudentID
        WHERE se.SectionID = ? AND se.SubjectID = ? AND se.Status = 'Active'
        AND s.StatusID = 1
        ORDER BY s.LastName, s.FirstName
    `;
    
    return await executeQuery(query, [sectionId, subjectId]);
}

/**
 * Update or insert attendance record
 * @param {string} studentId - Student ID
 * @param {number} subjectId - Subject ID
 * @param {number} sectionId - Section ID
 * @param {string} date - Date (YYYY-MM-DD)
 * @param {string} status - Attendance status ('Present' or 'Absent')
 * @param {number} recordedBy - User ID of who recorded this
 * @returns {Promise<Object>} Database result
 */
export async function updateAttendanceRecord(studentId, subjectId, sectionId, date, status, recordedBy) {
    const query = `
        INSERT INTO attendance_records (student_id, subject_id, section_id, attendance_date, status, recorded_by)
        VALUES (?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE 
        status = VALUES(status),
        recorded_by = VALUES(recorded_by),
        recorded_at = CURRENT_TIMESTAMP
    `;
    
    const params = [studentId, subjectId, sectionId, date, status, recordedBy];
    return await executeQuery(query, params);
}

/**
 * Bulk update attendance records for multiple students
 * @param {Array} attendanceUpdates - Array of attendance update objects
 * @returns {Promise<Object>} Database result
 */
export async function bulkUpdateAttendance(attendanceUpdates) {
    if (!attendanceUpdates || attendanceUpdates.length === 0) {
        return { affectedRows: 0 };
    }
    
    const values = attendanceUpdates.map(update => [
        update.studentId,
        update.subjectId, 
        update.sectionId,
        update.date,
        update.status,
        update.recordedBy
    ]);
    
    const placeholders = values.map(() => '(?, ?, ?, ?, ?, ?)').join(', ');
    const flatValues = values.flat();
    
    const query = `
        INSERT INTO attendance_records (student_id, subject_id, section_id, attendance_date, status, recorded_by)
        VALUES ${placeholders}
        ON DUPLICATE KEY UPDATE 
        status = VALUES(status),
        recorded_by = VALUES(recorded_by),
        recorded_at = CURRENT_TIMESTAMP
    `;
    
    return await executeQuery(query, flatValues);
}

/**
 * Generate attendance records for a month (creates blank records for all enrolled students)
 * @param {number} sectionId - Section ID
 * @param {number} subjectId - Subject ID
 * @param {string} year - Year (YYYY)
 * @param {string} month - Month (MM)
 * @param {number} recordedBy - User ID creating the records
 * @returns {Promise<Object>} Database result
 */
export async function generateMonthlyAttendanceRecords(sectionId, subjectId, year, month, recordedBy) {
    // Get all enrolled students
    const students = await getEnrolledStudentsForAttendance(sectionId, subjectId);
    
    if (students.length === 0) {
        return { affectedRows: 0, message: 'No enrolled students found' };
    }
    
    // Generate weekdays for the month
    const startDate = new Date(parseInt(year), parseInt(month) - 1, 1);
    const endDate = new Date(parseInt(year), parseInt(month), 0);
    const weekdays = [];
    
    for (let date = new Date(startDate); date <= endDate; date.setDate(date.getDate() + 1)) {
        const dayOfWeek = date.getDay();
        // Skip weekends (Sunday = 0, Saturday = 6)
        if (dayOfWeek !== 0 && dayOfWeek !== 6) {
            weekdays.push(new Date(date).toISOString().split('T')[0]);
        }
    }
    
    // Create attendance records for each student for each weekday
    const attendanceRecords = [];
    students.forEach(student => {
        weekdays.forEach(date => {
            attendanceRecords.push({
                studentId: student.StudentID,
                subjectId: subjectId,
                sectionId: sectionId,
                date: date,
                status: 'Absent', // Default to absent
                recordedBy: recordedBy
            });
        });
    });
    
    // Use bulk insert with IGNORE to avoid duplicates
    if (attendanceRecords.length > 0) {
        const values = attendanceRecords.map(record => [
            record.studentId,
            record.subjectId,
            record.sectionId,
            record.date,
            record.status,
            record.recordedBy
        ]);
        
        const placeholders = values.map(() => '(?, ?, ?, ?, ?, ?)').join(', ');
        const flatValues = values.flat();
        
        const query = `
            INSERT IGNORE INTO attendance_records (student_id, subject_id, section_id, attendance_date, status, recorded_by)
            VALUES ${placeholders}
        `;
        
        const result = await executeQuery(query, flatValues);
        return {
            ...result,
            message: `Generated ${result.affectedRows} attendance records for ${students.length} students across ${weekdays.length} days`
        };
    }
    
    return { affectedRows: 0, message: 'No records to generate' };
}

/**
 * Get attendance statistics for a section and subject
 * @param {number} sectionId - Section ID
 * @param {number} subjectId - Subject ID
 * @param {string} year - Year (YYYY)
 * @param {string} month - Month (MM)
 * @returns {Promise<Object>} Attendance statistics
 */
export async function getAttendanceStatistics(sectionId, subjectId, year, month) {
    const startDate = `${year}-${month.padStart(2, '0')}-01`;
    const endDate = `${year}-${month.padStart(2, '0')}-31`;
    
    const query = `
        SELECT 
            COUNT(DISTINCT ar.student_id) as total_students,
            COUNT(DISTINCT ar.attendance_date) as total_days,
            COUNT(*) as total_records,
            SUM(CASE WHEN ar.status = 'Present' THEN 1 ELSE 0 END) as total_present,
            SUM(CASE WHEN ar.status = 'Absent' THEN 1 ELSE 0 END) as total_absent,
            ROUND(
                (SUM(CASE WHEN ar.status = 'Present' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 
                2
            ) as attendance_percentage
        FROM attendance_records ar
        WHERE ar.section_id = ? 
        AND ar.subject_id = ?
        AND ar.attendance_date BETWEEN ? AND ?
    `;
    
    const results = await executeQuery(query, [sectionId, subjectId, startDate, endDate]);
    return results[0] || {
        total_students: 0,
        total_days: 0,
        total_records: 0,
        total_present: 0,
        total_absent: 0,
        attendance_percentage: 0
    };
}

/**
 * Get sections accessible by a teacher (based on their subject assignments)
 * @param {number} teacherUserId - Teacher's user ID
 * @returns {Promise<Array>} Array of accessible sections
 */
export async function getTeacherSections(teacherUserId) {
    const query = `
        SELECT DISTINCT
            s.SectionID,
            s.SectionName,
            s.CreatedAt
        FROM sections s
        JOIN section_subjects ss ON s.SectionID = ss.SectionID
        JOIN teachers t ON ss.TeacherID = t.TeacherID
        WHERE t.UserID = ? AND s.StatusID = 1
        ORDER BY s.SectionName
    `;
    
    return await executeQuery(query, [teacherUserId]);
}

/**
 * Get subjects accessible by a teacher in a specific section
 * @param {number} teacherUserId - Teacher's user ID
 * @param {number} sectionId - Section ID
 * @returns {Promise<Array>} Array of accessible subjects
 */
export async function getTeacherSubjectsInSection(teacherUserId, sectionId) {
    const query = `
        SELECT DISTINCT
            sub.SubjectID,
            sub.SubjectName,
            sub.SubjectCode,
            ss.StartTime,
            ss.EndTime
        FROM subjects sub
        JOIN section_subjects ss ON sub.SubjectID = ss.SubjectID
        JOIN teachers t ON ss.TeacherID = t.TeacherID
        WHERE t.UserID = ? 
        AND ss.SectionID = ?
        AND sub.StatusID = 1
        ORDER BY sub.SubjectName
    `;
    
    return await executeQuery(query, [teacherUserId, sectionId]);
}

/**
 * Delete attendance records for a specific date range
 * @param {number} sectionId - Section ID
 * @param {number} subjectId - Subject ID
 * @param {string} startDate - Start date (YYYY-MM-DD)
 * @param {string} endDate - End date (YYYY-MM-DD)
 * @returns {Promise<Object>} Database result
 */
export async function deleteAttendanceRecords(sectionId, subjectId, startDate, endDate) {
    const query = `
        DELETE FROM attendance_records 
        WHERE section_id = ? 
        AND subject_id = ?
        AND attendance_date BETWEEN ? AND ?
    `;
    
    return await executeQuery(query, [sectionId, subjectId, startDate, endDate]);
}

/**
 * Check if attendance records exist for a given month
 * @param {number} sectionId - Section ID
 * @param {number} subjectId - Subject ID
 * @param {string} year - Year (YYYY)
 * @param {string} month - Month (MM)
 * @returns {Promise<boolean>} Whether records exist
 */
export async function attendanceRecordsExist(sectionId, subjectId, year, month) {
    const startDate = `${year}-${month.padStart(2, '0')}-01`;
    const endDate = `${year}-${month.padStart(2, '0')}-31`;
    
    const query = `
        SELECT COUNT(*) as record_count
        FROM attendance_records 
        WHERE section_id = ? 
        AND subject_id = ?
        AND attendance_date BETWEEN ? AND ?
    `;
    
    const result = await executeQuery(query, [sectionId, subjectId, startDate, endDate]);
    return result[0].record_count > 0;
}