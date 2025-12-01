// Section service - handles section CRUD operations and subject enrollments
import { executeQuery } from './database.js';

/**
 * Get all sections with basic info
 * @returns {Promise<Array>} Array of sections
 */
export async function getAllSections() {
    const sections = await executeQuery(`
        SELECT 
            s.SectionID,
            s.SectionName,
            s.StatusID,
            st.StatusName,
            COUNT(DISTINCT ss.SubjectID) as SubjectCount,
            COUNT(DISTINCT se.StudentID) as TotalStudents,
            s.CreatedAt
        FROM sections s
        LEFT JOIN status st ON s.StatusID = st.StatusID
        LEFT JOIN section_subjects ss ON s.SectionID = ss.SectionID
        LEFT JOIN subject_enrollments se ON s.SectionID = se.SectionID AND se.Status = 'Active'
        GROUP BY s.SectionID, s.SectionName, s.StatusID, st.StatusName, s.CreatedAt
        ORDER BY s.SectionName
    `);

    return sections;
}

/**
 * Get section by ID with full details
 * @param {number} sectionId - Section ID
 * @returns {Promise<Object|null>} Section details or null
 */
export async function getSectionById(sectionId) {
    const sections = await executeQuery(
        'SELECT * FROM sections WHERE SectionID = ?',
        [sectionId]
    );

    return sections.length > 0 ? sections[0] : null;
}

/**
 * Get subjects for a specific section with enrollment counts
 * @param {number} sectionId - Section ID
 * @returns {Promise<Array>} Array of subjects in the section
 */
export async function getSectionSubjects(sectionId) {
    const subjects = await executeQuery(`
        SELECT 
            ss.SectionID,
            ss.SubjectID,
            sub.subject_name,
            sub.subject_code,
            ss.TeacherID,
            CONCAT(t.FirstName, ' ', t.LastName) as TeacherName,
            COUNT(DISTINCT se.StudentID) as EnrolledStudents,
            ss.CreatedAt as AssignedAt,
            ss.StartTime,
            ss.EndTime,
            ss.RoomID,
            r.RoomName,
            ss.Monday,
            ss.Tuesday,
            ss.Wednesday,
            ss.Thursday,
            ss.Friday,
            ss.MondayStart, ss.MondayEnd, ss.MondayTeacher,
            ss.TuesdayStart, ss.TuesdayEnd, ss.TuesdayTeacher,
            ss.WednesdayStart, ss.WednesdayEnd, ss.WednesdayTeacher,
            ss.ThursdayStart, ss.ThursdayEnd, ss.ThursdayTeacher,
            ss.FridayStart, ss.FridayEnd, ss.FridayTeacher
        FROM section_subjects ss
        JOIN subjects sub ON ss.SubjectID = sub.SubjectID
        LEFT JOIN teachers t ON ss.TeacherID = t.TeacherID
        LEFT JOIN subject_enrollments se ON ss.SectionID = se.SectionID 
            AND ss.SubjectID = se.SubjectID 
            AND se.Status = 'Active'
        LEFT JOIN status stat ON sub.StatusID = stat.StatusID
        LEFT JOIN room r ON ss.RoomID = r.RoomID
        WHERE ss.SectionID = ?
        GROUP BY ss.SectionID, ss.SubjectID, sub.subject_name, sub.subject_code,
                 ss.TeacherID, t.FirstName, t.LastName, 
                 ss.CreatedAt, ss.StartTime, ss.EndTime, ss.RoomID, r.RoomName,
                 ss.Monday, ss.Tuesday, ss.Wednesday, ss.Thursday, ss.Friday,
                 ss.MondayStart, ss.MondayEnd, ss.MondayTeacher,
                 ss.TuesdayStart, ss.TuesdayEnd, ss.TuesdayTeacher,
                 ss.WednesdayStart, ss.WednesdayEnd, ss.WednesdayTeacher,
                 ss.ThursdayStart, ss.ThursdayEnd, ss.ThursdayTeacher,
                 ss.FridayStart, ss.FridayEnd, ss.FridayTeacher
        ORDER BY sub.subject_name
    `, [sectionId]);

    return subjects;
}

/**
 * Get students enrolled in a specific subject within a section
 * @param {number} sectionId - Section ID
 * @param {number} subjectId - Subject ID
 * @returns {Promise<Array>} Array of enrolled students
 */
export async function getSubjectEnrollments(sectionId, subjectId) {
    const students = await executeQuery(`
        SELECT 
            se.SectionID,
            se.SubjectID,
            se.StudentID,
            s.FirstName,
            s.LastName,
            s.MiddleName,
            s.YearLevel,
            se.Status as EnrollmentStatus,
            se.EnrolledAt,
            stat.StatusName as StudentStatus
        FROM subject_enrollments se
        JOIN students s ON se.StudentID = s.StudentID
        LEFT JOIN status stat ON s.StatusID = stat.StatusID
        WHERE se.SectionID = ? AND se.SubjectID = ?
        ORDER BY s.LastName, s.FirstName
    `, [sectionId, subjectId]);

    return students;
}

