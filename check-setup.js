import { executeQuery } from './src/services/database.js';

async function checkAttendanceSetup() {
    try {
        console.log('🔍 Checking attendance system setup...\n');

        // Check if attendance_records table exists and has correct structure
        console.log('1. Checking attendance_records table structure:');
        const tableCheck = await executeQuery(`
            SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA = 'school_management'
              AND TABLE_NAME = 'attendance_records'
            ORDER BY ORDINAL_POSITION
        `);

        tableCheck.forEach(col => {
            console.log(`   - ${col.COLUMN_NAME}: ${col.DATA_TYPE} ${col.IS_NULLABLE === 'YES' ? 'NULL' : 'NOT NULL'}`);
        });

        // Check status ENUM values
        console.log('\n2. Checking status ENUM values:');
        const enumCheck = await executeQuery(`
            SELECT COLUMN_TYPE
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA = 'school_management'
              AND TABLE_NAME = 'attendance_records'
              AND COLUMN_NAME = 'status'
        `);

        if (enumCheck.length > 0) {
            console.log(`   Status ENUM: ${enumCheck[0].COLUMN_TYPE}`);
        }

        // Check for rooms
        console.log('\n3. Checking rooms setup:');
        const rooms = await executeQuery('SELECT RoomID, RoomName FROM rooms ORDER BY RoomID');
        console.log(`   Found ${rooms.length} rooms:`);
        rooms.forEach(room => {
            console.log(`   - Room ${room.RoomID}: ${room.RoomName}`);
        });

        // Check for schedules
        console.log('\n4. Checking section_subjects schedules:');
        const schedules = await executeQuery(`
            SELECT ss.SectionID, ss.SubjectID, s.SubjectName, ss.RoomID, ss.StartTime, ss.EndTime
            FROM section_subjects ss
            JOIN subjects s ON ss.SubjectID = s.SubjectID
            WHERE ss.RoomID IS NOT NULL AND ss.StartTime IS NOT NULL
            ORDER BY ss.RoomID, ss.StartTime
        `);
        console.log(`   Found ${schedules.length} scheduled subjects:`);
        schedules.forEach(schedule => {
            console.log(`   - Room ${schedule.RoomID}: ${schedule.SubjectName} (${schedule.StartTime} - ${schedule.EndTime})`);
        });

        // Check student enrollments
        console.log('\n5. Checking student enrollments:');
        const enrollments = await executeQuery(`
            SELECT se.StudentID, se.SectionID, se.SubjectID, s.SubjectName, se.Status
            FROM subject_enrollments se
            JOIN subjects s ON se.SubjectID = s.SubjectID
            WHERE se.Status = 'Active'
            ORDER BY se.StudentID
            LIMIT 10
        `);
        console.log(`   Sample of ${enrollments.length} active enrollments:`);
        enrollments.forEach(enrollment => {
            console.log(`   - Student ${enrollment.StudentID}: ${enrollment.SubjectName} (${enrollment.Status})`);
        });

        // Test the auto-detection query with sample data
        console.log('\n6. Testing auto-detection query (sample):');
        const testStudent = '2024001';
        const testRoom = 1;

        const testQuery = await executeQuery(`
            SELECT ss.SubjectID, ss.SectionID, ss.TeacherID, s.SubjectName, ss.StartTime, ss.EndTime
            FROM section_subjects ss
            JOIN subject_enrollments se ON ss.SectionID = se.SectionID
                                        AND ss.SubjectID = se.SubjectID
            JOIN subjects s ON ss.SubjectID = s.SubjectID
            WHERE se.StudentID = ?
              AND se.Status = 'Active'
              AND ss.RoomID = ?
              AND CURTIME() BETWEEN ss.StartTime AND ss.EndTime
            LIMIT 1
        `, [testStudent, testRoom]);

        if (testQuery.length > 0) {
            console.log(`   ✅ Auto-detection working: Student ${testStudent} in Room ${testRoom} -> ${testQuery[0].SubjectName}`);
        } else {
            console.log(`   ⚠️ No active schedule found for Student ${testStudent} in Room ${testRoom} at current time`);
            console.log('   This could be why attendance isn\'t being recorded!');
        }

        console.log('\n✅ Setup check completed!');

    } catch (error) {
        console.error('❌ Setup check failed:', error.message);
    }
}

checkAttendanceSetup();