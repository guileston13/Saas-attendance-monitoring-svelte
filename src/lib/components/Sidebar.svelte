<script>
	import { page } from '$app/stores';
	import { handleLogout } from '$lib/logout.js';
	
	export let session;
	export let currentSection = 'Dashboard';
	export let sidebarOpen = false;
	export let isMobile = false;
	
	$: menuItems = getMenuItems(session.role);
	
	// Track current path for reactivity
	$: currentPath = $page.url.pathname;
	
	// Reactive statement to compute active menu items based on current path and session
	$: activeMenuItems = $page.url.pathname && getMenuItems(session.role).map(item => ({
		...item,
		isActive: isMenuItemActive(item.href)
	}));
	
	function isMenuItemActive(href) {
		if (href === '/dashboard') {
			return currentPath === '/dashboard';
		}
		
		// For other routes, check if current path starts with href
		// but also ensure it doesn't match other routes
		if (href === '/subjects') {
			return currentPath === '/subjects' || currentPath.startsWith('/subjects/');
		}
		if (href === '/sections') {
			return currentPath === '/sections' || currentPath.startsWith('/sections/');
		}
		if (href === '/students') {
			return currentPath === '/students' || currentPath.startsWith('/students/');
		}
		if (href === '/teachers') {
			return currentPath === '/teachers' || currentPath.startsWith('/teachers/');
		}
		if (href === '/attendance') {
			return currentPath === '/attendance' || currentPath.startsWith('/attendance/');
		}
		if (href === '/users') {
			return currentPath === '/users' || currentPath.startsWith('/users/');
		}
		if (href === '/reports') {
			return currentPath === '/reports' || currentPath.startsWith('/reports/');
		}
		if (href === '/rooms') {
			return currentPath === '/rooms' || currentPath.startsWith('/rooms/');
		}
		
		// Default fallback
		return currentPath.startsWith(href);
	}
	
	function getMenuItems(role) {
		const commonItems = [
			{ href: '/dashboard', icon: '📊', text: 'Dashboard' }
		];
		
		if (role === 'Admin') {
			return [
				...commonItems,
				{ href: '/students', icon: '👥', text: 'Students' },
				{ href: '/teachers', icon: '👨‍🏫', text: 'Teachers' },
				{ href: '/subjects', icon: '📚', text: 'Subjects' },
				{ href: '/sections', icon: '🏫', text: 'Sections' },
				{ href: '/rooms', icon: '🏢', text: 'Rooms' },
				{ href: '/attendance', icon: '📋', text: 'Attendance' },
				{ href: '/users', icon: '👤', text: 'Users' },
				{ href: '/reports', icon: '📈', text: 'Reports' }
			];
		} else if (role === 'Teacher') {
			return [
				...commonItems,
				{ href: '/sections', icon: '🏫', text: 'My Sections' },
				{ href: '/attendance', icon: '📋', text: 'Attendance' },
				{ href: '/students', icon: '👥', text: 'Students' }
			];
		} else if (role === 'Student') {
			return [
				...commonItems,
				{ href: '/my-sections', icon: '🏫', text: 'My Sections' },
				{ href: '/profile', icon: '👤', text: 'Profile' }
			];
		}
		
		return commonItems;
	}
</script>

