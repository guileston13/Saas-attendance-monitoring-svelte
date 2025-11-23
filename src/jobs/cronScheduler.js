// Cron job scheduler
// Manages all scheduled jobs for the school management system
import cron from 'node-cron';
import { markAbsentStudents } from './markAbsences.js';

/**
 * Initialize all cron jobs
 */
export function initializeCronJobs() {
  console.log('🚀 Initializing cron jobs...');
  
  // Job 1: Mark absent students every hour
  // Runs at the start of every hour (e.g., 8:00, 9:00, 10:00, etc.)
  const absenceJob = cron.schedule('0 * * * *', async () => {
    console.log('\n════════════════════════════════════════');
    console.log('🕐 CRON JOB: Absence Marking (Hourly)');
    console.log('════════════════════════════════════════');
    
    try {
      const result = await markAbsentStudents();
      
      if (result.success) {
        console.log(`✅ Success: ${result.message}`);
        console.log(`📊 Stats: ${result.markedCount} marked, ${result.classesProcessed} classes processed`);
      } else {
        console.error(`❌ Failed: ${result.error}`);
      }
    } catch (error) {
      console.error('❌ Cron job error:', error);
    }
    
    console.log('════════════════════════════════════════\n');
  }, {
    scheduled: true,
    timezone: "Asia/Manila" // Change to your timezone
  });
  
  console.log('✅ Cron job scheduled: Mark absences every hour (0 * * * *)');
  
  // Return jobs object for management
  return {
    absenceJob
  };
}

/**
 * Stop all cron jobs
 */
export function stopCronJobs(jobs) {
  console.log('🛑 Stopping cron jobs...');
  
  if (jobs.absenceJob) {
    jobs.absenceJob.stop();
    console.log('✅ Absence marking job stopped');
  }
}

/**
 * Get cron job status
 */
export function getCronJobStatus(jobs) {
  return {
    absenceJob: {
      running: jobs.absenceJob ? true : false,
      schedule: '0 * * * * (Every hour)',
      description: 'Mark students as absent for ended classes'
    }
  };
}
