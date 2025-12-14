<script>
	import { browser } from '$app/environment';
	import { onMount } from 'svelte';
	
	/** @type {import('./$types').PageData} */
	export let data;
	
	$: session = data.session;
	
	console.log('Reports page session:', session);
	
	let teachers = [];
	let selectedTeacher = null;
	let subjects = [];
	let selectedSubject = null;
	let loading = false;
	let error = null;
	
	// Modal states
	let showSubjectsModal = false;
	let showDateRangeModal = false;
	
	// Date range
	let startDate = '';
	let endDate = '';
	
	onMount(async () => {
		if (session.role === 'Admin') {
			await loadTeachers();
		} else if (session.role === 'Teacher' && session.teacherId) {
			// For teachers, directly load their subjects
			await loadTeacherSubjects(session.teacherId);
			selectedTeacher = {
				TeacherID: session.teacherId,
				FirstName: session.firstName || 'Teacher',
				LastName: session.lastName || ''
			};
			showSubjectsModal = true;
		} else if (session.role === 'Teacher' && !session.teacherId) {
			error = 'Your teacher profile is not linked to your account. Please contact admin.';
		}
		
		// Set default date range (current month)
		const today = new Date();
		const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
		const lastDay = new Date(today.getFullYear(), today.getMonth() + 1, 0);
		
		startDate = formatDate(firstDay);
		endDate = formatDate(lastDay);
	});
	
	function formatDate(date) {
		const year = date.getFullYear();
		const month = String(date.getMonth() + 1).padStart(2, '0');
		const day = String(date.getDate()).padStart(2, '0');
		return `${year}-${month}-${day}`;
	}
	
	async function loadTeachers() {
		loading = true;
		error = null;
		
		try {
			const response = await fetch('/api/reports/teachers');
			const result = await response.json();
			
			if (response.ok) {
				teachers = result.teachers || [];
			} else {
				error = result.error || 'Failed to load teachers';
			}
		} catch (err) {
			console.error('Load teachers error:', err);
			error = 'An error occurred while loading teachers';
		} finally {
			loading = false;
		}
	}
	
	async function selectTeacher(teacher) {
		selectedTeacher = teacher;
		await loadTeacherSubjects(teacher.TeacherID);
		showSubjectsModal = true;
	}
	
	async function loadTeacherSubjects(teacherId) {
		loading = true;
		error = null;
		subjects = [];
		
		try {
			const response = await fetch(`/api/teachers/${teacherId}/subjects`);
			const result = await response.json();
			
			if (response.ok) {
				subjects = result.subjects || [];
			} else {
				error = result.error || 'Failed to load subjects';
			}
		} catch (err) {
			console.error('Load subjects error:', err);
			error = 'An error occurred while loading subjects';
		} finally {
			loading = false;
		}
	}
	
	function selectSubject(subject) {
		selectedSubject = subject;
		showSubjectsModal = false;
		showDateRangeModal = true;
	}
	
	function closeModals() {
		showSubjectsModal = false;
		showDateRangeModal = false;
	}
	
	function backToSubjects() {
		showDateRangeModal = false;
		showSubjectsModal = true;
	}
	
	async function generateReport() {
		if (!selectedSubject || !startDate || !endDate) {
			alert('Please select date range');
			return;
		}
		
		if (new Date(startDate) > new Date(endDate)) {
			alert('Start date must be before end date');
			return;
		}
		
		// Prepare report parameters
		const reportParams = {
			sectionId: selectedSubject.SectionID,
			subjectId: selectedSubject.SubjectID,
			startDate,
			endDate,
			teacherId: selectedTeacher.TeacherID
		};
		
		// Encode parameters for URL
		const queryString = new URLSearchParams(reportParams).toString();
		
		// Open report in new tab
		window.open(`/reports/view?${queryString}`, '_blank');
		
		// Close modal
		closeModals();
	}
</script>

<svelte:head>
	<title>Attendance Reports - School Management System</title>
</svelte:head>

