// Automatic absence marking job
// Runs every hour to mark students as absent if they didn't attend class
import { executeQuery } from '../services/database.js';

/**
 * Mark students as absent for classes that have ended
 * This job runs every hour and checks:
 * 1. Find all classes (section_subjects) where EndTime has passed
 * 2. Get all enrolled students for those classes
 * 3. Check if they have attendance record for today
 * 4. If no record (or null status), mark as Absent
 */
export async function markAbsentStudents() {
  console.log('🕐 [CRON] Starting automatic absence marking...');
  
  try {
    // Get current date and time
    const today = new Date().toISOString().split('T')[0];
    const currentTime = new Date().toLocaleTimeString('en-US', { 
      hour12: false, 
      hour: '2-digit', 
      minute: '2-digit', 
      second: '2-digit' 
    });
    
    console.log(`📅 Date: ${today}, Time: ${currentTime}`);
    
    // Step 1: Find all classes that have ended (EndTime < current time)
    const endedClasses = await executeQuery(`
      SELECT 
        ss.SectionID,
        ss.SubjectID,
        ss.StartTime,
        ss.EndTime,
        s.SectionName,
        sub.SubjectName
      FROM section_subjects ss
      JOIN sections s ON ss.SectionID = s.SectionID
      JOIN subjects sub ON ss.SubjectID = sub.SubjectID
      WHERE ss.EndTime IS NOT NULL
        AND ss.EndTime < ?
        AND s.StatusID = 1
    `, [currentTime]);
    
    if (endedClasses.length === 0) {
      console.log('✅ No classes have ended yet. Skipping...');
      return { success: true, message: 'No classes to process', markedCount: 0 };
    }
    
    console.log(`📚 Found ${endedClasses.length} ended classes`);
    
    let totalMarked = 0;
    
    // Step 2: Process each ended class
    for (const classInfo of endedClasses) {
      const { SectionID, SubjectID, SectionName, SubjectName, StartTime, EndTime } = classInfo;
      
      console.log(`\n📖 Processing: ${SubjectName} (${SectionName}) - ${StartTime} to ${EndTime}`);
      
      // Step 3: Get all enrolled students for this class
      const enrolledStudents = await executeQuery(`
        SELECT 
          se.StudentID,
          CONCAT(st.FirstName, ' ', st.LastName) as StudentName
        FROM subject_enrollments se
        JOIN students st ON se.StudentID = st.StudentID
        WHERE se.SectionID = ?
          AND se.SubjectID = ?
          AND se.Status = 'Active'
          AND st.StatusID = 1
      `, [SectionID, SubjectID]);
      
      console.log(`   👥 ${enrolledStudents.length} enrolled students`);
      
      if (enrolledStudents.length === 0) {
        console.log('   ⚠️ No enrolled students. Skipping...');
        continue;
      }
      
      // Step 4: Check attendance for each student
      for (const student of enrolledStudents) {
        const { StudentID, StudentName } = student;
        
        // Check if student has attendance record for today
        const attendanceCheck = await executeQuery(`
          SELECT status
          FROM attendance_records
          WHERE student_id = ?
            AND section_id = ?
            AND subject_id = ?
            AND attendance_date = ?
        `, [StudentID, SectionID, SubjectID, today]);
        
        // If no record exists, or status is NULL, mark as Absent
        if (attendanceCheck.length === 0 || !attendanceCheck[0].status) {
          console.log(`   ❌ Marking ${StudentName} (${StudentID}) as ABSENT`);
          
          // Insert or update attendance record
          await executeQuery(`
            INSERT INTO attendance_records 
            (student_id, subject_id, section_id, attendance_date, status, recorded_by)
            VALUES (?, ?, ?, ?, 'Absent', 1)
            ON DUPLICATE KEY UPDATE 
              status = IF(status IS NULL OR status = '', 'Absent', status),
              recorded_at = CURRENT_TIMESTAMP
          `, [StudentID, SubjectID, SectionID, today]);
          
          totalMarked++;
          
          // Check for 3 consecutive absences and mark as DF
          await checkAndMarkDF(StudentID, SectionID, SubjectID, today);
        } else {
          const status = attendanceCheck[0].status;
          console.log(`   ✅ ${StudentName} (${StudentID}) - Status: ${status}`);
        }
      }
    }
    
    console.log(`\n🎯 [CRON] Completed! Marked ${totalMarked} students as absent.`);
    
    return { 
      success: true, 
      message: `Marked ${totalMarked} students as absent`, 
      markedCount: totalMarked,
      classesProcessed: endedClasses.length
    };
    
  } catch (error) {
    console.error('❌ [CRON] Error marking absences:', error);
    return { 
      success: false, 
      error: error.message 
    };
  }
}

/**
 * Check for 3 consecutive absences and mark as DF
 * Only checks the last 3 days including today
 */
async function checkAndMarkDF(studentId, sectionId, subjectId, todayDate) {
  try {
    // Get the last 3 days of attendance including today
    const recentAttendance = await executeQuery(`
      SELECT attendance_date, status
      FROM attendance_records
      WHERE student_id = ?
        AND section_id = ?
        AND subject_id = ?
        AND attendance_date <= ?
      ORDER BY attendance_date DESC
      LIMIT 3
    `, [studentId, sectionId, subjectId, todayDate]);
    
    // Check if we have 3 records and all are 'Absent'
    if (recentAttendance.length === 3) {
      const allAbsent = recentAttendance.every(record => record.status === 'Absent');
      
      if (allAbsent) {
        console.log(`   🚨 Detected 3 consecutive absences for ${studentId} - Marking as DF`);
        
        // Update all 3 records to DF
        for (const record of recentAttendance) {
          await executeQuery(`
            UPDATE attendance_records
            SET status = 'DF'
            WHERE student_id = ?
              AND section_id = ?
              AND subject_id = ?
              AND attendance_date = ?
          `, [studentId, sectionId, subjectId, record.attendance_date]);
        }
        
        console.log(`   ✅ Marked 3 days as DF for student ${studentId}`);
      }
    }
  } catch (error) {
    console.error(`   ⚠️ Error checking DF for student ${studentId}:`, error.message);
  }
}

/**
 * Manual trigger for testing
 * Can be called via API endpoint
 */
export async function manualTrigger() {
  console.log('🔧 Manual trigger activated');
  return await markAbsentStudents();
}
