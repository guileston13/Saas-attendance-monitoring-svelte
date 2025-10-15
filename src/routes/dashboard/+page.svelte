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
		<div class="error-message mb-2">{data.error}</div>
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
			<div class="card">
				<div class="card-header">
					<h3 class="card-title">Recent Sections</h3>
					<a href="/sections" class="btn btn-small btn-primary">View All</a>
				</div>
				<div class="table-container">
					<table>
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
			
			<div class="card">
				<div class="card-header">
					<h3 class="card-title">Recent Students</h3>
					<a href="/students" class="btn btn-small btn-primary">View All</a>
				</div>
				<div class="table-container">
					<table>
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
		
		<div class="card">
			<div class="card-header">
				<h3 class="card-title">My Sections</h3>
				<a href="/sections" class="btn btn-small btn-primary">View All</a>
			</div>
			<div class="table-container">
				<table>
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
									<a href="/sections/{section.SectionID}" class="btn btn-small btn-secondary">
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
		
		<div class="card">
			<div class="card-header">
				<h3 class="card-title">My Sections</h3>
				<a href="/my-sections" class="btn btn-small btn-primary">View All</a>
			</div>
			<div class="table-container">
				<table>
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
		max-width: 1200px;
		margin: 0 auto;
	}
	
	.dashboard-header {
		margin-bottom: 2rem;
	}
	
	.dashboard-header h1 {
		margin: 0 0 0.5rem 0;
		color: #2c3e50;
	}
	
	.welcome-text {
		color: #7f8c8d;
		margin: 0;
		font-size: 1.1rem;
	}
	
	.stats-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
		gap: 1rem;
		margin-bottom: 2rem;
	}
	
	.stat-card {
		background: white;
		padding: 1.5rem;
		border-radius: 8px;
		box-shadow: 0 2px 10px rgba(0,0,0,0.1);
		text-align: center;
	}
	
	.stat-number {
		font-size: 2.5rem;
		font-weight: bold;
		color: #3498db;
		margin-bottom: 0.5rem;
	}
	
	.stat-label {
		color: #7f8c8d;
		font-size: 1rem;
		font-weight: 500;
	}
	
	.dashboard-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
		gap: 2rem;
	}
	
	@media (max-width: 768px) {
		.stats-grid {
			grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
		}
		
		.dashboard-grid {
			grid-template-columns: 1fr;
		}
		
		.stat-number {
			font-size: 2rem;
		}
	}
</style>