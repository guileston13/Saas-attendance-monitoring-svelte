// Global error handling for SvelteKit
// This file handles any unhandled errors in the application

/** @type {import('@sveltejs/kit').HandleServerError} */
export function handleError({ error, event }) {
    console.error('Server error:', error);
    
    return {
        message: 'An unexpected error occurred',
        code: error?.code ?? 'UNKNOWN'
    };
}

/** @type {import('@sveltejs/kit').Handle} */
export async function handle({ event, resolve }) {
    // Handle the request normally
    const response = await resolve(event);
    return response;
}