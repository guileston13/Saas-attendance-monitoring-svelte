import { error } from '@sveltejs/kit';

/** @type {import('@sveltejs/kit').Handle} */
export async function handle({ event, resolve }) {
  // Get the hostname or IP from headers
  const forwardedHost = event.request.headers.get('x-forwarded-host');
  const hostHeader = event.request.headers.get('host');
  const clientHost = forwardedHost || hostHeader || 'unknown';

  console.log('🔍 Host detection debug:');
  console.log('  x-forwarded-host:', forwardedHost);
  console.log('  host header:', hostHeader);
  console.log('  clientHost:', clientHost);

  // Allowed hostnames
  const allowedHosts = [
    'DESKTOP-R98PM6A.local',
    'raspberrypi.local',
    'localhost',
    '172.27.44.17',
    '172.27.44.73',
    '172.27.44.213',
    '10.136.35.91'

  ];

  const isAllowed = allowedHosts.some((allowed) =>
    clientHost.toLowerCase().includes(allowed.toLowerCase())
  );

  console.log('  Is host allowed?', isAllowed);

  if (!isAllowed) {
    console.warn(`🚫 Access denied for host: ${clientHost}`);
    throw error(403, 'Access denied. This attendance system is restricted to authorized devices/locations only.');
  }

  return resolve(event);
}