<div class="page">
	<div class="page-header">
		<h1>📊 Attendance Reports</h1>
		<p class="subtitle">Generate and view attendance reports by teacher and subject</p>
	</div>
	
	{#if error}
		<div class="error-message">{error}</div>
	{/if}
	
	{#if session.role === 'Admin'}
		<div class="card">
			<div class="card-header">
				<h3 class="card-title">Select Teacher</h3>
				<p>Click on a teacher to view their subjects</p>
			</div>
			
			{#if loading && teachers.length === 0}
				<div class="loading">
					<span class="spinner"></span>
					Loading teachers...
				</div>
			{:else}
				<div class="teachers-grid">
					{#each teachers as teacher}
						<div 
							class="teacher-card" 
							on:click={() => selectTeacher(teacher)}
							on:keydown={(e) => (e.key === 'Enter' || e.key === ' ') && selectTeacher(teacher)}
							role="button"
							tabindex="0"
						>
							<div class="teacher-avatar">
								<span class="avatar-icon">👤</span>
							</div>
							<div class="teacher-info">
								<h4>
									{teacher.FirstName} 
									{teacher.MiddleName ? teacher.MiddleName + ' ' : ''}
									{teacher.LastName}
								</h4>
								<span class="teacher-id">ID: {teacher.TeacherID}</span>
							</div>
							<div class="card-arrow">→</div>
						</div>
					{:else}
						<div class="no-data">
							<p>No teachers found</p>
						</div>
					{/each}
				</div>
			{/if}
		</div>
	{/if}
</div>

<!-- Subjects Modal -->
{#if showSubjectsModal}
	<div 
		class="modal-overlay" 
		on:click={closeModals}
		on:keydown={(e) => e.key === 'Escape' && closeModals()}
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
				<h3 class="modal-title">
					Select Subject - {selectedTeacher?.FirstName} {selectedTeacher?.LastName}
				</h3>
				<button class="close-btn" on:click={closeModals}>&times;</button>
			</div>
			
			{#if loading}
				<div class="loading">
					<span class="spinner"></span>
					Loading subjects...
				</div>
			{:else}
				<div class="subjects-list">
					{#each subjects as subject}
						<div 
							class="subject-item" 
							on:click={() => selectSubject(subject)}
							on:keydown={(e) => (e.key === 'Enter' || e.key === ' ') && selectSubject(subject)}
							role="button"
							tabindex="0"
						>
							<div class="subject-icon">📚</div>
							<div class="subject-info">
								<h4>{subject.subject_name}</h4>
								<div class="subject-details">
									{#if subject.subject_code}
										<span class="badge">{subject.subject_code}</span>
									{/if}
									<span class="badge">Section: {subject.SectionName}</span>
									{#if subject.teaching_days}
										<span class="badge days-badge">{subject.teaching_days}</span>
									{/if}
								</div>
							</div>
							<div class="item-arrow">→</div>
						</div>
					{:else}
						<div class="no-data">
							<p>No subjects assigned to this teacher</p>
						</div>
					{/each}
				</div>
			{/if}
		</div>
	</div>
{/if}

<!-- Date Range Modal -->
{#if showDateRangeModal}
	<div 
		class="modal-overlay" 
		on:click={closeModals}
		on:keydown={(e) => e.key === 'Escape' && closeModals()}
		role="button"
		tabindex="0"
		aria-label="Close modal"
	>
		<div 
			class="modal-content date-modal" 
			on:click|stopPropagation
			role="document"
			tabindex="-1"
		>
			<div class="modal-header">
				<button class="back-btn" on:click={backToSubjects}>
					← Back
				</button>
				<h3 class="modal-title">Select Date Range</h3>
				<button class="close-btn" on:click={closeModals}>&times;</button>
			</div>
			
			<div class="date-range-content">
				<div class="report-info">
					<h4>Report Details:</h4>
					<p><strong>Teacher:</strong> {selectedTeacher?.FirstName} {selectedTeacher?.LastName}</p>
					<p><strong>Subject:</strong> {selectedSubject?.subject_name} {#if selectedSubject?.subject_code}({selectedSubject.subject_code}){/if}</p>
					<p><strong>Section:</strong> {selectedSubject?.SectionName}</p>
					{#if selectedSubject?.teaching_days}
						<p><strong>Days:</strong> {selectedSubject.teaching_days}</p>
					{/if}
				</div>
				
				<div class="date-inputs">
					<div class="form-group">
						<label for="startDate">Start Date:</label>
						<input 
							type="date" 
							id="startDate" 
							bind:value={startDate}
							max={endDate}
							required
						/>
					</div>
					
					<div class="form-group">
						<label for="endDate">End Date:</label>
						<input 
							type="date" 
							id="endDate" 
							bind:value={endDate}
							min={startDate}
							required
						/>
					</div>
				</div>
				
				<div class="modal-actions">
					<button class="btn btn-secondary" on:click={backToSubjects}>
						Cancel
					</button>
					<button 
						class="btn btn-primary" 
						on:click={generateReport}
						disabled={!startDate || !endDate}
					>
						📄 Generate Report
					</button>
				</div>
			</div>
		</div>
	</div>
{/if}

<style>
	.page {
		max-width: 1200px;
		margin: 0 auto;
		padding: 2rem;
	}
	
	.page-header {
		margin-bottom: 2rem;
	}
	
	.page-header h1 {
		margin: 0 0 0.5rem 0;
		color: #2c3e50;
		font-size: 2rem;
	}
	
	.subtitle {
		color: #7f8c8d;
		margin: 0;
	}
	
	.teachers-grid {
		display: grid;
		grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
		gap: 1rem;
		margin-top: 1rem;
	}
	
	.teacher-card {
		background: white;
		border: 2px solid #ecf0f1;
		border-radius: 12px;
		padding: 1.5rem;
		cursor: pointer;
		transition: all 0.2s;
		display: flex;
		align-items: center;
		gap: 1rem;
	}
	
	.teacher-card:hover {
		border-color: #3498db;
		box-shadow: 0 4px 12px rgba(52, 152, 219, 0.2);
		transform: translateY(-2px);
	}
	
	.teacher-avatar {
		width: 60px;
		height: 60px;
		border-radius: 50%;
		background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
		display: flex;
		align-items: center;
		justify-content: center;
		flex-shrink: 0;
	}
	
	.avatar-icon {
		font-size: 2rem;
	}
	
	.teacher-info {
		flex: 1;
	}
	
	.teacher-info h4 {
		margin: 0 0 0.25rem 0;
		color: #2c3e50;
		font-size: 1.1rem;
	}
	
	.teacher-id {
		color: #95a5a6;
		font-size: 0.85rem;
	}
	
	.card-arrow {
		font-size: 1.5rem;
		color: #3498db;
		opacity: 0.5;
		transition: all 0.2s;
	}
	
	.teacher-card:hover .card-arrow {
		opacity: 1;
		transform: translateX(5px);
	}
	
	.subjects-list {
		max-height: 500px;
		overflow-y: auto;
	}
	
	.subject-item {
		background: white;
		border: 2px solid #ecf0f1;
		border-radius: 8px;
		padding: 1rem 1.5rem;
		margin-bottom: 0.75rem;
		cursor: pointer;
		transition: all 0.2s;
		display: flex;
		align-items: center;
		gap: 1rem;
	}
	
	.subject-item:hover {
		border-color: #3498db;
		background: #f8f9fa;
		transform: translateX(5px);
	}
	
	.subject-icon {
		font-size: 1.5rem;
	}
	
	.subject-info {
		flex: 1;
	}
	
	.subject-info h4 {
		margin: 0 0 0.5rem 0;
		color: #2c3e50;
	}
	
	.subject-details {
		display: flex;
		gap: 0.5rem;
		flex-wrap: wrap;
	}
	
	.badge {
		background: #e8f4f8;
		color: #2980b9;
		padding: 0.25rem 0.75rem;
		border-radius: 12px;
		font-size: 0.85rem;
		font-weight: 500;
	}
	
	.days-badge {
		background: #e8f5e9;
		color: #27ae60;
	}
	
	.item-arrow {
		font-size: 1.5rem;
		color: #3498db;
		opacity: 0.5;
		transition: all 0.2s;
	}
	
	.subject-item:hover .item-arrow {
		opacity: 1;
	}
	
	.date-modal {
		max-width: 550px;
	}
	
	.date-range-content {
		padding: 1rem 0;
	}
	
	.report-info {
		background: #f8f9fa;
		padding: 1rem;
		border-radius: 8px;
		margin-bottom: 1.5rem;
	}
	
	.report-info h4 {
		margin: 0 0 0.75rem 0;
		color: #2c3e50;
	}
	
	.report-info p {
		margin: 0.5rem 0;
		color: #34495e;
	}
	
	.date-inputs {
		display: grid;
		grid-template-columns: 1fr 1fr;
		gap: 1rem;
		margin-bottom: 1.5rem;
	}
	
	.form-group {
		display: flex;
		flex-direction: column;
	}
	
	.form-group label {
		font-weight: 600;
		color: #2c3e50;
		margin-bottom: 0.5rem;
	}
	
	.form-group input[type="date"] {
		padding: 0.75rem;
		border: 2px solid #ecf0f1;
		border-radius: 8px;
		font-size: 1rem;
		transition: border-color 0.2s;
	}
	
	.form-group input[type="date"]:focus {
		outline: none;
		border-color: #3498db;
	}
	
	.modal-actions {
		display: flex;
		gap: 1rem;
		justify-content: flex-end;
		padding-top: 1rem;
		border-top: 1px solid #ecf0f1;
	}
	
	.back-btn {
		background: transparent;
		border: none;
		color: #7f8c8d;
		cursor: pointer;
		font-size: 1rem;
		padding: 0.5rem;
		transition: color 0.2s;
	}
	
	.back-btn:hover {
		color: #2c3e50;
	}
	
	.no-data {
		text-align: center;
		padding: 3rem;
		color: #95a5a6;
		grid-column: 1 / -1;
	}
	
	@media (max-width: 768px) {
		.page {
			padding: 1rem;
		}
		
		.teachers-grid {
			grid-template-columns: 1fr;
		}
		
		.date-inputs {
			grid-template-columns: 1fr;
		}
		
		.modal-actions {
			flex-direction: column;
		}
		
		.modal-actions button {
			width: 100%;
		}
	}
</style>
