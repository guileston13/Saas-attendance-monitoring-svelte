// Client-side logout utility
import { goto, invalidateAll } from '$app/navigation';
import { browser } from '$app/environment';

/**
 * Handle logout process
 * Clears client-side data and redirects to login
 */
export async function handleLogout() {
    if (!browser) return;
    
    try {
        // Clear any client-side storage
        localStorage.clear();
        sessionStorage.clear();
        
        // Invalidate all data to force re-fetch
        await invalidateAll();
        
        // Navigate to logout endpoint which will clear server-side session
        await goto('/logout', { replaceState: true });
    } catch (error) {
        console.error('Logout error:', error);
        // Fallback: directly redirect to login
        window.location.href = '/login';
    }
}