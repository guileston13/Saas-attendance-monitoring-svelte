<script>
// Subjects management page
import { browser } from '$app/environment';

/** @type {import('./$types').PageData} */
export let data;

$: session = data.session;
$: subjects = data.subjects || [];
$: statusList = data.statusList || [];

let showModal = false;
let editingSubject = null;
let loading = false;
let searchTerm = '';
let isLoading = true;
let loadingProgress = 0;
let loadingText = 'Initializing...';
let loadingFadeOut = false;
let pageVisible = false;
let statsVisible = false;
let cardsVisible = false;
let scrollY = 0;

import { onMount } from 'svelte';

onMount(() => {
	const loadingSteps = [
		{ progress: 25, text: 'Loading subjects...' },
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

	window.addEventListener('scroll', handleScroll);
	return () => window.removeEventListener('scroll', handleScroll);
});

// Form data
let formData = {
	subjectName: '',
	subjectCode: '',
	room: '',
	startTime: '',
	endTime: '',
	statusId: ''
};

// Filter subjects based on search term
$: filteredSubjects = subjects.filter(subject => 
	subject.SubjectName.toLowerCase().includes(searchTerm.toLowerCase()) ||
	subject.SubjectCode.toLowerCase().includes(searchTerm.toLowerCase()) ||
	(subject.RoomID && subject.RoomID.toLowerCase().includes(searchTerm.toLowerCase()))
);

function openModal(subject = null) {
	editingSubject = subject;
	if (subject) {
		formData = {
			subjectName: subject.SubjectName,
			subjectCode: subject.SubjectCode,
			room: subject.RoomID || '',
			startTime: subject.StartTime || '',
			endTime: subject.EndTime || '',
			statusId: subject.StatusID.toString()
		};
	} else {
		formData = {
			subjectName: '',
			subjectCode: '',
			room: '',
			startTime: '',
			endTime: '',
			statusId: '1'
		};
	}
	showModal = true;
}

function closeModal() {
	showModal = false;
	editingSubject = null;
	resetForm();
}

function handleKeydown(event) {
	if (event.key === 'Escape') {
		closeModal();
	}
}

function resetForm() {
	formData = {
		subjectName: '',
		subjectCode: '',
		room: '',
		startTime: '',
		endTime: '',
		statusId: ''
	};
}

async function handleSubmit() {
	if (!browser) return;
	
	loading = true;
	
	try {
		const method = editingSubject ? 'PUT' : 'POST';
		const response = await fetch('/api/subjects', {
			method,
			headers: {
				'Content-Type': 'application/json'
			},
			body: JSON.stringify({
				...formData,
				statusId: parseInt(formData.statusId),
				...(editingSubject && { subjectId: editingSubject.SubjectID })
			})
		});
		
		const result = await response.json();
		
		if (response.ok) {
			window.location.reload();
		} else {
			alert(result.error || 'An error occurred');
		}
	} catch (error) {
		console.error('Submit error:', error);
		alert('An error occurred while saving');
	} finally {
		loading = false;
	}
}

async function handleDelete(subjectId) {
	if (!browser) return;

	if (!confirm('Are you sure you want to delete this subject?')) {
		return;
	}

	try {
		const response = await fetch('/api/subjects', {
			method: 'DELETE',
			headers: {
				'Content-Type': 'application/json'
			},
			body: JSON.stringify({ subjectId })
		});

		const result = await response.json();

		if (response.ok) {
			window.location.reload();
		} else {
			alert(result.error || 'Failed to delete subject');
		}
	} catch (error) {
		console.error('Delete error:', error);
		alert('An error occurred while deleting');
	}
}
</script>

<svelte:head>
	<title>Subjects - School Management System</title>
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
					<text x="50" y="65" font-size="40" font-weight="bold" text-anchor="middle" fill="white">📚</text>
				</svg>
			</div>

			<div class="loading-brand">
				<div class="brand-main">School Management</div>
				<div class="brand-tagline">SUBJECTS MODULE</div>
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

<div class="subjects-page" class:visible={pageVisible}>
	<div class="page-header" class:visible={pageVisible}>
		<div class="header-icon-wrapper">
			<svg class="header-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
				<path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path>
				<path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path>
			</svg>
		</div>
		<div class="header-content">
			<h1>Subjects Management</h1>
			<p class="subtitle">Manage academic subjects, schedules, and room assignments</p>
		</div>
		<button class="btn btn-primary" on:click={() => openModal()}>
			<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
				<line x1="12" y1="5" x2="12" y2="19"></line>
				<line x1="5" y1="12" x2="19" y2="12"></line>
			</svg>
			Add New Subject
		</button>
	</div>
	
	{#if data.error}
		<div class="error-message error-slide-in">
			<svg class="error-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
				<circle cx="12" cy="12" r="10"></circle>
				<line x1="12" y1="8" x2="12" y2="12"></line>
				<line x1="12" y1="16" x2="12.01" y2="16"></line>
			</svg>
			<span>{data.error}</span>
		</div>
	{/if}
	
	<div class="stats-grid" class:visible={statsVisible}>
		<div class="stat-card stat-card-1">
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
		<div class="stat-card stat-card-2">
			<div class="stat-glow"></div>
			<div class="stat-icon-wrapper">
				<svg class="stat-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
					<polyline points="20 6 9 17 4 12"></polyline>
				</svg>
			</div>
			<div class="stat-content">
				<div class="stat-number">{subjects.filter(s => s.StatusName === 'Active').length}</div>
				<div class="stat-label">Active Subjects</div>
			</div>
		</div>
		<div class="stat-card stat-card-3">
			<div class="stat-glow"></div>
			<div class="stat-icon-wrapper">
				<svg class="stat-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
					<path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path>
					<polyline points="9 22 9 12 15 12 15 22"></polyline>
				</svg>
			</div>
			<div class="stat-content">
				<div class="stat-number">{new Set(subjects.map(s => s.RoomID).filter(Boolean)).size}</div>
				<div class="stat-label">Rooms Used</div>
			</div>
		</div>
		<div class="stat-card stat-card-4">
			<div class="stat-glow"></div>
			<div class="stat-icon-wrapper">
				<svg class="stat-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
					<circle cx="12" cy="12" r="10"></circle>
					<polyline points="12 6 12 12 16 14"></polyline>
				</svg>
			</div>
			<div class="stat-content">
				<div class="stat-number">{subjects.filter(s => s.StartTime && s.EndTime).length}</div>
				<div class="stat-label">Scheduled</div>
			</div>
		</div>
	</div>
	
	<!-- Search and Table Section -->
	<div class="content-section" class:visible={cardsVisible}>
		<div class="section-card">
			<div class="card-header">
				<h3 class="card-title">📋 Subject Records</h3>
			</div>
			
			<div class="card-content">
				<!-- Search bar -->
				<div class="search-container">
					<input
						type="text"
						bind:value={searchTerm}
						placeholder="🔍 Search by name, code, or room..."
						class="search-input"
					>
				</div>
				
				<!-- Subjects table -->
				<div class="table-container">
					<table class="data-table">
						<thead>
							<tr>
								<th>Subject Code</th>
								<th>Subject Name</th>
								<th>Room</th>
								<th>Start Time</th>
								<th>End Time</th>
								<th>Status</th>
								{#if session.role === 'Admin'}
									<th>Actions</th>
								{/if}
							</tr>
						</thead>
						<tbody>
							{#each filteredSubjects as subject}
								<tr>
									<td><code>{subject.SubjectCode}</code></td>
									<td>{subject.SubjectName}</td>
									<td>{subject.RoomID || '-'}</td>
									<td>{subject.StartTime || '-'}</td>
									<td>{subject.EndTime || '-'}</td>
									<td>
										<span class="status-badge {subject.StatusName.toLowerCase()}">
											{subject.StatusName}
										</span>
									</td>
									{#if session.role === 'Admin'}
										<td>
											<div class="actions">
												<button 
													class="btn btn-secondary"
													on:click={() => openModal(subject)}
												>
													Edit
												</button>
												<button 
													class="btn btn-danger"
													on:click={() => handleDelete(subject.SubjectID)}
												>
													Delete
												</button>
											</div>
										</td>
									{/if}
								</tr>
							{:else}
								<tr>
									<td colspan={Number(session.role === 'Admin' ? '7' : '6')} class="text-center">
										<div class="empty-state">
											<h3>No subjects found</h3>
											<p>{searchTerm ? 'Try adjusting your search terms' : 'No subject records available'}</p>
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

<!-- Modal for add/edit subject -->
{#if showModal}
	<div class="modal-overlay" on:click={closeModal} on:keydown={handleKeydown} role="dialog" aria-modal="true" tabindex="-1">
		<div class="modal-content" on:click|stopPropagation role="document">
			<div class="modal-header">
				<div class="modal-title-wrapper">
					<div class="modal-icon">
						{#if editingSubject}
							<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
								<path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
								<path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
							</svg>
						{:else}
							<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
								<line x1="12" y1="5" x2="12" y2="19"></line>
								<line x1="5" y1="12" x2="19" y2="12"></line>
							</svg>
						{/if}
					</div>
					<h3 class="modal-title">
						{editingSubject ? 'Edit Subject' : 'Add New Subject'}
					</h3>
				</div>
				<button class="close-btn" on:click={closeModal} aria-label="Close modal">
					<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
						<line x1="18" y1="6" x2="6" y2="18"></line>
						<line x1="6" y1="6" x2="18" y2="18"></line>
					</svg>
				</button>
			</div>
			
			<form on:submit|preventDefault={handleSubmit}>
				<div class="form-group">
					<label for="subjectCode" class="form-label">Subject Code:</label>
					<input
						type="text"
						id="subjectCode"
						bind:value={formData.subjectCode}
						required
						disabled={loading}
						placeholder="e.g., MATH101"
						style="text-transform: uppercase;"
						class="form-input"
					/>
				</div>
				
				<div class="form-group">
					<label for="subjectName" class="form-label">Subject Name:</label>
					<input
						type="text"
						id="subjectName"
						bind:value={formData.subjectName}
						required
						disabled={loading}
						placeholder="e.g., Mathematics"
						class="form-input"
					/>
				</div>
				
				<div class="form-group">
					<label for="room" class="form-label">Room:</label>
					<input
						type="text"
						id="room"
						bind:value={formData.room}
						disabled={loading}
						placeholder="e.g., Room 101, Lab 1, Gym"
						class="form-input"
					/>
				</div>
				
				<div class="form-row">
					<div class="form-group">
						<label for="startTime" class="form-label">Start Time:</label>
						<input
							type="time"
							id="startTime"
							bind:value={formData.startTime}
							disabled={loading}
							class="form-input"
						/>
					</div>
					
					<div class="form-group">
						<label for="endTime" class="form-label">End Time:</label>
						<input
							type="time"
							id="endTime"
							bind:value={formData.endTime}
							disabled={loading}
							class="form-input"
						/>
					</div>
				</div>
				
				<div class="form-group">
					<label for="statusId" class="form-label">Status:</label>
					<select
						id="statusId"
						bind:value={formData.statusId}
						required
						disabled={loading}
						class="form-select"
					>
						{#each statusList as status}
							<option value={status.StatusID.toString()}>
								{status.StatusName}
							</option>
						{/each}
					</select>
				</div>
				
				<div class="modal-actions">
					<button type="button" class="btn btn-secondary" on:click={closeModal} disabled={loading}>
						Cancel
					</button>
					<button type="submit" class="btn btn-primary" disabled={loading}>
						{#if loading}
							<span class="spinner"></span>
						{/if}
						{editingSubject ? 'Update Subject' : 'Create Subject'}
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

	.particle-1 { width: 4px; height: 4px; background: #3B82F6; }
	.particle-2 { width: 6px; height: 6px; background: #A855F7; }
	.particle-3 { width: 3px; height: 3px; background: #22C55E; }
	.particle-4 { width: 5px; height: 5px; background: #F97316; }

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
		top: 0; left: 0; bottom: 0; right: 0;
		background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.4), transparent);
		animation: progressShine 2s ease-in-out infinite;
	}

	.progress-glow {
		position: absolute;
		top: 0; left: 0;
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

	.orb-1 { width: 200px; height: 200px; background: #3B82F6; top: 10%; left: 10%; animation-delay: 0s; }
	.orb-2 { width: 300px; height: 300px; background: #A855F7; top: 60%; right: 10%; animation-delay: 2s; }
	.orb-3 { width: 150px; height: 150px; background: #22C55E; bottom: 20%; left: 20%; animation-delay: 4s; }
	.orb-4 { width: 250px; height: 250px; background: #F97316; top: 30%; right: 30%; animation-delay: 1s; }

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
		top: 10%; left: 10%;
		width: 400px; height: 400px;
		background: linear-gradient(135deg, #3B82F6, #A855F7);
		animation: float 8s ease-in-out infinite;
	}

	.orb-bg-2 {
		top: 50%; right: 10%;
		width: 500px; height: 500px;
		background: linear-gradient(135deg, #22C55E, #3B82F6);
		animation: float 10s ease-in-out infinite reverse;
	}

	.orb-bg-3 {
		bottom: 10%; left: 30%;
		width: 350px; height: 350px;
		background: linear-gradient(135deg, #F97316, #A855F7);
		animation: float 12s ease-in-out infinite;
	}

	.subjects-page {
		max-width: 1400px;
		margin: 0 auto;
		padding: 2rem;
		opacity: 0;
		transform: translateY(20px);
		transition: all 0.6s cubic-bezier(0.4, 0, 0.2, 1);
	}

	.subjects-page.visible {
		opacity: 1;
		transform: translateY(0);
	}

	.page-header {
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

	.header-content {
		flex: 1;
	}

	.page-header h1 {
		margin: 0 0 0.5rem 0;
		font-size: 3rem;
		font-weight: 700;
		background: linear-gradient(135deg, #3B82F6, #A855F7);
		-webkit-background-clip: text;
		-webkit-text-fill-color: transparent;
		background-clip: text;
	}

	.subtitle {
		margin: 0;
		color: #64748b;
		font-size: 1.25rem;
		font-weight: 500;
	}

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
	}

	.error-slide-in {
		animation: slideInFromTop 0.5s ease-out, shake 0.4s ease 0.5s;
	}

	.error-icon {
		width: 1.5rem;
		height: 1.5rem;
		flex-shrink: 0;
	}

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
		transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
		position: relative;
	}

	.section-card::before {
		content: '';
		position: absolute;
		top: 0; left: 0; right: 0;
		height: 4px;
		background: linear-gradient(90deg, #3B82F6, #A855F7, #22C55E, #F97316);
	}

	.section-card:hover {
		transform: translateY(-4px);
		box-shadow: 0 25px 70px rgba(0, 0, 0, 0.12);
	}

	.card-header {
		background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(168, 85, 247, 0.1));
		backdrop-filter: blur(10px);
		padding: 2rem 2.5rem;
		border-bottom: 1px solid rgba(255, 255, 255, 0.3);
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

	.card-content {
		padding: 2rem 2.5rem;
	}

	.search-container {
		margin-bottom: 2rem;
	}

	.search-input {
		width: 100%;
		padding: 1rem 1.5rem;
		border: 2px solid rgba(148, 163, 184, 0.2);
		border-radius: 16px;
		font-size: 1rem;
		background: rgba(255, 255, 255, 0.5);
		backdrop-filter: blur(10px);
		transition: all 0.3s ease;
	}

	.search-input:focus {
		outline: none;
		border-color: #3B82F6;
		box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.1);
	}

	.search-input::placeholder {
		color: #94a3b8;
	}

	.table-container {
		overflow-x: auto;
		border-radius: 16px;
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

	code {
		background: rgba(148, 163, 184, 0.1);
		padding: 0.2rem 0.4rem;
		border-radius: 3px;
		font-family: 'Courier New', monospace;
		font-size: 0.9rem;
		color: #3B82F6;
	}

	.status-badge {
		display: inline-block;
		padding: 0.5rem 1rem;
		border-radius: 12px;
		font-size: 0.875rem;
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.05em;
	}

	.status-badge.active {
		background: linear-gradient(135deg, rgba(34, 197, 94, 0.1), rgba(34, 197, 94, 0.2));
		border: 1px solid rgba(34, 197, 94, 0.3);
		color: #16a34a;
	}

	.status-badge.inactive {
		background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.2));
		border: 1px solid rgba(239, 68, 68, 0.3);
		color: #dc2626;
	}

	.text-center {
		text-align: center;
		padding: 3rem;
	}

	.empty-state h3 {
		color: #64748b;
		font-size: 1.25rem;
		margin-bottom: 0.5rem;
	}

	.empty-state p {
		color: #94a3b8;
		font-size: 1rem;
	}

	.actions {
		display: flex;
		gap: 0.5rem;
		flex-wrap: wrap;
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

	.btn-primary {
		background: linear-gradient(135deg, #3B82F6, #2563EB);
		color: white;
		box-shadow: 0 4px 15px rgba(59, 130, 246, 0.3);
	}

	.btn-primary:hover:not(:disabled) {
		transform: translateY(-2px) scale(1.02);
		box-shadow: 0 8px 25px rgba(59, 130, 246, 0.4);
	}

	.btn-secondary {
		background: linear-gradient(135deg, #64748b, #475569);
		color: white;
		box-shadow: 0 4px 15px rgba(100, 116, 139, 0.3);
	}

	.btn-secondary:hover:not(:disabled) {
		transform: translateY(-2px) scale(1.02);
		box-shadow: 0 8px 25px rgba(100, 116, 139, 0.4);
	}

	.btn-danger {
		background: linear-gradient(135deg, #EF4444, #DC2626);
		color: white;
		box-shadow: 0 4px 15px rgba(239, 68, 68, 0.3);
	}

	.btn-danger:hover:not(:disabled) {
		transform: translateY(-2px) scale(1.02);
		box-shadow: 0 8px 25px rgba(239, 68, 68, 0.4);
	}

	.btn:disabled {
		opacity: 0.6;
		cursor: not-allowed;
	}

	.modal-overlay {
		position: fixed;
		inset: 0;
		background: rgba(15, 23, 42, 0.7);
		backdrop-filter: blur(8px);
		display: flex;
		align-items: center;
		justify-content: center;
		z-index: 1000;
		animation: fadeIn 0.3s ease;
	}

	.modal-content {
		background: rgba(255, 255, 255, 0.95);
		backdrop-filter: blur(20px);
		-webkit-backdrop-filter: blur(20px);
		border: 1px solid rgba(255, 255, 255, 0.5);
		border-radius: 24px;
		padding: 0;
		max-width: 600px;
		width: 90%;
		max-height: 90vh;
		overflow: hidden;
		box-shadow: 0 25px 70px rgba(0, 0, 0, 0.3);
		animation: modalSlideUp 0.4s cubic-bezier(0.4, 0, 0.2, 1);
		position: relative;
	}

	.modal-content::before {
		content: '';
		position: absolute;
		top: 0; left: 0; right: 0;
		height: 4px;
		background: linear-gradient(90deg, #3B82F6, #A855F7, #22C55E, #F97316);
	}

	.modal-header {
		background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(168, 85, 247, 0.1));
		backdrop-filter: blur(10px);
		padding: 2rem 2.5rem;
		border-bottom: 1px solid rgba(255, 255, 255, 0.3);
		display: flex;
		justify-content: space-between;
		align-items: center;
	}

	.modal-title-wrapper {
		display: flex;
		align-items: center;
		gap: 1rem;
	}

	.modal-icon {
		width: 48px;
		height: 48px;
		background: linear-gradient(135deg, #3B82F6, #A855F7);
		border-radius: 12px;
		display: flex;
		align-items: center;
		justify-content: center;
		box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
	}

	.modal-icon svg {
		width: 24px;
		height: 24px;
		color: white;
	}

	.modal-title {
		margin: 0;
		font-size: 1.5rem;
		font-weight: 700;
		background: linear-gradient(135deg, #3B82F6, #A855F7);
		-webkit-background-clip: text;
		-webkit-text-fill-color: transparent;
		background-clip: text;
	}

	.close-btn {
		width: 36px;
		height: 36px;
		background: rgba(148, 163, 184, 0.1);
		border: 1px solid rgba(148, 163, 184, 0.2);
		border-radius: 8px;
		cursor: pointer;
		display: flex;
		align-items: center;
		justify-content: center;
		transition: all 0.2s ease;
	}

	.close-btn:hover {
		background: rgba(239, 68, 68, 0.1);
		border-color: rgba(239, 68, 68, 0.3);
		transform: scale(1.1);
	}

	.close-btn svg {
		width: 18px;
		height: 18px;
		color: #64748b;
	}

	.close-btn:hover svg {
		color: #ef4444;
	}

	.modal-content form {
		padding: 2rem 2.5rem;
		max-height: calc(90vh - 180px);
		overflow-y: auto;
	}

	.form-group {
		margin-bottom: 1.5rem;
	}

	.form-label {
		display: block;
		margin-bottom: 0.5rem;
		font-weight: 600;
		color: #334155;
		font-size: 0.95rem;
	}

	.form-input,
	.form-select {
		width: 100%;
		padding: 0.875rem 1.25rem;
		border: 2px solid rgba(148, 163, 184, 0.2);
		border-radius: 12px;
		font-size: 1rem;
		background: rgba(255, 255, 255, 0.5);
		backdrop-filter: blur(10px);
		transition: all 0.3s ease;
		color: #1e293b;
	}

	.form-input:focus,
	.form-select:focus {
		outline: none;
		border-color: #3B82F6;
		box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.1);
	}

	.form-input:disabled,
	.form-select:disabled {
		background: rgba(148, 163, 184, 0.1);
		color: #94a3b8;
		cursor: not-allowed;
	}

	.form-row {
		display: flex;
		gap: 1rem;
	}

	.form-row .form-group {
		flex: 1;
	}

	.modal-actions {
		display: flex;
		justify-content: flex-end;
		gap: 1rem;
		padding: 1.5rem 2.5rem;
		border-top: 1px solid rgba(148, 163, 184, 0.2);
		background: rgba(248, 250, 252, 0.5);
	}

	.spinner {
		display: inline-block;
		width: 16px;
		height: 16px;
		border: 2px solid rgba(255, 255, 255, 0.3);
		border-top: 2px solid white;
		border-radius: 50%;
		animation: spin 0.8s linear infinite;
	}

	@keyframes loadingFadeIn {
		0% { opacity: 0; }
		100% { opacity: 1; }
	}

	@keyframes loadingFadeOut {
		0% { opacity: 1; transform: scale(1); }
		100% { opacity: 0; transform: scale(1.05); }
	}

	@keyframes particleFloat {
		0%, 100% { transform: translate(0, 0); opacity: 0.6; }
		25% { transform: translate(10px, -10px); opacity: 0.8; }
		50% { transform: translate(-10px, -20px); opacity: 0.4; }
		75% { transform: translate(-20px, 10px); opacity: 0.7; }
	}

	@keyframes logoRotate {
		0%, 100% { transform: rotate(0deg) scale(1); }
		25% { transform: rotate(5deg) scale(1.05); }
		50% { transform: rotate(-5deg) scale(0.95); }
		75% { transform: rotate(3deg) scale(1.02); }
	}

	@keyframes logoPulse {
		0%, 100% { transform: scale(1); opacity: 0.5; }
		50% { transform: scale(1.2); opacity: 0.8; }
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
		0%, 80%, 100% { transform: scale(0.8); opacity: 0.6; }
		40% { transform: scale(1.2); opacity: 1; }
	}

	@keyframes orbFloat {
		0%, 100% { transform: translate(0, 0) scale(1); }
		33% { transform: translate(30px, -30px) scale(1.1); }
		66% { transform: translate(-20px, 20px) scale(0.9); }
	}

	@keyframes float {
		0%, 100% { transform: translateY(0) rotate(0deg); }
		50% { transform: translateY(-30px) rotate(5deg); }
	}

	@keyframes pulse-slow {
		0%, 100% { opacity: 1; transform: scale(1); }
		50% { opacity: 0.9; transform: scale(1.05); }
	}

	@keyframes shake {
		0%, 100% { transform: translateX(0); }
		25% { transform: translateX(-8px); }
		75% { transform: translateX(8px); }
	}

	@keyframes slideInFromTop {
		0% { opacity: 0; transform: translateY(-20px); }
		100% { opacity: 1; transform: translateY(0); }
	}

	@keyframes cascadeIn {
		0% { opacity: 0; transform: translateY(20px) scale(0.95); }
		100% { opacity: 1; transform: translateY(0) scale(1); }
	}

	@keyframes glowPulse {
		0%, 100% { opacity: 0.5; transform: scale(1); }
		50% { opacity: 1; transform: scale(1.1); }
	}

	@keyframes fadeIn {
		0% { opacity: 0; }
		100% { opacity: 1; }
	}

	@keyframes modalSlideUp {
		0% { opacity: 0; transform: translateY(50px) scale(0.9); }
		100% { opacity: 1; transform: translateY(0) scale(1); }
	}

	@keyframes spin {
		0% { transform: rotate(0deg); }
		100% { transform: rotate(360deg); }
	}

	@media (max-width: 1024px) {
		.subjects-page { padding: 1.5rem; }
		.page-header { padding: 2rem; }
		.stats-grid { grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); }
	}

	@media (max-width: 768px) {
		.subjects-page { padding: 1rem; }
		.page-header { flex-direction: column; align-items: flex-start; padding: 1.5rem; gap: 1rem; }
		.page-header h1 { font-size: 2rem; }
		.header-icon-wrapper { width: 64px; height: 64px; }
		.header-icon { width: 36px; height: 36px; }
		.stats-grid { grid-template-columns: 1fr; gap: 1rem; }
		.stat-card { padding: 1.5rem; }
		.stat-number { font-size: 2rem; }
		.card-content { padding: 1.5rem; }
		.data-table { font-size: 0.9rem; }
		.data-table th, .data-table td { padding: 1rem 0.5rem; }
		.actions { flex-direction: column; }
		.actions .btn { width: 100%; }
		.modal-content { margin: 1rem; width: calc(100% - 2rem); }
		.modal-header, .modal-content form, .modal-actions { padding: 1.5rem; }
		.brand-main { font-size: 2rem; }
		.brand-tagline { font-size: 1.125rem; }
	}

	@media (max-width: 480px) {
		.page-header h1 { font-size: 1.75rem; }
		.subtitle { font-size: 1rem; }
		.stat-icon-wrapper { width: 56px; height: 56px; }
		.stat-icon { width: 28px; height: 28px; }
		.stat-number { font-size: 1.75rem; }
		.data-table { font-size: 0.85rem; }
	}

	@media (prefers-reduced-motion: reduce) {
		*, *::before, *::after {
			animation-duration: 0.01ms !important;
			animation-iteration-count: 1 !important;
			transition-duration: 0.01ms !important;
		}
	}
</style>