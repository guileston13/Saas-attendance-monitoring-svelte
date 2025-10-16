import { error } from '@sveltejs/kit';
import { env } from '$env/dynamic/private';

export async function load({ request, platform }) {
  // Get client IP address
  let clientIp = 'unknown';

  // Try standard proxy headers first
  const forwarded = request.headers.get('x-forwarded-for');
  const realIp = request.headers.get('x-real-ip');
  const cfConnectingIp = request.headers.get('cf-connecting-ip');

  if (forwarded) {
    clientIp = forwarded.split(',')[0].trim();
  } else if (realIp) {
    clientIp = realIp;
  } else if (cfConnectingIp) {
    clientIp = cfConnectingIp;
  } else {
    // For development: try to get IP from platform (Node.js raw request)
    try {
      if (platform && platform.req) {
        clientIp = platform.req.connection?.remoteAddress ||
                   platform.req.socket?.remoteAddress ||
                   platform.req.connection?.socket?.remoteAddress || 'unknown';
      }
    } catch (err) {
      console.log('Could not get IP from platform:', err.message);
    }
  }

  console.log('🔍 IP Detection Debug:');
  console.log('  x-forwarded-for:', forwarded);
  console.log('  x-real-ip:', realIp);
  console.log('  cf-connecting-ip:', cfConnectingIp);
  console.log('  Platform IP:', platform?.req?.connection?.remoteAddress || 'N/A');
  console.log('  Final clientIp:', clientIp);

  // Get allowed IPs from environment variable (comma-separated)
  const allowedIps = env.ALLOWED_ATTENDANCE_IPS?.split(',').map(ip => ip.trim()) || [];

  console.log('  Allowed IPs:', allowedIps);
  console.log('  Is client IP allowed?', allowedIps.includes(clientIp));

  // If no allowed IPs configured, allow all (for development)
  if (allowedIps.length === 0) {
    console.warn('No ALLOWED_ATTENDANCE_IPS configured - allowing all access');
    return {};
  }
  console.log("myip=>",clientIp);
  // Check if client IP is allowed
  if (!allowedIps.includes(clientIp)) {
    console.warn(`Access denied for IP: ${clientIp}`);
    throw error(403, 'Access denied. This attendance system is restricted to authorized devices/locations only.');
  }

  console.log(`Access granted for IP: ${clientIp}`);
  return {};
}