/**
 * Get available students for enrollment (not yet enrolled in the subject)
 * @param {number} sectionId - Section ID
 * @param {number} subjectId - Subject ID
 * @returns {Promise<Array>} Array of available students
 */
export async function getAvailableStudentsForSubject(sectionId, subjectId) {
    const students = await executeQuery(`
        SELECT DISTINCT
            s.StudentID,
            s.FirstName,
            s.LastName,
            s.MiddleName,
            s.YearLevel,
            stat.StatusName
        FROM students s
        LEFT JOIN status stat ON s.StatusID = stat.StatusID
        WHERE s.StatusID = 1
        AND s.StudentID NOT IN (
            SELECT se.StudentID 
            FROM subject_enrollments se 
            WHERE se.SectionID = ? AND se.SubjectID = ? AND se.Status = 'Active'
        )
        ORDER BY s.LastName, s.FirstName
    `, [sectionId, subjectId]);

    return students;
}

/**
 * Add subject to section
 * @param {number} sectionId - Section ID
 * @param {number} subjectId - Subject ID
 * @param {number} teacherId - Teacher ID (optional)
 * @param {number} roomId - Room ID (optional)
 * @param {string} startTime - Start time (optional)
 * @param {string} endTime - End time (optional)
 * @param {number} monday - Monday flag
 * @param {number} tuesday - Tuesday flag
 * @param {number} wednesday - Wednesday flag
 * @param {number} thursday - Thursday flag
 * @param {number} friday - Friday flag
 * @param {Object} schedule - Per-day schedule object { monday: {start, end, teacher}, ... }
 * @returns {Promise<Object>} Result
 */
