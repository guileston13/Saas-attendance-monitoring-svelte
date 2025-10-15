<script>
	// Main application layout with sidebar navigation
	import { page } from '$app/stores';
	import { goto, invalidateAll } from '$app/navigation';
	import { onMount } from 'svelte';
	import { handleLogout } from '$lib/logout.js';
	import Sidebar from '$lib/components/Sidebar.svelte';
	import '../styles/global.css';
	
	/** @type {import('./$types').LayoutData} */
	export let data;
	
	$: session = data.session;
	$: currentSection = data.currentSection || 'Dashboard';
	
	// Sidebar state management
	let sidebarOpen = false;
	let isMobile = false;
	
	// Handle navigation changes and invalidate data when needed
	$: if ($page.url.pathname === '/login' || $page.url.pathname === '/logout') {
		session = null;
	}
	
	// Close sidebar when navigating on mobile
	$: if ($page.url.pathname && isMobile) {
		sidebarOpen = false;
	}
	
	function toggleSidebar() {
		sidebarOpen = !sidebarOpen;
	}
	
	function handleResize() {
		isMobile = window.innerWidth < 768;
		if (!isMobile) {
			sidebarOpen = false; // Reset sidebar state on desktop
		}
	}
	
	onMount(() => {
		// Initialize mobile detection
		handleResize();
		window.addEventListener('resize', handleResize);
		
		// Listen for navigation events to ensure session state is updated
		const unsubscribe = page.subscribe(() => {
			if ($page.url.pathname === '/logout') {
				// Force reload of layout data
				invalidateAll();
			}
		});
		
		return () => {
			window.removeEventListener('resize', handleResize);
			unsubscribe();
		};
	});
</script>

<svelte:head>
	<title>School Management System</title>
</svelte:head>

<div class="app">
	{#if session}
		<!-- Mobile Header with Hamburger -->
		<header class="mobile-header">
			<button class="hamburger-btn" on:click={toggleSidebar} aria-label="Toggle menu">
				<span class="hamburger-line"></span>
				<span class="hamburger-line"></span>
				<span class="hamburger-line"></span>
			</button>
			<div class="mobile-title">
				<h1>School Management System</h1>
				{#if currentSection !== 'Dashboard'}
					<span class="section-name">| {currentSection}</span>
				{/if}
			</div>
		</header>

		<!-- Sidebar Overlay for Mobile -->
		{#if isMobile && sidebarOpen}
			<div class="sidebar-overlay" on:click={toggleSidebar}></div>
		{/if}

		<!-- Sidebar Navigation Component -->
		<Sidebar {session} {currentSection} {sidebarOpen} {isMobile} />
		
		<main class="main-content">
			<slot />
		</main>
	{:else}
		<main class="auth-content">
			<slot />
		</main>
	{/if}
</div>

<style>
	.app {
		min-height: 100vh;
		display: flex;
		background: #ecf0f1;
	}

	/* Mobile Header */
	.mobile-header {
		display: none;
		position: fixed;
		top: 0;
		left: 0;
		right: 0;
		height: 60px;
		background: #2c3e50;
		color: white;
		padding: 0 1rem;
		align-items: center;
		gap: 1rem;
		z-index: 1001;
		box-shadow: 0 2px 4px rgba(0,0,0,0.1);
	}

	.hamburger-btn {
		background: none;
		border: none;
		display: flex;
		flex-direction: column;
		gap: 3px;
		cursor: pointer;
		padding: 8px;
		border-radius: 4px;
		transition: background-color 0.2s;
	}

	.hamburger-btn:hover {
		background: rgba(255,255,255,0.1);
	}

	.hamburger-line {
		width: 20px;
		height: 2px;
		background: white;
		transition: all 0.3s ease;
		border-radius: 1px;
	}

	/* Hamburger animation when active */
	.hamburger-btn:active .hamburger-line:nth-child(1) {
		transform: rotate(45deg) translate(5px, 5px);
	}

	.hamburger-btn:active .hamburger-line:nth-child(2) {
		opacity: 0;
	}

	.hamburger-btn:active .hamburger-line:nth-child(3) {
		transform: rotate(-45deg) translate(7px, -6px);
	}

	.mobile-title h1 {
		margin: 0;
		font-size: 1.2rem;
	}

	.section-name {
		font-size: 1rem;
		opacity: 0.8;
	}

	/* Sidebar Overlay */
	.sidebar-overlay {
		position: fixed;
		top: 0;
		left: 0;
		right: 0;
		bottom: 0;
		background: rgba(0,0,0,0.5);
		z-index: 999;
	}

	/* Main Content */
	.main-content {
		flex: 1;
		margin-left: 280px;
		padding: 2rem;
		min-height: 100vh;
		transition: margin-left 0.3s ease;
	}

	.auth-content {
		flex: 1;
		display: flex;
		justify-content: center;
		align-items: center;
		background: #ecf0f1;
	}

	/* Mobile Responsive */
	@media (max-width: 768px) {
		.mobile-header {
			display: flex;
		}

		.main-content {
			margin-left: 0;
			padding-top: 80px; /* Account for mobile header */
		}
	}

	/* Tablet Responsive */
	@media (max-width: 1024px) and (min-width: 769px) {
		.main-content {
			margin-left: 240px;
		}
	}

	/* Smooth animations */
	@media (prefers-reduced-motion: reduce) {
		.main-content,
		.hamburger-line {
			transition: none;
		}
	}
</style>