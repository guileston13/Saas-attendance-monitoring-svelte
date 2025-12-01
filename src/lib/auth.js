// Session management utilities
import { parse, serialize } from 'cookie';

const SESSION_COOKIE_NAME = 'session';
const SESSION_SECRET = process.env.SESSION_SECRET || 'your-super-secret-key-change-in-production';

/**
 * Create a session token
 * @param {Object} userData - User data to encode in session
 * @returns {string} Session token
 */
export function createSessionToken(userData) {
    // In production, use JWT or similar secure token system
    const sessionData = {
        userId: userData.UserID || userData.id,
        email: userData.Email || userData.email,
        role: userData.Role || userData.role,
        timestamp: Date.now()
    };
    
    // Simple base64 encoding for demo - use JWT in production
    return Buffer.from(JSON.stringify(sessionData)).toString('base64');
}

/**
 * Parse session token
 * @param {string} token - Session token
 * @returns {Object|null} Session data or null if invalid
 */
export function parseSessionToken(token) {
    try {
        const sessionData = JSON.parse(Buffer.from(token, 'base64').toString());
        
        // Check if session is expired (24 hours)
        const twentyFourHours = 24 * 60 * 60 * 1000;
        if (Date.now() - sessionData.timestamp > twentyFourHours) {
            return null;
        }
        
        return sessionData;
    } catch (error) {
        return null;
    }
}

/**
 * Create session cookie
 * @param {Object} userData - User data
 * @returns {string} Cookie string
 */
export function createSessionCookie(userData) {
    const token = createSessionToken(userData);
    return serialize(SESSION_COOKIE_NAME, token, {
        httpOnly: true,
        secure: false, // Set to true in production with HTTPS
        sameSite: 'lax',
        maxAge: 24 * 60 * 60, // 24 hours
        path: '/'
    });
}

/**
 * Clear session cookie
 * @returns {string} Cookie string to clear session
 */
export function clearSessionCookie() {
    return serialize(SESSION_COOKIE_NAME, '', {
        httpOnly: true,
        secure: false,
        sameSite: 'lax',
        maxAge: 0,
        path: '/'
    });
}

/**
 * Get session from request cookies
 * @param {string} cookieHeader - Cookie header from request
 * @returns {Object|null} Session data or null
 */
export function getSessionFromCookies(cookieHeader) {
    if (!cookieHeader) return null;
    
    const cookies = parse(cookieHeader);
    const sessionToken = cookies[SESSION_COOKIE_NAME];
    
    if (!sessionToken) return null;
    
    return parseSessionToken(sessionToken);
}

/**
 * Check if user has required role
 * @param {Object} session - User session
 * @param {string|Array} requiredRoles - Required role(s)
 * @returns {boolean} Whether user has required role
 */
export function hasRole(session, requiredRoles) {
    if (!session) return false;
    
    const roles = Array.isArray(requiredRoles) ? requiredRoles : [requiredRoles];
    return roles.includes(session.role);
}

/**
 * Check if user is authenticated
 * @param {Object} session - User session
 * @returns {boolean} Whether user is authenticated
 */
export function isAuthenticated(session) {
    return session && session.userId && session.email;
}