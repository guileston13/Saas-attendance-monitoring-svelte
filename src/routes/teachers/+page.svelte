<script>
	import { browser } from '$app/environment';
	import { onMount } from 'svelte';
	
	/** @type {import('./$types').PageData} */
	export let data;
	
	$: session = data.session;
	$: teachers = data.teachers || [];
	$: statusList = data.statusList || [];
	
	let showModal = false;
	let editingTeacher = null;
	let loading = false;
	let searchTerm = '';
	let isLoading = true;
	let loadingProgress = 0;
	let loadingText = 'Initializing...';
	let loadingFadeOut = false;
	let pageVisible = false;
	let statsVisible = false;
	let cardsVisible = false;
	let scrollY = 0;
	
	// Form data
	let formData = {
		firstName: '',
		middleName: '',
		lastName: '',
		email: '',
		phone: '',
		statusId: '1'
	};
	
	onMount(() => {
		const loadingSteps = [
			{ progress: 25, text: 'Loading teachers...' },
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
		
		if (browser) {
			window.addEventListener('scroll', handleScroll);
			return () => window.removeEventListener('scroll', handleScroll);
		}
	});
	
	// Filter teachers based on search term
	$: filteredTeachers = teachers.filter(teacher => 
		teacher.FirstName.toLowerCase().includes(searchTerm.toLowerCase()) ||
		teacher.LastName.toLowerCase().includes(searchTerm.toLowerCase()) ||
		(teacher.Email && teacher.Email.toLowerCase().includes(searchTerm.toLowerCase()))
	);
	
	// Stats
	$: activeTeachers = filteredTeachers.filter(t => t.StatusName === 'Active').length;
	$: inactiveTeachers = filteredTeachers.filter(t => t.StatusName === 'Inactive').length;
	
	function openModal(teacher = null) {
		editingTeacher = teacher;
		if (teacher) {
			formData = {
				firstName: teacher.FirstName,
				middleName: teacher.MiddleName || '',
				lastName: teacher.LastName,
				email: teacher.Email || '',
				phone: teacher.Phone || '',
				statusId: teacher.StatusID.toString()
			};
		} else {
			formData = {
				firstName: '',
				middleName: '',
				lastName: '',
				email: '',
				phone: '',
				statusId: '1'
			};
		}
		showModal = true;
	}
	
	function closeModal() {
		showModal = false;
		editingTeacher = null;
		formData = {
			firstName: '',
			middleName: '',
			lastName: '',
			email: '',
			phone: '',
			statusId: '1'
		};
	}
	
	async function handleSubmit() {
		loading = true;
		
		try {
			const url = editingTeacher 
				? '/api/teachers' 
				: '/api/teachers';
			
			const method = editingTeacher ? 'PUT' : 'POST';
			
			const payload = editingTeacher 
				? { teacherId: editingTeacher.TeacherID, ...formData }
				: formData;
			
			const response = await fetch(url, {
				method,
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify(payload)
			});
			
			const result = await response.json();
			
			if (response.ok) {
				closeModal();
				window.location.reload();
			} else {
				alert(result.error || 'Failed to save teacher');
			}
		} catch (error) {
			console.error('Submit error:', error);
			alert('An error occurred while saving');
		} finally {
			loading = false;
		}
	}
	
	async function handleDelete(teacherId) {
		if (!confirm('Are you sure you want to delete this teacher?')) {
			return;
		}
		
		loading = true;
		
		try {
			const response = await fetch('/api/teachers', {
				method: 'DELETE',
				headers: { 'Content-Type': 'application/json' },
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
		} finally {
			loading = false;
		}
	}
</script>

<svelte:head>
	<title>Teachers - School Management System</title>
</svelte:head>

{#if isLoading}
	<div class="loading-screen" class:fade-out={loadingFadeOut}>
		<div class="loading-container">
			<div class="loading-icon">
				<svg width="100" height="100" viewBox="0 0 100 100">
					<circle cx="50" cy="50" r="45" fill="none" stroke="#3B82F6" stroke-width="4" stroke-dasharray="70 200" class="loading-circle"/>
					<text x="50" y="65" font-size="40" font-weight="bold" text-anchor="middle" fill="white">👨‍🏫</text>
				</svg>
			</div>
			
			<div class="loading-brand">
				<div class="brand-main">School Management</div>
				<div class="brand-tagline">TEACHERS MODULE</div>
			</div>
			
			<div class="loading-progress">
				<div class="progress-bar">
					<div class="progress-fill" style="width: {loadingProgress}%"></div>
				</div>
				<div class="loading-text">{loadingText}</div>
			</div>
			
			<div class="loading-dots">
				<div class="dot dot-1"></div>
				<div class="dot dot-2"></div>
				<div class="dot dot-3"></div>
			</div>
		</div>
	</div>
{/if}

<div class="page" class:visible={pageVisible}>
	<div class="page-header" class:header-scrolled={scrollY > 20}>
		<div class="header-content">
			<div class="header-title">
				<div class="icon-wrapper">
					<span class="icon">👨‍🏫</span>
				</div>
				<div>
					<h1>Teachers Management</h1>
					<p class="subtitle">Manage teaching staff information</p>
				</div>
			</div>
			
			<div class="header-actions">
				{#if session.role === 'Admin'}
					<button class="btn btn-primary" on:click={() => openModal()}>
						<span class="btn-icon">➕</span>
						Add Teacher
					</button>
				{/if}
			</div>
		</div>
	</div>
	
	<div class="container">
		<!-- Stats Cards -->
		<div class="stats-grid" class:visible={statsVisible}>
			<div class="stat-card stat-primary">
				<div class="stat-icon">👨‍🏫</div>
				<div class="stat-content">
					<div class="stat-value">{filteredTeachers.length}</div>
					<div class="stat-label">Total Teachers</div>
				</div>
			</div>
			
			<div class="stat-card stat-success">
				<div class="stat-icon">✅</div>
				<div class="stat-content">
					<div class="stat-value">{activeTeachers}</div>
					<div class="stat-label">Active</div>
				</div>
			</div>
			
			<div class="stat-card stat-warning">
				<div class="stat-icon">⏸️</div>
				<div class="stat-content">
					<div class="stat-value">{inactiveTeachers}</div>
					<div class="stat-label">Inactive</div>
				</div>
			</div>
		</div>
		
		<!-- Search and Table -->
		<div class="card" class:visible={cardsVisible}>
			<div class="card-header">
				<h3 class="card-title">👨‍🏫 Teacher Records</h3>
				
				<div class="card-actions">
					<div class="search-box">
						<span class="search-icon">🔍</span>
						<input 
							type="text" 
							placeholder="Search teachers..." 
							bind:value={searchTerm}
							class="search-input"
						/>
					</div>
				</div>
			</div>
			
			<div class="card-content">
				<div class="table-container">
					<table class="data-table">
						<thead>
							<tr>
								<th>ID</th>
								<th>Name</th>
								<th>Email</th>
								<th>Phone</th>
								<th>Status</th>
								{#if session.role === 'Admin'}
									<th>Actions</th>
								{/if}
							</tr>
						</thead>
						<tbody>
							{#each filteredTeachers as teacher}
								<tr>
									<td><span class="badge badge-neutral">{teacher.TeacherID}</span></td>
									<td>
										<div class="teacher-name">
											{teacher.FirstName} {teacher.MiddleName || ''} {teacher.LastName}
										</div>
									</td>
									<td>{teacher.Email || '-'}</td>
									<td>{teacher.Phone || '-'}</td>
									<td>
										<span class="badge badge-{teacher.StatusName === 'Active' ? 'success' : 'warning'}">
											{teacher.StatusName}
										</span>
									</td>
									{#if session.role === 'Admin'}
										<td>
											<div class="action-buttons">
												<button 
													class="btn-icon btn-edit"
													on:click={() => openModal(teacher)}
													title="Edit"
												>
													✏️
												</button>
												<button 
													class="btn-icon btn-delete"
													on:click={() => handleDelete(teacher.TeacherID)}
													title="Delete"
												>
													🗑️
												</button>
											</div>
										</td>
									{/if}
								</tr>
							{:else}
								<tr>
									<td colspan={session.role === 'Admin' ? 6 : 5} class="no-data">
										<div class="no-data-message">
											<span class="no-data-icon">📭</span>
											<p>No teachers found</p>
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

<!-- Modal -->
{#if showModal}
	<div class="modal-overlay" on:click={closeModal} role="button" tabindex="0" on:keydown={(e) => e.key === 'Escape' && closeModal()}>
		<div class="modal-content" on:click|stopPropagation role="document">
			<div class="modal-header">
				<h3>{editingTeacher ? 'Edit Teacher' : 'Add New Teacher'}</h3>
				<button class="modal-close" on:click={closeModal}>&times;</button>
			</div>
			
			<form on:submit|preventDefault={handleSubmit}>
				<div class="modal-body">
					<div class="form-group">
						<label for="firstName">First Name: <span class="required">*</span></label>
						<input 
							type="text" 
							id="firstName" 
							bind:value={formData.firstName}
							required
							placeholder="Enter first name"
						/>
					</div>
					
					<div class="form-group">
						<label for="middleName">Middle Name:</label>
						<input 
							type="text" 
							id="middleName" 
							bind:value={formData.middleName}
							placeholder="Enter middle name (optional)"
						/>
					</div>
					
					<div class="form-group">
						<label for="lastName">Last Name: <span class="required">*</span></label>
						<input 
							type="text" 
							id="lastName" 
							bind:value={formData.lastName}
							required
							placeholder="Enter last name"
						/>
					</div>
					
					<div class="form-group">
						<label for="email">Email:</label>
						<input 
							type="email" 
							id="email" 
							bind:value={formData.email}
							placeholder="Enter email address"
						/>
					</div>
					
					<div class="form-group">
						<label for="phone">Phone:</label>
						<input 
							type="tel" 
							id="phone" 
							bind:value={formData.phone}
							placeholder="Enter phone number"
						/>
					</div>
					
					<div class="form-group">
						<label for="status">Status: <span class="required">*</span></label>
						<select id="status" bind:value={formData.statusId} required>
							{#each statusList as status}
								<option value={status.StatusID}>{status.StatusName}</option>
							{/each}
						</select>
					</div>
				</div>
				
				<div class="modal-footer">
					<button type="button" class="btn btn-secondary" on:click={closeModal} disabled={loading}>
						Cancel
					</button>
					<button type="submit" class="btn btn-primary" disabled={loading}>
						{#if loading}
							Saving...
						{:else}
							{editingTeacher ? 'Update' : 'Create'}
						{/if}
					</button>
				</div>
			</form>
		</div>
	</div>
{/if}

<style>
	/* Same comprehensive styles as rooms page */
	* {
		margin: 0;
		padding: 0;
		box-sizing: border-box;
	}
	
	.page {
		min-height: 100vh;
		background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
		opacity: 0;
		transform: translateY(20px);
		transition: all 0.6s cubic-bezier(0.4, 0, 0.2, 1);
	}
	
	.page.visible {
		opacity: 1;
		transform: translateY(0);
	}
	
	.page-header {
		background: white;
		padding: 2rem;
		box-shadow: 0 2px 8px rgba(0,0,0,0.1);
		position: sticky;
		top: 0;
		z-index: 100;
		transition: all 0.3s ease;
	}
	
	.page-header.header-scrolled {
		box-shadow: 0 4px 12px rgba(0,0,0,0.15);
		padding: 1.5rem 2rem;
	}
	
	.header-content {
		max-width: 1400px;
		margin: 0 auto;
		display: flex;
		justify-content: space-between;
		align-items: center;
	}
	
	.header-title {
		display: flex;
		align-items: center;
		gap: 1.5rem;
	}
	
	.icon-wrapper {
		width: 70px;
		height: 70px;
		background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
		border-radius: 20px;
		display: flex;
		align-items: center;
		justify-content: center;
		box-shadow: 0 8px 16px rgba(102, 126, 234, 0.3);
		transition: transform 0.3s ease;
	}
	
	.icon-wrapper:hover {
		transform: scale(1.05) rotate(5deg);
	}
	
	.icon {
		font-size: 2.5rem;
	}
	
	h1 {
		font-size: 2rem;
		color: #1a1a1a;
		font-weight: 800;
		margin-bottom: 0.25rem;
	}
	
	.subtitle {
		color: #666;
		font-size: 0.95rem;
	}
	
	.container {
		max-width: 1400px;
		margin: 0 auto;
		padding: 2rem;
	}
	
	.stats-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
		gap: 1.5rem;
		margin-bottom: 2rem;
		opacity: 0;
		transform: translateY(20px);
		transition: all 0.6s cubic-bezier(0.4, 0, 0.2, 1);
	}
	
	.stats-grid.visible {
		opacity: 1;
		transform: translateY(0);
	}
	
	.stat-card {
		background: white;
		padding: 1.5rem;
		border-radius: 16px;
		display: flex;
		align-items: center;
		gap: 1.5rem;
		box-shadow: 0 4px 12px rgba(0,0,0,0.08);
		transition: all 0.3s ease;
	}
	
	.stat-card:hover {
		transform: translateY(-5px);
		box-shadow: 0 8px 20px rgba(0,0,0,0.12);
	}
	
	.stat-icon {
		font-size: 3rem;
		width: 80px;
		height: 80px;
		display: flex;
		align-items: center;
		justify-content: center;
		border-radius: 50%;
	}
	
	.stat-primary .stat-icon {
		background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
	}
	
	.stat-success .stat-icon {
		background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
	}
	
	.stat-warning .stat-icon {
		background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
	}
	
	.stat-value {
		font-size: 2.5rem;
		font-weight: 800;
		color: #1a1a1a;
	}
	
	.stat-label {
		color: #666;
		font-size: 0.95rem;
		font-weight: 500;
	}
	
	.card {
		background: white;
		border-radius: 20px;
		box-shadow: 0 8px 24px rgba(0,0,0,0.1);
		overflow: hidden;
		opacity: 0;
		transform: translateY(30px);
		transition: all 0.6s cubic-bezier(0.4, 0, 0.2, 1);
	}
	
	.card.visible {
		opacity: 1;
		transform: translateY(0);
	}
	
	.card-header {
		padding: 2rem;
		border-bottom: 1px solid #f0f0f0;
		display: flex;
		justify-content: space-between;
		align-items: center;
		flex-wrap: wrap;
		gap: 1rem;
	}
	
	.card-title {
		font-size: 1.5rem;
		font-weight: 700;
		color: #1a1a1a;
	}
	
	.search-box {
		position: relative;
		width: 300px;
	}
	
	.search-icon {
		position: absolute;
		left: 1rem;
		top: 50%;
		transform: translateY(-50%);
		font-size: 1.2rem;
	}
	
	.search-input {
		width: 100%;
		padding: 0.75rem 1rem 0.75rem 3rem;
		border: 2px solid #e0e0e0;
		border-radius: 12px;
		font-size: 1rem;
		transition: all 0.3s ease;
	}
	
	.search-input:focus {
		outline: none;
		border-color: #667eea;
		box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
	}
	
	.table-container {
		overflow-x: auto;
	}
	
	.data-table {
		width: 100%;
		border-collapse: collapse;
	}
	
	.data-table thead {
		background: #f8f9fa;
	}
	
	.data-table th {
		padding: 1rem;
		text-align: left;
		font-weight: 600;
		color: #666;
		font-size: 0.9rem;
		text-transform: uppercase;
		letter-spacing: 0.5px;
	}
	
	.data-table td {
		padding: 1rem;
		border-top: 1px solid #f0f0f0;
	}
	
	.data-table tbody tr {
		transition: background 0.2s ease;
	}
	
	.data-table tbody tr:hover {
		background: #f8f9fa;
	}
	
	.teacher-name {
		font-weight: 500;
		color: #1a1a1a;
	}
	
	.badge {
		padding: 0.4rem 0.8rem;
		border-radius: 8px;
		font-size: 0.85rem;
		font-weight: 600;
		display: inline-block;
	}
	
	.badge-success {
		background: #d4edda;
		color: #155724;
	}
	
	.badge-warning {
		background: #fff3cd;
		color: #856404;
	}
	
	.badge-neutral {
		background: #e9ecef;
		color: #495057;
	}
	
	.action-buttons {
		display: flex;
		gap: 0.5rem;
	}
	
	.btn-icon {
		padding: 0.5rem;
		border: none;
		background: transparent;
		cursor: pointer;
		border-radius: 8px;
		font-size: 1.2rem;
		transition: all 0.2s ease;
	}
	
	.btn-icon:hover {
		background: #f0f0f0;
		transform: scale(1.1);
	}
	
	.btn {
		padding: 0.75rem 1.5rem;
		border: none;
		border-radius: 12px;
		font-weight: 600;
		cursor: pointer;
		transition: all 0.3s ease;
		display: inline-flex;
		align-items: center;
		gap: 0.5rem;
	}
	
	.btn-primary {
		background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
		color: white;
	}
	
	.btn-primary:hover {
		transform: translateY(-2px);
		box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
	}
	
	.btn-secondary {
		background: #e0e0e0;
		color: #333;
	}
	
	.btn:disabled {
		opacity: 0.5;
		cursor: not-allowed;
	}
	
	.modal-overlay {
		position: fixed;
		inset: 0;
		background: rgba(0,0,0,0.5);
		display: flex;
		align-items: center;
		justify-content: center;
		z-index: 1000;
		padding: 1rem;
	}
	
	.modal-content {
		background: white;
		border-radius: 20px;
		max-width: 600px;
		width: 100%;
		max-height: 90vh;
		overflow-y: auto;
		box-shadow: 0 20px 60px rgba(0,0,0,0.3);
	}
	
	.modal-header {
		padding: 1.5rem 2rem;
		border-bottom: 1px solid #f0f0f0;
		display: flex;
		justify-content: space-between;
		align-items: center;
	}
	
	.modal-header h3 {
		font-size: 1.5rem;
		font-weight: 700;
	}
	
	.modal-close {
		background: none;
		border: none;
		font-size: 2rem;
		cursor: pointer;
		color: #999;
		transition: color 0.2s ease;
	}
	
	.modal-close:hover {
		color: #333;
	}
	
	.modal-body {
		padding: 2rem;
		display: flex;
		flex-direction: column;
		gap: 1.5rem;
	}
	
	.form-group {
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
	}
	
	.form-group label {
		font-weight: 600;
		color: #333;
	}
	
	.required {
		color: #e74c3c;
	}
	
	.form-group input,
	.form-group select {
		padding: 0.75rem;
		border: 2px solid #e0e0e0;
		border-radius: 8px;
		font-size: 1rem;
		transition: border-color 0.2s ease;
	}
	
	.form-group input:focus,
	.form-group select:focus {
		outline: none;
		border-color: #667eea;
	}
	
	.modal-footer {
		padding: 1.5rem 2rem;
		border-top: 1px solid #f0f0f0;
		display: flex;
		justify-content: flex-end;
		gap: 1rem;
	}
	
	.no-data {
		text-align: center;
		padding: 3rem;
	}
	
	.no-data-message {
		display: flex;
		flex-direction: column;
		align-items: center;
		gap: 1rem;
	}
	
	.no-data-icon {
		font-size: 4rem;
		opacity: 0.5;
	}
	
	/* Loading screen */
	.loading-screen {
		position: fixed;
		inset: 0;
		background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
		display: flex;
		align-items: center;
		justify-content: center;
		z-index: 9999;
		transition: opacity 0.8s ease;
	}
	
	.loading-screen.fade-out {
		opacity: 0;
		pointer-events: none;
	}
	
	.loading-container {
		text-align: center;
		color: white;
	}
	
	.loading-icon {
		margin-bottom: 2rem;
	}
	
	.loading-circle {
		animation: rotate 2s linear infinite;
	}
	
	@keyframes rotate {
		100% { transform: rotate(360deg); }
	}
	
	.brand-main {
		font-size: 2rem;
		font-weight: 800;
		margin-bottom: 0.5rem;
	}
	
	.brand-tagline {
		font-size: 1rem;
		opacity: 0.8;
		letter-spacing: 2px;
	}
	
	.loading-progress {
		margin-top: 2rem;
	}
	
	.progress-bar {
		width: 300px;
		height: 4px;
		background: rgba(255,255,255,0.2);
		border-radius: 2px;
		overflow: hidden;
		margin: 0 auto 1rem;
	}
	
	.progress-fill {
		height: 100%;
		background: white;
		transition: width 0.3s ease;
	}
	
	.loading-text {
		font-size: 0.9rem;
		opacity: 0.8;
	}
	
	.loading-dots {
		display: flex;
		justify-content: center;
		gap: 0.5rem;
		margin-top: 2rem;
	}
	
	.dot {
		width: 12px;
		height: 12px;
		border-radius: 50%;
		background: white;
		animation: dotBounce 1.4s ease-in-out infinite both;
	}
	
	.dot-1 { animation-delay: -0.32s; }
	.dot-2 { animation-delay: -0.16s; }
	.dot-3 { animation-delay: 0s; }
	
	@keyframes dotBounce {
		0%, 80%, 100% { transform: scale(0); }
		40% { transform: scale(1); }
	}
	
	@media (max-width: 768px) {
		.header-content {
			flex-direction: column;
			gap: 1rem;
		}
		
		.stats-grid {
			grid-template-columns: 1fr;
		}
		
		.search-box {
			width: 100%;
		}
		
		.table-container {
			overflow-x: scroll;
		}
	}
</style>
