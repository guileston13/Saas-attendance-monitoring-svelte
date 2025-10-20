<script>
	import { enhance } from '$app/forms';
	import { invalidateAll } from '$app/navigation';
	
	/** @type {import('./$types').PageData} */
	export let data;
	
	$: users = data.users || [];
	$: statuses = data.statuses || [];
	
	let showCreateModal = false;
	let editingUser = null;
	let loading = false;
	let searchTerm = '';
	
	// Filter users based on search term
	$: filteredUsers = users.filter(user => 
		user.FullName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
		user.Email.toLowerCase().includes(searchTerm.toLowerCase()) ||
		user.Role.toLowerCase().includes(searchTerm.toLowerCase()) ||
		user.StatusName.toLowerCase().includes(searchTerm.toLowerCase())
	);
	
	function openCreateModal() {
		showCreateModal = true;
	}
	
	function closeCreateModal() {
		showCreateModal = false;
	}
	
	function editUser(user) {
		editingUser = { ...user };
	}
	
	function cancelEdit() {
		editingUser = null;
	}
	
	function handleKeydown(event) {
		if (event.key === 'Escape') {
			closeCreateModal();
			cancelEdit();
		}
	}
	
	function formatDate(dateString) {
		return new Date(dateString).toLocaleDateString();
	}
	
	function getStatusColor(statusName) {
		switch (statusName?.toLowerCase()) {
			case 'active': return '#27ae60';
			case 'inactive': return '#95a5a6';
			case 'suspended': return '#e74c3c';
			case 'graduated': return '#3498db';
			default: return '#95a5a6';
		}
	}
</script>

<svelte:head>
	<title>User Management - School Management System</title>
</svelte:head>

