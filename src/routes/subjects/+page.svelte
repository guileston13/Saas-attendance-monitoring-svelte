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
		(subject.Room && subject.Room.toLowerCase().includes(searchTerm.toLowerCase()))
	);
	
	function openModal(subject = null) {
		editingSubject = subject;
		if (subject) {
			formData = {
				subjectName: subject.SubjectName,
				subjectCode: subject.SubjectCode,
				room: subject.Room || '',
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

<div class="page">
	<div class="page-header">
		<h1>Subjects Management</h1>
		{#if session.role === 'Admin'}
			<button class="btn btn-primary" on:click={() => openModal()}>
				Add New Subject
			</button>
		{/if}
	</div>
	
	{#if data.error}
		<div class="error-message mb-2">{data.error}</div>
	{/if}
	
	<!-- Search bar -->
	<div class="card mb-2">
		<div class="form-group">
			<label for="search">Search Subjects:</label>
			<input
				type="text"
				id="search"
				bind:value={searchTerm}
				placeholder="Search by name, code, or room..."
			/>
		</div>
	</div>
	
	<!-- Subjects table -->
	<div class="card">
		<div class="table-container">
			<table>
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
							<td>{subject.Room || '-'}</td>
							<td>{subject.StartTime || '-'}</td>
							<td>{subject.EndTime || '-'}</td>
							<td>{subject.StatusName}</td>
							{#if session.role === 'Admin'}
								<td>
									<div class="actions">
										<button 
											class="btn btn-small btn-secondary"
											on:click={() => openModal(subject)}
										>
											Edit
										</button>
										<button 
											class="btn btn-small btn-danger"
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
							<td colspan={session.role === 'Admin' ? '7' : '6'} class="text-center">
								No subjects found
							</td>
						</tr>
					{/each}
				</tbody>
			</table>
		</div>
	</div>
</div>

<!-- Modal for add/edit subject -->
{#if showModal}
	<div class="modal-overlay" on:click={closeModal}>
		<div class="modal-content" on:click|stopPropagation>
			<div class="modal-header">
				<h3 class="modal-title">
					{editingSubject ? 'Edit Subject' : 'Add New Subject'}
				</h3>
				<button class="close-btn" on:click={closeModal}>&times;</button>
			</div>
			
			<form on:submit|preventDefault={handleSubmit}>
				<div class="form-group">
					<label for="subjectCode">Subject Code:</label>
					<input
						type="text"
						id="subjectCode"
						bind:value={formData.subjectCode}
						required
						disabled={loading}
						placeholder="e.g., MATH101"
						style="text-transform: uppercase;"
					/>
				</div>
				
				<div class="form-group">
					<label for="subjectName">Subject Name:</label>
					<input
						type="text"
						id="subjectName"
						bind:value={formData.subjectName}
						required
						disabled={loading}
						placeholder="e.g., Mathematics"
					/>
				</div>
				
				<div class="form-group">
					<label for="room">Room:</label>
					<input
						type="text"
						id="room"
						bind:value={formData.room}
						disabled={loading}
						placeholder="e.g., Room 101, Lab 1, Gym"
					/>
				</div>
				
				<div class="form-row">
					<div class="form-group">
						<label for="startTime">Start Time:</label>
						<input
							type="time"
							id="startTime"
							bind:value={formData.startTime}
							disabled={loading}
						/>
					</div>
					
					<div class="form-group">
						<label for="endTime">End Time:</label>
						<input
							type="time"
							id="endTime"
							bind:value={formData.endTime}
							disabled={loading}
						/>
					</div>
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
						{editingSubject ? 'Update' : 'Create'} Subject
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
	
	code {
		background: #f8f9fa;
		padding: 0.2rem 0.4rem;
		border-radius: 3px;
		font-family: 'Courier New', monospace;
		font-size: 0.9rem;
		color: #e74c3c;
	}
	
	.form-row {
		display: flex;
		gap: 1rem;
	}
	
	.form-row .form-group {
		flex: 1;
	}
	
	@media (max-width: 768px) {
		.page-header {
			flex-direction: column;
			gap: 1rem;
			align-items: stretch;
		}
		
		.form-row {
			flex-direction: column;
			gap: 0;
		}
	}
</style>