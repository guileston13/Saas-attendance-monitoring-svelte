// Database service - handles MariaDB connection and queries
import mysql from 'mysql2/promise';

// MariaDB connection configuration
const dbConfig = {
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '1234',
    port: process.env.DB_PORT || 3306,
    database: process.env.DB_NAME || 'school_management',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
};

// Create connection pool
const pool = mysql.createPool(dbConfig);

/**
 * Execute a query with parameters - prevents SQL injection
 * @param {string} query - SQL query with placeholders
 * @param {Array} params - Parameters for the query
 * @returns {Promise} Query results
 */
export async function executeQuery(query, params = []) {
    try {
        const [results] = await pool.execute(query, params);
        return results;
    } catch (error) {
        console.error('Database query error:', error);
        throw error;
    }
}

/**
 * Execute multiple queries in a transaction
 * @param {Array} queries - Array of {query, params} objects
 * @returns {Promise} Transaction results
 */
export async function executeTransaction(queries) {
    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();
        
        const results = [];
        for (const { query, params } of queries) {
            const [result] = await connection.execute(query, params);
            results.push(result);
        }
        
        await connection.commit();
        return results;
    } catch (error) {
        await connection.rollback();
        console.error('Transaction error:', error);
        throw error;
    } finally {
        connection.release();
    }
}

/**
 * Close database connection pool
 */
export async function closePool() {
    await pool.end();
}