<script>
	import { onMount } from 'svelte';
	
	/** @type {import('./$types').PageData} */
	export let data;
	
	$: session = data.session;
	$: stats = data.stats || {};
	$: sections = data.sections || [];
	$: students = data.students || [];
	$: teachers = data.teachers || [];
	$: subjects = data.subjects || [];
	
	// 🚀 REMOVED: Premium loading animations for instant page load
	let scrollY = 0;
	
	// Parallax scroll effect only
	onMount(() => {
		const handleScroll = () => {
			scrollY = window.scrollY;
		};

		window.addEventListener('scroll', handleScroll, { passive: true });

		return () => {
			window.removeEventListener('scroll', handleScroll);
		};
	});
</script>

<svelte:head>
	<title>Dashboard - School Management System</title>
</svelte:head>

<!-- Animated Background Layer -->
<div class="animated-background" style="transform: translateY({scrollY * 0.3}px)">
	<!-- ContentGrow-style Dot Pattern -->
	<div class="dot-pattern"></div>
	
	<!-- Floating Gradient Orbs -->
	<div class="floating-orb orb-bg-1"></div>
	<div class="floating-orb orb-bg-2"></div>
	<div class="floating-orb orb-bg-3"></div>
</div>

<div class="dashboard">
	<!-- Page Header with Glass Morphism -->
	<div class="dashboard-header">
		<div class="header-icon-wrapper">
			<svg class="header-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
			</svg>
		</div>
		<div>
			<h1>Dashboard</h1>
			<p class="welcome-text">Welcome back, <span class="user-email">{session.email}</span></p>
		</div>
	</div>
	
	{#if data.error}
		<div class="error-message">
			<svg class="error-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
			</svg>
			{data.error}
		</div>
	{/if}
	
	<!-- Admin Dashboard -->
	{#if session.role === 'Admin'}
		<div class="stats-grid">
			<div class="stat-card stat-card-1">
				<div class="stat-glow"></div>
				<div class="stat-icon-wrapper">
					<svg class="stat-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
					</svg>
				</div>
				<div class="stat-content">
					<div class="stat-number">{stats.totalSections || 0}</div>
					<div class="stat-label">Total Sections</div>
				</div>
			</div>
			<div class="stat-card stat-card-2">
				<div class="stat-glow"></div>
				<div class="stat-icon-wrapper">
					<svg class="stat-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
					</svg>
				</div>
				<div class="stat-content">
					<div class="stat-number">{stats.totalStudents || 0}</div>
					<div class="stat-label">Total Students</div>
				</div>
			</div>
			<div class="stat-card stat-card-3">
				<div class="stat-glow"></div>
				<div class="stat-icon-wrapper">
					<svg class="stat-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
					</svg>
				</div>
				<div class="stat-content">
					<div class="stat-number">{stats.totalTeachers || 0}</div>
					<div class="stat-label">Total Teachers</div>
				</div>
			</div>
			<div class="stat-card stat-card-4">
				<div class="stat-glow"></div>
				<div class="stat-icon-wrapper">
					<svg class="stat-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
					</svg>
				</div>
				<div class="stat-content">
					<div class="stat-number">{stats.totalSubjects || 0}</div>
					<div class="stat-label">Total Subjects</div>
				</div>
			</div>
		</div>
		
		<div class="dashboard-grid">
			<div class="dashboard-card">
				<div class="card-header">
					<h3 class="card-title">📋 Recent Sections</h3>
					<a href="/sections" class="btn btn-primary">View All →</a>
				</div>
				<div class="table-container">
					<table class="data-table">
						<thead>
							<tr>
								<th>Section Name</th>
								<th>Students</th>
							</tr>
						</thead>
						<tbody>
							{#each sections.slice(0, 5) as section}
								<tr>
									<td>{section.SectionName}</td>
									<td>{section.StudentCount || 0}</td>
								</tr>
							{:else}
								<tr><td colspan="2" class="text-center">No sections found</td></tr>
							{/each}
						</tbody>
					</table>
				</div>
			</div>
			
			<div class="dashboard-card">
				<div class="card-header">
					<h3 class="card-title">👥 Recent Students</h3>
					<a href="/students" class="btn btn-primary">View All →</a>
				</div>
				<div class="table-container">
					<table class="data-table">
						<thead>
							<tr>
								<th>Student ID</th>
								<th>Name</th>
								<th>Year Level</th>
							</tr>
						</thead>
						<tbody>
							{#each students.slice(0, 5) as student}
								<tr>
									<td>{student.StudentID}</td>
									<td>{student.FirstName} {student.LastName}</td>
									<td>{student.YearLevel}</td>
								</tr>
							{:else}
								<tr><td colspan="3" class="text-center">No students found</td></tr>
							{/each}
						</tbody>
					</table>
				</div>
			</div>
		</div>
	{/if}
	
	<!-- Teacher Dashboard -->
	{#if session.role === 'Teacher'}
		<div class="stats-grid">
			<div class="stat-card">
				<div class="stat-number">{stats.mySections || 0}</div>
				<div class="stat-label">My Sections</div>
			</div>
			<div class="stat-card">
				<div class="stat-number">{stats.myStudents || 0}</div>
				<div class="stat-label">My Students</div>
			</div>
		</div>
		
		<div class="dashboard-card">
			<div class="card-header">
				<h3 class="card-title">🏫 My Sections</h3>
				<a href="/sections" class="btn btn-primary">View All →</a>
			</div>
			<div class="table-container">
				<table class="data-table">
					<thead>
						<tr>
							<th>Section Name</th>
							<th>Students</th>
							<th>Actions</th>
						</tr>
					</thead>
					<tbody>
						{#each sections as section}
							<tr>
								<td>{section.SectionName}</td>
								<td>{section.TotalStudents || 0}</td>
								<td>
									<a href="/sections/{section.SectionID}" class="btn btn-secondary">
										View Details
									</a>
								</td>
							</tr>
						{:else}
							<tr><td colspan="3" class="text-center">No sections assigned</td></tr>
						{/each}
					</tbody>
				</table>
			</div>
		</div>
	{/if}
	
	<!-- Student Dashboard -->
	{#if session.role === 'Student'}
		<div class="stats-grid">
			<div class="stat-card">
				<div class="stat-number">{stats.enrolledSections || 0}</div>
				<div class="stat-label">Enrolled Sections</div>
			</div>
		</div>
		
		<div class="dashboard-card">
			<div class="card-header">
				<h3 class="card-title">📚 My Sections</h3>
				<a href="/my-sections" class="btn btn-primary">View All →</a>
			</div>
			<div class="table-container">
				<table class="data-table">
					<thead>
						<tr>
							<th>Section Name</th>
							<th>Students</th>
						</tr>
					</thead>
					<tbody>
						{#each sections as section}
							<tr>
								<td>{section.SectionName}</td>
								<td>{section.TotalStudents || 0}</td>
							</tr>
						{:else}
							<tr><td colspan="2" class="text-center">No sections enrolled</td></tr>
						{/each}
					</tbody>
				</table>
			</div>
		</div>
	{/if}
</div>

<style>
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
	
	.dashboard {
		max-width: 1400px;
		margin: 0 auto;
		padding: 2rem;
	}

	/* ========================================
	   PREMIUM DASHBOARD HEADER WITH GLASS MORPHISM
	   ======================================== */
	
	.dashboard-header {
		background: rgba(255, 255, 255, 0.4);
		backdrop-filter: blur(20px);
		-webkit-backdrop-filter: blur(20px);
		border: 1px solid rgba(255, 255, 255, 0.5);
		border-radius: 24px;
		padding: 2.5rem;
		margin-bottom: 2rem;
		box-shadow: 0 20px 60px rgba(0, 0, 0, 0.08);
		display: flex;
		align-items: center;
		gap: 2rem;
		position: relative;
		overflow: hidden;
	}

	.dashboard-header::before {
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

	.header-icon-wrapper {
		width: 80px;
		height: 80px;
		background: linear-gradient(135deg, #3B82F6, #A855F7);
		border-radius: 20px;
		display: flex;
		align-items: center;
		justify-content: center;
		flex-shrink: 0;
		box-shadow: 0 8px 20px rgba(59, 130, 246, 0.3);
		animation: pulse-slow 3s ease-in-out infinite;
	}

	.header-icon {
		width: 44px;
		height: 44px;
		color: white;
	}

	.dashboard-header h1 {
		margin: 0 0 0.5rem 0;
		font-size: 3rem;
		font-weight: 700;
		background: linear-gradient(135deg, #3B82F6, #A855F7);
		-webkit-background-clip: text;
		-webkit-text-fill-color: transparent;
		background-clip: text;
	}

	.welcome-text {
		margin: 0;
		color: #64748b;
		font-size: 1.25rem;
		font-weight: 500;
	}

	.user-email {
		color: #3B82F6;
		font-weight: 600;
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
	   DASHBOARD GRID & CARDS
	   ======================================== */
	
	.dashboard-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
		gap: 2rem;
	}

	.dashboard-card {
		background: rgba(255, 255, 255, 0.5);
		backdrop-filter: blur(20px);
		-webkit-backdrop-filter: blur(20px);
		border: 1px solid rgba(255, 255, 255, 0.6);
		border-radius: 24px;
		box-shadow: 0 20px 60px rgba(0, 0, 0, 0.08);
		overflow: hidden;
		transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
		position: relative;
	}

	.dashboard-card::before {
		content: '';
		position: absolute;
		top: 0;
		left: 0;
		right: 0;
		height: 4px;
		background: linear-gradient(90deg, #3B82F6, #A855F7, #22C55E, #F97316);
	}

	.dashboard-card:hover {
		transform: translateY(-4px);
		box-shadow: 0 25px 70px rgba(0, 0, 0, 0.12);
	}

	.card-header {
		background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(168, 85, 247, 0.1));
		backdrop-filter: blur(10px);
		padding: 2rem 2.5rem;
		border-bottom: 1px solid rgba(255, 255, 255, 0.3);
		display: flex;
		justify-content: space-between;
		align-items: center;
		flex-wrap: wrap;
		gap: 1rem;
	}

	.card-title {
		margin: 0;
		font-size: 1.5rem;
		font-weight: 700;
		background: linear-gradient(135deg, #3B82F6, #A855F7);
		-webkit-background-clip: text;
		-webkit-text-fill-color: transparent;
		background-clip: text;
	}

	/* ========================================
	   TABLE STYLES
	   ======================================== */
	
	.table-container {
		padding: 2rem 2.5rem;
	}

	.data-table {
		width: 100%;
		border-collapse: collapse;
		background: rgba(255, 255, 255, 0.4);
		backdrop-filter: blur(10px);
		border-radius: 16px;
		overflow: hidden;
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

	.data-table td {
		padding: 1.25rem 1rem;
		color: #334155;
		font-size: 0.95rem;
		border-bottom: 1px solid rgba(148, 163, 184, 0.1);
	}

	.data-table tbody tr {
		transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
	}

	.data-table tbody tr:hover {
		background: rgba(59, 130, 246, 0.05);
		transform: translateX(4px);
	}

	.text-center {
		text-align: center;
		color: #94a3b8;
		font-style: italic;
	}

	/* ========================================
	   BUTTON STYLES
	   ======================================== */
	
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

	.btn-primary {
		background: linear-gradient(135deg, #3B82F6, #2563EB);
		color: white;
		box-shadow: 0 4px 15px rgba(59, 130, 246, 0.3);
	}

	.btn-primary:hover {
		transform: translateY(-2px) scale(1.02);
		box-shadow: 0 8px 25px rgba(59, 130, 246, 0.4);
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

	/* ========================================
	   ANIMATIONS & KEYFRAMES
	   ======================================== */
	


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

	/* ========================================
	   RESPONSIVE DESIGN
	   ======================================== */
	
	@media (max-width: 1024px) {
		.dashboard {
			padding: 1.5rem;
		}

		.dashboard-header {
			padding: 2rem;
		}

		.stats-grid {
			grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
		}

		.dashboard-grid {
			grid-template-columns: 1fr;
		}
	}

	@media (max-width: 768px) {
		.dashboard {
			padding: 1rem;
		}

		.dashboard-header {
			flex-direction: column;
			align-items: flex-start;
			padding: 1.5rem;
			gap: 1rem;
		}

		.dashboard-header h1 {
			font-size: 2rem;
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

		.table-container {
			padding: 1.5rem;
		}

		.card-header {
			flex-direction: column;
			align-items: flex-start;
			padding: 1.5rem;
		}

		.data-table {
			font-size: 0.9rem;
		}
	}

	@media (max-width: 480px) {
		.dashboard-header h1 {
			font-size: 1.75rem;
		}

		.welcome-text {
			font-size: 1rem;
		}

		.header-icon-wrapper {
			width: 64px;
			height: 64px;
		}

		.header-icon {
			width: 36px;
			height: 36px;
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
</style>