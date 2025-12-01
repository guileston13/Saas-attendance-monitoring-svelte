<script>
	// Sections management page
	import { onMount } from 'svelte';
	import { browser } from '$app/environment';
	
	/** @type {import('./$types').PageData} */
	export let data;
	
	$: session = data.session;
	$: sections = data.sections || [];
	
	let showModal = false;
	let showStudentsModal = false;
	let editingSection = null;
	let selectedSection = null;
	let loading = false;
	let studentsLoading = false;
	let searchTerm = '';
	
	// Form data
	let formData = {
		sectionName: ''
	};
	
	// Section students data
	let sectionStudents = [];
	let availableStudents = [];
	let showAddStudentForm = false;
	let selectedStudentId = '';
	
	// Filter sections based on search term
	$: filteredSections = sections.filter(section => 
		section.SectionName.toLowerCase().includes(searchTerm.toLowerCase())
	);
	
	function openModal(section = null) {
		editingSection = section;
		if (section) {
			formData = {
				sectionName: section.SectionName
			};
		} else {
			formData = {
				sectionName: ''
			};
		}
		showModal = true;
	}
	
	function closeModal() {
		showModal = false;
		editingSection = null;
	}
	
	async function handleSubmit() {
		if (!browser) return;
		
		loading = true;
		
		try {
			const method = editingSection ? 'PUT' : 'POST';
			const response = await fetch('/api/sections', {
				method,
				headers: {
					'Content-Type': 'application/json'
				},
				body: JSON.stringify({
					...formData,
					...(editingSection && { sectionId: editingSection.SectionID })
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
	
	async function handleDelete(sectionId) {
		if (!browser) return;
		
		if (!confirm('Are you sure you want to delete this section?')) {
			return;
		}
		
		try {
			const response = await fetch('/api/sections', {
				method: 'DELETE',
				headers: {
					'Content-Type': 'application/json'
				},
				body: JSON.stringify({ sectionId })
			});
			
			const result = await response.json();
			
			if (response.ok) {
				window.location.reload();
			} else {
				alert(result.error || 'Failed to delete section');
			}
		} catch (error) {
			console.error('Delete error:', error);
			alert('An error occurred while deleting');
		}
	}
	
	async function viewStudents(section) {
		selectedSection = section;
		studentsLoading = true;
		showStudentsModal = true;
		
		try {
			const [studentsResponse, availableResponse] = await Promise.all([
				fetch(`/api/sections/${section.SectionID}/students`),
				fetch(`/api/sections/${section.SectionID}/students?action=available`)
			]);
			
			const studentsData = await studentsResponse.json();
			const availableData = await availableResponse.json();
			
			if (studentsResponse.ok && availableResponse.ok) {
				sectionStudents = studentsData.students || [];
				availableStudents = availableData.students || [];
			} else {
				alert('Failed to load students data');
			}
		} catch (error) {
			console.error('Load students error:', error);
			alert('An error occurred while loading students');
		} finally {
			studentsLoading = false;
		}
	}
	
	function closeStudentsModal() {
		showStudentsModal = false;
		selectedSection = null;
		sectionStudents = [];
		availableStudents = [];
		showAddStudentForm = false;
		selectedStudentId = '';
	}
	
	async function addStudentToSection() {
		if (!browser || !selectedStudentId) return;
		
		try {
			const response = await fetch(`/api/sections/${selectedSection.SectionID}/students`, {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json'
				},
				body: JSON.stringify({ studentId: selectedStudentId })
			});
			
			const result = await response.json();
			
			if (response.ok) {
				// Refresh students data
				viewStudents(selectedSection);
				showAddStudentForm = false;
				selectedStudentId = '';
			} else {
				alert(result.error || 'Failed to add student');
			}
		} catch (error) {
			console.error('Add student error:', error);
			alert('An error occurred while adding student');
		}
	}
	
	async function removeStudentFromSection(studentId) {
		if (!browser) return;
		
		if (!confirm('Remove this student from the section?')) {
			return;
		}
		
		try {
			const response = await fetch(`/api/sections/${selectedSection.SectionID}/students`, {
				method: 'DELETE',
				headers: {
					'Content-Type': 'application/json'
				},
				body: JSON.stringify({ studentId })
			});
			
			const result = await response.json();
			
			if (response.ok) {
				// Refresh students data
				viewStudents(selectedSection);
			} else {
				alert(result.error || 'Failed to remove student');
			}
		} catch (error) {
			console.error('Remove student error:', error);
			alert('An error occurred while removing student');
		}
	}
</script>

<svelte:head>
	<title>Sections - School Management System</title>
</svelte:head>

<div class="page">
	<div class="page-header">
		<h1>Sections Management</h1>
		{#if session.role === 'Admin'}
			<button class="btn btn-primary" on:click={() => openModal()}>
				Add New Section
			</button>
		{/if}
	</div>
	
	{#if data.error}
		<div class="error-message mb-2">{data.error}</div>
	{/if}
	
	<!-- Search bar -->
	<div class="card mb-2">
		<div class="form-group">
			<label for="search">Search Sections:</label>
			<input
				type="text"
				id="search"
				bind:value={searchTerm}
				placeholder="Search by section name..."
			/>
		</div>
	</div>
	
	<!-- Sections table -->
	<div class="card">
		<div class="table-container">
			<table>
				<thead>
					<tr>
						<th>Section Name</th>
						<th>Number of Students</th>
						<th>Actions</th>
					</tr>
				</thead>
				<tbody>
					{#each filteredSections as section}
						<tr>
							<td>{section.SectionName}</td>
							<td>
								<button 
									class="student-count-btn" 
									on:click={() => viewStudents(section)}
									title="Click to view/manage students"
								>
									{section.StudentCount || 0} students
								</button>
							</td>
							<td>
								<div class="actions">
									{#if session.role === 'Admin'}
										<button 
											class="btn btn-small btn-secondary"
											on:click={() => openModal(section)}
										>
											Edit
										</button>
										<button 
											class="btn btn-small btn-danger"
											on:click={() => handleDelete(section.SectionID)}
										>
											Delete
										</button>
									{/if}
								</div>
							</td>
						</tr>
					{:else}
						<tr>
							<td colspan="3" class="text-center">No sections found</td>
						</tr>
					{/each}
				</tbody>
			</table>
		</div>
	</div>
</div>

<!-- Modal for add/edit section -->
{#if showModal}
	<div class="modal-overlay" on:click={closeModal}>
		<div class="modal-content" on:click|stopPropagation>
			<div class="modal-header">
				<h3 class="modal-title">
					{editingSection ? 'Edit Section' : 'Add New Section'}
				</h3>
				<button class="close-btn" on:click={closeModal}>&times;</button>
			</div>
			
			<form on:submit|preventDefault={handleSubmit}>
				<div class="form-group">
					<label for="sectionName">Section Name:</label>
					<input
						type="text"
						id="sectionName"
						bind:value={formData.sectionName}
						required
						disabled={loading}
						placeholder="e.g., Grade 10 - Section A"
					/>
				</div>
				
				<div class="flex gap-1 mt-2">
					<button type="submit" class="btn btn-primary" disabled={loading}>
						{#if loading}
							<span class="spinner"></span>
						{/if}
						{editingSection ? 'Update' : 'Create'} Section
					</button>
					<button type="button" class="btn btn-secondary" on:click={closeModal}>
						Cancel
					</button>
				</div>
			</form>
		</div>
	</div>
{/if}

<!-- Modal for viewing/managing section students -->
{#if showStudentsModal}
	<div class="modal-overlay" on:click={closeStudentsModal}>
		<div class="modal-content large-modal" on:click|stopPropagation>
			<div class="modal-header">
				<h3 class="modal-title">
					Students in {selectedSection?.SectionName}
				</h3>
				<button class="close-btn" on:click={closeStudentsModal}>&times;</button>
			</div>
			
			{#if studentsLoading}
				<div class="loading">
					<span class="spinner"></span>
					Loading students...
				</div>
			{:else}
				<div class="students-section">
					<div class="section-header">
						<h4>Enrolled Students ({sectionStudents.length})</h4>
						{#if session.role === 'Admin' || session.role === 'Teacher'}
							<button 
								class="btn btn-small btn-primary"
								on:click={() => showAddStudentForm = !showAddStudentForm}
							>
								{showAddStudentForm ? 'Cancel' : 'Add Student'}
							</button>
						{/if}
					</div>
					
					{#if showAddStudentForm}
						<div class="add-student-form">
							<div class="form-group">
								<label for="studentSelect">Select Student:</label>
								<select
									id="studentSelect"
									bind:value={selectedStudentId}
									required
								>
									<option value="">Choose a student...</option>
									{#each availableStudents as student}
										<option value={student.StudentID}>
											{student.StudentID} - {student.FirstName} {student.LastName}
										</option>
									{/each}
								</select>
							</div>
							<button 
								class="btn btn-success btn-small" 
								on:click={addStudentToSection}
								disabled={!selectedStudentId}
							>
								Add Student
							</button>
						</div>
					{/if}
					
					<div class="table-container">
						<table>
							<thead>
								<tr>
									<th>Student ID</th>
									<th>Name</th>
									<th>Year Level</th>
									{#if session.role === 'Admin' || session.role === 'Teacher'}
										<th>Actions</th>
									{/if}
								</tr>
							</thead>
							<tbody>
								{#each sectionStudents as student}
									<tr>
										<td>{student.StudentID}</td>
										<td>
											{student.FirstName} 
											{student.MiddleName ? student.MiddleName + ' ' : ''}
											{student.LastName}
										</td>
										<td>{student.YearLevel}</td>
										{#if session.role === 'Admin' || session.role === 'Teacher'}
											<td>
												<button 
													class="btn btn-small btn-danger"
													on:click={() => removeStudentFromSection(student.StudentID)}
												>
													Remove
												</button>
											</td>
										{/if}
									</tr>
								{:else}
									<tr>
										<td colspan={session.role === 'Admin' || session.role === 'Teacher' ? '4' : '3'} class="text-center">
											No students enrolled
										</td>
									</tr>
								{/each}
							</tbody>
						</table>
					</div>
				</div>
			{/if}
		</div>
	</div>
{/if}

<style>
	.page {
		max-width: 1200px;
		margin: 0 auto;
	}
	
	.page-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		margin-bottom: 2rem;
	}
	
	.page-header h1 {
		margin: 0;
		color: #2c3e50;
	}
	
	.student-count-btn {
		background: #3498db;
		color: white;
		border: none;
		padding: 0.25rem 0.5rem;
		border-radius: 4px;
		cursor: pointer;
		font-size: 0.9rem;
		transition: background-color 0.2s;
	}
	
	.student-count-btn:hover {
		background: #2980b9;
	}
	
	.large-modal {
		max-width: 800px;
		width: 90%;
	}
	
	.students-section {
		margin-top: 1rem;
	}
	
	.section-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		margin-bottom: 1rem;
		padding-bottom: 0.5rem;
		border-bottom: 1px solid #ecf0f1;
	}
	
	.section-header h4 {
		margin: 0;
		color: #2c3e50;
	}
	
	.add-student-form {
		background: #f8f9fa;
		padding: 1rem;
		border-radius: 4px;
		margin-bottom: 1rem;
	}
	
	@media (max-width: 768px) {
		.page-header {
			flex-direction: column;
			gap: 1rem;
			align-items: stretch;
		}
		
		.large-modal {
			width: 95%;
		}
		
		.section-header {
			flex-direction: column;
			gap: 0.5rem;
			align-items: stretch;
		}
	}
</style>