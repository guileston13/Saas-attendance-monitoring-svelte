// Report Service - Handles attendance report data retrieval
import { executeQuery } from './database.js';

/**
 * Get all teachers (for admin view)
 * @returns {Promise<Array>} List of active teachers
 */
export async function getAllTeachersForReports() {
    const query = `
        SELECT 
            TeacherID,
            FirstName,
            LastName,
            MiddleName
        FROM teachers
        WHERE StatusID = 1
        ORDER BY LastName, FirstName
    `;
    
    return await executeQuery(query);
}

/**
 * Get subjects taught by a teacher (showing all days combined)
 * SIMPLIFIED VERSION - Works without day-specific columns
 * @param {number} teacherId - Teacher ID
 * @returns {Promise<Array>} List of subjects with teaching days
 */
export async function getTeacherSubjects(teacherId) {
    const query = `
        SELECT DISTINCT
            ss.SectionID,
            ss.SubjectID,
            s.SectionName,
            sub.subject_name,
            sub.subject_code,
            ss.TeacherID
        FROM section_subjects ss
        JOIN sections s ON ss.SectionID = s.SectionID
        JOIN subjects sub ON ss.SubjectID = sub.SubjectID
        WHERE ss.TeacherID = ?
        AND s.StatusID = 1
        ORDER BY sub.subject_name, s.SectionName
    `;
    
    return await executeQuery(query, [teacherId]);
}

/**
 * Get attendance report data for a section and subject
 * SIMPLIFIED VERSION - Works without day-specific columns
 * @param {number} sectionId - Section ID
 * @param {number} subjectId - Subject ID
 * @param {string} startDate - Start date (YYYY-MM-DD)
 * @param {string} endDate - End date (YYYY-MM-DD)
 * @param {number} teacherId - Teacher ID (optional, for filtering)
 * @returns {Promise<Object>} Complete report data
 */
