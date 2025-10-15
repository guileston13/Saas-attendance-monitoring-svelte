// Teacher service - handles teacher CRUD operations
import { executeQuery } from './database.js';

/**
 * Get all teachers
 * @returns {Promise<Array>} Array of teachers
 */
export async function getAllTeachers() {
    return await executeQuery(
        `SELECT t.*, st.StatusName 
         FROM teachers t 
         LEFT JOIN status st ON t.StatusID = st.StatusID 
         ORDER BY t.FirstName, t.LastName`
    );
}

/**
 * Get teacher by ID
 * @param {number} teacherId - Teacher ID
 * @returns {Promise<Object|null>} Teacher object or null
 */
export async function getTeacherById(teacherId) {
    const teachers = await executeQuery(
        `SELECT t.*, st.StatusName 
         FROM teachers t 
         LEFT JOIN status st ON t.StatusID = st.StatusID 
         WHERE t.TeacherID = ?`,
        [teacherId]
    );
    
    return teachers.length > 0 ? teachers[0] : null;
}

/**
 * Create a new teacher
 * @param {Object} teacherData - Teacher data
 * @returns {Promise<Object>} Created teacher result
 */
export async function createTeacher(teacherData) {
    const { firstName, lastName, middleName, role, statusId } = teacherData;
    
    return await executeQuery(
        `INSERT INTO teachers (FirstName, LastName, MiddleName, Role, StatusID) 
         VALUES (?, ?, ?, ?, ?)`,
        [firstName, lastName, middleName, role, statusId]
    );
}

/**
 * Update teacher
 * @param {number} teacherId - Teacher ID
 * @param {Object} teacherData - Updated teacher data
 * @returns {Promise<Object>} Update result
 */
export async function updateTeacher(teacherId, teacherData) {
    const { firstName, lastName, middleName, role, statusId } = teacherData;
    
    return await executeQuery(
        `UPDATE teachers 
         SET FirstName = ?, LastName = ?, MiddleName = ?, Role = ?, StatusID = ? 
         WHERE TeacherID = ?`,
        [firstName, lastName, middleName, role, statusId, teacherId]
    );
}

/**
 * Delete teacher
 * @param {number} teacherId - Teacher ID
 * @returns {Promise<Object>} Delete result
 */
export async function deleteTeacher(teacherId) {
    return await executeQuery(
        'DELETE FROM teachers WHERE TeacherID = ?',
        [teacherId]
    );
}

/**
 * Get teachers by subject
 * @param {number} subjectId - Subject ID
 * @returns {Promise<Array>} Array of teachers for the subject
 */
export async function getTeachersBySubject(subjectId) {
    return await executeQuery(
        `SELECT t.*, st.StatusName 
         FROM teachers t 
         LEFT JOIN status st ON t.StatusID = st.StatusID 
         INNER JOIN teacher_subjects ts ON t.TeacherID = ts.TeacherID 
         WHERE ts.SubjectID = ? 
         ORDER BY t.FirstName, t.LastName`,
        [subjectId]
    );
}

/**
 * Assign teacher to subject
 * @param {number} teacherId - Teacher ID
 * @param {number} subjectId - Subject ID
 * @returns {Promise<Object>} Insert result
 */
export async function assignTeacherToSubject(teacherId, subjectId) {
    return await executeQuery(
        'INSERT INTO teacher_subjects (TeacherID, SubjectID) VALUES (?, ?)',
        [teacherId, subjectId]
    );
}

/**
 * Remove teacher from subject
 * @param {number} teacherId - Teacher ID
 * @param {number} subjectId - Subject ID
 * @returns {Promise<Object>} Delete result
 */
export async function removeTeacherFromSubject(teacherId, subjectId) {
    return await executeQuery(
        'DELETE FROM teacher_subjects WHERE TeacherID = ? AND SubjectID = ?',
        [teacherId, subjectId]
    );
}