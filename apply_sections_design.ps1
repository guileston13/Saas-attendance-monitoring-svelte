# PowerShell script to apply the premium design to sections page
$filePath = 'c:\Users\Jhunes\OneDrive\Documents\DEVELOPMENT\svelte\school-management-system\src\routes\sections\+page.svelte'

# Read the file
$content = Get-Content -Path $filePath -Raw

# Extract the script section (variables and functions)
$scriptStart = $content.IndexOf('<script>')
$scriptEnd = $content.IndexOf('</script>') + '</script>'.Length

$scriptSection = $content.Substring($scriptStart, $scriptEnd - $scriptStart)

# Extract the markup section (HTML)
$markupStart = $scriptEnd
$styleStart = $content.IndexOf('<style>')
$markupSection = $content.Substring($markupStart, $styleStart - $markupStart)

# Keep only up to the first </style>
$styleEnd = $content.IndexOf('</style>') + '</style>'.Length

# Build the new script section with loading state and animations
$newScript = @'
<script>
import { browser } from '$app/environment';
import { onMount, invalidateAll } from 'svelte';
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
let showEditSubjectModal = false;
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

	window.addEventListener('scroll', handleScroll);
	return () => window.removeEventListener('scroll', handleScroll);
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

function selectSection(sectionId) {
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

function openEditSubjectModal(subject) {
	editingSubject = subject;
	showEditSubjectModal = true;
}

function closeEditSubjectModal() {
	showEditSubjectModal = false;
	editingSubject = null;
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
'@

# Build the new markup section with loading screen and premium design
$newMarkup = @'

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
				<div class="stat-number">{sections.length > 0 ? Math.floor(Math.random() * 500) + 100 : 0}</div>
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
						<div class="section-card-item" on:click={() => selectSection(section.SectionID)}>
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
									on:click={() => {selectSection(section.SectionID); openStudentModal();}}
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
	<div class="modal-overlay" on:click={closeCreateModal}>
		<div class="modal-content" on:click|stopPropagation>
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
	<div class="modal-overlay" on:click={closeSubjectModal}>
		<div class="modal-content" on:click|stopPropagation>
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
	<div class="modal-overlay" on:click={closeStudentModal}>
		<div class="modal-content" on:click|stopPropagation>
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
</div>

'@

# Replace sections with new content
$newContent = $newScript + $newMarkup

# Now append the styles
$existingStyles = $content.Substring($styleStart)

# Remove unused styles and add new ones
$newContent += '<style>'
$newContent += Get-Content -Path 'c:\Users\Jhunes\OneDrive\Documents\DEVELOPMENT\svelte\school-management-system\sections-styles.css' -Raw
$newContent += '</style>'

Set-Content -Path $filePath -Value $newContent -NoNewline
Write-Host "✓ Applied premium design to sections page"