<div class="users-page">
	<!-- Page Header -->
	<div class="page-header">
		<div class="header-content">
			<h1>👥 User Management</h1>
			<p class="subtitle">Manage user accounts, roles, and access permissions</p>
		</div>
		<button class="btn btn-primary" on:click={openCreateModal}>
			➕ Add New User
		</button>
	</div>
	
	{#if data.error}
		<div class="error-message">{data.error}</div>
	{/if}
	
	<!-- Stats Cards -->
	<div class="stats-grid">
		<div class="stat-card">
			<div class="stat-icon">👥</div>
			<span class="stat-number">{users.length}</span>
			<span class="stat-label">Total Users</span>
		</div>
		<div class="stat-card">
			<div class="stat-icon">✅</div>
			<span class="stat-number">{users.filter(u => u.StatusName === 'Active').length}</span>
			<span class="stat-label">Active Users</span>
		</div>
		<div class="stat-card">
			<div class="stat-icon">👨‍🏫</div>
			<span class="stat-number">{users.filter(u => u.Role === 'Admin').length}</span>
			<span class="stat-label">Administrators</span>
		</div>
		<div class="stat-card">
			<div class="stat-icon">🎓</div>
			<span class="stat-number">{users.filter(u => u.Role === 'Student').length}</span>
			<span class="stat-label">Students</span>
		</div>
	</div>
	
	<!-- Search and Table Section -->
	<div class="content-section">
		<div class="section-card">
			<div class="card-header">
				<h3 class="card-title">📋 System Users</h3>
			</div>
			
			<div class="card-content">
				<!-- Search bar -->
				<div class="search-container">
					<input
						type="text"
						bind:value={searchTerm}
						placeholder="🔍 Search by name, email, role, or status..."
						class="search-input"
					>
				</div>
				
				<!-- Users table -->
				<div class="table-container">
					<table class="data-table">
						<thead>
							<tr>
								<th>User ID</th>
								<th>Name</th>
								<th>Email</th>
								<th>Role</th>
								<th>Status</th>
								<th>Created</th>
								<th>Actions</th>
							</tr>
						</thead>
						<tbody>
							{#each filteredUsers as user}
								<tr>
									<td>#{user.UserID}</td>
									<td>{user.FullName || 'N/A'}</td>
									<td>{user.Email}</td>
									<td>
										<span class="role-badge role-{user.Role.toLowerCase()}">{user.Role}</span>
									</td>
									<td>
										<span 
											class="status-badge" 
											style="background-color: {getStatusColor(user.StatusName)}"
										>
											{user.StatusName}
										</span>
									</td>
									<td>{formatDate(user.CreatedAt)}</td>
									<td>
										<div class="actions">
											<button 
												class="btn btn-secondary" 
												on:click={() => editUser(user)}
											>
												Edit
											</button>
											{#if user.UserID !== data.session.userId}
												<button 
													class="btn btn-danger"
													on:click={() => {
														if (confirm('Are you sure you want to delete this user?')) {
															console.log('Delete user', user.UserID);
														}
													}}
												>
													Delete
												</button>
											{/if}
										</div>
									</td>
								</tr>
							{:else}
								<tr>
									<td colspan="7" class="text-center">
										<div class="empty-state">
											<h3>No users found</h3>
											<p>{searchTerm ? 'Try adjusting your search terms' : 'No user records available'}</p>
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

<!-- Create User Modal -->
{#if showCreateModal}
	<div class="modal-overlay" on:click={closeCreateModal} on:keydown={handleKeydown} role="dialog" aria-modal="true" tabindex="-1">
		<div class="modal-content" on:click|stopPropagation role="document">
			<div class="modal-header">
				<h3 class="modal-title">
					➕ Create New User
				</h3>
				<button class="close-btn" on:click={closeCreateModal} aria-label="Close modal">×</button>
			</div>
			
			<form method="POST" action="?/create" use:enhance>
				<div class="form-group">
					<label for="email" class="form-label">Email:</label>
					<input type="email" id="email" name="email" required class="form-input" />
				</div>
				
				<div class="form-group">
					<label for="password" class="form-label">Password:</label>
					<input type="password" id="password" name="password" required minlength="6" class="form-input" />
				</div>
				
				<div class="form-group">
					<label for="role" class="form-label">Role:</label>
					<select id="role" name="role" required class="form-select">
						<option value="">Select Role</option>
						<option value="Admin">Admin</option>
						<option value="Teacher">Teacher</option>
						<option value="Student">Student</option>
					</select>
				</div>
				
				<div class="form-group">
					<label for="status" class="form-label">Status:</label>
					<select id="status" name="statusId" required class="form-select">
						<option value="">Select Status</option>
						{#each statuses as status}
							<option value={status.StatusID}>{status.StatusName}</option>
						{/each}
					</select>
				</div>
				
				<div class="modal-actions">
					<button type="button" class="btn btn-secondary" on:click={closeCreateModal}>
						Cancel
					</button>
					<button type="submit" class="btn btn-primary">
						Create User
					</button>
				</div>
			</form>
		</div>
	</div>
{/if}

<!-- Edit User Modal -->
{#if editingUser}
	<div class="modal-overlay" on:click={cancelEdit} on:keydown={handleKeydown} role="dialog" aria-modal="true" tabindex="-1">
		<div class="modal-content" on:click|stopPropagation role="document">
			<div class="modal-header">
				<h3 class="modal-title">
					✏️ Edit User
				</h3>
				<button class="close-btn" on:click={cancelEdit} aria-label="Close modal">×</button>
			</div>
			
			<form method="POST" action="?/update" use:enhance>
				<input type="hidden" name="userId" value={editingUser.UserID} />
				
				<div class="form-group">
					<label for="edit-email" class="form-label">Email:</label>
					<input type="email" id="edit-email" name="email" bind:value={editingUser.Email} required class="form-input" />
				</div>
				
				<div class="form-group">
					<label for="edit-role" class="form-label">Role:</label>
					<select id="edit-role" name="role" bind:value={editingUser.Role} required class="form-select">
						<option value="Admin">Admin</option>
						<option value="Teacher">Teacher</option>
						<option value="Student">Student</option>
					</select>
				</div>
				
				<div class="form-group">
					<label for="edit-status" class="form-label">Status:</label>
					<select id="edit-status" name="statusId" bind:value={editingUser.StatusID} required class="form-select">
						{#each statuses as status}
							<option value={status.StatusID}>{status.StatusName}</option>
						{/each}
					</select>
				</div>
				
				<div class="modal-actions">
					<button type="button" class="btn btn-secondary" on:click={cancelEdit}>
						Cancel
					</button>
					<button type="submit" class="btn btn-primary">
						Update User
					</button>
				</div>
			</form>
		</div>
	</div>
{/if}

<style>
	.users-page {
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
	
	/* Role and Status Badges */
	.role-badge {
		padding: 0.25rem 0.75rem;
		border-radius: 20px;
		font-size: 0.9rem;
		font-weight: 500;
		text-transform: uppercase;
		color: white;
	}
	
	.role-admin { background-color: #e74c3c; }
	.role-teacher { background-color: #3498db; }
	.role-student { background-color: #27ae60; }
	
	.status-badge {
		padding: 0.25rem 0.75rem;
		border-radius: 20px;
		font-size: 0.85rem;
		font-weight: 500;
		color: white;
		text-transform: uppercase;
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
	
	.modal-actions {
		display: flex;
		justify-content: flex-end;
		gap: 1rem;
		padding-top: 1.5rem;
		border-top: 1px solid #ecf0f1;
	}
	
	/* Responsive Design */
	@media (max-width: 768px) {
		.users-page {
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