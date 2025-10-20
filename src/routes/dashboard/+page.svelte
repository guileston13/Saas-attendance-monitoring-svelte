<script>
	// Dashboard page component
	/** @type {import('./$types').PageData} */
	export let data;
	
	$: session = data.session;
	$: stats = data.stats || {};
	$: sections = data.sections || [];
	$: students = data.students || [];
	$: teachers = data.teachers || [];
	$: subjects = data.subjects || [];
</script>

<svelte:head>
	<title>Dashboard - School Management System</title>
</svelte:head>

<div class="dashboard">
	<div class="dashboard-header">
		<h1>Dashboard</h1>
		<p class="welcome-text">Welcome back, {session.email}</p>
	</div>
	
	{#if data.error}
		<div class="error-message">{data.error}</div>
	{/if}
	
	<!-- Admin Dashboard -->
	{#if session.role === 'Admin'}
		<div class="stats-grid">
			<div class="stat-card">
				<div class="stat-number">{stats.totalSections || 0}</div>
				<div class="stat-label">Total Sections</div>
			</div>
			<div class="stat-card">
				<div class="stat-number">{stats.totalStudents || 0}</div>
				<div class="stat-label">Total Students</div>
			</div>
			<div class="stat-card">
				<div class="stat-number">{stats.totalTeachers || 0}</div>
				<div class="stat-label">Total Teachers</div>
			</div>
			<div class="stat-card">
				<div class="stat-number">{stats.totalSubjects || 0}</div>
				<div class="stat-label">Total Subjects</div>
			</div>
		</div>
		
		<div class="dashboard-grid">
			<div class="dashboard-card">
				<div class="card-header">
					<h3 class="card-title">📋 Recent Sections</h3>
					<a href="/sections" class="btn btn-primary">View All →</a>
				</div>
				<div class="table-container">
					<table class="data-table">
						<thead>
							<tr>
								<th>Section Name</th>
								<th>Students</th>
							</tr>
						</thead>
						<tbody>
							{#each sections.slice(0, 5) as section}
								<tr>
									<td>{section.SectionName}</td>
									<td>{section.StudentCount || 0}</td>
								</tr>
							{:else}
								<tr><td colspan="2" class="text-center">No sections found</td></tr>
							{/each}
						</tbody>
					</table>
				</div>
			</div>
			
			<div class="dashboard-card">
				<div class="card-header">
					<h3 class="card-title">👥 Recent Students</h3>
					<a href="/students" class="btn btn-primary">View All →</a>
				</div>
				<div class="table-container">
					<table class="data-table">
						<thead>
							<tr>
								<th>Student ID</th>
								<th>Name</th>
								<th>Year Level</th>
							</tr>
						</thead>
						<tbody>
							{#each students.slice(0, 5) as student}
								<tr>
									<td>{student.StudentID}</td>
									<td>{student.FirstName} {student.LastName}</td>
									<td>{student.YearLevel}</td>
								</tr>
							{:else}
								<tr><td colspan="3" class="text-center">No students found</td></tr>
							{/each}
						</tbody>
					</table>
				</div>
			</div>
		</div>
	{/if}
	
	<!-- Teacher Dashboard -->
	{#if session.role === 'Teacher'}
		<div class="stats-grid">
			<div class="stat-card">
				<div class="stat-number">{stats.mySections || 0}</div>
				<div class="stat-label">My Sections</div>
			</div>
			<div class="stat-card">
				<div class="stat-number">{stats.myStudents || 0}</div>
				<div class="stat-label">My Students</div>
			</div>
		</div>
		
		<div class="dashboard-card">
			<div class="card-header">
				<h3 class="card-title">🏫 My Sections</h3>
				<a href="/sections" class="btn btn-primary">View All →</a>
			</div>
			<div class="table-container">
				<table class="data-table">
					<thead>
						<tr>
							<th>Section Name</th>
							<th>Students</th>
							<th>Actions</th>
						</tr>
					</thead>
					<tbody>
						{#each sections as section}
							<tr>
								<td>{section.SectionName}</td>
								<td>{section.StudentCount || 0}</td>
								<td>
									<a href="/sections/{section.SectionID}" class="btn btn-secondary">
										View Details
									</a>
								</td>
							</tr>
						{:else}
							<tr><td colspan="3" class="text-center">No sections assigned</td></tr>
						{/each}
					</tbody>
				</table>
			</div>
		</div>
	{/if}
	
	<!-- Student Dashboard -->
	{#if session.role === 'Student'}
		<div class="stats-grid">
			<div class="stat-card">
				<div class="stat-number">{stats.enrolledSections || 0}</div>
				<div class="stat-label">Enrolled Sections</div>
			</div>
		</div>
		
		<div class="dashboard-card">
			<div class="card-header">
				<h3 class="card-title">📚 My Sections</h3>
				<a href="/my-sections" class="btn btn-primary">View All →</a>
			</div>
			<div class="table-container">
				<table class="data-table">
					<thead>
						<tr>
							<th>Section Name</th>
							<th>Students</th>
						</tr>
					</thead>
					<tbody>
						{#each sections as section}
							<tr>
								<td>{section.SectionName}</td>
								<td>{section.StudentCount || 0}</td>
							</tr>
						{:else}
							<tr><td colspan="2" class="text-center">No sections enrolled</td></tr>
						{/each}
					</tbody>
				</table>
			</div>
		</div>
	{/if}
</div>

<style>
	.dashboard {
		max-width: 1400px;
		margin: 0 auto;
		padding: 1rem;
	}
	
	.dashboard-header {
		margin-bottom: 2rem;
		text-align: center;
	}
	
	.dashboard-header h1 {
		margin: 0 0 0.5rem 0;
		color: #2c3e50;
		font-size: 2.5rem;
		font-weight: 600;
	}
	
	.welcome-text {
		color: #7f8c8d;
		margin: 0;
		font-size: 1.1rem;
	}
	
	/* Stats Grid - Matching attendance module */
	.stats-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
		gap: 1.5rem;
		margin-bottom: 2rem;
	}
	
	.stat-card {
		background: white;
		padding: 2rem;
		border-radius: 12px;
		box-shadow: 0 4px 20px rgba(0,0,0,0.1);
		text-align: center;
		transition: transform 0.3s ease, box-shadow 0.3s ease;
	}
	
	.stat-card:hover {
		transform: translateY(-4px);
		box-shadow: 0 8px 25px rgba(52, 152, 219, 0.15);
	}
	
	.stat-number {
		font-size: 3rem;
		font-weight: bold;
		color: #3498db;
		margin-bottom: 0.5rem;
		display: block;
	}
	
	.stat-label {
		color: #7f8c8d;
		font-size: 1rem;
		font-weight: 500;
	}
	
	/* Dashboard Grid */
	.dashboard-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
		gap: 2rem;
	}
	
	/* Dashboard Cards - Matching attendance module design */
	.dashboard-card {
		background: white;
		border-radius: 12px;
		box-shadow: 0 4px 20px rgba(0,0,0,0.1);
		overflow: hidden;
		transition: transform 0.3s ease, box-shadow 0.3s ease;
	}
	
	.dashboard-card:hover {
		transform: translateY(-4px);
		box-shadow: 0 8px 25px rgba(52, 152, 219, 0.15);
	}
	
	.card-header {
		padding: 2rem;
		background: linear-gradient(135deg, #3498db, #2980b9);
		color: white;
		display: flex;
		justify-content: space-between;
		align-items: center;
		flex-wrap: wrap;
		gap: 1rem;
	}
	
	.card-title {
		margin: 0;
		font-size: 1.5rem;
		font-weight: 600;
	}
	
	/* Table Styles - Matching attendance module */
	.table-container {
		padding: 0 2rem 2rem;
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
		padding: 1rem 0.5rem;
		text-align: left;
		font-weight: 500;
		border: 1px solid #2c3e50;
	}
	
	.data-table td {
		padding: 1rem 0.5rem;
		border: 1px solid #ecf0f1;
		color: #2c3e50;
	}
	
	.data-table tbody tr:hover {
		background: #f8f9fa;
	}
	
	.text-center {
		text-align: center;
		color: #7f8c8d;
		font-style: italic;
	}
	
	/* Button Styles - Matching attendance module */
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
		background: #5a6268;
		transform: translateY(-1px);
		box-shadow: 0 4px 12px rgba(108, 117, 125, 0.3);
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
	
	/* Responsive Design */
	@media (max-width: 768px) {
		.dashboard {
			padding: 0.5rem;
		}
		
		.stats-grid {
			grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
		}
		
		.dashboard-grid {
			grid-template-columns: 1fr;
		}
		
		.stat-number {
			font-size: 2rem;
		}
		
		.card-header {
			flex-direction: column;
			align-items: flex-start;
			text-align: left;
		}
		
		.table-container {
			padding: 0 1rem 1rem;
		}
		
		.data-table {
			font-size: 0.9rem;
		}
	}
</style>