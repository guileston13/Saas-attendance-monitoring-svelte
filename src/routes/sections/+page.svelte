<script>
	import { page } from '$app/stores';
	import { goto, invalidateAll } from '$app/navigation';
	import { enhance } from '$app/forms';
	
	/** @type {import('./$types').PageData} */
	export let data;
	
	$: sections = data.sections || [];
	$: selectedSection = data.selectedSection;
	$: sectionSubjects = data.sectionSubjects || [];
	$: subjects = data.subjects || [];
	$: teachers = data.teachers || [];
	$: statuses = data.statuses || [];
	$: isAdmin = data.session?.role === 'Admin';
	
	let showCreateModal = false;
	let showSubjectModal = false;
	let showStudentModal = false;
	let editingSection = null;
	let selectedSubject = null;
	let loading = false;
	
	// Student enrollment modal state
	let enrolledStudents = [];
	let availableStudents = [];
	let searchQuery = '';
	let loadingStudents = false;
	let selectedStudents = new Set();
	let originalAvailableStudents = [];
	
	// Additional student enrollment variables
	let studentSearchTerm = '';
	let selectedCount = 0;
	let enrolling = false;
	
	// Update selected count when students are selected/deselected
	function updateSelectionCount() {
		selectedCount = filteredAvailableStudents.filter(student => student.selected).length;
	}
	
	// Reactive statements for filtering
	$: filteredAvailableStudents = availableStudents.filter(student => {
		const searchTerm = studentSearchTerm.toLowerCase();
		const fullName = `${student.FirstName} ${student.LastName}`.toLowerCase();
		const studentId = student.StudentID.toString();
		return fullName.includes(searchTerm) || studentId.includes(searchTerm);
	});
	
	// Modal functions
	function openCreateModal() {
		showCreateModal = true;
		editingSection = null;
	}
	
	function editSection(section) {
		editingSection = { ...section };
		showCreateModal = true;
	}
	
	function closeCreateModal() {
		showCreateModal = false;
		editingSection = null;
	}
	
	function openSubjectModal() {
		showSubjectModal = true;
	}
	
	function closeSubjectModal() {
		showSubjectModal = false;
	}
	
	function openStudentModal(subject) {
		selectedSubject = subject;
		showStudentModal = true;
		
		// Load student data when modal opens
		setTimeout(() => {
			loadEnrolledStudents();
			loadAvailableStudents();
		}, 100);
	}
	
	function closeStudentModal() {
		showStudentModal = false;
		selectedSubject = null;
		enrolledStudents = [];
		availableStudents = [];
		searchQuery = '';
		selectedStudents.clear();
	}
	
	// Navigation
	function selectSection(sectionId) {
		goto(`/sections?section=${sectionId}`);
	}
	
	function goBack() {
		goto('/sections');
	}
	
	// Utility functions
	function formatDate(dateString) {
		return new Date(dateString).toLocaleDateString();
	}
	
	function formatTime(timeString) {
		if (!timeString) return 'TBD';
		try {
			// Handle time strings in HH:MM:SS format
			const [hours, minutes] = timeString.split(':');
			const hour = parseInt(hours);
			const ampm = hour >= 12 ? 'PM' : 'AM';
			const displayHour = hour % 12 || 12;
			return `${displayHour}:${minutes} ${ampm}`;
		} catch (error) {
			return timeString; // Return original if parsing fails
		}
	}
	
	function getStatusColor(statusName) {
		switch (statusName?.toLowerCase()) {
			case 'active': return '#27ae60';
			case 'inactive': return '#95a5a6';
			case 'suspended': return '#e74c3c';
			default: return '#3498db';
		}
	}
	
	// Student enrollment functions
	async function loadEnrolledStudents() {
		if (!selectedSubject || !selectedSection) return;
		
		loadingStudents = true;
		try {
			const response = await fetch(`/api/sections/${selectedSection.SectionID}/students/${selectedSubject.SubjectID}`, {
				credentials: 'include'
			});
			if (response.ok) {
				const data = await response.json();
				enrolledStudents = data.students || [];
				console.log('Loaded enrolled students:', enrolledStudents);
			} else {
				const errorData = await response.json();
				console.error('Error response:', errorData);
				enrolledStudents = [];
			}
		} catch (error) {
			console.error('Error loading enrolled students:', error);
			enrolledStudents = [];
		} finally {
			loadingStudents = false;
		}
	}

	async function loadAvailableStudents() {
		if (!selectedSubject || !selectedSection) return;
		
		try {
			const response = await fetch(`/api/sections/${selectedSection.SectionID}/available-students?subjectId=${selectedSubject.SubjectID}`, {
				credentials: 'include'
			});
			if (response.ok) {
				const data = await response.json();
				originalAvailableStudents = data.students || [];
				availableStudents = originalAvailableStudents.map(student => ({ ...student, selected: false }));
				console.log('Loaded available students:', availableStudents);
			} else {
				const errorData = await response.json();
				console.error('Error response:', errorData);
				originalAvailableStudents = [];
				availableStudents = [];
			}
		} catch (error) {
			console.error('Error loading available students:', error);
			originalAvailableStudents = [];
			availableStudents = [];
		}
	}
	
	function toggleStudentSelection(student) {
		student.selected = !student.selected;
		selectedCount = filteredAvailableStudents.filter(s => s.selected).length;
		// Force reactivity
		availableStudents = [...availableStudents];
	}

	async function enrollSelectedStudents() {
		if (!selectedSubject || !selectedSection || selectedCount === 0) return;
		
		enrolling = true;
		try {
			const selectedStudentIds = filteredAvailableStudents
				.filter(student => student.selected)
				.map(student => student.StudentID);
			
			console.log('Enrolling students:', selectedStudentIds);
			
			const response = await fetch(`/api/sections/${selectedSection.SectionID}/enroll-students`, {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json'
				},
				credentials: 'include',
				body: JSON.stringify({
					subjectId: selectedSubject.SubjectID,
					studentIds: selectedStudentIds
				})
			});
			
			if (response.ok) {
				const result = await response.json();
				console.log('Enrollment result:', result);
				
				// Refresh the data
				await Promise.all([
					loadEnrolledStudents(),
					loadAvailableStudents()
				]);
				
				// Reset selection
				selectedCount = 0;
				console.log(`Successfully enrolled ${result.enrolled} students`);
				
				// Show success message
				alert(`Successfully enrolled ${result.enrolled} students!`);
			} else {
				const errorData = await response.json();
				console.error('Enrollment error:', errorData);
				alert(`Error enrolling students: ${errorData.error}`);
			}
		} catch (error) {
			console.error('Error enrolling students:', error);
			alert('Error enrolling students. Please try again.');
		} finally {
			enrolling = false;
		}
	}
	
	async function removeStudent(studentId) {
		if (!selectedSubject || !selectedSection) return;
		
		if (!confirm('Remove this student from the subject?')) return;
		
		loadingStudents = true;
		try {
			const response = await fetch(`/api/sections/${selectedSection.SectionID}/students/${selectedSubject.SubjectID}/${studentId}`, {
				method: 'DELETE',
				credentials: 'include'
			});
			
			if (response.ok) {
				console.log('Student removed successfully');
				// Refresh the data
				await Promise.all([
					loadEnrolledStudents(),
					loadAvailableStudents()
				]);
			} else {
				const errorData = await response.json();
				console.error('Remove error:', errorData);
				alert(`Error removing student: ${errorData.error}`);
			}
		} catch (error) {
			console.error('Error removing student:', error);
			alert('Error removing student. Please try again.');
		} finally {
			loadingStudents = false;
		}
	}
	
	// Edit subject modal state and functions
	let showEditSubjectModal = false;
	let editSubject = {};

	function openEditSubjectModal(subject) {
		editSubject = { ...subject };
		showEditSubjectModal = true;
	}

	function closeEditSubjectModal() {
		showEditSubjectModal = false;
		editSubject = {};
	}

	async function submitEditSubject() {
		if (!selectedSection || !editSubject.SubjectID) return;
		try {
			const response = await fetch(`/api/sections/${selectedSection.SectionID}/subjects/${editSubject.SubjectID}`, {
				method: 'PUT',
				headers: { 'Content-Type': 'application/json' },
				credentials: 'include',
				body: JSON.stringify({
					Room: editSubject.Room,
					StartTime: editSubject.StartTime,
					EndTime: editSubject.EndTime,
					TeacherID: editSubject.TeacherID
				})
			});
			if (response.ok) {
				await invalidateAll();
				closeEditSubjectModal();
			} else {
				const errorData = await response.json();
				alert('Error updating subject: ' + (errorData.error || 'Unknown error'));
			}
		} catch (error) {
			alert('Error updating subject: ' + error.message);
		}
	}
