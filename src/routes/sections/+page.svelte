<script>
	import { browser } from '$app/environment';
	import { onMount } from 'svelte';
	import { invalidateAll } from '$app/navigation';
	import { enhance } from '$app/forms';

	export let data;

	$: session = data.session;
	$: sections = data.sections || [];
	$: statuses = data.statuses || [];
	$: subjects = data.subjects || [];
	$: teachers = data.teachers || [];

	let showCreateModal = false;
	let showSubjectModal = false;
	let showStudentModal = false;
	let editingSection = null;
	let selectedSection = null;
	let selectedCount = 0;
	let loading = false;
	let searching = false;
	let selecting = false;
	let enrolling = false;
	let editingSubject = null;
	let searchTerm = '';
	let isLoading = true;
	let loadingProgress = 0;
	let loadingText = 'Initializing...';
	let loadingFadeOut = false;
	let pageVisible = false;
	let statsVisible = false;
	let cardsVisible = false;
	let scrollY = 0;
	let selectedStudents = new Set();

	onMount(() => {
		const loadingSteps = [
			{ progress: 25, text: 'Loading sections...' },
			{ progress: 50, text: 'Preparing interface...' },
			{ progress: 75, text: 'Finishing up...' },
			{ progress: 100, text: 'Ready!' }
		];

		function runLoadingStep(index) {
			if (index < loadingSteps.length) {
				const step = loadingSteps[index];
				loadingProgress = step.progress;
				loadingText = step.text;
				setTimeout(() => runLoadingStep(index + 1), 300);
			} else {
				loadingFadeOut = true;
				setTimeout(() => {
					isLoading = false;
					setTimeout(() => {
						pageVisible = true;
						setTimeout(() => {
							statsVisible = true;
							setTimeout(() => {
								cardsVisible = true;
							}, 200);
						}, 100);
					}, 100);
				}, 800);
			}
		}

		runLoadingStep(0);

		const handleScroll = () => {
			scrollY = window.scrollY;
		};

		if (browser) {
			window.addEventListener('scroll', handleScroll);
			return () => window.removeEventListener('scroll', handleScroll);
		}
	});

	function openCreateModal() {
		editingSection = null;
		showCreateModal = true;
	}

	function closeCreateModal() {
		showCreateModal = false;
		editingSection = null;
	}

	function editSection(section) {
		editingSection = section;
		showCreateModal = true;
	}

	function selectSectionItem(sectionId) {
		selectedSection = sections.find(s => s.SectionID === sectionId);
		selectedStudents.clear();
	}

	function openSubjectModal() {
		showSubjectModal = true;
	}

	function closeSubjectModal() {
		showSubjectModal = false;
	}

	function openStudentModal() {
		showStudentModal = true;
	}

	function closeStudentModal() {
		showStudentModal = false;
		selectedStudents.clear();
		selectedCount = 0;
	}

	$: filteredSections = sections.filter(section =>
		section.SectionName.toLowerCase().includes(searchTerm.toLowerCase())
	);

	function toggleStudent(studentId) {
		if (selectedStudents.has(studentId)) {
			selectedStudents.delete(studentId);
		} else {
			selectedStudents.add(studentId);
		}
		selectedCount = selectedStudents.size;
	}
</script>

<svelte:head>
	<title>Sections - School Management System</title>
</svelte:head>

