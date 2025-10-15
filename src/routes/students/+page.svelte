<script>
	// Students management page
	import { onMount } from 'svelte';
	import { browser } from '$app/environment';
	
	/** @type {import('./$types').PageData} */
	export let data;
	
	$: session = data.session;
	$: students = data.students || [];
	$: statusList = data.statusList || [];
	
	let showModal = false;
	let editingStudent = null;
	let loading = false;
	let searchTerm = '';
	
	// Form data
	let formData = {
		studentId: '',
		firstName: '',
		lastName: '',
		middleName: '',
		statusId: '',
		yearLevel: ''
	};
	
	const yearLevels = [
		'Grade 7', 'Grade 8', 'Grade 9', 'Grade 10', 'Grade 11', 'Grade 12'
	];
	
	// Filter students based on search term
	$: filteredStudents = students.filter(student => 
		student.StudentID.toLowerCase().includes(searchTerm.toLowerCase()) ||
		student.FirstName.toLowerCase().includes(searchTerm.toLowerCase()) ||
		student.LastName.toLowerCase().includes(searchTerm.toLowerCase()) ||
		student.YearLevel.toLowerCase().includes(searchTerm.toLowerCase())
	);
	
	function openModal(student = null) {
		editingStudent = student;
		if (student) {
			formData = {
				studentId: student.StudentID,
				firstName: student.FirstName,
				lastName: student.LastName,
				middleName: student.MiddleName || '',
				statusId: student.StatusID.toString(),
				yearLevel: student.YearLevel
			};
		} else {
			formData = {
				studentId: '',
				firstName: '',
				lastName: '',
				middleName: '',
				statusId: '1',
				yearLevel: ''
			};
		}
		showModal = true;
	}
	
	function closeModal() {
		showModal = false;
		editingStudent = null;
	}
	
	async function handleSubmit() {
		if (!browser) return;
		
		loading = true;
		
		try {
			const method = editingStudent ? 'PUT' : 'POST';
			const response = await fetch('/api/students', {
				method,
				headers: {
					'Content-Type': 'application/json'
				},
				body: JSON.stringify({
					...formData,
					statusId: parseInt(formData.statusId)
				})
			});
			
			const result = await response.json();
			
			if (response.ok) {
				// Reload the page to refresh data
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
	
	async function handleDelete(studentId) {
		if (!browser) return;
		
		if (!confirm('Are you sure you want to delete this student?')) {
			return;
		}
		
		try {
			const response = await fetch('/api/students', {
				method: 'DELETE',
				headers: {
					'Content-Type': 'application/json'
				},
				body: JSON.stringify({ studentId })
			});
			
			const result = await response.json();
			
			if (response.ok) {
				window.location.reload();
			} else {
				alert(result.error || 'Failed to delete student');
			}
		} catch (error) {
			console.error('Delete error:', error);
			alert('An error occurred while deleting');
		}
	}
</script>

<svelte:head>
	<title>Students - School Management System</title>
</svelte:head>

<div class="page">
	<div class="page-header">
		<h1>Students Management</h1>
		{#if session.role === 'Admin'}
			<button class="btn btn-primary" on:click={() => openModal()}>
				Add New Student
			</button>
		{/if}
	</div>
	
	{#if data.error}
		<div class="error-message mb-2">{data.error}</div>
	{/if}
	
	<!-- Search bar -->
	<div class="card mb-2">
		<div class="form-group">
			<label for="search">Search Students:</label>
			<input
				type="text"
				id="search"
				bind:value={searchTerm}
				placeholder="Search by ID, name, or year level..."
			/>
		</div>
	</div>
	
	<!-- Students table -->
	<div class="card">
		<div class="table-container">
			<table>
				<thead>
					<tr>
						<th>Student ID</th>
						<th>Name</th>
						<th>Year Level</th>
						<th>Status</th>
						{#if session.role === 'Admin'}
							<th>Actions</th>
						{/if}
					</tr>
				</thead>
				<tbody>
					{#each filteredStudents as student}
						<tr>
							<td>{student.StudentID}</td>
							<td>
								{student.FirstName} 
								{student.MiddleName ? student.MiddleName + ' ' : ''}
								{student.LastName}
							</td>
							<td>{student.YearLevel}</td>
							<td>{student.StatusName}</td>
							{#if session.role === 'Admin'}
								<td>
									<div class="actions">
										<button 
											class="btn btn-small btn-secondary"
											on:click={() => openModal(student)}
										>
											Edit
										</button>
										<button 
											class="btn btn-small btn-danger"
											on:click={() => handleDelete(student.StudentID)}
										>
											Delete
										</button>
									</div>
								</td>
							{/if}
						</tr>
					{:else}
						<tr>
							<td colspan={session.role === 'Admin' ? '5' : '4'} class="text-center">
								No students found
							</td>
						</tr>
					{/each}
				</tbody>
			</table>
		</div>
	</div>
</div>

<!-- Modal for add/edit student -->
{#if showModal}
	<div class="modal-overlay" on:click={closeModal}>
		<div class="modal-content" on:click|stopPropagation>
			<div class="modal-header">
				<h3 class="modal-title">
					{editingStudent ? 'Edit Student' : 'Add New Student'}
				</h3>
				<button class="close-btn" on:click={closeModal}>&times;</button>
			</div>
			
			<form on:submit|preventDefault={handleSubmit}>
				<div class="form-group">
					<label for="studentId">Student ID:</label>
					<input
						type="text"
						id="studentId"
						bind:value={formData.studentId}
						required
						disabled={!!editingStudent || loading}
						placeholder="e.g., 2024001"
					/>
				</div>
				
				<div class="form-group">
					<label for="firstName">First Name:</label>
					<input
						type="text"
						id="firstName"
						bind:value={formData.firstName}
						required
						disabled={loading}
					/>
				</div>
				
				<div class="form-group">
					<label for="lastName">Last Name:</label>
					<input
						type="text"
						id="lastName"
						bind:value={formData.lastName}
						required
						disabled={loading}
					/>
				</div>
				
				<div class="form-group">
					<label for="middleName">Middle Name:</label>
					<input
						type="text"
						id="middleName"
						bind:value={formData.middleName}
						disabled={loading}
					/>
				</div>
				
				<div class="form-group">
					<label for="yearLevel">Year Level:</label>
					<select
						id="yearLevel"
						bind:value={formData.yearLevel}
						required
						disabled={loading}
					>
						<option value="">Select Year Level</option>
						{#each yearLevels as level}
							<option value={level}>{level}</option>
						{/each}
					</select>
				</div>
				
				<div class="form-group">
					<label for="statusId">Status:</label>
					<select
						id="statusId"
						bind:value={formData.statusId}
						required
						disabled={loading}
					>
						{#each statusList as status}
							<option value={status.StatusID.toString()}>
								{status.StatusName}
							</option>
						{/each}
					</select>
				</div>
				
				<div class="flex gap-1 mt-2">
					<button type="submit" class="btn btn-primary" disabled={loading}>
						{#if loading}
							<span class="spinner"></span>
						{/if}
						{editingStudent ? 'Update' : 'Create'} Student
					</button>
					<button type="button" class="btn btn-secondary" on:click={closeModal}>
						Cancel
					</button>
				</div>
			</form>
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
	
	@media (max-width: 768px) {
		.page-header {
			flex-direction: column;
			gap: 1rem;
			align-items: stretch;
		}
	}
</style>