</script>

<svelte:head>
	<title>
		{selectedSection ? `${selectedSection.SectionName} - Sections` : 'Sections'} - School Management System
	</title>
</svelte:head>

<div class="sections-page">
	{#if !selectedSection}
		<!-- Sections List View -->
		<div class="page-header">
			<div>
				<h1>Sections</h1>
				<p class="subtitle">Manage class sections, subjects, and student enrollments</p>
			</div>
			{#if isAdmin}
				<button class="btn btn-primary" on:click={openCreateModal}>
					Create Section
				</button>
			{/if}
		</div>
		
		{#if data.error}
			<div class="error-message mb-2">{data.error}</div>
		{/if}
		
		<div class="sections-grid">
			{#each sections as section}
				<div class="section-card" on:click={() => selectSection(section.SectionID)}>
					<div class="card-header">
						<h3>{section.SectionName}</h3>
						<span 
							class="status-badge" 
							style="background-color: {getStatusColor(section.StatusName)}"
						>
							{section.StatusName || 'Active'}
						</span>
					</div>
					<div class="card-stats">
						<div class="stat">
							<span class="stat-number">{section.SubjectCount || 0}</span>
							<span class="stat-label">Subjects</span>
						</div>
						<div class="stat">
							<span class="stat-number">{section.TotalStudents || 0}</span>
							<span class="stat-label">Students</span>
						</div>
					</div>
					<div class="card-footer">
						<small>Created: {formatDate(section.CreatedAt)}</small>
						{#if isAdmin}
							<div class="card-actions" on:click|stopPropagation>
								<button 
									class="btn btn-small btn-secondary" 
									on:click={() => editSection(section)}
								>
									Edit
								</button>
							</div>
						{/if}
					</div>
				</div>
			{:else}
				<div class="empty-state">
					<h3>No sections found</h3>
					<p>Get started by creating your first section.</p>
					{#if isAdmin}
						<button class="btn btn-primary" on:click={openCreateModal}>
							Create Section
						</button>
					{/if}
				</div>
			{/each}
		</div>
		
	{:else}
		<!-- Section Detail View -->
		<div class="page-header">
			<div>
				<button class="btn btn-secondary back-btn" on:click={goBack}>
					← Back to Sections
				</button>
				<h1>{selectedSection.SectionName}</h1>
				<p class="subtitle">Manage subjects and student enrollments</p>
			</div>
			{#if isAdmin}
				<button class="btn btn-primary" on:click={openSubjectModal}>
					Add Subject
				</button>
			{/if}
		</div>
		
		<div class="card">
			<div class="card-header">
				<h3 class="card-title">Subjects in {selectedSection.SectionName}</h3>
			</div>
			
			<div class="table-container">
				<table>
					<thead>
						<tr>
							<th>Subject Name</th>
							<th>Students Enrolled</th>
							<th>Teacher</th>
							<th>Schedule</th>
							<th>Room</th>
							{#if isAdmin}
								<th></th>
							{/if}
						</tr>
					</thead>
					<tbody>
						{#each sectionSubjects as subject}
							<tr>
								<td>
									<div class="subject-info">
										<strong>{subject.SubjectName}</strong>
										<small class="subject-code">{subject.SubjectCode}</small>
									</div>
								</td>
								<td>
									<button 
										class="student-count-btn" 
										on:click={() => openStudentModal(subject)}
									>
										{subject.EnrolledStudents} students
									</button>
								</td>
								<td>{subject.TeacherName || 'No teacher assigned'}</td>
								<td>
									<div class="schedule-info">
										<div class="time-display">
											{subject.StartTime ? formatTime(subject.StartTime) : 'TBD'}
											<span class="time-separator">-</span>
											{subject.EndTime ? formatTime(subject.EndTime) : 'TBD'}
										</div>
									</div>
								</td>
								<td>{subject.Room || 'Not yet assigned Room'}</td>
								{#if isAdmin}
									<td>
										<div class="actions">
											<button 
												class="btn btn-small btn-primary"
												on:click={() => openEditSubjectModal(subject)}
											>
												Edit
											</button>
											<button 
												class="btn btn-small btn-danger"
												on:click={() => {
													if (confirm('Remove this subject from the section?')) {
														// Handle remove subject
														console.log('Remove subject', subject.SubjectID);
													}
												}}
											>
												Remove
											</button>
										</div>
									</td>
								{/if}
							</tr>
						{:else}
							<tr>
								<td colspan="{isAdmin ? 6 : 5}" class="text-center">
									No subjects assigned to this section
								</td>
							</tr>
						{/each}
					</tbody>
				</table>
			</div>
		</div>
	{/if}

<!-- Edit Subject Modal -->
{#if showEditSubjectModal}
	<div class="modal-overlay" on:click={closeEditSubjectModal}>
		<div class="modal-content" on:click|stopPropagation>
			<div class="modal-header">
				<h3>Edit Subject Assignment</h3>
				<button class="modal-close" on:click={closeEditSubjectModal}>&times;</button>
			</div>
			<form on:submit|preventDefault={submitEditSubject}>
				<div class="form-group">
					<label for="editRoom">Room:</label>
					<input id="editRoom" type="text" bind:value={editSubject.Room} placeholder="Room name or number" />
				</div>
				<div class="form-group">
					<label for="editStartTime">Start Time:</label>
					<input id="editStartTime" type="time" bind:value={editSubject.StartTime} />
				</div>
				<div class="form-group">
					<label for="editEndTime">End Time:</label>
					<input id="editEndTime" type="time" bind:value={editSubject.EndTime} />
				</div>
				<div class="form-group">
					<label for="editTeacher">Teacher:</label>
					<select id="editTeacher" bind:value={editSubject.TeacherID}>
						<option value="">No teacher assigned</option>
						{#each teachers as teacher}
							<option value={teacher.TeacherID}>{teacher.FirstName} {teacher.LastName}</option>
						{/each}
					</select>
				</div>
				<div class="modal-actions">
					<button type="button" class="btn btn-secondary" on:click={closeEditSubjectModal}>Cancel</button>
					<button type="submit" class="btn btn-primary">Save Changes</button>
				</div>
			</form>
		</div>
	</div>
{/if}

<!-- Create/Edit Section Modal -->
{#if showCreateModal}
	<div class="modal-overlay" on:click={closeCreateModal}>
		<div class="modal-content" on:click|stopPropagation>
			<div class="modal-header">
				<h3>{editingSection ? 'Edit Section' : 'Create New Section'}</h3>
				<button class="modal-close" on:click={closeCreateModal}>&times;</button>
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
						{loading ? 'Saving...' : (editingSection ? 'Update Section' : 'Create Section')}
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
				<button class="modal-close" on:click={closeSubjectModal}>&times;</button>
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
					<button type="submit" class="btn btn-primary">
						Add Subject
					</button>
				</div>
			</form>
		</div>
	</div>
{/if}

<!-- Student Enrollment Modal -->
{#if showStudentModal}
	<div class="modal-overlay" on:click={closeStudentModal}>
		<div class="modal-content" on:click|stopPropagation>
			<div class="modal-header">
				<h3>Enroll Students - {selectedSection?.SectionName || ''}</h3>
				<button class="close-btn" on:click={closeStudentModal}>&times;</button>
			</div>
			
			<div class="modal-body">
				<!-- Search Box -->
				<div class="search-container">
					<input 
						type="text" 
						placeholder="Search students by name or ID..." 
						bind:value={studentSearchTerm}
						class="search-input"
					>
					<span class="search-icon">🔍</span>
				</div>
				
				<!-- Student Lists -->
				<div class="student-lists">
					<!-- Available Students -->
					<div class="student-list">
						<h4>Available Students ({filteredAvailableStudents.length})</h4>
						<div class="student-items">
							{#each filteredAvailableStudents as student}
								<label class="student-item">
									<input 
										type="checkbox" 
										bind:checked={student.selected}
										on:change={updateSelectionCount}
									>
									<div class="student-info">
										<span class="student-name">{student.FirstName} {student.LastName}</span>
										<span class="student-id">ID: {student.StudentID}</span>
										{#if student.YearLevel}
											<span class="student-year">Year {student.YearLevel}</span>
										{/if}
									</div>
								</label>
							{:else}
								<p class="no-students">No available students found.</p>
							{/each}
						</div>
					</div>
					
					<!-- Enrolled Students -->
					<div class="student-list">
						<h4>Enrolled Students ({enrolledStudents.length})</h4>
						<div class="student-items">
							{#each enrolledStudents as student}
								<div class="student-item enrolled">
									<div class="student-info">
										<span class="student-name">{student.FirstName} {student.LastName}</span>
										<span class="student-id">ID: {student.StudentID}</span>
										{#if student.YearLevel}
											<span class="student-year">Year {student.YearLevel}</span>
										{/if}
									</div>
									{#if isAdmin}
										<button 
											class="remove-btn" 
											on:click={() => removeStudent(student.StudentID)}
											title="Remove student"
											disabled={loadingStudents}
										>
											✕
										</button>
									{/if}
								</div>
							{:else}
								<p class="no-students">No students enrolled yet.</p>
							{/each}
						</div>
					</div>
				</div>
				
				<!-- Selection Summary -->
				{#if selectedCount > 0}
					<div class="selection-summary">
						<span>{selectedCount} student(s) selected for enrollment</span>
					</div>
				{/if}
			</div>
			
			<div class="modal-actions">
				<button class="btn-secondary" on:click={closeStudentModal}>Cancel</button>
				<button 
					class="btn-primary" 
					on:click={enrollSelectedStudents}
					disabled={selectedCount === 0 || enrolling}
				>
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

<style>
	.sections-page {
		max-width: 1200px;
		margin: 0 auto;
	}
	
	.page-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		margin-bottom: 2rem;
		flex-wrap: wrap;
		gap: 1rem;
	}
	
	.back-btn {
		margin-bottom: 0.5rem;
	}
	
	.subtitle {
		color: #7f8c8d;
		margin: 0.5rem 0 0 0;
		font-size: 1.1rem;
	}
	
	.sections-grid {
		display: grid;
		grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
		gap: 1.5rem;
	}
	
	.section-card {
		background: white;
		border-radius: 8px;
		padding: 1.5rem;
		box-shadow: 0 2px 10px rgba(0,0,0,0.1);
		cursor: pointer;
		transition: transform 0.2s, box-shadow 0.2s;
	}
	
	.section-card:hover {
		transform: translateY(-2px);
		box-shadow: 0 4px 20px rgba(0,0,0,0.15);
	}
	
	.card-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		margin-bottom: 1rem;
	}
	
	.card-header h3 {
		margin: 0;
		color: #2c3e50;
	}
	
	.card-stats {
		display: flex;
		gap: 2rem;
		margin-bottom: 1rem;
	}
	
	.stat {
		text-align: center;
	}
	
	.stat-number {
		display: block;
		font-size: 1.5rem;
		font-weight: bold;
		color: #3498db;
	}
	
	.stat-label {
		font-size: 0.9rem;
		color: #7f8c8d;
	}
	
	.card-footer {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding-top: 1rem;
		border-top: 1px solid #ecf0f1;
		font-size: 0.9rem;
		color: #7f8c8d;
	}
	
	.card-actions {
		display: flex;
		gap: 0.5rem;
	}
	
	.status-badge {
		padding: 0.2rem 0.6rem;
		border-radius: 12px;
		font-size: 0.8rem;
		font-weight: bold;
		color: white;
	}
	
	.subject-info {
		display: flex;
		flex-direction: column;
	}
	
	.subject-code {
		color: #7f8c8d;
		font-size: 0.8rem;
	}
	
	.student-count-btn {
		background: none;
		border: none;
		color: #3498db;
		text-decoration: underline;
		cursor: pointer;
		font-size: inherit;
	}
	
	.student-count-btn:hover {
		color: #2980b9;
	}
	
	.actions {
		display: flex;
		gap: 0.5rem;
		flex-wrap: wrap;
	}
	
	.empty-state {
		grid-column: 1 / -1;
		text-align: center;
		padding: 3rem;
		color: #7f8c8d;
	}
	
	.empty-state h3 {
		margin-bottom: 0.5rem;
		color: #2c3e50;
	}
	
	/* Modal Styles */
	.modal-overlay {
		position: fixed;
		top: 0;
		left: 0;
		width: 100%;
		height: 100%;
		background: rgba(0, 0, 0, 0.5);
		display: flex;
		justify-content: center;
		align-items: center;
		z-index: 1000;
	}
	
	.modal-content {
		background: white;
		border-radius: 8px;
		width: 90%;
		max-width: 800px;
		max-height: 80vh;
		overflow: hidden;
		box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
	}
	
	.modal-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: 1.5rem;
		border-bottom: 1px solid #ecf0f1;
		background: #f8f9fa;
	}
	
	.modal-header h3 {
		margin: 0;
		color: #2c3e50;
		font-size: 1.25rem;
	}
	
	.close-btn {
		background: none;
		border: none;
		font-size: 1.5rem;
		cursor: pointer;
		color: #7f8c8d;
		padding: 0;
		width: 30px;
		height: 30px;
		display: flex;
		align-items: center;
		justify-content: center;
		border-radius: 50%;
		transition: background-color 0.2s;
	}
	
	.close-btn:hover {
		background: #ecf0f1;
		color: #2c3e50;
	}
	
	.modal-body {
		padding: 1.5rem;
		max-height: 60vh;
		overflow-y: auto;
	}
	
	.search-container {
		position: relative;
		margin-bottom: 1.5rem;
	}
	
	.search-input {
		width: 100%;
		padding: 0.75rem 2.5rem 0.75rem 1rem;
		border: 2px solid #ecf0f1;
		border-radius: 6px;
		font-size: 1rem;
		transition: border-color 0.2s;
	}
	
	.search-input:focus {
		outline: none;
		border-color: #3498db;
	}
	
	.search-icon {
		position: absolute;
		right: 0.75rem;
		top: 50%;
		transform: translateY(-50%);
		color: #7f8c8d;
		font-size: 1.2rem;
	}
	
	.student-lists {
		display: grid;
		grid-template-columns: 1fr 1fr;
		gap: 2rem;
		margin-bottom: 1rem;
	}
	
	.student-list h4 {
		margin: 0 0 1rem 0;
		color: #2c3e50;
		font-size: 1.1rem;
		border-bottom: 2px solid #ecf0f1;
		padding-bottom: 0.5rem;
	}
	
	.student-items {
		max-height: 300px;
		overflow-y: auto;
		border: 1px solid #ecf0f1;
		border-radius: 6px;
	}
	
	.student-item {
		display: flex;
		align-items: center;
		padding: 0.75rem 1rem;
		border-bottom: 1px solid #f8f9fa;
		transition: background-color 0.2s;
	}
	
	.student-item:last-child {
		border-bottom: none;
	}
	
	.student-item:hover {
		background: #f8f9fa;
	}
	
	.student-item input[type="checkbox"] {
		margin-right: 0.75rem;
		transform: scale(1.2);
	}
	
	.student-info {
		flex: 1;
		display: flex;
		flex-direction: column;
	}
	
	.student-name {
		font-weight: 500;
		color: #2c3e50;
		margin-bottom: 0.25rem;
	}
	
	.student-id {
		font-size: 0.85rem;
		color: #7f8c8d;
	}
	
	.student-year {
		font-size: 0.8rem;
		color: #95a5a6;
		font-style: italic;
	}
	
	.no-students {
		text-align: center;
		color: #7f8c8d;
		font-style: italic;
		padding: 2rem;
		margin: 0;
	}
	
	.student-item.enrolled {
		background: #e8f5e8;
		border-left: 4px solid #27ae60;
	}
	
	.remove-btn {
		background: #e74c3c;
		color: white;
		border: none;
		border-radius: 50%;
		width: 24px;
		height: 24px;
		display: flex;
		align-items: center;
		justify-content: center;
		cursor: pointer;
		font-size: 0.8rem;
		transition: background-color 0.2s;
	}
	
	.remove-btn:hover {
		background: #c0392b;
	}
	
	.selection-summary {
		background: #ecf0f1;
		padding: 0.75rem 1rem;
		border-radius: 6px;
		margin-top: 1rem;
		text-align: center;
		font-weight: 500;
		color: #2c3e50;
	}
	
	.modal-actions {
		display: flex;
		justify-content: flex-end;
		gap: 1rem;
		padding: 1.5rem;
		border-top: 1px solid #ecf0f1;
		background: #f8f9fa;
	}
	
	.btn-primary {
		background: #3498db;
		color: white;
		border: none;
		padding: 0.75rem 1.5rem;
		border-radius: 6px;
		font-size: 1rem;
		font-weight: 500;
		cursor: pointer;
		transition: background-color 0.2s;
	}
	
	.btn-primary:hover:not(:disabled) {
		background: #2980b9;
	}
	
	.btn-primary:disabled {
		background: #bdc3c7;
		cursor: not-allowed;
	}
	
	.btn-secondary {
		background: #ecf0f1;
		color: #2c3e50;
		border: 1px solid #bdc3c7;
		padding: 0.75rem 1.5rem;
		border-radius: 6px;
		font-size: 1rem;
		font-weight: 500;
		cursor: pointer;
		transition: background-color 0.2s;
	}
	
	.btn-secondary:hover {
		background: #d5dbdb;
	}
	
	@media (max-width: 768px) {
		.sections-grid {
			grid-template-columns: 1fr;
		}
		
		.page-header {
			flex-direction: column;
			align-items: flex-start;
		}
		
		.card-stats {
			flex-direction: column;
			gap: 1rem;
		}
		
		.modal-content {
			width: 95%;
			margin: 1rem;
		}
		
		.modal-actions {
			flex-direction: column;
		}
	}
</style>