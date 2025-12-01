// Student service - handles student CRUD operations
import { executeQuery } from './database.js';

/**
 * Get all students
 * @returns {Promise<Array>} Array of students
 */
export async function getAllStudents() {
    return await executeQuery(
        `SELECT s.*, st.StatusName 
         FROM students s 
         LEFT JOIN status st ON s.StatusID = st.StatusID 
         ORDER BY s.FirstName, s.LastName`
    );
}

/**
 * Get student by ID
 * @param {string} studentId - Student ID
 * @returns {Promise<Object|null>} Student object or null
 */
export async function getStudentById(studentId) {
    const students = await executeQuery(
        `SELECT s.*, st.StatusName 
         FROM students s 
         LEFT JOIN status st ON s.StatusID = st.StatusID 
         WHERE s.StudentID = ?`,
        [studentId]
    );
    
    return students.length > 0 ? students[0] : null;
}

/**
 * Create a new student
 * @param {Object} studentData - Student data
 * @returns {Promise<Object>} Created student result
 */
export async function createStudent(studentData) {
    const { studentId, firstName, lastName, middleName, statusId, yearLevel, userId } = studentData;
    
    return await executeQuery(
        `INSERT INTO students (StudentID, FirstName, LastName, MiddleName, StatusID, YearLevel, UserID) 
         VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [studentId, firstName, lastName, middleName, statusId, yearLevel, userId]
    );
}

/**
 * Update student
 * @param {string} studentId - Student ID
 * @param {Object} studentData - Updated student data
 * @returns {Promise<Object>} Update result
 */
export async function updateStudent(studentId, studentData) {
    const { firstName, lastName, middleName, statusId, yearLevel } = studentData;
    
    return await executeQuery(
        `UPDATE students 
         SET FirstName = ?, LastName = ?, MiddleName = ?, StatusID = ?, YearLevel = ? 
         WHERE StudentID = ?`,
        [firstName, lastName, middleName, statusId, yearLevel, studentId]
    );
}

/**
 * Delete student
 * @param {string} studentId - Student ID
 * @returns {Promise<Object>} Delete result
 */
export async function deleteStudent(studentId) {
    return await executeQuery(
        'DELETE FROM students WHERE StudentID = ?',
        [studentId]
    );
}

/**
 * Get students by section
 * @param {number} sectionId - Section ID
 * @returns {Promise<Array>} Array of students in the section
 */
export async function getStudentsBySection(sectionId) {
    return await executeQuery(
        `SELECT s.*, st.StatusName 
         FROM students s 
         LEFT JOIN status st ON s.StatusID = st.StatusID 
         INNER JOIN section_students ss ON s.StudentID = ss.StudentID 
         WHERE ss.SectionID = ? 
         ORDER BY s.FirstName, s.LastName`,
        [sectionId]
    );
}

/**
 * Add student to section
 * @param {number} sectionId - Section ID
 * @param {string} studentId - Student ID
 * @returns {Promise<Object>} Insert result
 */
export async function addStudentToSection(sectionId, studentId) {
    return await executeQuery(
        'INSERT INTO section_students (SectionID, StudentID) VALUES (?, ?)',
        [sectionId, studentId]
    );
}

/**
 * Remove student from section
 * @param {number} sectionId - Section ID
 * @param {string} studentId - Student ID
 * @returns {Promise<Object>} Delete result
 */
export async function removeStudentFromSection(sectionId, studentId) {
    return await executeQuery(
        'DELETE FROM section_students WHERE SectionID = ? AND StudentID = ?',
        [sectionId, studentId]
    );
}