<script>
	import { page } from '$app/stores';
	import { handleLogout } from '$lib/logout.js';
	
	export let session;
	export let currentSection = 'Dashboard';
	export let sidebarOpen = false;
	export let isMobile = false;
	
	$: menuItems = getMenuItems(session.role);
	
	function getMenuItems(role) {
		const commonItems = [
			{ href: '/dashboard', icon: '📊', text: 'Dashboard', active: $page.url.pathname === '/dashboard' }
		];
		
		if (role === 'Admin') {
			return [
				...commonItems,
				{ href: '/students', icon: '👥', text: 'Students', active: $page.url.pathname.startsWith('/students') },
				{ href: '/teachers', icon: '👨‍🏫', text: 'Teachers', active: $page.url.pathname.startsWith('/teachers') },
				{ href: '/subjects', icon: '📚', text: 'Subjects', active: $page.url.pathname.startsWith('/subjects') },
				{ href: '/sections', icon: '🏫', text: 'Sections', active: $page.url.pathname.startsWith('/sections') },
				{ href: '/attendance', icon: '📋', text: 'Attendance', active: $page.url.pathname.startsWith('/attendance') },
				{ href: '/users', icon: '👤', text: 'Users', active: $page.url.pathname.startsWith('/users') },
				{ href: '/reports', icon: '📈', text: 'Reports', active: $page.url.pathname.startsWith('/reports') }
			];
		} else if (role === 'Teacher') {
			return [
				...commonItems,
				{ href: '/sections', icon: '🏫', text: 'My Sections', active: $page.url.pathname.startsWith('/sections') },
				{ href: '/attendance', icon: '📋', text: 'Attendance', active: $page.url.pathname.startsWith('/attendance') },
				{ href: '/students', icon: '👥', text: 'Students', active: $page.url.pathname.startsWith('/students') }
			];
		} else if (role === 'Student') {
			return [
				...commonItems,
				{ href: '/my-sections', icon: '🏫', text: 'My Sections', active: $page.url.pathname.startsWith('/my-sections') },
				{ href: '/profile', icon: '👤', text: 'Profile', active: $page.url.pathname === '/profile' }
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
		{#each menuItems as item}
			<a href={item.href} 
				class="nav-link" 
				class:active={item.active}>
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