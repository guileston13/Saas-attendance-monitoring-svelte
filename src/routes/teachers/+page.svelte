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
		resetForm();
	}
	
	function handleKeydown(event) {
		if (event.key === 'Escape') {
			closeModal();
		}
	}
	
	function resetForm() {
		formData = {
			firstName: '',
			lastName: '',
			middleName: '',
			role: '',
			statusId: ''
		};
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

<div class="teachers-page">
	<!-- Page Header -->
	<div class="page-header">
		<div class="header-content">
			<h1>👨‍🏫 Teachers Management</h1>
			<p class="subtitle">Manage teacher records and information</p>
		</div>
		{#if session.role === 'Admin'}
			<button class="btn btn-primary" on:click={() => openModal()}>
				➕ Add New Teacher
			</button>
		{/if}
	</div>
	
	{#if data.error}
		<div class="error-message">{data.error}</div>
	{/if}
	
	<!-- Stats Cards -->
	<div class="stats-grid">
		<div class="stat-card">
			<div class="stat-icon">👨‍🏫</div>
			<span class="stat-number">{teachers.length}</span>
			<span class="stat-label">Total Teachers</span>
		</div>
		<div class="stat-card">
			<div class="stat-icon">✅</div>
			<span class="stat-number">{teachers.filter(t => t.StatusName === 'Active').length}</span>
			<span class="stat-label">Active Teachers</span>
		</div>
		<div class="stat-card">
			<div class="stat-icon">📚</div>
			<span class="stat-number">{new Set(teachers.map(t => t.Role).filter(Boolean)).size}</span>
			<span class="stat-label">Roles</span>
		</div>
	</div>
	
	<!-- Search and Table Section -->
	<div class="content-section">
		<div class="section-card">
			<div class="card-header">
				<h3 class="card-title">📋 Teacher Records</h3>
			</div>
			
			<div class="card-content">
				<!-- Search bar -->
				<div class="search-container">
					<input
						type="text"
						bind:value={searchTerm}
						placeholder="🔍 Search by name or role..."
						class="search-input"
					>
				</div>
				
				<!-- Teachers table -->
				<div class="table-container">
					<table class="data-table">
						<thead>
							<tr>
								<th>Full Name</th>
								<th>Role/Position</th>
								<th>Status</th>
								{#if session.role === 'Admin'}
									<th>Actions</th>
								{/if}
							</tr>
						</thead>
						<tbody>
							{#each filteredTeachers as teacher}
								<tr>
									<td>
										<div class="teacher-name">
											<strong>{teacher.FirstName} {teacher.LastName}</strong>
											{#if teacher.MiddleName}
												<small class="middle-name">{teacher.MiddleName}</small>
											{/if}
										</div>
									</td>
									<td>
										<span class="role-badge">{teacher.Role || 'Teacher'}</span>
									</td>
									<td>
										<span class="status-badge {teacher.StatusName.toLowerCase()}">
											{teacher.StatusName}
										</span>
									</td>
									{#if session.role === 'Admin'}
										<td>
											<div class="actions">
												<button 
													class="btn btn-primary"
													on:click={() => openModal(teacher)}
												>
													Edit
												</button>
												<button 
													class="btn btn-danger"
													on:click={() => handleDelete(teacher.TeacherID)}
												>
													Delete
												</button>
											</div>
										</td>
									{/if}
								</tr>
							{:else}
								<tr>
									<td colspan={Number(session.role === 'Admin' ? '4' : '3')} class="text-center">
										<div class="empty-state">
											<h3>No teachers found</h3>
											<p>{searchTerm ? 'Try adjusting your search terms' : 'No teacher records available'}</p>
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

<!-- Modal for add/edit teacher -->
{#if showModal}
	<div class="modal-overlay" on:click={closeModal} on:keydown={handleKeydown} role="dialog" aria-modal="true" tabindex="-1">
		<div class="modal-content" on:click|stopPropagation role="document" tabindex="-1">
			<div class="modal-header">
				<h3 class="modal-title">
					{editingTeacher ? '✏️ Edit Teacher' : '➕ Add New Teacher'}
				</h3>
				<button class="close-btn" on:click={closeModal} aria-label="Close modal">×</button>
			</div>
			
			<form on:submit|preventDefault={handleSubmit}>
				<div class="form-group">
					<label for="firstName" class="form-label">First Name:</label>
					<input
						type="text"
						id="firstName"
						bind:value={formData.firstName}
						required
						disabled={loading}
						class="form-input"
					/>
				</div>
				
				<div class="form-group">
					<label for="lastName" class="form-label">Last Name:</label>
					<input
						type="text"
						id="lastName"
						bind:value={formData.lastName}
						required
						disabled={loading}
						class="form-input"
					/>
				</div>
				
				<div class="form-group">
					<label for="middleName" class="form-label">Middle Name:</label>
					<input
						type="text"
						id="middleName"
						bind:value={formData.middleName}
						disabled={loading}
						class="form-input"
					/>
				</div>
				
				<div class="form-group">
					<label for="role" class="form-label">Role/Position:</label>
					<input
						type="text"
						id="role"
						bind:value={formData.role}
						disabled={loading}
						placeholder="e.g., Mathematics Teacher, Head Teacher"
						class="form-input"
					/>
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
						{editingTeacher ? 'Update Teacher' : 'Create Teacher'}
					</button>
				</div>
			</form>
		</div>
	</div>
{/if}

<style>
	.teachers-page {
		max-width: 1400px;
		margin: 0 auto;
		padding: 1rem;
	}
	
	/* Page Header */
	.page-header {
		background: linear-gradient(135deg, #3498db, #2980b9);
		color: white;
		padding: 2rem;
		border-radius: 12px;
		margin-bottom: 2rem;
		box-shadow: 0 4px 20px rgba(0,0,0,0.1);
		display: flex;
		justify-content: space-between;
		align-items: center;
		flex-wrap: wrap;
		gap: 1rem;
	}
	
	.page-header h1 {
		margin: 0 0 0.5rem 0;
		font-size: 2rem;
	}
	
	.subtitle {
		margin: 0;
		opacity: 0.9;
		font-size: 1.1rem;
	}
	
	/* Stats Grid */
	.stats-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
		gap: 1.5rem;
		margin-bottom: 2rem;
	}
	
	.stat-card {
		background: white;
		border-radius: 12px;
		padding: 1.5rem;
		text-align: center;
		transition: all 0.3s ease;
		border: 2px solid #ecf0f1;
	}
	
	.stat-card:hover {
		transform: translateY(-4px);
		box-shadow: 0 8px 25px rgba(39, 174, 96, 0.15);
		border-color: #27ae60;
	}
	
	.stat-icon {
		font-size: 2.5rem;
		margin-bottom: 1rem;
	}
	
	.stat-number {
		display: block;
		font-size: 2.5rem;
		font-weight: bold;
		color: #2c3e50;
		margin-bottom: 0.5rem;
	}
	
	.stat-label {
		color: #7f8c8d;
		font-size: 1.1rem;
		font-weight: 500;
	}
	
	/* Content Section */
	.content-section {
		background: white;
		border-radius: 12px;
		box-shadow: 0 4px 20px rgba(0,0,0,0.1);
		overflow: hidden;
	}
	
	.section-card {
		background: white;
		border-radius: 12px;
		box-shadow: 0 4px 20px rgba(0,0,0,0.1);
		overflow: hidden;
	}
	
	.card-header {
		background: linear-gradient(135deg, #27ae60, #2ecc71);
		color: white;
		padding: 1.5rem 2rem;
	}
	
	.card-title {
		margin: 0;
		font-size: 1.5rem;
		font-weight: 600;
	}
	
	.card-content {
		padding: 2rem;
	}
	
	/* Search Container */
	.search-container {
		margin-bottom: 2rem;
	}
	
	.search-input {
		width: 100%;
		padding: 0.75rem 1rem;
		border: 2px solid #ecf0f1;
		border-radius: 8px;
		font-size: 1rem;
		transition: border-color 0.2s ease;
	}
	
	.search-input:focus {
		outline: none;
		border-color: #3498db;
	}
	
	/* Table Styles */
	.table-container {
		overflow-x: auto;
	}
	
	.data-table {
		width: 100%;
		border-collapse: collapse;
		background: white;
		border-radius: 8px;
		overflow: hidden;
		box-shadow: 0 2px 10px rgba(0,0,0,0.1);
	}
	
	.data-table th {
		background: #34495e;
		color: white;
		padding: 1rem 0.75rem;
		text-align: left;
		font-weight: 500;
		border: 1px solid #2c3e50;
	}
	
	.data-table td {
		padding: 1rem 0.75rem;
		border: 1px solid #ecf0f1;
	}
	
	.data-table tbody tr:hover {
		background: #f8f9fa;
	}
	
	.text-center {
		text-align: center;
	}
	
	/* Teacher Info */
	.teacher-name strong {
		color: #2c3e50;
		font-size: 1rem;
	}
	
	.middle-name {
		color: #7f8c8d;
		font-size: 0.85rem;
		margin-left: 0.5rem;
	}
	
	/* Badges */
	.role-badge {
		background: #f8f9fa;
		padding: 0.25rem 0.75rem;
		border-radius: 20px;
		font-size: 0.9rem;
		color: #5a6c7d;
		font-weight: 500;
	}
	
	.status-badge {
		padding: 0.25rem 0.75rem;
		border-radius: 20px;
		font-size: 0.85rem;
		font-weight: 500;
		text-transform: uppercase;
	}
	
	.status-badge.active {
		background: #d4edda;
		color: #155724;
	}
	
	.status-badge.inactive {
		background: #f8d7da;
		color: #721c24;
	}
	
	/* Actions */
	.actions {
		display: flex;
		gap: 0.5rem;
		flex-wrap: wrap;
	}
	
	/* Buttons */
	.btn {
		padding: 0.75rem 1.5rem;
		border: none;
		border-radius: 6px;
		cursor: pointer;
		font-size: 1rem;
		font-weight: 500;
		transition: all 0.2s ease;
		text-decoration: none;
		display: inline-block;
	}
	
	.btn-primary {
		background: #3498db;
		color: white;
	}
	
	.btn-primary:hover {
		background: #2980b9;
		transform: translateY(-1px);
		box-shadow: 0 4px 12px rgba(52, 152, 219, 0.3);
	}
	
	.btn-secondary {
		background: #6c757d;
		color: white;
	}
	
	.btn-secondary:hover {
		background: #545b62;
		transform: translateY(-1px);
		box-shadow: 0 4px 12px rgba(108, 117, 125, 0.3);
	}
	
	.btn-danger {
		background: #e74c3c;
		color: white;
	}
	
	.btn-danger:hover {
		background: #c0392b;
		transform: translateY(-1px);
		box-shadow: 0 4px 12px rgba(231, 76, 60, 0.3);
	}
	
	/* Empty State */
	.empty-state {
		text-align: center;
		padding: 3rem;
		color: #7f8c8d;
	}
	
	.empty-state h3 {
		margin-bottom: 0.5rem;
		color: #2c3e50;
	}
	
	/* Loading State */
	.loading-state {
		text-align: center;
		padding: 3rem;
	}
	
	.spinner {
		width: 40px;
		height: 40px;
		border: 4px solid #ecf0f1;
		border-top: 4px solid #3498db;
		border-radius: 50%;
		animation: spin 1s linear infinite;
		margin: 0 auto 1rem;
	}
	
	@keyframes spin {
		0% { transform: rotate(0deg); }
		100% { transform: rotate(360deg); }
	}
	
	/* Error Message */
	.error-message {
		background: #f8d7da;
		color: #721c24;
		padding: 1rem;
		border-radius: 6px;
		margin-bottom: 1rem;
		text-align: center;
	}
	
	/* Modal Styles */
	.modal-overlay {
		position: fixed;
		top: 0;
		left: 0;
		width: 100%;
		height: 100%;
		background: rgba(0,0,0,0.5);
		display: flex;
		align-items: center;
		justify-content: center;
		z-index: 1000;
	}
	
	.modal-content {
		background: white;
		border-radius: 12px;
		padding: 2rem;
		max-width: 500px;
		width: 90%;
		max-height: 90vh;
		overflow-y: auto;
		box-shadow: 0 10px 30px rgba(0,0,0,0.3);
	}
	
	.modal-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		margin-bottom: 1.5rem;
		padding-bottom: 1rem;
		border-bottom: 1px solid #ecf0f1;
	}
	
	.modal-title {
		margin: 0;
		color: #2c3e50;
		font-size: 1.5rem;
	}
	
	.close-btn {
		background: none;
		border: none;
		font-size: 1.5rem;
		cursor: pointer;
		color: #7f8c8d;
		padding: 0.25rem;
		border-radius: 4px;
		transition: all 0.2s ease;
	}
	
	.close-btn:hover {
		background: #f8f9fa;
		color: #2c3e50;
	}
	
	.form-group {
		margin-bottom: 1.5rem;
	}
	
	.form-label {
		display: block;
		margin-bottom: 0.5rem;
		font-weight: 500;
		color: #2c3e50;
	}
	
	.form-input, .form-select {
		width: 100%;
		padding: 0.75rem;
		border: 2px solid #ecf0f1;
		border-radius: 6px;
		font-size: 1rem;
		transition: border-color 0.2s ease;
	}
	
	.form-input:focus, .form-select:focus {
		outline: none;
		border-color: #3498db;
	}
	
	.form-input:disabled, .form-select:disabled {
		background: #f8f9fa;
		color: #7f8c8d;
		cursor: not-allowed;
	}
	
	.modal-actions {
		display: flex;
		justify-content: flex-end;
		gap: 1rem;
		padding-top: 1.5rem;
		border-top: 1px solid #ecf0f1;
	}
	
	/* Responsive Design */
	@media (max-width: 768px) {
		.teachers-page {
			padding: 0.5rem;
		}
		
		.page-header {
			padding: 1.5rem;
			flex-direction: column;
			align-items: flex-start;
		}
		
		.page-header h1 {
			font-size: 1.5rem;
		}
		
		.stats-grid {
			grid-template-columns: 1fr;
		}
		
		.card-content {
			padding: 1rem;
		}
		
		.data-table {
			font-size: 0.9rem;
		}
		
		.actions {
			flex-direction: column;
		}
		
		.btn {
			width: 100%;
			margin-bottom: 0.5rem;
		}
		
		.modal-content {
			margin: 1rem;
			padding: 1.5rem;
		}
		
		.modal-actions {
			flex-direction: column;
		}
	}
</style>