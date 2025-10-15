<script>
	// Teachers management page
	import { browser } from '$app/environment';
	
	/** @type {import('./$types').PageData} */
	export let data;
	
	$: session = data.session;
	$: teachers = data.teachers || [];
	$: statusList = data.statusList || [];
	
	let showModal = false;
	let editingTeacher = null;
	let loading = false;
	let searchTerm = '';
	
	// Form data
	let formData = {
		firstName: '',
		lastName: '',
		middleName: '',
		role: '',
		statusId: ''
	};
	
	// Filter teachers based on search term
	$: filteredTeachers = teachers.filter(teacher => 
		teacher.FirstName.toLowerCase().includes(searchTerm.toLowerCase()) ||
		teacher.LastName.toLowerCase().includes(searchTerm.toLowerCase()) ||
		(teacher.Role && teacher.Role.toLowerCase().includes(searchTerm.toLowerCase()))
	);
	
	function openModal(teacher = null) {
		editingTeacher = teacher;
		if (teacher) {
			formData = {
				firstName: teacher.FirstName,
				lastName: teacher.LastName,
				middleName: teacher.MiddleName || '',
				role: teacher.Role || '',
				statusId: teacher.StatusID.toString()
			};
		} else {
			formData = {
				firstName: '',
				lastName: '',
				middleName: '',
				role: 'Teacher',
				statusId: '1'
			};
		}
		showModal = true;
	}
	
	function closeModal() {
		showModal = false;
		editingTeacher = null;
	}
	
	async function handleSubmit() {
		if (!browser) return;
		
		loading = true;
		
		try {
			const method = editingTeacher ? 'PUT' : 'POST';
			const response = await fetch('/api/teachers', {
				method,
				headers: {
					'Content-Type': 'application/json'
				},
				body: JSON.stringify({
					...formData,
					statusId: parseInt(formData.statusId),
					...(editingTeacher && { teacherId: editingTeacher.TeacherID })
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
	
	async function handleDelete(teacherId) {
		if (!browser) return;
		
		if (!confirm('Are you sure you want to delete this teacher?')) {
			return;
		}
		
		try {
			const response = await fetch('/api/teachers', {
				method: 'DELETE',
				headers: {
					'Content-Type': 'application/json'
				},
				body: JSON.stringify({ teacherId })
			});
			
			const result = await response.json();
			
			if (response.ok) {
				window.location.reload();
			} else {
				alert(result.error || 'Failed to delete teacher');
			}
		} catch (error) {
			console.error('Delete error:', error);
			alert('An error occurred while deleting');
		}
	}
</script>

<svelte:head>
	<title>Teachers - School Management System</title>
</svelte:head>

<div class="page">
	<div class="page-header">
		<h1>Teachers Management</h1>
		<button class="btn btn-primary" on:click={() => openModal()}>
			Add New Teacher
		</button>
	</div>
	
	{#if data.error}
		<div class="error-message mb-2">{data.error}</div>
	{/if}
	
	<!-- Search bar -->
	<div class="card mb-2">
		<div class="form-group">
			<label for="search">Search Teachers:</label>
			<input
				type="text"
				id="search"
				bind:value={searchTerm}
				placeholder="Search by name or role..."
			/>
		</div>
	</div>
	
	<!-- Teachers table -->
	<div class="card">
		<div class="table-container">
			<table>
				<thead>
					<tr>
						<th>Name</th>
						<th>Role</th>
						<th>Status</th>
						<th>Actions</th>
					</tr>
				</thead>
				<tbody>
					{#each filteredTeachers as teacher}
						<tr>
							<td>
								{teacher.FirstName} 
								{teacher.MiddleName ? teacher.MiddleName + ' ' : ''}
								{teacher.LastName}
							</td>
							<td>{teacher.Role || 'Teacher'}</td>
							<td>{teacher.StatusName}</td>
							<td>
								<div class="actions">
									<button 
										class="btn btn-small btn-secondary"
										on:click={() => openModal(teacher)}
									>
										Edit
									</button>
									<button 
										class="btn btn-small btn-danger"
										on:click={() => handleDelete(teacher.TeacherID)}
									>
										Delete
									</button>
								</div>
							</td>
						</tr>
					{:else}
						<tr>
							<td colspan="4" class="text-center">No teachers found</td>
						</tr>
					{/each}
				</tbody>
			</table>
		</div>
	</div>
</div>

<!-- Modal for add/edit teacher -->
{#if showModal}
	<div class="modal-overlay" on:click={closeModal}>
		<div class="modal-content" on:click|stopPropagation>
			<div class="modal-header">
				<h3 class="modal-title">
					{editingTeacher ? 'Edit Teacher' : 'Add New Teacher'}
				</h3>
				<button class="close-btn" on:click={closeModal}>&times;</button>
			</div>
			
			<form on:submit|preventDefault={handleSubmit}>
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
					<label for="role">Role/Position:</label>
					<input
						type="text"
						id="role"
						bind:value={formData.role}
						disabled={loading}
						placeholder="e.g., Mathematics Teacher, Head Teacher"
					/>
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
						{editingTeacher ? 'Update' : 'Create'} Teacher
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