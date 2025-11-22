<script>
	import { enhance } from '$app/forms';
	import { invalidateAll } from '$app/navigation';
	import { onMount } from 'svelte';
	
	/** @type {import('./$types').PageData} */
	export let data;
	
	$: users = data.users || [];
	$: statuses = data.statuses || [];
	
	let showCreateModal = false;
	let editingUser = null;
	let loading = false;
	let searchTerm = '';
	
	// Premium loading and animation states
	let isLoading = true;
	let loadingProgress = 0;
	let loadingText = 'Initializing...';
	let loadingFadeOut = false;
	let pageVisible = false;
	let statsVisible = false;
	let tableVisible = false;
	let scrollY = 0;
	
	// Filter users based on search term
	$: filteredUsers = users.filter(user => 
		user.FullName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
		user.Email.toLowerCase().includes(searchTerm.toLowerCase()) ||
		user.Role.toLowerCase().includes(searchTerm.toLowerCase()) ||
		user.StatusName.toLowerCase().includes(searchTerm.toLowerCase())
	);
	
	// Premium loading animation sequence
	onMount(() => {
		const loadingSteps = [
			{ progress: 25, text: 'Loading user data...', delay: 300 },
			{ progress: 50, text: 'Preparing interface...', delay: 600 },
			{ progress: 75, text: 'Almost ready...', delay: 900 },
			{ progress: 100, text: 'Welcome!', delay: 1200 }
		];

		let currentStep = 0;
		
		const runLoadingStep = () => {
			if (currentStep < loadingSteps.length) {
				const step = loadingSteps[currentStep];
				setTimeout(() => {
					loadingProgress = step.progress;
					loadingText = step.text;
					currentStep++;
					runLoadingStep();
				}, step.delay);
			} else {
				// Loading complete - cascade animations
				setTimeout(() => {
					loadingFadeOut = true;
					setTimeout(() => {
						isLoading = false;
						setTimeout(() => pageVisible = true, 100);
						setTimeout(() => statsVisible = true, 300);
						setTimeout(() => tableVisible = true, 500);
					}, 800);
				}, 400);
			}
		};

		runLoadingStep();

		// Parallax scroll effect
		const handleScroll = () => {
			scrollY = window.scrollY;
		};

		setTimeout(() => {
			window.addEventListener('scroll', handleScroll, { passive: true });
		}, 2000);

		return () => {
			window.removeEventListener('scroll', handleScroll);
		};
	});
	
	function openCreateModal() {
		showCreateModal = true;
	}
	
	function closeCreateModal() {
		showCreateModal = false;
	}
	
	function editUser(user) {
		editingUser = { ...user };
	}
	
	function cancelEdit() {
		editingUser = null;
	}
	
	function handleKeydown(event) {
		if (event.key === 'Escape') {
			closeCreateModal();
			cancelEdit();
		}
	}
	
	function formatDate(dateString) {
		return new Date(dateString).toLocaleDateString();
	}
	
	function getStatusColor(statusName) {
		switch (statusName?.toLowerCase()) {
			case 'active': return '#22C55E';
			case 'inactive': return '#94A3B8';
			case 'suspended': return '#EF4444';
			case 'graduated': return '#3B82F6';
			default: return '#94A3B8';
		}
	}
</script>

<svelte:head>
	<title>User Management - School Management System</title>
</svelte:head>

