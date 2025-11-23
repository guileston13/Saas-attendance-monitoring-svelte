import mysql from 'mysql2/promise';

// Database configuration
const dbConfig = {
    host: 'localhost',
    user: 'root',
    password: '1234',
    database: 'school_management'
};

async function runMigration() {
    let connection;

    try {
        console.log('🔄 Connecting to database...');
        connection = await mysql.createConnection(dbConfig);

        console.log('📋 Running attendance system migration...');

        // Step 1: Update status ENUM to include 'Late'
        console.log('1. Updating status ENUM to include "Late"...');
        await connection.execute(`
            ALTER TABLE attendance_records
            MODIFY COLUMN status ENUM('Present', 'Absent', 'Late') DEFAULT 'Absent'
        `);

        // Step 2: Add login_time column if it doesn't exist
        console.log('2. Adding login_time column...');
        try {
            await connection.execute(`
                ALTER TABLE attendance_records
                ADD COLUMN login_time TIME NULL AFTER attendance_date
            `);
        } catch (error) {
            if (error.code === 'ER_DUP_FIELDNAME') {
                console.log('   login_time column already exists, skipping...');
            } else {
                throw error;
            }
        }

        // Step 3: Add indexes
        console.log('3. Adding performance indexes...');
        try {
            await connection.execute(`
                CREATE INDEX idx_attendance_date_time ON attendance_records(attendance_date, login_time)
            `);
        } catch (error) {
            if (error.code === 'ER_DUP_KEYNAME') {
                console.log('   idx_attendance_date_time index already exists, skipping...');
            } else {
                throw error;
            }
        }

        try {
            await connection.execute(`
                CREATE INDEX idx_section_subjects_time ON section_subjects(RoomID, StartTime, EndTime)
            `);
        } catch (error) {
            if (error.code === 'ER_DUP_KEYNAME') {
                console.log('   idx_section_subjects_time index already exists, skipping...');
            } else {
                throw error;
            }
        }

        console.log('✅ Migration completed successfully!');

        // Verify the changes
        console.log('\n🔍 Verifying changes...');
        const [columns] = await connection.execute(`
            SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA = 'school_management'
              AND TABLE_NAME = 'attendance_records'
            ORDER BY ORDINAL_POSITION
        `);

        console.log('Updated attendance_records columns:');
        columns.forEach(col => {
            console.log(`  - ${col.COLUMN_NAME}: ${col.DATA_TYPE} ${col.IS_NULLABLE === 'YES' ? 'NULL' : 'NOT NULL'}`);
        });

    } catch (error) {
        console.error('❌ Migration failed:', error.message);
        process.exit(1);
    } finally {
        if (connection) {
            await connection.end();
        }
    }
}

runMigration();