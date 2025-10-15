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
            sub.SubjectName,
            sub.SubjectCode,
            ss.TeacherID,
            CONCAT(t.FirstName, ' ', t.LastName) as TeacherName,
            COUNT(DISTINCT se.StudentID) as EnrolledStudents,
            sub.StatusID,
            stat.StatusName as SubjectStatus,
            ss.CreatedAt as AssignedAt,
            ss.StartTime as StartTime,
            ss.EndTime as EndTime,
            ss.Room as Room
        FROM section_subjects ss
        JOIN subjects sub ON ss.SubjectID = sub.SubjectID
        LEFT JOIN teachers t ON ss.TeacherID = t.TeacherID
        LEFT JOIN subject_enrollments se ON ss.SectionID = se.SectionID 
            AND ss.SubjectID = se.SubjectID 
            AND se.Status = 'Active'
        LEFT JOIN status stat ON sub.StatusID = stat.StatusID
        WHERE ss.SectionID = ?
        GROUP BY ss.SectionID, ss.SubjectID, sub.SubjectName, sub.SubjectCode, 
                 ss.TeacherID, t.FirstName, t.LastName, sub.StatusID, stat.StatusName, ss.CreatedAt, ss.StartTime, ss.EndTime, ss.Room
        ORDER BY sub.SubjectName
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
 * @returns {Promise<Object>} Result
 */
export async function addSubjectToSection(sectionId, subjectId, teacherId = null) {
    const result = await executeQuery(
        'INSERT INTO section_subjects (SectionID, SubjectID, TeacherID) VALUES (?, ?, ?)',
        [sectionId, subjectId, teacherId]
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