<!-- Premium Loading Screen -->
{#if isLoading}
	<div class="loading-screen" class:fade-out={loadingFadeOut}>
		<!-- Animated Background Particles -->
		<div class="particles-container">
			{#each Array(20) as _, i}
				<div class="particle particle-{i % 4 + 1}" style="animation-delay: {i * 0.1}s"></div>
			{/each}
		</div>

		<!-- Main Loading Content -->
		<div class="loading-content">
			<!-- Animated Logo -->
			<div class="loading-logo">
				<svg class="logo-svg" fill="none" stroke="url(#logoGradient)" viewBox="0 0 24 24">
					<defs>
						<linearGradient id="logoGradient" x1="0%" y1="0%" x2="100%" y2="100%">
							<stop offset="0%" stop-color="#3B82F6">
								<animate attributeName="stop-color" values="#3B82F6;#A855F7;#22C55E;#F97316;#3B82F6" dur="3s" repeatCount="indefinite" />
							</stop>
							<stop offset="100%" stop-color="#A855F7">
								<animate attributeName="stop-color" values="#A855F7;#22C55E;#F97316;#3B82F6;#A855F7" dur="3s" repeatCount="indefinite" />
							</stop>
						</linearGradient>
					</defs>
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
				</svg>
				<div class="logo-pulse"></div>
			</div>

			<!-- Brand Text -->
			<div class="loading-brand">
				<h1 class="brand-main">User Management</h1>
				<p class="brand-tagline">System</p>
			</div>

			<!-- Loading Progress -->
			<div class="loading-progress">
				<div class="progress-bar">
					<div class="progress-fill" style="width: {loadingProgress}%"></div>
					<div class="progress-glow" style="width: {loadingProgress}%"></div>
				</div>
				<div class="progress-text">{loadingText}</div>
				<div class="progress-percentage">{loadingProgress}%</div>
			</div>

			<!-- Loading Dots Animation -->
			<div class="loading-dots">
				<div class="dot dot-1"></div>
				<div class="dot dot-2"></div>
				<div class="dot dot-3"></div>
			</div>
		</div>

		<!-- Background Gradient Orbs -->
		<div class="loading-orbs">
			<div class="orb orb-1"></div>
			<div class="orb orb-2"></div>
			<div class="orb orb-3"></div>
			<div class="orb orb-4"></div>
		</div>
	</div>
{/if}

<!-- Animated Background Layer -->
<div class="animated-background" style="transform: translateY({scrollY * 0.3}px)">
	<!-- ContentGrow-style Dot Pattern -->
	<div class="dot-pattern"></div>
	
	<!-- Floating Gradient Orbs -->
	<div class="floating-orb orb-bg-1"></div>
	<div class="floating-orb orb-bg-2"></div>
	<div class="floating-orb orb-bg-3"></div>
</div>

<div class="users-page" class:visible={pageVisible}>
	<!-- Page Header with Glass Morphism -->
	<div class="page-header" class:visible={pageVisible}>
		<div class="header-content">
			<div class="header-icon-wrapper">
				<svg class="header-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
				</svg>
			</div>
			<div>
				<h1>User Management</h1>
				<p class="subtitle">Manage user accounts, roles, and access permissions with ease</p>
			</div>
		</div>
		<button class="btn btn-primary" on:click={openCreateModal}>
			<svg class="btn-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
			</svg>
			Add New User
		</button>
	</div>
	
	{#if data.error}
		<div class="error-message error-slide-in">
			<svg class="error-icon" fill="currentColor" viewBox="0 0 20 20">
				<path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
			</svg>
			{data.error}
		</div>
	{/if}
	
	<!-- Premium Stats Cards with Glass Morphism -->
	<div class="stats-grid" class:visible={statsVisible}>
		<div class="stat-card stat-card-1">
			<div class="stat-icon-wrapper">
				<svg class="stat-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
				</svg>
			</div>
			<div class="stat-content">
				<span class="stat-number">{users.length}</span>
				<span class="stat-label">Total Users</span>
			</div>
			<div class="stat-glow"></div>
		</div>
		
		<div class="stat-card stat-card-2">
			<div class="stat-icon-wrapper">
				<svg class="stat-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
				</svg>
			</div>
			<div class="stat-content">
				<span class="stat-number">{users.filter(u => u.StatusName === 'Active').length}</span>
				<span class="stat-label">Active Users</span>
			</div>
			<div class="stat-glow"></div>
		</div>
		
		<div class="stat-card stat-card-3">
			<div class="stat-icon-wrapper">
				<svg class="stat-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
				</svg>
			</div>
			<div class="stat-content">
				<span class="stat-number">{users.filter(u => u.Role === 'Admin').length}</span>
				<span class="stat-label">Administrators</span>
			</div>
			<div class="stat-glow"></div>
		</div>
		
		<div class="stat-card stat-card-4">
			<div class="stat-icon-wrapper">
				<svg class="stat-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 14l9-5-9-5-9 5 9 5z" />
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 14l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14z" />
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 14l9-5-9-5-9 5 9 5zm0 0l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14zm-4 6v-7.5l4-2.222" />
				</svg>
			</div>
			<div class="stat-content">
				<span class="stat-number">{users.filter(u => u.Role === 'Student').length}</span>
				<span class="stat-label">Students</span>
			</div>
			<div class="stat-glow"></div>
		</div>
	</div>
	
	<!-- Premium Table Section with Glass Morphism -->
	<div class="content-section" class:visible={tableVisible}>
		<div class="section-card">
			<div class="card-header">
				<div class="header-left">
					<svg class="card-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01" />
					</svg>
					<h3 class="card-title">System Users</h3>
				</div>
			</div>
			
			<div class="card-content">
				<!-- Premium Search Bar -->
				<div class="search-container">
					<svg class="search-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
					</svg>
					<input
						type="text"
						bind:value={searchTerm}
						placeholder="Search by name, email, role, or status..."
						class="search-input"
					>
					{#if searchTerm}
						<button class="search-clear" on:click={() => searchTerm = ''}>
							<svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
								<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
							</svg>
						</button>
					{/if}
				</div>
				
				<!-- Premium Table -->
				<div class="table-container">
					<table class="data-table">
						<thead>
							<tr>
								<th>
									<div class="th-content">
										<svg class="th-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
											<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 20l4-16m2 16l4-16M6 9h14M4 15h14" />
										</svg>
										User ID
									</div>
								</th>
								<th>
									<div class="th-content">
										<svg class="th-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
											<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
										</svg>
										Name
									</div>
								</th>
								<th>
									<div class="th-content">
										<svg class="th-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
											<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
										</svg>
										Email
									</div>
								</th>
								<th>
									<div class="th-content">
										<svg class="th-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
											<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
										</svg>
										Role
									</div>
								</th>
								<th>
									<div class="th-content">
										<svg class="th-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
											<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
										</svg>
										Status
									</div>
								</th>
								<th>
									<div class="th-content">
										<svg class="th-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
											<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
										</svg>
										Created
									</div>
								</th>
								<th>
									<div class="th-content">
										<svg class="th-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
											<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z" />
										</svg>
										Actions
									</div>
								</th>
							</tr>
						</thead>
						<tbody>
							{#each filteredUsers as user, i}
								<tr class="table-row" style="animation-delay: {i * 0.05}s">
									<td>
										<span class="user-id">#{user.UserID}</span>
									</td>
									<td>
										<div class="user-name-cell">
											<div class="user-avatar">
												{(user.FullName || 'N/A').charAt(0).toUpperCase()}
											</div>
											<span class="user-name">{user.FullName || 'N/A'}</span>
										</div>
									</td>
									<td>
										<span class="user-email">{user.Email}</span>
									</td>
									<td>
										<span class="role-badge role-{user.Role.toLowerCase()}">{user.Role}</span>
									</td>
									<td>
										<span 
											class="status-badge" 
											style="--status-color: {getStatusColor(user.StatusName)}"
										>
											{user.StatusName}
										</span>
									</td>
									<td>
										<span class="date-text">{formatDate(user.CreatedAt)}</span>
									</td>
									<td>
										<div class="actions">
											<button 
												class="btn btn-action btn-edit" 
												on:click={() => editUser(user)}
												title="Edit user"
											>
												<svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
													<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
												</svg>
											</button>
											{#if user.UserID !== data.session.userId}
												<button 
													class="btn btn-action btn-delete"
													on:click={() => {
														if (confirm('Are you sure you want to delete this user?')) {
															console.log('Delete user', user.UserID);
														}
													}}
													title="Delete user"
												>
													<svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
														<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
													</svg>
												</button>
											{/if}
										</div>
									</td>
								</tr>
							{:else}
								<tr>
									<td colspan="7" class="text-center">
										<div class="empty-state">
											<svg class="empty-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
												<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4" />
											</svg>
											<h3>No users found</h3>
											<p>{searchTerm ? 'Try adjusting your search terms' : 'No user records available'}</p>
										</div>
									</td>
								</tr>
							{/each}
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>
</div>

<!-- Premium Create User Modal with Glass Morphism -->
{#if showCreateModal}
	<!-- svelte-ignore a11y-click-events-have-key-events -->
	<!-- svelte-ignore a11y-no-noninteractive-element-interactions -->
	<div class="modal-overlay modal-fade-in" on:click={closeCreateModal} on:keydown={handleKeydown} role="dialog" aria-modal="true" tabindex="-1">
		<!-- svelte-ignore a11y-click-events-have-key-events -->
		<!-- svelte-ignore a11y-no-static-element-interactions -->
		<div class="modal-content modal-slide-up" on:click|stopPropagation role="document">
			<div class="modal-header">
				<div class="modal-title-wrapper">
					<div class="modal-icon-wrapper modal-icon-create">
						<svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" />
						</svg>
					</div>
					<h3 class="modal-title">Create New User</h3>
				</div>
				<button class="close-btn" on:click={closeCreateModal} aria-label="Close modal">
					<svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
					</svg>
				</button>
			</div>
			
			<form method="POST" action="?/create" use:enhance>
				<div class="form-group">
					<label for="email" class="form-label">
						<svg class="label-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
						</svg>
						Email Address
					</label>
					<div class="input-wrapper">
						<input type="email" id="email" name="email" required class="form-input" placeholder="user@example.com" />
					</div>
				</div>
				
				<div class="form-group">
					<label for="password" class="form-label">
						<svg class="label-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
						</svg>
						Password
					</label>
					<div class="input-wrapper">
						<input type="password" id="password" name="password" required minlength="6" class="form-input" placeholder="Minimum 6 characters" />
					</div>
				</div>
				
				<div class="form-group">
					<label for="role" class="form-label">
						<svg class="label-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
						</svg>
						User Role
					</label>
					<div class="select-wrapper">
						<select id="role" name="role" required class="form-select">
							<option value="">Select Role</option>
							<option value="Admin">Administrator</option>
							<option value="Teacher">Teacher</option>
							<option value="Student">Student</option>
						</select>
						<svg class="select-arrow" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
						</svg>
					</div>
				</div>
				
				<div class="form-group">
					<label for="status" class="form-label">
						<svg class="label-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
						</svg>
						Account Status
					</label>
					<div class="select-wrapper">
						<select id="status" name="statusId" required class="form-select">
							<option value="">Select Status</option>
							{#each statuses as status}
								<option value={status.StatusID}>{status.StatusName}</option>
							{/each}
						</select>
						<svg class="select-arrow" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
						</svg>
					</div>
				</div>
				
				<div class="modal-actions">
					<button type="button" class="btn btn-secondary" on:click={closeCreateModal}>
						<svg class="btn-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
						</svg>
						Cancel
					</button>
					<button type="submit" class="btn btn-primary">
						<svg class="btn-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
						</svg>
						Create User
					</button>
				</div>
			</form>
		</div>
	</div>
{/if}

<!-- Premium Edit User Modal with Glass Morphism -->
{#if editingUser}
	<!-- svelte-ignore a11y-click-events-have-key-events -->
	<!-- svelte-ignore a11y-no-noninteractive-element-interactions -->
	<div class="modal-overlay modal-fade-in" on:click={cancelEdit} on:keydown={handleKeydown} role="dialog" aria-modal="true" tabindex="-1">
		<!-- svelte-ignore a11y-click-events-have-key-events -->
		<!-- svelte-ignore a11y-no-static-element-interactions -->
		<div class="modal-content modal-slide-up" on:click|stopPropagation role="document">
			<div class="modal-header">
				<div class="modal-title-wrapper">
					<div class="modal-icon-wrapper modal-icon-edit">
						<svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
						</svg>
					</div>
					<h3 class="modal-title">Edit User</h3>
				</div>
				<button class="close-btn" on:click={cancelEdit} aria-label="Close modal">
					<svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
					</svg>
				</button>
			</div>
			
			<form method="POST" action="?/update" use:enhance>
				<input type="hidden" name="userId" value={editingUser.UserID} />
				
				<div class="form-group">
					<label for="edit-email" class="form-label">
						<svg class="label-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
						</svg>
						Email Address
					</label>
					<div class="input-wrapper">
						<input type="email" id="edit-email" name="email" bind:value={editingUser.Email} required class="form-input" />
					</div>
				</div>
				
				<div class="form-group">
					<label for="edit-role" class="form-label">
						<svg class="label-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
						</svg>
						User Role
					</label>
					<div class="select-wrapper">
						<select id="edit-role" name="role" bind:value={editingUser.Role} required class="form-select">
							<option value="Admin">Administrator</option>
							<option value="Teacher">Teacher</option>
							<option value="Student">Student</option>
						</select>
						<svg class="select-arrow" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
						</svg>
					</div>
				</div>
				
				<div class="form-group">
					<label for="edit-status" class="form-label">
						<svg class="label-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
						</svg>
						Account Status
					</label>
					<div class="select-wrapper">
						<select id="edit-status" name="statusId" bind:value={editingUser.StatusID} required class="form-select">
							{#each statuses as status}
								<option value={status.StatusID}>{status.StatusName}</option>
							{/each}
						</select>
						<svg class="select-arrow" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
						</svg>
					</div>
				</div>
				
				<div class="modal-actions">
					<button type="button" class="btn btn-secondary" on:click={cancelEdit}>
						<svg class="btn-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
						</svg>
						Cancel
					</button>
					<button type="submit" class="btn btn-primary">
						<svg class="btn-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
						</svg>
						Update User
					</button>
				</div>
			</form>
		</div>
	</div>
{/if}

<style>
	/* ========================================
	   PREMIUM LOADING SCREEN STYLES
	   ======================================== */
	
	.loading-screen {
		position: fixed;
		inset: 0;
		z-index: 9999;
		background: linear-gradient(135deg, #0f172a, #1e293b, #334155);
		display: flex;
		align-items: center;
		justify-content: center;
		overflow: hidden;
		animation: loadingFadeIn 0.5s ease-out;
	}

	.loading-screen.fade-out {
		animation: loadingFadeOut 0.8s ease-in-out forwards;
	}

	/* Animated Particles */
	.particles-container {
		position: absolute;
		inset: 0;
		pointer-events: none;
	}

	.particle {
		position: absolute;
		border-radius: 50%;
		opacity: 0.6;
		animation: particleFloat 8s ease-in-out infinite;
	}

	.particle-1 {
		width: 4px;
		height: 4px;
		background: #3B82F6;
	}

	.particle-2 {
		width: 6px;
		height: 6px;
		background: #A855F7;
	}

	.particle-3 {
		width: 3px;
		height: 3px;
		background: #22C55E;
	}

	.particle-4 {
		width: 5px;
		height: 5px;
		background: #F97316;
	}

	.particle:nth-child(1) { top: 10%; left: 10%; }
	.particle:nth-child(2) { top: 20%; left: 80%; animation-delay: 0.5s; }
	.particle:nth-child(3) { top: 30%; left: 20%; animation-delay: 1s; }
	.particle:nth-child(4) { top: 40%; left: 70%; animation-delay: 1.5s; }
	.particle:nth-child(5) { top: 50%; left: 30%; animation-delay: 2s; }
	.particle:nth-child(6) { top: 60%; left: 90%; animation-delay: 0.3s; }
	.particle:nth-child(7) { top: 70%; left: 40%; animation-delay: 0.8s; }
	.particle:nth-child(8) { top: 80%; left: 60%; animation-delay: 1.3s; }
	.particle:nth-child(9) { top: 15%; left: 50%; animation-delay: 1.8s; }
	.particle:nth-child(10) { top: 85%; left: 15%; animation-delay: 0.6s; }
	.particle:nth-child(11) { top: 25%; left: 85%; animation-delay: 1.1s; }
	.particle:nth-child(12) { top: 75%; left: 25%; animation-delay: 1.6s; }
	.particle:nth-child(13) { top: 35%; left: 45%; animation-delay: 2.1s; }
	.particle:nth-child(14) { top: 65%; left: 75%; animation-delay: 0.4s; }
	.particle:nth-child(15) { top: 45%; left: 5%; animation-delay: 0.9s; }
	.particle:nth-child(16) { top: 55%; left: 95%; animation-delay: 1.4s; }
	.particle:nth-child(17) { top: 5%; left: 35%; animation-delay: 1.9s; }
	.particle:nth-child(18) { top: 95%; left: 65%; animation-delay: 0.7s; }
	.particle:nth-child(19) { top: 55%; left: 55%; animation-delay: 1.2s; }
	.particle:nth-child(20) { top: 75%; left: 85%; animation-delay: 1.7s; }

	/* Loading Content */
	.loading-content {
		text-align: center;
		z-index: 10;
		position: relative;
	}

	.loading-logo {
		position: relative;
		display: inline-block;
		margin-bottom: 2rem;
	}

	.logo-svg {
		width: 6rem;
		height: 6rem;
		filter: drop-shadow(0 0 20px rgba(59, 130, 246, 0.5));
		animation: logoRotate 4s ease-in-out infinite;
	}

	.logo-pulse {
		position: absolute;
		inset: -1rem;
		border-radius: 50%;
		background: radial-gradient(circle, rgba(59, 130, 246, 0.3) 0%, transparent 70%);
		animation: logoPulse 2s ease-in-out infinite;
	}

	.loading-brand {
		margin-bottom: 3rem;
	}

	.brand-main {
		font-size: 3rem;
		font-weight: 800;
		background: linear-gradient(135deg, #3B82F6, #A855F7, #22C55E, #F97316);
		-webkit-background-clip: text;
		-webkit-text-fill-color: transparent;
		background-clip: text;
		margin-bottom: 0.5rem;
		animation: textGlow 3s ease-in-out infinite alternate;
	}

	.brand-tagline {
		font-size: 1.5rem;
		font-weight: 600;
		color: #94a3b8;
		letter-spacing: 0.1em;
	}

	/* Progress Bar */
	.loading-progress {
		margin-bottom: 2rem;
	}

	.progress-bar {
		width: 300px;
		height: 6px;
		background: rgba(255, 255, 255, 0.1);
		border-radius: 3px;
		margin: 0 auto 1rem;
		overflow: hidden;
		position: relative;
	}

	.progress-fill {
		height: 100%;
		background: linear-gradient(90deg, #3B82F6, #A855F7, #22C55E);
		border-radius: 3px;
		transition: width 0.8s cubic-bezier(0.4, 0, 0.2, 1);
		position: relative;
	}

	.progress-fill::after {
		content: '';
		position: absolute;
		top: 0;
		left: 0;
		bottom: 0;
		right: 0;
		background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.4), transparent);
		animation: progressShine 2s ease-in-out infinite;
	}

	.progress-glow {
		position: absolute;
		top: 0;
		left: 0;
		height: 100%;
		background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.6), transparent);
		border-radius: 3px;
		animation: progressGlow 1.5s ease-in-out infinite;
	}

	.progress-text {
		color: #cbd5e1;
		font-size: 1rem;
		font-weight: 500;
		margin-bottom: 0.5rem;
		animation: textFade 0.5s ease-in-out;
	}

	.progress-percentage {
		color: #3B82F6;
		font-size: 1.2rem;
		font-weight: 700;
		font-variant-numeric: tabular-nums;
	}

	/* Loading Dots */
	.loading-dots {
		display: flex;
		justify-content: center;
		gap: 0.5rem;
		margin-top: 1rem;
	}

	.loading-dots .dot {
		width: 8px;
		height: 8px;
		border-radius: 50%;
		background: #3B82F6;
		animation: dotBounce 1.4s ease-in-out infinite both;
	}

	.dot-1 { animation-delay: -0.32s; }
	.dot-2 { animation-delay: -0.16s; }
	.dot-3 { animation-delay: 0s; }

	/* Background Orbs */
	.loading-orbs {
		position: absolute;
		inset: 0;
		pointer-events: none;
	}

	.orb {
		position: absolute;
		border-radius: 50%;
		filter: blur(60px);
		opacity: 0.3;
		animation: orbFloat 6s ease-in-out infinite;
	}

	.orb-1 {
		width: 200px;
		height: 200px;
		background: #3B82F6;
		top: 10%;
		left: 10%;
		animation-delay: 0s;
	}

	.orb-2 {
		width: 300px;
		height: 300px;
		background: #A855F7;
		top: 60%;
		right: 10%;
		animation-delay: 2s;
	}

	.orb-3 {
		width: 150px;
		height: 150px;
		background: #22C55E;
		bottom: 20%;
		left: 20%;
		animation-delay: 4s;
	}

	.orb-4 {
		width: 250px;
		height: 250px;
		background: #F97316;
		top: 30%;
		right: 30%;
		animation-delay: 1s;
	}

	/* ========================================
	   ANIMATED BACKGROUND & DOT PATTERN
	   ======================================== */
	
	.animated-background {
		position: fixed;
		inset: 0;
		z-index: -10;
		overflow: hidden;
		background: #FFFFFF;
		transition: transform 0.1s ease-out;
	}

	/* ContentGrow-style Dot Pattern */
	.dot-pattern {
		position: absolute;
		inset: 0;
		background-image: radial-gradient(circle, #d0d0d0 1px, transparent 1px);
		background-size: 30px 30px;
		background-position: 0 0;
		opacity: 0.6;
	}

	.floating-orb {
		position: absolute;
		border-radius: 50%;
		filter: blur(80px);
		opacity: 0.15;
	}

	.orb-bg-1 {
		top: 10%;
		left: 10%;
		width: 400px;
		height: 400px;
		background: linear-gradient(135deg, #3B82F6, #A855F7);
		animation: float 8s ease-in-out infinite;
	}

	.orb-bg-2 {
		top: 50%;
		right: 10%;
		width: 500px;
		height: 500px;
		background: linear-gradient(135deg, #22C55E, #3B82F6);
		animation: float 10s ease-in-out infinite reverse;
	}

	.orb-bg-3 {
		bottom: 10%;
		left: 30%;
		width: 350px;
		height: 350px;
		background: linear-gradient(135deg, #F97316, #A855F7);
		animation: float 12s ease-in-out infinite;
	}

	/* ========================================
	   MAIN PAGE CONTAINER
	   ======================================== */
	
	.users-page {
		max-width: 1400px;
		margin: 0 auto;
		padding: 2rem;
		opacity: 0;
		transform: translateY(20px);
		transition: all 0.6s cubic-bezier(0.4, 0, 0.2, 1);
	}

	.users-page.visible {
		opacity: 1;
		transform: translateY(0);
	}

	/* ========================================
	   PREMIUM PAGE HEADER WITH GLASS MORPHISM
	   ======================================== */
	
	.page-header {
		background: rgba(255, 255, 255, 0.4);
		backdrop-filter: blur(20px);
		-webkit-backdrop-filter: blur(20px);
		border: 1px solid rgba(255, 255, 255, 0.5);
		border-radius: 24px;
		padding: 2.5rem;
		margin-bottom: 2rem;
		box-shadow: 
			0 20px 60px rgba(0, 0, 0, 0.08),
			0 0 0 1px rgba(255, 255, 255, 0.3) inset;
		display: flex;
		justify-content: space-between;
		align-items: center;
		flex-wrap: wrap;
		gap: 1.5rem;
		position: relative;
		overflow: hidden;
		opacity: 0;
		transform: translateY(30px) scale(0.95);
		transition: all 0.6s cubic-bezier(0.4, 0, 0.2, 1);
	}

	.page-header.visible {
		opacity: 1;
		transform: translateY(0) scale(1);
	}

	.page-header::before {
		content: '';
		position: absolute;
		inset: 0;
		border-radius: 24px;
		padding: 2px;
		background: linear-gradient(135deg, #3B82F6, #A855F7, #22C55E);
		-webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
		-webkit-mask-composite: xor;
		mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
		mask-composite: exclude;
		opacity: 0.3;
	}

	.header-content {
		display: flex;
		align-items: center;
		gap: 1.5rem;
	}

	.header-icon-wrapper {
		width: 64px;
		height: 64px;
		background: linear-gradient(135deg, #3B82F6, #A855F7);
		border-radius: 16px;
		display: flex;
		align-items: center;
		justify-content: center;
		box-shadow: 0 8px 20px rgba(59, 130, 246, 0.3);
		animation: pulse-slow 3s ease-in-out infinite;
	}

	.header-icon {
		width: 36px;
		height: 36px;
		color: white;
	}

	.page-header h1 {
		margin: 0 0 0.5rem 0;
		font-size: 2.5rem;
		font-weight: 700;
		background: linear-gradient(135deg, #3B82F6, #A855F7);
		-webkit-background-clip: text;
		-webkit-text-fill-color: transparent;
		background-clip: text;
	}

	.subtitle {
		margin: 0;
		color: #64748b;
		font-size: 1.1rem;
		font-weight: 500;
	}

	/* ========================================
	   ERROR MESSAGE
	   ======================================== */
	
	.error-message {
		display: flex;
		align-items: center;
		gap: 0.75rem;
		padding: 1.25rem 1.5rem;
		background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.1));
		border: 1px solid rgba(239, 68, 68, 0.3);
		border-radius: 16px;
		color: #DC2626;
		font-size: 0.95rem;
		font-weight: 500;
		margin-bottom: 1.5rem;
		animation: shake 0.4s ease;
	}

	.error-slide-in {
		animation: slideInFromTop 0.5s ease-out, shake 0.4s ease 0.5s;
	}

	.error-icon {
		width: 1.5rem;
		height: 1.5rem;
		flex-shrink: 0;
	}

	/* ========================================
	   PREMIUM STATS CARDS WITH GLASS MORPHISM
	   ======================================== */
	
	.stats-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
		gap: 1.5rem;
		margin-bottom: 2rem;
		opacity: 0;
		transform: translateY(30px);
		transition: all 0.6s cubic-bezier(0.4, 0, 0.2, 1) 0.2s;
	}

	.stats-grid.visible {
		opacity: 1;
		transform: translateY(0);
	}

	.stat-card {
		background: rgba(255, 255, 255, 0.5);
		backdrop-filter: blur(20px);
		-webkit-backdrop-filter: blur(20px);
		border: 1px solid rgba(255, 255, 255, 0.6);
		border-radius: 20px;
		padding: 2rem;
		display: flex;
		align-items: center;
		gap: 1.5rem;
		transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
		position: relative;
		overflow: hidden;
		box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
		opacity: 0;
		transform: translateY(20px) scale(0.95);
	}

	.stat-card-1 { animation: cascadeIn 0.5s ease-out 0.1s forwards; }
	.stat-card-2 { animation: cascadeIn 0.5s ease-out 0.2s forwards; }
	.stat-card-3 { animation: cascadeIn 0.5s ease-out 0.3s forwards; }
	.stat-card-4 { animation: cascadeIn 0.5s ease-out 0.4s forwards; }

	.stat-card:hover {
		transform: translateY(-8px) scale(1.02);
		box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
		border-color: rgba(59, 130, 246, 0.4);
	}

	.stat-card::before {
		content: '';
		position: absolute;
		inset: 0;
		border-radius: 20px;
		padding: 2px;
		background: linear-gradient(135deg, #3B82F6, #A855F7);
		-webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
		-webkit-mask-composite: xor;
		mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
		mask-composite: exclude;
		opacity: 0;
		transition: opacity 0.3s ease;
	}

	.stat-card:hover::before {
		opacity: 0.5;
	}

	.stat-glow {
		position: absolute;
		inset: -50%;
		background: radial-gradient(circle, rgba(59, 130, 246, 0.1) 0%, transparent 70%);
		opacity: 0;
		transition: opacity 0.3s ease;
		pointer-events: none;
	}

	.stat-card:hover .stat-glow {
		opacity: 1;
		animation: glowPulse 2s ease-in-out infinite;
	}

	.stat-icon-wrapper {
		width: 64px;
		height: 64px;
		background: linear-gradient(135deg, #3B82F6, #A855F7);
		border-radius: 16px;
		display: flex;
		align-items: center;
		justify-content: center;
		flex-shrink: 0;
		box-shadow: 0 8px 20px rgba(59, 130, 246, 0.3);
		transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
	}

	.stat-card:hover .stat-icon-wrapper {
		transform: scale(1.1) rotate(5deg);
	}

	.stat-icon {
		width: 32px;
		height: 32px;
		color: white;
	}

	.stat-content {
		flex: 1;
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
	}

	.stat-number {
		font-size: 2.5rem;
		font-weight: 800;
		background: linear-gradient(135deg, #2c3e50, #3B82F6);
		-webkit-background-clip: text;
		-webkit-text-fill-color: transparent;
		background-clip: text;
		line-height: 1;
	}

	.stat-label {
		color: #64748b;
		font-size: 1rem;
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.05em;
	}

	/* ========================================
	   PREMIUM TABLE SECTION WITH GLASS MORPHISM
	   ======================================== */
	
	.content-section {
		opacity: 0;
		transform: translateY(30px);
		transition: all 0.6s cubic-bezier(0.4, 0, 0.2, 1) 0.4s;
	}

	.content-section.visible {
		opacity: 1;
		transform: translateY(0);
	}

	.section-card {
		background: rgba(255, 255, 255, 0.5);
		backdrop-filter: blur(20px);
		-webkit-backdrop-filter: blur(20px);
		border: 1px solid rgba(255, 255, 255, 0.6);
		border-radius: 24px;
		box-shadow: 0 20px 60px rgba(0, 0, 0, 0.08);
		overflow: hidden;
		position: relative;
	}

	.section-card::before {
		content: '';
		position: absolute;
		top: 0;
		left: 0;
		right: 0;
		height: 4px;
		background: linear-gradient(90deg, #3B82F6, #A855F7, #22C55E, #F97316);
	}

	.card-header {
		background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(168, 85, 247, 0.1));
		backdrop-filter: blur(10px);
		padding: 2rem 2.5rem;
		border-bottom: 1px solid rgba(255, 255, 255, 0.3);
	}

	.header-left {
		display: flex;
		align-items: center;
		gap: 1rem;
	}

	.card-icon {
		width: 32px;
		height: 32px;
		color: #3B82F6;
	}

	.card-title {
		margin: 0;
		font-size: 1.75rem;
		font-weight: 700;
		background: linear-gradient(135deg, #3B82F6, #A855F7);
		-webkit-background-clip: text;
		-webkit-text-fill-color: transparent;
		background-clip: text;
	}

	.card-content {
		padding: 2.5rem;
	}

	/* ========================================
	   PREMIUM SEARCH BAR
	   ======================================== */
	
	.search-container {
		position: relative;
		margin-bottom: 2rem;
	}

	.search-icon {
		position: absolute;
		left: 1.25rem;
		top: 50%;
		transform: translateY(-50%);
		width: 20px;
		height: 20px;
		color: #94a3b8;
		pointer-events: none;
	}

	.search-input {
		width: 100%;
		padding: 1rem 1.25rem 1rem 3.5rem;
		border: 2px solid rgba(148, 163, 184, 0.2);
		border-radius: 16px;
		font-size: 1rem;
		background: rgba(255, 255, 255, 0.7);
		backdrop-filter: blur(10px);
		transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
		outline: none;
	}

	.search-input:focus {
		border-color: #3B82F6;
		background: rgba(255, 255, 255, 0.95);
		box-shadow: 0 8px 20px rgba(59, 130, 246, 0.15);
		transform: translateY(-2px);
	}

	.search-input::placeholder {
		color: #94a3b8;
	}

	.search-clear {
		position: absolute;
		right: 1rem;
		top: 50%;
		transform: translateY(-50%);
		background: rgba(148, 163, 184, 0.1);
		border: none;
		border-radius: 50%;
		width: 28px;
		height: 28px;
		display: flex;
		align-items: center;
		justify-content: center;
		cursor: pointer;
		transition: all 0.2s ease;
	}

	.search-clear:hover {
		background: rgba(148, 163, 184, 0.2);
		transform: translateY(-50%) scale(1.1);
	}

	.search-clear svg {
		width: 16px;
		height: 16px;
		color: #64748b;
	}

	/* ========================================
	   PREMIUM DATA TABLE
	   ======================================== */
	
	.table-container {
		overflow-x: auto;
		border-radius: 16px;
		background: rgba(255, 255, 255, 0.4);
		backdrop-filter: blur(10px);
	}

	.data-table {
		width: 100%;
		border-collapse: collapse;
	}

	.data-table thead tr {
		background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(168, 85, 247, 0.1));
		backdrop-filter: blur(10px);
	}

	.data-table th {
		padding: 1.25rem 1rem;
		text-align: left;
		font-weight: 600;
		font-size: 0.875rem;
		text-transform: uppercase;
		letter-spacing: 0.05em;
		color: #475569;
		border-bottom: 2px solid rgba(148, 163, 184, 0.2);
	}

	.th-content {
		display: flex;
		align-items: center;
		gap: 0.5rem;
	}

	.th-icon {
		width: 16px;
		height: 16px;
		color: #3B82F6;
		opacity: 0.7;
	}

	.data-table tbody tr {
		border-bottom: 1px solid rgba(148, 163, 184, 0.1);
		transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
	}

	.table-row {
		opacity: 0;
		transform: translateX(-20px);
		animation: slideInRow 0.5s ease-out forwards;
	}

	.data-table tbody tr:hover {
		background: rgba(59, 130, 246, 0.05);
		transform: translateX(4px);
	}

	.data-table td {
		padding: 1.25rem 1rem;
		color: #334155;
		font-size: 0.95rem;
	}

	.user-id {
		font-weight: 700;
		color: #3B82F6;
		font-size: 0.9rem;
	}

	.user-name-cell {
		display: flex;
		align-items: center;
		gap: 0.75rem;
	}

	.user-avatar {
		width: 40px;
		height: 40px;
		border-radius: 50%;
		background: linear-gradient(135deg, #3B82F6, #A855F7);
		display: flex;
		align-items: center;
		justify-content: center;
		color: white;
		font-weight: 700;
		font-size: 1.1rem;
		flex-shrink: 0;
		box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
	}

	.user-name {
		font-weight: 600;
		color: #1e293b;
	}

	.user-email {
		color: #64748b;
		font-size: 0.9rem;
	}

	.date-text {
		color: #64748b;
		font-size: 0.9rem;
	}

	/* ========================================
	   ROLE & STATUS BADGES
	   ======================================== */
	
	.role-badge {
		display: inline-flex;
		align-items: center;
		padding: 0.5rem 1rem;
		border-radius: 12px;
		font-size: 0.85rem;
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.05em;
		color: white;
		transition: all 0.2s ease;
	}

	.role-admin {
		background: linear-gradient(135deg, #EF4444, #DC2626);
		box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
	}

	.role-teacher {
		background: linear-gradient(135deg, #3B82F6, #2563EB);
		box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
	}

	.role-student {
		background: linear-gradient(135deg, #22C55E, #16A34A);
		box-shadow: 0 4px 12px rgba(34, 197, 94, 0.3);
	}

	.role-badge:hover {
		transform: translateY(-2px) scale(1.05);
	}

	.status-badge {
		display: inline-flex;
		align-items: center;
		padding: 0.5rem 1rem;
		border-radius: 12px;
		font-size: 0.85rem;
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.05em;
		color: white;
		background: var(--status-color);
		box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
		transition: all 0.2s ease;
	}

	.status-badge:hover {
		transform: translateY(-2px) scale(1.05);
	}

	/* ========================================
	   ACTION BUTTONS
	   ======================================== */
	
	.actions {
		display: flex;
		gap: 0.5rem;
		align-items: center;
	}

	.btn {
		padding: 0.75rem 1.5rem;
		border: none;
		border-radius: 12px;
		cursor: pointer;
		font-size: 0.95rem;
		font-weight: 600;
		transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
		text-decoration: none;
		display: inline-flex;
		align-items: center;
		gap: 0.5rem;
		position: relative;
		overflow: hidden;
	}

	.btn::before {
		content: '';
		position: absolute;
		inset: 0;
		background: linear-gradient(135deg, rgba(255, 255, 255, 0.2), rgba(255, 255, 255, 0));
		opacity: 0;
		transition: opacity 0.3s ease;
	}

	.btn:hover::before {
		opacity: 1;
	}

	.btn-icon {
		width: 18px;
		height: 18px;
	}

	.btn-primary {
		background: linear-gradient(135deg, #3B82F6, #2563EB);
		color: white;
		box-shadow: 0 4px 15px rgba(59, 130, 246, 0.3);
	}

	.btn-primary:hover {
		transform: translateY(-2px) scale(1.02);
		box-shadow: 0 8px 25px rgba(59, 130, 246, 0.4);
	}

	.btn-primary:active {
		transform: translateY(0) scale(0.98);
	}

	.btn-secondary {
		background: linear-gradient(135deg, #64748b, #475569);
		color: white;
		box-shadow: 0 4px 15px rgba(100, 116, 139, 0.3);
	}

	.btn-secondary:hover {
		transform: translateY(-2px) scale(1.02);
		box-shadow: 0 8px 25px rgba(100, 116, 139, 0.4);
	}

	.btn-action {
		padding: 0.625rem;
		width: 40px;
		height: 40px;
		justify-content: center;
	}

	.btn-action svg {
		width: 20px;
		height: 20px;
	}

	.btn-edit {
		background: linear-gradient(135deg, #3B82F6, #2563EB);
		color: white;
		box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
	}

	.btn-edit:hover {
		transform: translateY(-2px) scale(1.1);
		box-shadow: 0 6px 18px rgba(59, 130, 246, 0.4);
	}

	.btn-delete {
		background: linear-gradient(135deg, #EF4444, #DC2626);
		color: white;
		box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
	}

	.btn-delete:hover {
		transform: translateY(-2px) scale(1.1);
		box-shadow: 0 6px 18px rgba(239, 68, 68, 0.4);
	}

	/* ========================================
	   EMPTY STATE
	   ======================================== */
	
	.empty-state {
		text-align: center;
		padding: 4rem 2rem;
		color: #94a3b8;
	}

	.empty-icon {
		width: 80px;
		height: 80px;
		color: #cbd5e1;
		margin: 0 auto 1.5rem;
		opacity: 0.5;
	}

	.empty-state h3 {
		margin-bottom: 0.75rem;
		color: #475569;
		font-size: 1.5rem;
		font-weight: 700;
	}

	.empty-state p {
		color: #94a3b8;
		font-size: 1rem;
	}

	.text-center {
		text-align: center;
	}

	/* ========================================
	   PREMIUM MODAL STYLES WITH GLASS MORPHISM
	   ======================================== */
	
	.modal-overlay {
		position: fixed;
		top: 0;
		left: 0;
		width: 100%;
		height: 100%;
		background: rgba(15, 23, 42, 0.6);
		backdrop-filter: blur(8px);
		display: flex;
		align-items: center;
		justify-content: center;
		z-index: 1000;
		padding: 1rem;
	}

	.modal-fade-in {
		animation: modalFadeIn 0.3s ease-out;
	}

	.modal-content {
		background: rgba(255, 255, 255, 0.95);
		backdrop-filter: blur(40px);
		-webkit-backdrop-filter: blur(40px);
		border: 1px solid rgba(255, 255, 255, 0.8);
		border-radius: 24px;
		padding: 0;
		max-width: 540px;
		width: 100%;
		max-height: 90vh;
		overflow-y: auto;
		box-shadow: 0 25px 80px rgba(0, 0, 0, 0.2);
		position: relative;
	}

	.modal-slide-up {
		animation: modalSlideUp 0.4s cubic-bezier(0.4, 0, 0.2, 1);
	}

	.modal-content::before {
		content: '';
		position: absolute;
		inset: 0;
		border-radius: 24px;
		padding: 2px;
		background: linear-gradient(135deg, #3B82F6, #A855F7, #22C55E);
		-webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
		-webkit-mask-composite: xor;
		mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
		mask-composite: exclude;
		opacity: 0.5;
		pointer-events: none;
	}

	.modal-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: 2rem 2.5rem;
		border-bottom: 1px solid rgba(148, 163, 184, 0.2);
		background: linear-gradient(135deg, rgba(59, 130, 246, 0.05), rgba(168, 85, 247, 0.05));
	}

	.modal-title-wrapper {
		display: flex;
		align-items: center;
		gap: 1rem;
	}

	.modal-icon-wrapper {
		width: 48px;
		height: 48px;
		border-radius: 12px;
		display: flex;
		align-items: center;
		justify-content: center;
		box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
	}

	.modal-icon-create {
		background: linear-gradient(135deg, #22C55E, #16A34A);
	}

	.modal-icon-edit {
		background: linear-gradient(135deg, #3B82F6, #2563EB);
	}

	.modal-icon-wrapper svg {
		width: 24px;
		height: 24px;
		color: white;
	}

	.modal-title {
		margin: 0;
		color: #1e293b;
		font-size: 1.75rem;
		font-weight: 700;
	}

	.close-btn {
		background: rgba(148, 163, 184, 0.1);
		border: none;
		width: 40px;
		height: 40px;
		border-radius: 12px;
		cursor: pointer;
		color: #64748b;
		display: flex;
		align-items: center;
		justify-content: center;
		transition: all 0.2s ease;
	}

	.close-btn:hover {
		background: rgba(239, 68, 68, 0.1);
		color: #EF4444;
		transform: scale(1.1);
	}

	.close-btn svg {
		width: 20px;
		height: 20px;
	}

	.modal-content form {
		padding: 2rem 2.5rem;
	}

	.form-group {
		margin-bottom: 1.75rem;
	}

	.form-label {
		display: flex;
		align-items: center;
		gap: 0.5rem;
		margin-bottom: 0.75rem;
		font-weight: 600;
		color: #334155;
		font-size: 0.95rem;
	}

	.label-icon {
		width: 18px;
		height: 18px;
		color: #3B82F6;
	}

	.input-wrapper,
	.select-wrapper {
		position: relative;
	}

	.form-input,
	.form-select {
		width: 100%;
		padding: 1rem 1.25rem;
		border: 2px solid rgba(148, 163, 184, 0.2);
		border-radius: 12px;
		font-size: 1rem;
		background: rgba(255, 255, 255, 0.8);
		backdrop-filter: blur(10px);
		transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
		outline: none;
		color: #1e293b;
	}

	.form-input:focus,
	.form-select:focus {
		border-color: #3B82F6;
		background: rgba(255, 255, 255, 1);
		box-shadow: 0 8px 20px rgba(59, 130, 246, 0.15);
		transform: translateY(-2px);
	}

	.form-input::placeholder {
		color: #94a3b8;
	}

	.select-wrapper {
		position: relative;
	}

	.form-select {
		appearance: none;
		padding-right: 3rem;
		cursor: pointer;
	}

	.select-arrow {
		position: absolute;
		right: 1rem;
		top: 50%;
		transform: translateY(-50%);
		width: 20px;
		height: 20px;
		color: #64748b;
		pointer-events: none;
		transition: transform 0.2s ease;
	}

	.form-select:focus ~ .select-arrow {
		transform: translateY(-50%) rotate(180deg);
	}

	.modal-actions {
		display: flex;
		justify-content: flex-end;
		gap: 1rem;
		padding-top: 1.5rem;
		border-top: 1px solid rgba(148, 163, 184, 0.2);
		margin-top: 0.5rem;
	}

	/* ========================================
	   ANIMATIONS & KEYFRAMES
	   ======================================== */
	
	@keyframes loadingFadeIn {
		0% { opacity: 0; }
		100% { opacity: 1; }
	}

	@keyframes loadingFadeOut {
		0% { opacity: 1; transform: scale(1); }
		100% { opacity: 0; transform: scale(1.05); }
	}

	@keyframes particleFloat {
		0%, 100% {
			transform: translate(0, 0);
			opacity: 0.6;
		}
		25% {
			transform: translate(10px, -10px);
			opacity: 0.8;
		}
		50% {
			transform: translate(-10px, -20px);
			opacity: 0.4;
		}
		75% {
			transform: translate(-20px, 10px);
			opacity: 0.7;
		}
	}

	@keyframes logoRotate {
		0%, 100% { transform: rotate(0deg) scale(1); }
		25% { transform: rotate(5deg) scale(1.05); }
		50% { transform: rotate(-5deg) scale(0.95); }
		75% { transform: rotate(3deg) scale(1.02); }
	}

	@keyframes logoPulse {
		0%, 100% {
			transform: scale(1);
			opacity: 0.5;
		}
		50% {
			transform: scale(1.2);
			opacity: 0.8;
		}
	}

	@keyframes textGlow {
		0% { filter: drop-shadow(0 0 10px rgba(59, 130, 246, 0.5)); }
		100% { filter: drop-shadow(0 0 20px rgba(59, 130, 246, 0.8)); }
	}

	@keyframes progressShine {
		0% { transform: translateX(-100%); }
		100% { transform: translateX(100%); }
	}

	@keyframes progressGlow {
		0%, 100% { opacity: 0; transform: translateX(-50%); }
		50% { opacity: 1; transform: translateX(50%); }
	}

	@keyframes textFade {
		0% { opacity: 0; transform: translateY(10px); }
		100% { opacity: 1; transform: translateY(0); }
	}

	@keyframes dotBounce {
		0%, 80%, 100% {
			transform: scale(0.8);
			opacity: 0.6;
		}
		40% {
			transform: scale(1.2);
			opacity: 1;
		}
	}

	@keyframes orbFloat {
		0%, 100% {
			transform: translate(0, 0) scale(1);
		}
		33% {
			transform: translate(30px, -30px) scale(1.1);
		}
		66% {
			transform: translate(-20px, 20px) scale(0.9);
		}
	}

	@keyframes float {
		0%, 100% {
			transform: translateY(0) rotate(0deg);
		}
		50% {
			transform: translateY(-30px) rotate(5deg);
		}
	}

	@keyframes pulse-slow {
		0%, 100% {
			opacity: 1;
			transform: scale(1);
		}
		50% {
			opacity: 0.9;
			transform: scale(1.05);
		}
	}

	@keyframes shake {
		0%, 100% { transform: translateX(0); }
		25% { transform: translateX(-8px); }
		75% { transform: translateX(8px); }
	}

	@keyframes slideInFromTop {
		0% {
			opacity: 0;
			transform: translateY(-20px);
		}
		100% {
			opacity: 1;
			transform: translateY(0);
		}
	}

	@keyframes cascadeIn {
		0% {
			opacity: 0;
			transform: translateY(20px) scale(0.95);
		}
		100% {
			opacity: 1;
			transform: translateY(0) scale(1);
		}
	}

	@keyframes glowPulse {
		0%, 100% {
			opacity: 0.5;
			transform: scale(1);
		}
		50% {
			opacity: 1;
			transform: scale(1.1);
		}
	}

	@keyframes slideInRow {
		0% {
			opacity: 0;
			transform: translateX(-20px);
		}
		100% {
			opacity: 1;
			transform: translateX(0);
		}
	}

	@keyframes modalFadeIn {
		0% {
			opacity: 0;
		}
		100% {
			opacity: 1;
		}
	}

	@keyframes modalSlideUp {
		0% {
			opacity: 0;
			transform: translateY(30px) scale(0.95);
		}
		100% {
			opacity: 1;
			transform: translateY(0) scale(1);
		}
	}

	/* ========================================
	   RESPONSIVE DESIGN
	   ======================================== */
	
	@media (max-width: 1024px) {
		.users-page {
			padding: 1.5rem;
		}

		.page-header {
			padding: 2rem;
		}

		.stats-grid {
			grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
		}
	}

	@media (max-width: 768px) {
		.users-page {
			padding: 1rem;
		}

		.page-header {
			flex-direction: column;
			align-items: stretch;
			padding: 1.5rem;
		}

		.page-header h1 {
			font-size: 2rem;
		}

		.header-content {
			flex-direction: column;
			align-items: flex-start;
			gap: 1rem;
		}

		.btn-primary {
			width: 100%;
			justify-content: center;
		}

		.stats-grid {
			grid-template-columns: 1fr;
			gap: 1rem;
		}

		.stat-card {
			padding: 1.5rem;
		}

		.stat-number {
			font-size: 2rem;
		}

		.card-content {
			padding: 1.5rem;
		}

		.table-container {
			overflow-x: auto;
			-webkit-overflow-scrolling: touch;
		}

		.data-table {
			min-width: 800px;
		}

		.modal-content {
			margin: 1rem;
		}

		.modal-header,
		.modal-content form {
			padding: 1.5rem;
		}

		.modal-title {
			font-size: 1.5rem;
		}

		.modal-actions {
			flex-direction: column;
		}

		.modal-actions .btn {
			width: 100%;
			justify-content: center;
		}
	}

	@media (max-width: 480px) {
		.page-header h1 {
			font-size: 1.75rem;
		}

		.subtitle {
			font-size: 0.95rem;
		}

		.header-icon-wrapper {
			width: 48px;
			height: 48px;
		}

		.header-icon {
			width: 28px;
			height: 28px;
		}

		.stat-icon-wrapper {
			width: 56px;
			height: 56px;
		}

		.stat-icon {
			width: 28px;
			height: 28px;
		}

		.stat-number {
			font-size: 1.75rem;
		}

		.stat-label {
			font-size: 0.875rem;
		}

		.brand-main {
			font-size: 2rem;
		}

		.brand-tagline {
			font-size: 1.125rem;
		}
	}

	/* ========================================
	   ACCESSIBILITY & REDUCED MOTION
	   ======================================== */
	
	@media (prefers-reduced-motion: reduce) {
		*, *::before, *::after {
			animation-duration: 0.01ms !important;
			animation-iteration-count: 1 !important;
			transition-duration: 0.01ms !important;
		}
	}

	/* ========================================
	   SCROLLBAR STYLING (WEBKIT)
	   ======================================== */
	
	.table-container::-webkit-scrollbar,
	.modal-content::-webkit-scrollbar {
		height: 8px;
		width: 8px;
	}

	.table-container::-webkit-scrollbar-track,
	.modal-content::-webkit-scrollbar-track {
		background: rgba(148, 163, 184, 0.1);
		border-radius: 4px;
	}

	.table-container::-webkit-scrollbar-thumb,
	.modal-content::-webkit-scrollbar-thumb {
		background: linear-gradient(135deg, #3B82F6, #A855F7);
		border-radius: 4px;
	}

	.table-container::-webkit-scrollbar-thumb:hover,
	.modal-content::-webkit-scrollbar-thumb:hover {
		background: linear-gradient(135deg, #2563EB, #9333EA);
	}
</style>