<!-- Sidebar Navigation -->
<aside class="sidebar" class:sidebar-open={sidebarOpen}>
	<div class="sidebar-header">
		<h1>School Management</h1>
		{#if currentSection !== 'Dashboard'}
			<span class="section-name">{currentSection}</span>
		{/if}
	</div>
	
	<nav class="sidebar-nav">
		{#each activeMenuItems as item}
			<a href={item.href} 
				class="nav-link" 
				class:active={item.isActive}>
				<span class="nav-icon">{item.icon}</span>
				<span class="nav-text">{item.text}</span>
			</a>
		{/each}
	</nav>
	
	<div class="sidebar-footer">
		<div class="user-info">
			<div class="user-avatar">
				{session.email.charAt(0).toUpperCase()}
			</div>
			<div class="user-details">
				<span class="user-email">{session.email}</span>
				<span class="user-role">{session.role}</span>
			</div>
		</div>
		<button type="button" class="logout-btn" on:click={handleLogout}>
			<span class="nav-icon">🚪</span>
			<span class="nav-text">Logout</span>
		</button>
	</div>
</aside>

<style>
	/* Sidebar */
	.sidebar {
		position: fixed;
		left: 0;
		top: 0;
		width: 280px;
		height: 100vh;
		background: #2c3e50;
		color: white;
		display: flex;
		flex-direction: column;
		box-shadow: 2px 0 4px rgba(0,0,0,0.1);
		z-index: 1000;
		transition: transform 0.3s ease;
	}

	.sidebar-header {
		padding: 2rem 1.5rem 1rem;
		border-bottom: 1px solid rgba(255,255,255,0.1);
	}

	.sidebar-header h1 {
		margin: 0 0 0.5rem 0;
		font-size: 1.5rem;
		font-weight: 700;
	}

	.section-name {
		font-size: 1rem;
		opacity: 0.8;
	}

	.sidebar-nav {
		flex: 1;
		padding: 1rem 0;
		overflow-y: auto;
	}

	.nav-link {
		display: flex;
		align-items: center;
		gap: 1rem;
		padding: 0.875rem 1.5rem;
		color: white;
		text-decoration: none;
		transition: all 0.2s ease;
		border-left: 3px solid transparent;
		position: relative;
	}

	.nav-link:hover {
		background: rgba(255,255,255,0.1);
		border-left-color: #3498db;
		transform: translateX(2px);
	}

	.nav-link.active {
		background: #3498db;
		border-left-color: #2980b9;
		box-shadow: 0 2px 4px rgba(52, 152, 219, 0.3);
	}

	.nav-link.active::after {
		content: '';
		position: absolute;
		right: 1rem;
		width: 6px;
		height: 6px;
		background: white;
		border-radius: 50%;
		opacity: 0.8;
	}

	.nav-icon {
		font-size: 1.2rem;
		width: 20px;
		text-align: center;
	}

	.nav-text {
		font-weight: 500;
	}

	.sidebar-footer {
		padding: 1rem;
		border-top: 1px solid rgba(255,255,255,0.1);
	}

	.user-info {
		display: flex;
		align-items: center;
		gap: 0.75rem;
		padding: 0.75rem;
		background: rgba(255,255,255,0.05);
		border-radius: 8px;
		margin-bottom: 1rem;
	}

	.user-avatar {
		width: 40px;
		height: 40px;
		background: #3498db;
		border-radius: 50%;
		display: flex;
		align-items: center;
		justify-content: center;
		font-weight: bold;
		font-size: 1.1rem;
	}

	.user-details {
		flex: 1;
		display: flex;
		flex-direction: column;
		gap: 0.25rem;
	}

	.user-email {
		font-size: 0.9rem;
		font-weight: 500;
	}

	.user-role {
		font-size: 0.8rem;
		opacity: 0.7;
	}

	.logout-btn {
		width: 100%;
		display: flex;
		align-items: center;
		gap: 1rem;
		padding: 0.75rem 1rem;
		background: #e74c3c;
		color: white;
		border: none;
		border-radius: 6px;
		cursor: pointer;
		font-size: 0.9rem;
		transition: background-color 0.2s;
	}

	.logout-btn:hover {
		background: #c0392b;
	}

	/* Mobile Responsive */
	@media (max-width: 768px) {
		.sidebar {
			transform: translateX(-100%);
		}

		.sidebar-open {
			transform: translateX(0);
		}

		.sidebar-header {
			padding-top: 1rem;
		}

		.nav-link {
			padding: 1rem 1.5rem;
		}

		.nav-icon {
			font-size: 1.3rem;
		}
	}

	/* Tablet Responsive */
	@media (max-width: 1024px) and (min-width: 769px) {
		.sidebar {
			width: 240px;
		}

		.sidebar-header {
			padding: 1.5rem 1rem 1rem;
		}

		.sidebar-header h1 {
			font-size: 1.3rem;
		}

		.nav-link {
			padding: 0.75rem 1rem;
		}
	}
</style>