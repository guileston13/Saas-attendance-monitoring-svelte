// User service - handles user CRUD operations
import { executeQuery } from './database.js';

/**
 * Create a new user
 * @param {Object} userData - User data
 * @returns {Promise<Object>} Created user result
 */
export async function createUser(userData) {
    const { email, password, role, statusId } = userData;
    
    const result = await executeQuery(
        'INSERT INTO users (Email, Password, Role, StatusID) VALUES (?, ?, ?, ?)',
        [email, password, role, statusId]
    );
    
    return result;
}

/**
 * Get user by email
 * @param {string} email - User email
 * @returns {Promise<Object|null>} User object or null
 */
export async function getUserByEmail(email) {
    const users = await executeQuery(
        'SELECT * FROM users WHERE Email = ?',
        [email]
    );
    
    return users.length > 0 ? users[0] : null;
}

/**
 * Get user by ID
 * @param {number} userId - User ID
 * @returns {Promise<Object|null>} User object or null
 */
export async function getUserById(userId) {
    const users = await executeQuery(
        'SELECT UserID, Email, Role, StatusID FROM users WHERE UserID = ?',
        [userId]
    );
    
    return users.length > 0 ? users[0] : null;
}

/**
 * Update user
 * @param {number} userId - User ID
 * @param {Object} userData - Updated user data
 * @returns {Promise<Object>} Update result
 */
export async function updateUser(userId, userData) {
    const { email, role, statusId } = userData;
    
    const result = await executeQuery(
        'UPDATE users SET Email = ?, Role = ?, StatusID = ? WHERE UserID = ?',
        [email, role, statusId, userId]
    );
    
    return result;
}

/**
 * Delete user
 * @param {number} userId - User ID
 * @returns {Promise<Object>} Delete result
 */
export async function deleteUser(userId) {
    const result = await executeQuery(
        'DELETE FROM users WHERE UserID = ?',
        [userId]
    );
    
    return result;
}