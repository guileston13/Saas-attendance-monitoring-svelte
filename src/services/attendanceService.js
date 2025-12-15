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
            recordedBy: record.recorded_by
           
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
 * @param {string} status - Attendance status ('Present', 'Absent', or 'Late')
 * @param {number} recordedBy - User ID of who recorded this
 * @param {string} loginTime - Optional login time (HH:MM:SS), defaults to current time for Present/Late
 * @returns {Promise<Object>} Database result
 */
export async function updateAttendanceRecord(studentId, subjectId, sectionId, date, status, recordedBy, loginTime = null) {
    // If loginTime not provided and status is Present or Late, use current time
    if (!loginTime && (status === 'Present' || status === 'Late')) {
        const now = new Date();
        loginTime = now.toTimeString().split(' ')[0]; // HH:MM:SS
    }
    
    const query = `
        INSERT INTO attendance_records (student_id, subject_id, section_id, attendance_date, status, login_time, recorded_by)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE 
        status = VALUES(status),
        login_time = VALUES(login_time),
        recorded_by = VALUES(recorded_by)
    `;
    
    const params = [studentId, subjectId, sectionId, date, status, loginTime, recordedBy];
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
        recorded_by = VALUES(recorded_by)
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
                status: '-', // Default status (not counted in reports)
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
 * @param {number} teacherId - Teacher ID
 * @returns {Promise<Array>} Array of accessible sections
 */
export async function getTeacherSections(teacherId) {
    const query = `
        SELECT DISTINCT
            s.SectionID,
            s.SectionName,
            s.CreatedAt
        FROM sections s
        JOIN section_subjects ss ON s.SectionID = ss.SectionID
        WHERE (ss.TeacherID = ? 
           OR ss.MondayTeacher = ?
           OR ss.TuesdayTeacher = ?
           OR ss.WednesdayTeacher = ?
           OR ss.ThursdayTeacher = ?
           OR ss.FridayTeacher = ?)
        AND s.StatusID = 1
        ORDER BY s.SectionName
    `;
    
    return await executeQuery(query, [teacherId, teacherId, teacherId, teacherId, teacherId, teacherId]);
}

/**
 * Get subjects accessible by a teacher in a specific section
 * @param {number} teacherId - Teacher ID
 * @param {number} sectionId - Section ID
 * @returns {Promise<Array>} Array of accessible subjects
 */
export async function getTeacherSubjectsInSection(teacherId, sectionId) {
    const query = `
        SELECT DISTINCT
            sub.SubjectID,
            sub.subject_name,
            sub.subject_code,
            ss.StartTime,
            ss.EndTime,
            ss.SectionID
        FROM subjects sub
        JOIN section_subjects ss ON sub.SubjectID = ss.SubjectID
        WHERE (ss.TeacherID = ?
           OR ss.MondayTeacher = ?
           OR ss.TuesdayTeacher = ?
           OR ss.WednesdayTeacher = ?
           OR ss.ThursdayTeacher = ?
           OR ss.FridayTeacher = ?)
        AND ss.SectionID = ?
        AND sub.StatusID = 1
        ORDER BY sub.subject_name
    `;
    
    return await executeQuery(query, [teacherId, teacherId, teacherId, teacherId, teacherId, teacherId, sectionId]);
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

/**
 * Get all subjects assigned to a teacher
 * @param {number} teacherId - Teacher ID
 * @returns {Promise<Array>} Array of subjects with section info
 */
export async function getTeacherSubjects(teacherId) {
    const query = `
        SELECT DISTINCT
            sec.SectionID,
            sec.SectionName,
            sec.Semester,
            sec.SchoolYear,
            sub.subject_id,
            sub.SubjectName,
            sub.SubjectCode,
            sch.Weekdays,
            sch.StartTime,
            sch.EndTime,
            r.RoomName,
            r.Building,
            COUNT(DISTINCT se.StudentID) as EnrolledStudents
        FROM section_subjects ss
        JOIN sections sec ON ss.SectionID = sec.SectionID
        JOIN course_catalog sub ON ss.SubjectID = sub.subject_id
        LEFT JOIN subject_schedules sch ON ss.SectionID = sch.SectionID AND ss.SubjectID = sch.SubjectID
        LEFT JOIN room r ON sch.RoomID = r.RoomID
        LEFT JOIN subject_enrollments se ON ss.SectionID = se.SectionID 
            AND ss.SubjectID = se.SubjectID 
            AND se.Status = 'Active'
        WHERE ss.TeacherID = ?
        AND sec.StatusID = 1
        GROUP BY 
            sec.SectionID, sec.SectionName, sec.Semester, sec.SchoolYear,
            sub.subject_id, sub.SubjectName, sub.SubjectCode,
            sch.Weekdays, sch.StartTime, sch.EndTime,
            r.RoomName, r.Building
        ORDER BY sec.SectionName, sub.SubjectName
    `;
    
    return await executeQuery(query, [teacherId]);
}

/**
 * Get filtered attendance dates for a subject based on its schedule
 * @param {number} sectionId - Section ID
 * @param {number} subjectId - Subject ID
 * @param {string} year - Year (YYYY)
 * @param {string} month - Month (MM)
 * @returns {Promise<Array>} Array of valid attendance dates
 */
export async function getSubjectAttendanceDates(sectionId, subjectId, year, month) {
    const query = `CALL get_subject_attendance_dates(?, ?, ?, ?)`;
    
    try {
        const results = await executeQuery(query, [sectionId, subjectId, year, month]);
        // Stored procedure returns array of result sets, we want the first one
        return Array.isArray(results[0]) ? results[0] : results;
    } catch (error) {
        console.error('Error getting subject attendance dates:', error);
        // Fallback: return empty array
        return [];
    }
}

/**
 * Get subject schedule information
 * @param {number} sectionId - Section ID
 * @param {number} subjectId - Subject ID
 * @returns {Promise<Object|null>} Schedule information
 */
export async function getSubjectSchedule(sectionId, subjectId) {
    const query = `
        SELECT 
            sch.ScheduleID,
            sch.Weekdays,
            sch.StartTime,
            sch.EndTime,
            sch.RoomID,
            r.RoomName,
            r.Building,
            sec.SectionName,
            sec.Semester,
            sec.SchoolYear,
            sub.SubjectName,
            sub.SubjectCode
        FROM subject_schedules sch
        JOIN sections sec ON sch.SectionID = sec.SectionID
        JOIN course_catalog sub ON sch.SubjectID = sub.subject_id
        LEFT JOIN room r ON sch.RoomID = r.RoomID
        WHERE sch.SectionID = ? AND sch.SubjectID = ?
        LIMIT 1
    `;
    
    const results = await executeQuery(query, [sectionId, subjectId]);
    return results.length > 0 ? results[0] : null;
}