export async function getAttendanceReportData(sectionId, subjectId, startDate, endDate, teacherId = null) {
    try {
        // Get schedule information
        const scheduleQuery = `
            SELECT 
                ss.*,
                s.SectionName,
                sub.subject_name,
                sub.subject_code,
                ss.StartTime,
                ss.EndTime
            FROM section_subjects ss
            JOIN sections s ON ss.SectionID = s.SectionID
            JOIN subjects sub ON ss.SubjectID = sub.SubjectID
            WHERE ss.SectionID = ? AND ss.SubjectID = ?
        `;
        
        const scheduleData = await executeQuery(scheduleQuery, [sectionId, subjectId]);
        
        if (scheduleData.length === 0) {
            throw new Error('Section subject not found');
        }
        
        const schedule = scheduleData[0];
        
        // Get teacher information
        let teachers = [];
        if (schedule.TeacherID) {
            const teacherQuery = `
                SELECT 
                    TeacherID,
                    CONCAT(FirstName, ' ', COALESCE(MiddleName, ''), ' ', LastName) AS FullName,
                    FirstName,
                    LastName
                FROM teachers
                WHERE TeacherID = ?
            `;
            teachers = await executeQuery(teacherQuery, [schedule.TeacherID]);
        }
        
        const teacherName = teachers.length > 0 ? teachers[0].FullName.trim() : 'Not Assigned';
        
        // Get attendance records (no day filtering for now)
        const attendanceQuery = `
            SELECT 
                ar.student_id,
                ar.attendance_date,
                ar.login_time,
                ar.status,
                s.StudentID,
                s.FirstName,
                s.LastName,
                s.MiddleName,
                s.YearLevel,
                DAYNAME(ar.attendance_date) AS day_of_week_name
            FROM attendance_records ar
            JOIN students s ON ar.student_id = s.StudentID
            WHERE ar.section_id = ? 
            AND ar.subject_id = ?
            AND ar.attendance_date BETWEEN ? AND ?
            AND ar.status IN ('Present', 'Absent', 'Late')
            ORDER BY s.LastName, s.FirstName, ar.attendance_date
        `;
        
        const attendanceRecords = await executeQuery(attendanceQuery, [
            sectionId,
            subjectId,
            startDate,
            endDate
        ]);
        
        // Get all enrolled students
        const studentsQuery = `
            SELECT DISTINCT
                s.StudentID,
                s.FirstName,
                s.LastName,
                s.MiddleName,
                s.YearLevel
            FROM students s
            JOIN subject_enrollments se ON s.StudentID = se.StudentID
            WHERE se.SectionID = ?
            AND se.SubjectID = ?
            AND se.Status = 'Active'
            ORDER BY s.LastName, s.FirstName
        `;
        
        const students = await executeQuery(studentsQuery, [sectionId, subjectId]);
        
        // Get unique attendance dates
        const attendanceDates = [...new Set(attendanceRecords.map(r => formatDateString(r.attendance_date)))];
        attendanceDates.sort();
        
        // Process attendance data
        const attendanceData = {};
        
        students.forEach(student => {
            attendanceData[student.StudentID] = {
                student: {
                    StudentID: student.StudentID,
                    FirstName: student.FirstName,
                    LastName: student.LastName,
                    MiddleName: student.MiddleName,
                    YearLevel: student.YearLevel
                },
                attendance: {},
                summary: {
                    present: 0,
                    absent: 0,
                    total: attendanceDates.length
                }
            };
        });
        
        // Fill in attendance data - Late is considered present
        attendanceRecords.forEach(record => {
            const dateStr = formatDateString(record.attendance_date);
            
            let status = 'absent';
            let displayStatus = 'A';
            
            if (record.status === 'Present') {
                status = 'present';
                displayStatus = 'P';
                attendanceData[record.StudentID].summary.present++;
            } else if (record.status === 'Late') {
                status = 'present';
                displayStatus = 'L';
                attendanceData[record.StudentID].summary.present++;
            } else {
                attendanceData[record.StudentID].summary.absent++;
            }
            
            attendanceData[record.StudentID].attendance[dateStr] = {
                status,
                displayStatus,
                recordedAt: record.recorded_at,
                dayOfWeek: record.day_of_week_name,
                teacher: teacherName
            };
        });
        
        // Fill in absent for missing dates
        students.forEach(student => {
            attendanceDates.forEach(date => {
                if (!attendanceData[student.StudentID].attendance[date]) {
                    attendanceData[student.StudentID].attendance[date] = {
                        status: 'absent',
                        displayStatus: 'A'
                    };
                    attendanceData[student.StudentID].summary.absent++;
                }
            });
        });
        
        // Calculate percentages
        Object.values(attendanceData).forEach(data => {
            if (data.summary.total > 0) {
                data.summary.percentage = Math.round(
                    (data.summary.present / data.summary.total) * 100
                );
            } else {
                data.summary.percentage = 0;
            }
        });
        
        // Build schedule info for display
        const scheduleInfo = [{
            startTime: schedule.StartTime,
            endTime: schedule.EndTime,
            teacher: teacherName,
            teacherId: schedule.TeacherID
        }];
        
        return {
            success: true,
            reportData: {
                section: {
                    id: sectionId,
                    name: schedule.SectionName
                },
                subject: {
                    id: subjectId,
                    name: schedule.subject_name,
                    code: schedule.subject_code || ''
                },
                dateRange: {
                    start: startDate,
                    end: endDate
                },
                schedule: scheduleInfo,
                attendanceDates,
                students: Object.values(attendanceData),
                totalStudents: students.length,
                teacher: teacherName
            }
        };
        
    } catch (error) {
        console.error('Error fetching attendance report data:', error);
        throw error;
    }
}

/**
 * Format date to YYYY-MM-DD string
 * @param {Date|string} date - Date to format
 * @returns {string} Formatted date string
 */
function formatDateString(date) {
    if (typeof date === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(date)) {
        return date;
    }
    
    const d = new Date(date);
    const year = d.getFullYear();
    const month = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
}

/**
 * Get schedule information for a section and subject
 * @param {number} sectionId - Section ID
 * @param {number} subjectId - Subject ID
 * @returns {Promise<Object>} Schedule information
 */
export async function getSubjectSchedule(sectionId, subjectId) {
    const query = `
        SELECT 
            Monday, Tuesday, Wednesday, Thursday, Friday,
            MondayStart, MondayEnd, MondayTeacher,
            TuesdayStart, TuesdayEnd, TuesdayTeacher,
            WednesdayStart, WednesdayEnd, WednesdayTeacher,
            ThursdayStart, ThursdayEnd, ThursdayTeacher,
            FridayStart, FridayEnd, FridayTeacher
        FROM section_subjects
        WHERE SectionID = ? AND SubjectID = ?
    `;
    
    const result = await executeQuery(query, [sectionId, subjectId]);
    return result[0] || null;
}