{#if isLoading}
	<div class="loading-screen" class:fade-out={loadingFadeOut}>
		<div class="particles-container">
			{#each Array(20) as _, i}
				<div class="particle particle-{(i % 4) + 1}"></div>
			{/each}
		</div>

		<div class="loading-content">
			<div class="loading-logo">
				<div class="logo-pulse"></div>
				<svg class="logo-svg" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
					<defs>
						<linearGradient id="gradientLogo" x1="0%" y1="0%" x2="100%" y2="100%">
							<stop offset="0%" style="stop-color:#3B82F6;stop-opacity:1" />
							<stop offset="100%" style="stop-color:#A855F7;stop-opacity:1" />
						</linearGradient>
					</defs>
					<rect x="20" y="20" width="60" height="60" rx="10" fill="url(#gradientLogo)" />
					<text x="50" y="65" font-size="40" font-weight="bold" text-anchor="middle" fill="white">🏫</text>
				</svg>
			</div>

			<div class="loading-brand">
				<div class="brand-main">School Management</div>
				<div class="brand-tagline">SECTIONS MODULE</div>
			</div>

			<div class="loading-progress">
				<div class="progress-bar">
					<div class="progress-fill" style="width: {loadingProgress}%"></div>
					<div class="progress-glow" style="left: {loadingProgress}%"></div>
				</div>
				<div class="progress-text">
					<span class="progress-percentage">{loadingProgress}%</span>
					<span> - {loadingText}</span>
				</div>
			</div>

			<div class="loading-dots">
				<span class="dot dot-1"></span>
				<span class="dot dot-2"></span>
				<span class="dot dot-3"></span>
			</div>

			<div class="loading-orbs">
				<div class="orb orb-1"></div>
				<div class="orb orb-2"></div>
				<div class="orb orb-3"></div>
				<div class="orb orb-4"></div>
			</div>
		</div>
	</div>
{/if}

<div class="animated-background" style="transform: translateY({scrollY * 0.3}px);">
	<div class="dot-pattern"></div>
	<div class="floating-orb orb-bg-1"></div>
	<div class="floating-orb orb-bg-2"></div>
	<div class="floating-orb orb-bg-3"></div>
</div>

<div class="sections-page" class:visible={pageVisible}>
	<div class="page-header" class:visible={pageVisible}>
		<div class="header-icon-wrapper">
			<svg class="header-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
				<rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect>
				<line x1="9" y1="3" x2="9" y2="21"></line>
				<line x1="3" y1="9" x2="21" y2="9"></line>
			</svg>
		</div>
		<div class="header-content">
			<h1>Sections Management</h1>
			<p class="subtitle">Organize classes and manage section assignments</p>
		</div>
		<button class="btn btn-primary" on:click={openCreateModal}>
			<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
				<line x1="12" y1="5" x2="12" y2="19"></line>
				<line x1="5" y1="12" x2="19" y2="12"></line>
			</svg>
			Add New Section
		</button>
	</div>

	<div class="stats-grid" class:visible={statsVisible}>
		<div class="stat-card stat-card-1">
			<div class="stat-glow"></div>
			<div class="stat-icon-wrapper">
				<svg class="stat-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
					<rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect>
					<line x1="9" y1="3" x2="9" y2="21"></line>
					<line x1="3" y1="9" x2="21" y2="9"></line>
				</svg>
			</div>
			<div class="stat-content">
				<div class="stat-number">{sections.length}</div>
				<div class="stat-label">Total Sections</div>
			</div>
		</div>
		<div class="stat-card stat-card-2">
			<div class="stat-glow"></div>
			<div class="stat-icon-wrapper">
				<svg class="stat-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
					<path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
					<circle cx="12" cy="7" r="4"></circle>
				</svg>
			</div>
			<div class="stat-content">
				<div class="stat-number">0</div>
				<div class="stat-label">Total Students</div>
			</div>
		</div>
		<div class="stat-card stat-card-3">
			<div class="stat-glow"></div>
			<div class="stat-icon-wrapper">
				<svg class="stat-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
					<path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path>
					<path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path>
				</svg>
			</div>
			<div class="stat-content">
				<div class="stat-number">{subjects.length}</div>
				<div class="stat-label">Total Subjects</div>
			</div>
		</div>
		<div class="stat-card stat-card-4">
			<div class="stat-glow"></div>
			<div class="stat-icon-wrapper">
				<svg class="stat-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
					<path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path>
					<polyline points="9 22 9 12 15 12 15 22"></polyline>
				</svg>
			</div>
			<div class="stat-content">
				<div class="stat-number">{teachers.length}</div>
				<div class="stat-label">Teachers</div>
			</div>
		</div>
	</div>

	<!-- Search and Sections Grid -->
	<div class="content-section" class:visible={cardsVisible}>
		<div class="section-card">
			<div class="card-header">
				<h3 class="card-title">📚 Section Records</h3>
			</div>

			<div class="card-content">
				<!-- Search bar -->
				<div class="search-container">
					<input
						type="text"
						bind:value={searchTerm}
						placeholder="🔍 Search by section name..."
						class="search-input"
					>
				</div>

				<!-- Sections Grid -->
				<div class="sections-grid">
					{#each filteredSections as section (section.SectionID)}
						<div 
							class="section-card-item" 
							on:click={() => selectSectionItem(section.SectionID)}
							on:keydown={(e) => (e.key === 'Enter' || e.key === ' ') && selectSectionItem(section.SectionID)}
							role="button"
							tabindex="0"
						>
							<div class="card-glow"></div>
							<div class="card-header-mini">
								<div class="card-title-section">
									<h3>{section.SectionName}</h3>
									<span class="status-badge {section.StatusName.toLowerCase()}">
										{section.StatusName}
									</span>
								</div>
							</div>
							<div class="card-stats">
								<div class="stat-item">
									<span class="stat-icon-mini">👥</span>
									<span class="stat-text">Students</span>
								</div>
								<div class="stat-item">
									<span class="stat-icon-mini">📖</span>
									<span class="stat-text">Subjects</span>
								</div>
							</div>
							<div class="card-actions">
								<button 
									class="btn btn-secondary"
									on:click={() => editSection(section)}
								>
									<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
										<path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
										<path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
									</svg>
									Edit
								</button>
								<button 
									class="btn btn-primary"
									on:click={() => {selectSectionItem(section.SectionID); openStudentModal();}}
								>
									<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
										<path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
										<circle cx="12" cy="7" r="4"></circle>
									</svg>
									Enroll
								</button>
							</div>
						</div>
					{:else}
						<div class="empty-state">
							<h3>No sections found</h3>
							<p>{searchTerm ? 'Try adjusting your search terms' : 'No section records available'}</p>
						</div>
					{/each}
				</div>
			</div>
		</div>
	</div>
</div>

<!-- Create/Edit Section Modal -->
{#if showCreateModal}
	<div 
		class="modal-overlay" 
		on:click={closeCreateModal}
		on:keydown={(e) => e.key === 'Escape' && closeCreateModal()}
		role="button"
		tabindex="0"
		aria-label="Close modal"
	>
		<div 
			class="modal-content" 
			on:click|stopPropagation
			role="document"
			tabindex="-1"
		>
			<div class="modal-header">
				<h3>{editingSection ? 'Edit Section' : 'Create New Section'}</h3>
				<button class="close-btn" on:click={closeCreateModal}>&times;</button>
			</div>
			
			<form 
				method="POST" 
				action={editingSection ? "?/updateSection" : "?/createSection"}
				use:enhance={() => {
					loading = true;
					return async ({ result }) => {
						loading = false;
						if (result.type === 'success') {
							closeCreateModal();
							await invalidateAll();
						}
					};
				}}
			>
				{#if editingSection}
					<input type="hidden" name="sectionId" value={editingSection.SectionID} />
				{/if}
				
				<div class="form-group">
					<label for="sectionName">Section Name:</label>
					<input 
						type="text" 
						id="sectionName" 
						name="sectionName" 
						required 
						value={editingSection ? editingSection.SectionName : ''}
						placeholder="e.g., Grade 10 - Section A"
					/>
				</div>
				
				{#if editingSection}
					<div class="form-group">
						<label for="statusId">Status:</label>
						<select id="statusId" name="statusId" bind:value={editingSection.StatusID}>
							{#each statuses as status}
								<option value={status.StatusID}>{status.StatusName}</option>
							{/each}
						</select>
					</div>
				{/if}
				
				<div class="modal-actions">
					<button type="button" class="btn btn-secondary" on:click={closeCreateModal}>
						Cancel
					</button>
					<button type="submit" class="btn btn-primary" disabled={loading}>
						{#if loading}
							<span class="spinner"></span>
							Saving...
						{:else}
							{editingSection ? 'Update Section' : 'Create Section'}
						{/if}
					</button>
				</div>
			</form>
		</div>
	</div>
{/if}

<!-- Add Subject Modal -->
{#if showSubjectModal}
	<div 
		class="modal-overlay" 
		on:click={closeSubjectModal}
		on:keydown={(e) => e.key === 'Escape' && closeSubjectModal()}
		role="button"
		tabindex="0"
		aria-label="Close modal"
	>
		<div 
			class="modal-content" 
			on:click|stopPropagation
			role="document"
			tabindex="-1"
		>
			<div class="modal-header">
				<h3>Add Subject to {selectedSection?.SectionName}</h3>
				<button class="close-btn" on:click={closeSubjectModal}>&times;</button>
			</div>
			
			<form method="POST" action="?/addSubject">
				<input type="hidden" name="sectionId" value={selectedSection?.SectionID} />
				
				<div class="form-group">
					<label for="subjectId">Subject:</label>
					<select id="subjectId" name="subjectId" required>
						<option value="">Select Subject</option>
						{#each subjects as subject}
							<option value={subject.SubjectID}>
								{subject.SubjectName} ({subject.SubjectCode})
							</option>
						{/each}
					</select>
				</div>
				
				<div class="form-group">
					<label for="teacherId">Assign Teacher (Optional):</label>
					<select id="teacherId" name="teacherId">
						<option value="">No teacher assigned</option>
						{#each teachers as teacher}
							<option value={teacher.TeacherID}>
								{teacher.FirstName} {teacher.LastName}
							</option>
						{/each}
					</select>
				</div>
				
				<div class="modal-actions">
					<button type="button" class="btn btn-secondary" on:click={closeSubjectModal}>
						Cancel
					</button>
					<button type="submit" class="btn btn-primary" disabled={loading}>
						Add Subject
					</button>
				</div>
			</form>
		</div>
	</div>
{/if}

<!-- Enroll Students Modal -->
{#if showStudentModal}
	<div 
		class="modal-overlay" 
		on:click={closeStudentModal}
		on:keydown={(e) => e.key === 'Escape' && closeStudentModal()}
		role="button"
		tabindex="0"
		aria-label="Close modal"
	>
		<div 
			class="modal-content" 
			on:click|stopPropagation
			role="document"
			tabindex="-1"
		>
			<div class="modal-header">
				<h3>Enroll Students - {selectedSection?.SectionName || ''}</h3>
				<button class="close-btn" on:click={closeStudentModal}>&times;</button>
			</div>
			
			<div class="modal-actions">
				<button type="button" class="btn btn-secondary" on:click={closeStudentModal}>
					Cancel
				</button>
				<button type="button" class="btn btn-primary" disabled={enrolling}>
					{#if enrolling}
						Enrolling...
					{:else}
						Enroll Selected ({selectedCount})
					{/if}
				</button>
			</div>
		</div>
	</div>
{/if}

<style>
	/* ===== LOADING SCREEN ===== */
	:global(body) {
		margin: 0;
		padding: 0;
		overflow-x: hidden;
	}

	.loading-screen {
		position: fixed;
		top: 0;
		left: 0;
		width: 100%;
		height: 100vh;
		background: linear-gradient(135deg, #f5f7fa 0%, #f1f5f9 100%);
		display: flex;
		align-items: center;
		justify-content: center;
		z-index: 9999;
		overflow: hidden;
		transition: opacity 0.8s ease-out;
	}

	.loading-screen.fade-out {
		opacity: 0;
		pointer-events: none;
	}

	.particles-container {
		position: absolute;
		width: 100%;
		height: 100%;
		overflow: hidden;
	}

	.particle {
		position: absolute;
		width: 6px;
		height: 6px;
		background: radial-gradient(circle, rgba(59, 130, 246, 0.6), rgba(59, 130, 246, 0.2));
		border-radius: 50%;
		animation: particleFloat 4s ease-in-out infinite;
	}

	.particle-1 { width: 4px; height: 4px; animation-delay: 0s; left: 10%; top: 20%; }
	.particle-2 { width: 6px; height: 6px; animation-delay: 1s; left: 80%; top: 60%; }
	.particle-3 { width: 5px; height: 5px; animation-delay: 2s; left: 30%; top: 70%; }
	.particle-4 { width: 7px; height: 7px; animation-delay: 3s; left: 60%; top: 10%; }

	@keyframes particleFloat {
		0%, 100% { transform: translateY(0px) translateX(0px); opacity: 0; }
		50% { transform: translateY(-20px) translateX(10px); opacity: 0.6; }
	}

	.loading-content {
		position: relative;
		z-index: 10;
		text-align: center;
	}

	.loading-logo {
		position: relative;
		width: 100px;
		height: 100px;
		margin: 0 auto 30px;
	}

	.logo-pulse {
		position: absolute;
		inset: 0;
		border-radius: 20px;
		background: linear-gradient(135deg, rgba(59, 130, 246, 0.3), rgba(168, 85, 247, 0.3));
		animation: pulse-scale 2s ease-in-out infinite;
	}

	.logo-svg {
		position: relative;
		width: 100%;
		height: 100%;
		z-index: 2;
	}

	@keyframes pulse-scale {
		0%, 100% { transform: scale(1); opacity: 0.5; }
		50% { transform: scale(1.1); opacity: 1; }
	}

	.loading-brand {
		margin-bottom: 30px;
	}

	.brand-main {
		font-size: 28px;
		font-weight: 700;
		background: linear-gradient(135deg, #3B82F6, #A855F7);
		-webkit-background-clip: text;
		-webkit-text-fill-color: transparent;
		background-clip: text;
		letter-spacing: -0.5px;
	}

	.brand-tagline {
		font-size: 12px;
		color: #64748b;
		text-transform: uppercase;
		letter-spacing: 2px;
		margin-top: 8px;
		font-weight: 600;
	}

	.loading-progress {
		width: 280px;
		margin: 0 auto 20px;
	}

	.progress-bar {
		position: relative;
		height: 6px;
		background: rgba(15, 23, 42, 0.1);
		border-radius: 10px;
		overflow: hidden;
		margin-bottom: 8px;
	}

	.progress-fill {
		height: 100%;
		background: linear-gradient(90deg, #3B82F6, #A855F7);
		border-radius: 10px;
		transition: width 0.3s ease-out;
	}

	.progress-glow {
		position: absolute;
		top: 0;
		height: 100%;
		width: 30px;
		background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.8), transparent);
		filter: blur(8px);
		animation: glow-shift 1.5s ease-in-out infinite;
	}

	@keyframes glow-shift {
		0%, 100% { opacity: 0; }
		50% { opacity: 1; }
	}

	.progress-text {
		font-size: 12px;
		color: #475569;
		text-align: center;
		font-weight: 500;
	}

	.progress-percentage {
		font-weight: 700;
		color: #1e293b;
	}

	.loading-dots {
		display: flex;
		gap: 8px;
		justify-content: center;
		margin-bottom: 20px;
	}

	.dot {
		width: 8px;
		height: 8px;
		border-radius: 50%;
		background: #cbd5e1;
		animation: dot-bounce 1s ease-in-out infinite;
	}

	.dot-1 { animation-delay: 0s; }
	.dot-2 { animation-delay: 0.15s; }
	.dot-3 { animation-delay: 0.3s; }

	@keyframes dot-bounce {
		0%, 100% { transform: translateY(0); opacity: 0.5; }
		50% { transform: translateY(-8px); opacity: 1; }
	}

	.loading-orbs {
		position: absolute;
		inset: 0;
		width: 100%;
		height: 100%;
		pointer-events: none;
	}

	.orb {
		position: absolute;
		border-radius: 50%;
		filter: blur(60px);
		opacity: 0.1;
	}

	.orb-1 { width: 150px; height: 150px; background: #3B82F6; top: 20%; left: 10%; }
	.orb-2 { width: 200px; height: 200px; background: #A855F7; bottom: 20%; right: 10%; }
	.orb-3 { width: 120px; height: 120px; background: #22C55E; top: 50%; left: 50%; }
	.orb-4 { width: 180px; height: 180px; background: #F97316; bottom: 30%; left: 20%; }

	/* ===== ANIMATED BACKGROUND ===== */
	.animated-background {
		position: fixed;
		top: 0;
		left: 0;
		width: 100%;
		height: 100%;
		z-index: -1;
		pointer-events: none;
	}

	.dot-pattern {
		position: absolute;
		inset: 0;
		background-image: radial-gradient(circle, #d0d0d0 1px, transparent 1px);
		background-size: 30px 30px;
		opacity: 0.6;
	}

	.floating-orb {
		position: absolute;
		border-radius: 50%;
		filter: blur(80px);
		opacity: 0.15;
	}

	.orb-bg-1 {
		width: 400px;
		height: 400px;
		background: linear-gradient(135deg, #3B82F6, #60A5FA);
		top: 10%;
		left: 10%;
		animation: float-8s 8s ease-in-out infinite;
	}

	.orb-bg-2 {
		width: 500px;
		height: 500px;
		background: linear-gradient(135deg, #A855F7, #D8B4FE);
		bottom: 5%;
		right: 5%;
		animation: float-10s-reverse 10s ease-in-out infinite;
	}

	.orb-bg-3 {
		width: 350px;
		height: 350px;
		background: linear-gradient(135deg, #22C55E, #86EFAC);
		top: 50%;
		right: 10%;
		animation: float-12s 12s ease-in-out infinite;
	}

	@keyframes float-8s {
		0%, 100% { transform: translate(0, 0); }
		25% { transform: translate(30px, -30px); }
		50% { transform: translate(0, -40px); }
		75% { transform: translate(-30px, -20px); }
	}

	@keyframes float-10s-reverse {
		0%, 100% { transform: translate(0, 0); }
		25% { transform: translate(-30px, 30px); }
		50% { transform: translate(0, 40px); }
		75% { transform: translate(30px, 20px); }
	}

	@keyframes float-12s {
		0%, 100% { transform: translate(0, 0); }
		33% { transform: translate(20px, -40px); }
		66% { transform: translate(-20px, 20px); }
	}

	/* ===== PAGE STRUCTURE ===== */
	.sections-page {
		position: relative;
		z-index: 1;
		padding: 40px 20px;
		min-height: 100vh;
		opacity: 0;
		transform: translateY(20px);
		transition: all 0.6s cubic-bezier(0.4, 0, 0.2, 1);
	}

	.sections-page.visible {
		opacity: 1;
		transform: translateY(0);
	}

	/* ===== PAGE HEADER ===== */
	.page-header {
		display: flex;
		align-items: center;
		gap: 24px;
		background: rgba(255, 255, 255, 0.4);
		backdrop-filter: blur(20px);
		border: 1px solid rgba(255, 255, 255, 0.6);
		border-radius: 20px;
		padding: 30px 32px;
		margin-bottom: 40px;
		position: relative;
		overflow: hidden;
		opacity: 0;
		transform: translateY(-20px);
		transition: all 0.6s cubic-bezier(0.4, 0, 0.2, 1);
	}

	.page-header.visible {
		opacity: 1;
		transform: translateY(0);
	}

	.page-header::before {
		content: '';
		position: absolute;
		top: 0;
		left: 0;
		right: 0;
		height: 1px;
		background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.8), transparent);
	}

	.header-icon-wrapper {
		display: flex;
		align-items: center;
		justify-content: center;
		width: 80px;
		height: 80px;
		background: linear-gradient(135deg, #3B82F6, #A855F7);
		border-radius: 16px;
		flex-shrink: 0;
		animation: pulse-slow 3s ease-in-out infinite;
	}

	.header-icon {
		width: 40px;
		height: 40px;
		color: white;
	}

	@keyframes pulse-slow {
		0%, 100% { box-shadow: 0 0 0 0 rgba(59, 130, 246, 0.7); }
		50% { box-shadow: 0 0 0 20px rgba(59, 130, 246, 0); }
	}

	.header-content {
		flex: 1;
	}

	.header-content h1 {
		font-size: 32px;
		font-weight: 700;
		margin: 0 0 8px 0;
		background: linear-gradient(135deg, #1e293b, #3B82F6);
		-webkit-background-clip: text;
		-webkit-text-fill-color: transparent;
		background-clip: text;
	}

	.header-content .subtitle {
		font-size: 14px;
		color: #64748b;
		margin: 0;
	}

	/* ===== STATS GRID ===== */
	.stats-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
		gap: 20px;
		margin-bottom: 40px;
		opacity: 0;
		transform: translateY(20px);
		transition: all 0.6s cubic-bezier(0.4, 0, 0.2, 1);
	}

	.stats-grid.visible {
		opacity: 1;
		transform: translateY(0);
	}

	.stat-card {
		position: relative;
		background: rgba(255, 255, 255, 0.4);
		backdrop-filter: blur(20px);
		border: 1px solid rgba(255, 255, 255, 0.6);
		border-radius: 16px;
		padding: 24px;
		overflow: hidden;
		transition: all 0.3s ease-out;
		animation: cascadeIn 0.5s ease-out forwards;
	}

	.stat-card-1 { animation-delay: 0.1s; }
	.stat-card-2 { animation-delay: 0.2s; }
	.stat-card-3 { animation-delay: 0.3s; }
	.stat-card-4 { animation-delay: 0.4s; }

	@keyframes cascadeIn {
		from {
			opacity: 0;
			transform: translateY(20px);
		}
		to {
			opacity: 1;
			transform: translateY(0);
		}
	}

	.stat-card::before {
		content: '';
		position: absolute;
		top: 0;
		left: 0;
		right: 0;
		height: 2px;
		background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.8), transparent);
	}

	.stat-card:hover {
		transform: translateY(-8px) scale(1.02);
		box-shadow: 0 20px 40px rgba(59, 130, 246, 0.1);
	}

	.stat-glow {
		position: absolute;
		inset: -50%;
		background: radial-gradient(circle, rgba(59, 130, 246, 0.2), transparent);
		animation: glowPulse 3s ease-in-out infinite;
		pointer-events: none;
	}

	@keyframes glowPulse {
		0%, 100% { opacity: 0.5; }
		50% { opacity: 1; }
	}

	.stat-icon-wrapper {
		display: flex;
		align-items: center;
		justify-content: center;
		width: 60px;
		height: 60px;
		background: linear-gradient(135deg, #3B82F6, #60A5FA);
		border-radius: 12px;
		margin-bottom: 16px;
	}

	.stat-card-2 .stat-icon-wrapper {
		background: linear-gradient(135deg, #A855F7, #D8B4FE);
	}

	.stat-card-3 .stat-icon-wrapper {
		background: linear-gradient(135deg, #22C55E, #86EFAC);
	}

	.stat-card-4 .stat-icon-wrapper {
		background: linear-gradient(135deg, #F97316, #FBBD23);
	}

	.stat-icon {
		width: 30px;
		height: 30px;
		color: white;
	}

	.stat-content {
		position: relative;
		z-index: 2;
	}

	.stat-number {
		font-size: 32px;
		font-weight: 700;
		color: #1e293b;
		margin-bottom: 4px;
	}

	.stat-label {
		font-size: 13px;
		color: #64748b;
		font-weight: 500;
		text-transform: uppercase;
		letter-spacing: 0.5px;
	}

	/* ===== CONTENT SECTION ===== */
	.content-section {
		opacity: 0;
		transform: translateY(20px);
		transition: all 0.6s cubic-bezier(0.4, 0, 0.2, 1);
	}

	.content-section.visible {
		opacity: 1;
		transform: translateY(0);
	}

	.section-card {
		background: rgba(255, 255, 255, 0.4);
		backdrop-filter: blur(20px);
		border: 1px solid rgba(255, 255, 255, 0.6);
		border-radius: 16px;
		overflow: hidden;
		position: relative;
	}

	.section-card::before {
		content: '';
		position: absolute;
		top: 0;
		left: 0;
		right: 0;
		height: 3px;
		background: linear-gradient(90deg, #3B82F6, #A855F7, #22C55E);
	}

	.card-header {
		padding: 24px 32px;
		border-bottom: 1px solid rgba(255, 255, 255, 0.3);
	}

	.card-title {
		margin: 0;
		font-size: 20px;
		font-weight: 600;
		color: #1e293b;
	}

	.card-content {
		padding: 24px 32px;
	}

	/* ===== SEARCH BAR ===== */
	.search-container {
		margin-bottom: 24px;
	}

	.search-input {
		width: 100%;
		padding: 12px 16px;
		background: rgba(255, 255, 255, 0.5);
		border: 1px solid rgba(255, 255, 255, 0.5);
		border-radius: 12px;
		font-size: 14px;
		color: #1e293b;
		transition: all 0.3s ease-out;
		backdrop-filter: blur(10px);
		font-family: inherit;
	}

	.search-input::placeholder {
		color: #94a3b8;
	}

	.search-input:focus {
		outline: none;
		background: rgba(255, 255, 255, 0.7);
		border-color: rgba(59, 130, 246, 0.5);
		box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
	}

	/* ===== SECTIONS GRID ===== */
	.sections-grid {
		display: grid;
		grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
		gap: 20px;
	}

	.section-card-item {
		background: rgba(255, 255, 255, 0.3);
		border: 1px solid rgba(255, 255, 255, 0.4);
		border-radius: 12px;
		padding: 20px;
		cursor: pointer;
		transition: all 0.3s ease-out;
		position: relative;
		overflow: hidden;
		animation: cascadeIn 0.5s ease-out forwards;
	}

	.section-card-item::before {
		content: '';
		position: absolute;
		top: 0;
		left: 0;
		right: 0;
		height: 2px;
		background: linear-gradient(90deg, transparent, rgba(59, 130, 246, 0.6), transparent);
	}

	.section-card-item:hover {
		background: rgba(255, 255, 255, 0.5);
		border-color: rgba(59, 130, 246, 0.3);
		transform: translateY(-4px);
		box-shadow: 0 12px 24px rgba(59, 130, 246, 0.15);
	}

	.card-glow {
		position: absolute;
		inset: 0;
		background: radial-gradient(circle at center, rgba(59, 130, 246, 0.1), transparent);
		opacity: 0;
		transition: opacity 0.3s ease-out;
	}

	.section-card-item:hover .card-glow {
		opacity: 1;
	}

	.card-header-mini {
		margin-bottom: 16px;
	}

	.card-title-section {
		display: flex;
		align-items: center;
		justify-content: space-between;
		gap: 12px;
		margin-bottom: 12px;
	}

	.card-title-section h3 {
		margin: 0;
		font-size: 16px;
		font-weight: 600;
		color: #1e293b;
	}

	.status-badge {
		display: inline-block;
		padding: 4px 12px;
		border-radius: 20px;
		font-size: 11px;
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.5px;
	}

	.status-badge.active {
		background: rgba(34, 197, 94, 0.2);
		color: #16a34a;
	}

	.status-badge.inactive {
		background: rgba(148, 163, 184, 0.2);
		color: #64748b;
	}

	.card-stats {
		display: flex;
		gap: 12px;
		margin-bottom: 16px;
	}

	.stat-item {
		display: flex;
		align-items: center;
		gap: 6px;
		font-size: 13px;
		color: #64748b;
	}

	.stat-icon-mini {
		font-size: 16px;
	}

	.card-actions {
		display: flex;
		gap: 8px;
	}

	/* ===== BUTTONS ===== */
	.btn {
		display: inline-flex;
		align-items: center;
		justify-content: center;
		gap: 8px;
		padding: 10px 16px;
		border: none;
		border-radius: 8px;
		font-size: 13px;
		font-weight: 600;
		cursor: pointer;
		transition: all 0.3s ease-out;
		text-transform: uppercase;
		letter-spacing: 0.5px;
		font-family: inherit;
	}

	.btn-primary {
		background: linear-gradient(135deg, #3B82F6, #2563eb);
		color: white;
		box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
	}

	.btn-primary:hover {
		transform: translateY(-2px);
		box-shadow: 0 6px 20px rgba(59, 130, 246, 0.4);
	}

	.btn-primary:active {
		transform: translateY(0);
	}

	.btn-secondary {
		background: rgba(255, 255, 255, 0.3);
		color: #1e293b;
		border: 1px solid rgba(255, 255, 255, 0.4);
		backdrop-filter: blur(10px);
	}

	.btn-secondary:hover {
		background: rgba(255, 255, 255, 0.5);
		border-color: rgba(59, 130, 246, 0.3);
		transform: translateY(-2px);
	}

	.btn:disabled {
		opacity: 0.6;
		cursor: not-allowed;
	}

	.spinner {
		display: inline-block;
		width: 12px;
		height: 12px;
		border: 2px solid rgba(255, 255, 255, 0.3);
		border-top-color: white;
		border-radius: 50%;
		animation: spin 0.8s linear infinite;
	}

	@keyframes spin {
		to { transform: rotate(360deg); }
	}

	/* ===== MODAL ===== */
	.modal-overlay {
		position: fixed;
		inset: 0;
		background: rgba(15, 23, 42, 0.5);
		backdrop-filter: blur(8px);
		display: flex;
		align-items: center;
		justify-content: center;
		z-index: 1000;
		animation: fadeIn 0.3s ease-out;
	}

	@keyframes fadeIn {
		from { opacity: 0; }
		to { opacity: 1; }
	}

	.modal-content {
		background: rgba(255, 255, 255, 0.4);
		backdrop-filter: blur(20px);
		border: 1px solid rgba(255, 255, 255, 0.6);
		border-radius: 16px;
		padding: 32px;
		max-width: 500px;
		width: 90%;
		animation: slideUp 0.3s ease-out;
	}

	@keyframes slideUp {
		from {
			opacity: 0;
			transform: translateY(20px);
		}
		to {
			opacity: 1;
			transform: translateY(0);
		}
	}

	.modal-header {
		display: flex;
		align-items: center;
		justify-content: space-between;
		margin-bottom: 24px;
	}

	.modal-header h3 {
		margin: 0;
		font-size: 20px;
		font-weight: 600;
		color: #1e293b;
	}

	.close-btn {
		background: none;
		border: none;
		font-size: 28px;
		color: #64748b;
		cursor: pointer;
		transition: color 0.3s ease-out;
		font-family: inherit;
	}

	.close-btn:hover {
		color: #1e293b;
	}

	/* ===== FORM ===== */
	.form-group {
		margin-bottom: 20px;
	}

	.form-group label {
		display: block;
		margin-bottom: 8px;
		font-size: 13px;
		font-weight: 600;
		color: #1e293b;
		text-transform: uppercase;
		letter-spacing: 0.5px;
	}

	.form-group input,
	.form-group select {
		width: 100%;
		padding: 12px 16px;
		background: rgba(255, 255, 255, 0.5);
		border: 1px solid rgba(255, 255, 255, 0.5);
		border-radius: 8px;
		font-size: 14px;
		color: #1e293b;
		transition: all 0.3s ease-out;
		font-family: inherit;
		box-sizing: border-box;
	}

	.form-group input::placeholder {
		color: #94a3b8;
	}

	.form-group input:focus,
	.form-group select:focus {
		outline: none;
		background: rgba(255, 255, 255, 0.7);
		border-color: rgba(59, 130, 246, 0.5);
		box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
	}

	/* ===== MODAL ACTIONS ===== */
	.modal-actions {
		display: flex;
		gap: 12px;
		justify-content: flex-end;
		margin-top: 28px;
		padding-top: 20px;
		border-top: 1px solid rgba(255, 255, 255, 0.2);
	}

	/* ===== EMPTY STATE ===== */
	.empty-state {
		padding: 60px 20px;
		text-align: center;
		grid-column: 1 / -1;
	}

	.empty-state h3 {
		margin: 0 0 8px 0;
		font-size: 18px;
		font-weight: 600;
		color: #1e293b;
	}

	.empty-state p {
		margin: 0;
		font-size: 14px;
		color: #64748b;
	}

	/* ===== RESPONSIVE DESIGN ===== */
	@media (max-width: 768px) {
		.sections-page {
			padding: 20px 16px;
		}

		.page-header {
			flex-direction: column;
			text-align: center;
			padding: 20px 16px;
		}

		.header-content h1 {
			font-size: 24px;
		}

		.stats-grid {
			grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
			gap: 16px;
		}

		.modal-content {
			max-width: 90%;
		}

		.card-actions {
			flex-direction: column;
		}

		.btn {
			width: 100%;
		}
	}

	@media (max-width: 480px) {
		.loading-brand .brand-main {
			font-size: 22px;
		}

		.page-header {
			padding: 16px 12px;
		}

		.header-content h1 {
			font-size: 20px;
		}

		.stats-grid {
			grid-template-columns: 1fr;
		}

		.sections-grid {
			grid-template-columns: 1fr;
		}

		.modal-content {
			padding: 20px;
		}
	}

	/* ===== ACCESSIBILITY ===== */
	@media (prefers-reduced-motion: reduce) {
		* {
			animation-duration: 0.01ms !important;
			animation-iteration-count: 1 !important;
			transition-duration: 0.01ms !important;
		}
	}

	@media (prefers-color-scheme: dark) {
		.loading-screen {
			background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
		}

		.page-header,
		.stat-card,
		.section-card,
		.section-card-item {
			background: rgba(30, 41, 59, 0.4);
			border-color: rgba(148, 163, 184, 0.2);
		}

		.header-content h1,
		.card-title,
		.modal-header h3,
		.stat-number,
		.card-title-section h3 {
			color: #f1f5f9;
		}

		.search-input,
		.form-group input,
		.form-group select {
			background: rgba(30, 41, 59, 0.5);
			border-color: rgba(148, 163, 184, 0.2);
			color: #f1f5f9;
		}

		.search-input::placeholder,
		.form-group input::placeholder {
			color: #94a3b8;
		}
	}
</style>