export async function addSubjectToSection(sectionId, subjectId, teacherId = null, roomId = null, startTime = null, endTime = null, monday = 0, tuesday = 0, wednesday = 0, thursday = 0, friday = 0, schedule = {}) {
    const result = await executeQuery(
        `INSERT INTO section_subjects (
            SectionID, SubjectID, TeacherID, RoomID, StartTime, EndTime, 
            Monday, Tuesday, Wednesday, Thursday, Friday,
            MondayStart, MondayEnd, MondayTeacher,
            TuesdayStart, TuesdayEnd, TuesdayTeacher,
            WednesdayStart, WednesdayEnd, WednesdayTeacher,
            ThursdayStart, ThursdayEnd, ThursdayTeacher,
            FridayStart, FridayEnd, FridayTeacher
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
            sectionId, subjectId, teacherId, roomId, startTime, endTime,
            monday, tuesday, wednesday, thursday, friday,
            schedule.monday?.start || null, schedule.monday?.end || null, schedule.monday?.teacher || null,
            schedule.tuesday?.start || null, schedule.tuesday?.end || null, schedule.tuesday?.teacher || null,
            schedule.wednesday?.start || null, schedule.wednesday?.end || null, schedule.wednesday?.teacher || null,
            schedule.thursday?.start || null, schedule.thursday?.end || null, schedule.thursday?.teacher || null,
            schedule.friday?.start || null, schedule.friday?.end || null, schedule.friday?.teacher || null
        ]
    );

    return result;
}

/**
 * Add subject to section (simple version for auto-adding during section creation)
 * @param {number} sectionId - Section ID
 * @param {number} subjectId - Subject ID
 * @returns {Promise<Object>} Result
 */
export async function addSubjectToSectionSimple(sectionId, subjectId) {
    const result = await executeQuery(
        `INSERT INTO section_subjects (SectionID, SubjectID) VALUES (?, ?)`,
        [sectionId, subjectId]
    );
    return result;
}

/**
 * Update section subject details (teacher, room and schedule)
 * @param {number} sectionId - Section ID
 * @param {number} subjectId - Subject ID
 * @param {number} teacherId - Teacher ID
 * @param {number} roomId - Room ID
 * @param {string} startTime - Start time
 * @param {string} endTime - End time
 * @param {number} monday - Monday flag
 * @param {number} tuesday - Tuesday flag
 * @param {number} wednesday - Wednesday flag
 * @param {number} thursday - Thursday flag
 * @param {number} friday - Friday flag
 * @param {Object} schedule - Per-day schedule object
 * @returns {Promise<Object>} Result
 */
export async function updateSectionSubject(sectionId, subjectId, teacherId, roomId, startTime, endTime, monday, tuesday, wednesday, thursday, friday, schedule = {}) {
    const result = await executeQuery(
        `UPDATE section_subjects SET 
            TeacherID = ?, RoomID = ?, StartTime = ?, EndTime = ?, 
            Monday = ?, Tuesday = ?, Wednesday = ?, Thursday = ?, Friday = ?,
            MondayStart = ?, MondayEnd = ?, MondayTeacher = ?,
            TuesdayStart = ?, TuesdayEnd = ?, TuesdayTeacher = ?,
            WednesdayStart = ?, WednesdayEnd = ?, WednesdayTeacher = ?,
            ThursdayStart = ?, ThursdayEnd = ?, ThursdayTeacher = ?,
            FridayStart = ?, FridayEnd = ?, FridayTeacher = ?
        WHERE SectionID = ? AND SubjectID = ?`,
        [
            teacherId, roomId, startTime, endTime,
            monday, tuesday, wednesday, thursday, friday,
            schedule.monday?.start || null, schedule.monday?.end || null, schedule.monday?.teacher || null,
            schedule.tuesday?.start || null, schedule.tuesday?.end || null, schedule.tuesday?.teacher || null,
            schedule.wednesday?.start || null, schedule.wednesday?.end || null, schedule.wednesday?.teacher || null,
            schedule.thursday?.start || null, schedule.thursday?.end || null, schedule.thursday?.teacher || null,
            schedule.friday?.start || null, schedule.friday?.end || null, schedule.friday?.teacher || null,
            sectionId, subjectId
        ]
    );

    return result;
}

/**
 * Remove subject from section (and all related enrollments)
 * @param {number} sectionId - Section ID
 * @param {number} subjectId - Subject ID
 * @returns {Promise<Object>} Result
 */
export async function removeSubjectFromSection(sectionId, subjectId) {
    const result = await executeQuery(
        'DELETE FROM section_subjects WHERE SectionID = ? AND SubjectID = ?',
        [sectionId, subjectId]
    );

    return result;
}

/**
 * Enroll student in a subject within a section
 * @param {number} sectionId - Section ID
 * @param {number} subjectId - Subject ID
 * @param {string} studentId - Student ID
 * @returns {Promise<Object>} Result
 */
export async function enrollStudentInSubject(sectionId, subjectId, studentId) {
    const result = await executeQuery(`
        INSERT INTO subject_enrollments (SectionID, SubjectID, StudentID, Status) 
        VALUES (?, ?, ?, 'Active')
    `, [sectionId, subjectId, studentId]);

    return result;
}

/**
 * Remove student from subject enrollment
 * @param {number} sectionId - Section ID
 * @param {number} subjectId - Subject ID
 * @param {string} studentId - Student ID
 * @returns {Promise<Object>} Result
 */
export async function unenrollStudentFromSubject(sectionId, subjectId, studentId) {
    const result = await executeQuery(
        'DELETE FROM subject_enrollments WHERE SectionID = ? AND SubjectID = ? AND StudentID = ?',
        [sectionId, subjectId, studentId]
    );

    return result;
}

/**
 * Update teacher assignment for a subject in section
 * @param {number} sectionId - Section ID
 * @param {number} subjectId - Subject ID
 * @param {number} teacherId - Teacher ID
 * @returns {Promise<Object>} Result
 */
export async function updateSubjectTeacher(sectionId, subjectId, teacherId) {
    const result = await executeQuery(
        'UPDATE section_subjects SET TeacherID = ? WHERE SectionID = ? AND SubjectID = ?',
        [teacherId, sectionId, subjectId]
    );

    return result;
}

/**
 * Create a new section
 * @param {Object} sectionData - Section data
 * @returns {Promise<Object>} Created section result
 */
export async function createSection(sectionData) {
    const { sectionName, statusId } = sectionData;

    const result = await executeQuery(
        'INSERT INTO sections (SectionName, StatusID) VALUES (?, ?)',
        [sectionName, statusId || 1]
    );

    return result;
}

/**
 * Update section
 * @param {number} sectionId - Section ID
 * @param {Object} sectionData - Updated section data
 * @returns {Promise<Object>} Update result
 */
export async function updateSection(sectionId, sectionData) {
    const { sectionName, statusId } = sectionData;

    const result = await executeQuery(
        'UPDATE sections SET SectionName = ?, StatusID = ? WHERE SectionID = ?',
        [sectionName, statusId, sectionId]
    );

    return result;
}

/**
 * Delete section
 * @param {number} sectionId - Section ID
 * @returns {Promise<Object>} Delete result
 */
export async function deleteSection(sectionId) {
    // First, delete all subject enrollments for this section
    await executeQuery(
        'DELETE FROM subject_enrollments WHERE SectionID = ?',
        [sectionId]
    );

    // Then, delete all section_subjects entries for this section
    await executeQuery(
        'DELETE FROM section_subjects WHERE SectionID = ?',
        [sectionId]
    );

    // Finally, delete the section itself
    const result = await executeQuery(
        'DELETE FROM sections WHERE SectionID = ?',
        [sectionId]
    );

    return result;
}

/**
 * Get comprehensive section details including subjects, teachers, and student counts
 * @param {number} sectionId - Section ID
 * @returns {Promise<Object>} Detailed section information
 */
export async function getSectionDetails(sectionId) {
    const sectionSubjects = await getSectionSubjects(sectionId);

    // Get total unique students enrolled in any subject in this section
    const totalStudentsResult = await executeQuery(`
        SELECT COUNT(DISTINCT StudentID) as totalStudents
        FROM subject_enrollments 
        WHERE SectionID = ? AND Status = 'Active'
    `, [sectionId]);

    const totalStudents = totalStudentsResult[0]?.totalStudents || 0;

    return {
        subjects: sectionSubjects,
        totalStudents: parseInt(totalStudents),
        subjectCount: sectionSubjects.length
    };
}