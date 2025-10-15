// Client-side hooks for SvelteKit
import { dev } from '$app/environment';

// Handle client-side errors
export function handleError({ error, event }) {
    if (dev) {
        console.error('Client error:', error);
    }
    
    return {
        message: 'An error occurred',
        code: error?.code ?? 'UNKNOWN'
    };
}