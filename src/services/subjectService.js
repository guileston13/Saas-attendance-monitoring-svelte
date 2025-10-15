// Subject service - handles subject CRUD operations
import { executeQuery } from './database.js';

/**
 * Get all subjects
 * @returns {Promise<Array>} Array of subjects
 */
export async function getAllSubjects() {
    return await executeQuery(
        `SELECT s.*, st.StatusName 
         FROM subjects s 
         LEFT JOIN status st ON s.StatusID = st.StatusID 
         ORDER BY s.SubjectName`
    );
}

/**
 * Get subject by ID
 * @param {number} subjectId - Subject ID
 * @returns {Promise<Object|null>} Subject object or null
 */
export async function getSubjectById(subjectId) {
    const subjects = await executeQuery(
        `SELECT s.*, st.StatusName 
         FROM subjects s 
         LEFT JOIN status st ON s.StatusID = st.StatusID 
         WHERE s.SubjectID = ?`,
        [subjectId]
    );
    
    return subjects.length > 0 ? subjects[0] : null;
}

/**
 * Create a new subject
 * @param {Object} subjectData - Subject data
 * @returns {Promise<Object>} Created subject result
 */
export async function createSubject(subjectData) {
    const { subjectName, subjectCode, room, startTime, endTime, statusId } = subjectData;
    
    return await executeQuery(
        `INSERT INTO subjects (SubjectName, SubjectCode, Room, StartTime, EndTime, StatusID) 
         VALUES (?, ?, ?, ?, ?, ?)`,
        [subjectName, subjectCode, room, startTime, endTime, statusId]
    );
}

/**
 * Update subject
 * @param {number} subjectId - Subject ID
 * @param {Object} subjectData - Updated subject data
 * @returns {Promise<Object>} Update result
 */
export async function updateSubject(subjectId, subjectData) {
    const { subjectName, subjectCode, room, startTime, endTime, statusId } = subjectData;
    
    return await executeQuery(
        `UPDATE subjects 
         SET SubjectName = ?, SubjectCode = ?, Room = ?, StartTime = ?, EndTime = ?, StatusID = ? 
         WHERE SubjectID = ?`,
        [subjectName, subjectCode, room, startTime, endTime, statusId, subjectId]
    );
}

/**
 * Delete subject
 * @param {number} subjectId - Subject ID
 * @returns {Promise<Object>} Delete result
 */
export async function deleteSubject(subjectId) {
    return await executeQuery(
        'DELETE FROM subjects WHERE SubjectID = ?',
        [subjectId]
    );
}

/**
 * Get subjects by section
 * @param {number} sectionId - Section ID
 * @returns {Promise<Array>} Array of subjects for the section with teacher info
 */
export async function getSubjectsBySection(sectionId) {
    return await executeQuery(
        `SELECT s.*, st.StatusName, 
                CONCAT(t.FirstName, ' ', t.LastName) as TeacherName,
                COUNT(ss.StudentID) as EnrolledStudents
         FROM subjects s 
         LEFT JOIN status st ON s.StatusID = st.StatusID 
         LEFT JOIN section_subjects sec_sub ON s.SubjectID = sec_sub.SubjectID
         LEFT JOIN teachers t ON sec_sub.TeacherID = t.TeacherID
         LEFT JOIN section_students ss ON sec_sub.SectionID = ss.SectionID
         WHERE sec_sub.SectionID = ? 
         GROUP BY s.SubjectID, t.TeacherID
         ORDER BY s.SubjectName`,
        [sectionId]
    );
}