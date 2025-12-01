// Authentication service - handles user login, registration and session management
import bcrypt from 'bcryptjs';
import { executeQuery } from './database.js';
import { createUser, getUserByEmail } from './userService.js';

/**
 * Hash a password using bcrypt
 * @param {string} password - Plain text password
 * @returns {Promise<string>} Hashed password
 */
export async function hashPassword(password) {
    return await bcrypt.hash(password, 10);
}

/**
 * Compare a password with its hash
 * @param {string} password - Plain text password
 * @param {string} hash - Hashed password
 * @returns {Promise<boolean>} Whether passwords match
 */
export async function comparePassword(password, hash) {
    if (!password || !hash) {
        console.error('Missing password or hash in comparePassword');
        return false;
    }
    
    return await bcrypt.compare(password, hash);
}

/**
 * Authenticate user login
 * @param {string} email - User email
 * @param {string} password - User password
 * @returns {Promise<Object|null>} User object without password or null if invalid
 */
export async function authenticateUser(email, password) {
    try {
        const user = await getUserByEmail(email);
        if (!user) {
            return null;
        }

        if (!user.Password) {
            console.error('User found but password field is missing');
            return null;
        }

        const isValid = await comparePassword(password, user.Password);
        if (!isValid) {
            return null;
        }

        // Return user without password
        const { Password: _, ...userWithoutPassword } = user;
        return userWithoutPassword;
    } catch (error) {
        console.error('Authentication error:', error);
        return null;
    }
}

/**
 * Register a new user and create corresponding student record
 * @param {Object} userData - User registration data
 * @returns {Promise<Object>} Created user object
 */
export async function registerUser(userData) {
    const {
        email,
        password,
        firstName,
        lastName,
        middleName,
        studentId,
        yearLevel
    } = userData;

    try {
        // Create user account
        const hashedPassword = await hashPassword(password);
        const user = await createUser({
            email,
            password: hashedPassword,
            role: 'Student',
            statusId: 1
        });

        // Create student record
        await executeQuery(
            `INSERT INTO students (StudentID, FirstName, LastName, MiddleName, StatusID, YearLevel, UserID)
             VALUES (?, ?, ?, ?, ?, ?, ?)`,
            [studentId, firstName, lastName, middleName, 1, yearLevel, user.insertId]
        );

        return { id: user.insertId, email, role: 'Student' };
    } catch (error) {
        console.error('Registration error:', error);
        throw error;
    }
}