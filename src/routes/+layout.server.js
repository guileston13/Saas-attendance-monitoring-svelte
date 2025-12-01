// Main layout component - provides navigation and session context
import { getSessionFromCookies, isAuthenticated } from '$lib/auth.js';

/** @type {import('./$types').LayoutServerLoad} */
export async function load({ request, cookies, url }) {
    console.log('Layout load - checking session...');
    console.log('Current URL:', url.pathname);
    
    // If we're on logout page, ensure session is cleared
    if (url.pathname === '/logout') {
        cookies.delete('session', { path: '/' });
        return { session: null };
    }
    
    // Try both methods to get cookies
    const cookieHeader = request.headers.get('cookie');
    const sessionFromHeader = getSessionFromCookies(cookieHeader);
    
    // Also try SvelteKit cookies
    const sessionToken = cookies.get('session');
    let sessionFromCookies = null;
    
    if (sessionToken) {
        try {
            const sessionData = JSON.parse(Buffer.from(sessionToken, 'base64').toString());
            // Check if session is expired (24 hours)
            const twentyFourHours = 24 * 60 * 60 * 1000;
            if (Date.now() - sessionData.timestamp <= twentyFourHours) {
                sessionFromCookies = sessionData;
            } else {
                // Session expired, clear it
                cookies.delete('session', { path: '/' });
            }
        } catch (error) {
            console.log('Session parsing error:', error);
            // Invalid session, clear it
            cookies.delete('session', { path: '/' });
        }
    }
    
    const session = sessionFromCookies || sessionFromHeader;
    const authenticated = session && isAuthenticated(session);
    
    console.log('Cookie header:', cookieHeader ? 'EXISTS' : 'MISSING');
    console.log('Session token:', sessionToken ? 'EXISTS' : 'MISSING');
    console.log('Parsed session:', session ? 'EXISTS' : 'MISSING');
    console.log('Is authenticated:', authenticated);
    
    if (session) {
        console.log('Session details:', { userId: session.userId, email: session.email, role: session.role });
    }
    
    return {
        session: authenticated ? session : null
    };
}