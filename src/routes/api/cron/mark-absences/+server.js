// Manual trigger API for cron jobs (testing/admin use)
import { json } from '@sveltejs/kit';
import { getSessionFromCookies, isAuthenticated, hasRole } from '../../../../lib/auth.js';
import { manualTrigger } from '../../../../jobs/markAbsences.js';

/**
 * POST /api/cron/mark-absences
 * Manually trigger the absence marking job
 * Requires Admin authentication
 */
export async function POST({ request }) {
  const session = getSessionFromCookies(request.headers.get('cookie'));
  
  // Only admins can manually trigger cron jobs
  if (!isAuthenticated(session) || !hasRole(session, 'Admin')) {
    return json({ 
      success: false, 
      error: 'Unauthorized. Admin access required.' 
    }, { status: 401 });
  }
  
  try {
    console.log('🔧 Manual trigger requested by admin');
    const result = await manualTrigger();
    
    return json({
      success: result.success,
      message: result.message,
      data: {
        markedCount: result.markedCount,
        classesProcessed: result.classesProcessed,
        timestamp: new Date().toISOString()
      }
    });
  } catch (error) {
    console.error('Error triggering absence marking:', error);
    return json({ 
      success: false, 
      error: error.message 
    }, { status: 500 });
  }
}

/**
 * GET /api/cron/mark-absences
 * Get status of the cron job
 */
export async function GET({ request }) {
  const session = getSessionFromCookies(request.headers.get('cookie'));
  
  if (!isAuthenticated(session) || !hasRole(session, 'Admin')) {
    return json({ 
      success: false, 
      error: 'Unauthorized. Admin access required.' 
    }, { status: 401 });
  }
  
  return json({
    success: true,
    jobInfo: {
      name: 'Automatic Absence Marking',
      schedule: '0 * * * * (Every hour at minute 0)',
      description: 'Marks students as absent if they did not attend class after EndTime',
      timezone: 'Asia/Manila',
      enabled: true
    }
  });
}
