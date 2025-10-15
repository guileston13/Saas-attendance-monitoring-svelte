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
	<div class="page-header">
		<div>
			<h1>User Management</h1>
			<p class="subtitle">Manage user accounts, roles, and access permissions</p>
		</div>
		<button class="btn btn-primary" on:click={openCreateModal}>
			Add New User
		</button>
	</div>
	
	{#if data.error}
		<div class="error-message mb-2">{data.error}</div>
	{/if}
	
	<div class="card">
		<div class="card-header">
			<h3 class="card-title">System Users ({users.length})</h3>
		</div>
		
		<div class="table-container">
			<table>
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
					{#each users as user}
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
										class="btn btn-small btn-secondary" 
										on:click={() => editUser(user)}
									>
										Edit
									</button>
									{#if user.UserID !== data.session.userId}
										<button 
											class="btn btn-small btn-danger"
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
							<td colspan="7" class="text-center">No users found</td>
						</tr>
					{/each}
				</tbody>
			</table>
		</div>
	</div>
</div>

<!-- Create User Modal -->
{#if showCreateModal}
	<div class="modal-overlay" on:click={closeCreateModal}>
		<div class="modal-content" on:click|stopPropagation>
			<div class="modal-header">
				<h3>Create New User</h3>
				<button class="modal-close" on:click={closeCreateModal}>&times;</button>
			</div>
			
			<form method="POST" action="?/create">
				<div class="form-group">
					<label for="email">Email:</label>
					<input type="email" id="email" name="email" required />
				</div>
				
				<div class="form-group">
					<label for="password">Password:</label>
					<input type="password" id="password" name="password" required minlength="6" />
				</div>
				
				<div class="form-group">
					<label for="role">Role:</label>
					<select id="role" name="role" required>
						<option value="">Select Role</option>
						<option value="Admin">Admin</option>
						<option value="Teacher">Teacher</option>
						<option value="Student">Student</option>
					</select>
				</div>
				
				<div class="form-group">
					<label for="status">Status:</label>
					<select id="status" name="statusId" required>
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
	<div class="modal-overlay" on:click={cancelEdit}>
		<div class="modal-content" on:click|stopPropagation>
			<div class="modal-header">
				<h3>Edit User</h3>
				<button class="modal-close" on:click={cancelEdit}>&times;</button>
			</div>
			
			<form method="POST" action="?/update">
				<input type="hidden" name="userId" value={editingUser.UserID} />
				
				<div class="form-group">
					<label for="edit-email">Email:</label>
					<input type="email" id="edit-email" name="email" bind:value={editingUser.Email} required />
				</div>
				
				<div class="form-group">
					<label for="edit-role">Role:</label>
					<select id="edit-role" name="role" bind:value={editingUser.Role} required>
						<option value="Admin">Admin</option>
						<option value="Teacher">Teacher</option>
						<option value="Student">Student</option>
					</select>
				</div>
				
				<div class="form-group">
					<label for="edit-status">Status:</label>
					<select id="edit-status" name="statusId" bind:value={editingUser.StatusID} required>
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
	
	.subtitle {
		color: #7f8c8d;
		margin: 0.5rem 0 0 0;
		font-size: 1.1rem;
	}
	
	.role-badge {
		padding: 0.2rem 0.6rem;
		border-radius: 12px;
		font-size: 0.8rem;
		font-weight: bold;
		text-transform: uppercase;
		color: white;
	}
	
	.role-admin { background-color: #e74c3c; }
	.role-teacher { background-color: #3498db; }
	.role-student { background-color: #27ae60; }
	
	.status-badge {
		padding: 0.2rem 0.6rem;
		border-radius: 12px;
		font-size: 0.8rem;
		font-weight: bold;
		color: white;
	}
	
	.actions {
		display: flex;
		gap: 0.5rem;
		flex-wrap: wrap;
	}
	
	.modal-overlay {
		position: fixed;
		top: 0;
		left: 0;
		width: 100%;
		height: 100%;
		background-color: rgba(0, 0, 0, 0.5);
		display: flex;
		justify-content: center;
		align-items: center;
		z-index: 1000;
	}
	
	.modal-content {
		background: white;
		padding: 0;
		border-radius: 8px;
		width: 90%;
		max-width: 500px;
		max-height: 90vh;
		overflow-y: auto;
	}
	
	.modal-header {
		padding: 1.5rem;
		border-bottom: 1px solid #eee;
		display: flex;
		justify-content: space-between;
		align-items: center;
	}
	
	.modal-header h3 {
		margin: 0;
		color: #2c3e50;
	}
	
	.modal-close {
		background: none;
		border: none;
		font-size: 1.5rem;
		cursor: pointer;
		color: #7f8c8d;
	}
	
	.modal-content form {
		padding: 1.5rem;
	}
	
	.modal-actions {
		display: flex;
		gap: 1rem;
		justify-content: flex-end;
		margin-top: 1.5rem;
		padding-top: 1rem;
		border-top: 1px solid #eee;
	}
	
	@media (max-width: 768px) {
		.page-header {
			flex-direction: column;
			align-items: flex-start;
		}
		
		.actions {
			flex-direction: column;
		}
		
		.modal-actions {
			flex-direction: column;
		}
	}
</style>