// src/routes/attendance-login/+page.server.js
export async function load() {
    const DEV_MODE = true; // ✅ allow all local access

    if (DEV_MODE) {
        console.log('DEV_MODE: bypassing IP checks');
        return { 
            session: { user: 'dev' }
        };
    }

    // Production: check client IP if needed
    // const clientIp = request.headers.get('x-forwarded-for') || request.headers.get('x-real-ip') || 'unknown';
    // const allowedIps = ['127.0.0.1', 'DESKTOP-R98PM6A.local'];
    // if (!allowedIps.includes(clientIp)) {
    //     throw error(403, 'Access denied.');
    // }

    return {
        session: null
    };
}
