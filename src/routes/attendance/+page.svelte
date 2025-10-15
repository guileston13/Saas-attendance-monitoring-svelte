<script>
	import { page } from '$app/stores';
	import { goto } from '$app/navigation';
	import { onMount } from 'svelte';
	import { generateSchoolDays, calculateAttendanceStats } from '$lib/attendance.js';
	
	/** @type {import('./$types').PageData} */
	export let data;
	
	// Reactive data
	$: availableSections = data.availableSections || [];
	$: availableSubjects = data.availableSubjects || [];
	$: isAdmin = data.session?.role === 'Admin';
	$: isTeacher = data.session?.role === 'Teacher';
	
	// State management
	let selectedSectionId = data.selectedSectionId;
	let selectedSubjectId = data.selectedSubjectId;
	let selectedMonth = data.selectedMonth;
	let selectedYear = data.selectedYear || new Date().getFullYear().toString();
	
	// Real attendance data from database
	let attendanceData = {};
	let enrolledStudents = [];
	let attendanceStatistics = {};
	let loading = false;
	let error = null;
	let updating = false; // Track when updating attendance
	
	// UI state
	let showAttendanceTable = false;
	
	// Month options
	const months = [
		{ value: '01', label: 'January' },
		{ value: '02', label: 'February' },
		{ value: '03', label: 'March' },
		{ value: '04', label: 'April' },
		{ value: '05', label: 'May' },
		{ value: '06', label: 'June' },
		{ value: '07', label: 'July' },
		{ value: '08', label: 'August' },
		{ value: '09', label: 'September' },
		{ value: '10', label: 'October' },
		{ value: '11', label: 'November' },
		{ value: '12', label: 'December' }
	];
	
	// Year options (current year ± 2)
	const currentYear = new Date().getFullYear();
	const years = [];
	for (let i = currentYear - 2; i <= currentYear + 2; i++) {
		years.push(i.toString());
	}
	
	// Computed values
	$: selectedSection = availableSections.find(s => s.SectionID.toString() === selectedSectionId);
	$: selectedSubject = availableSubjects.find(s => s.SubjectID.toString() === selectedSubjectId);
	
	// Generate calendar days for selected month
	$: calendarDays = selectedMonth && selectedYear ? generateSchoolDays(selectedYear, selectedMonth) : [];
	
	// Navigation functions
	async function selectSection(sectionId) {
		selectedSectionId = sectionId;
		selectedSubjectId = null;
		selectedMonth = null;
		showAttendanceTable = false;
		
		// Load subjects for this section
		await loadSubjects();
		updateURL();
	}
	
	function selectSubject(subjectId) {
		selectedSubjectId = subjectId;
		selectedMonth = null;
		showAttendanceTable = false;
		updateURL();
	}
	
	async function selectMonth(month) {
		selectedMonth = month;
		await loadAttendanceData();
		updateURL();
	}
	
	function selectYear(year) {
		selectedYear = year;
		if (selectedMonth) {
			loadAttendanceData();
		}
		updateURL();
	}
	
	function updateURL() {
		const params = new URLSearchParams();
		if (selectedSectionId) params.set('section', selectedSectionId);
		if (selectedSubjectId) params.set('subject', selectedSubjectId);
		if (selectedMonth) params.set('month', selectedMonth);
		if (selectedYear) params.set('year', selectedYear);
		
		goto(`/attendance?${params.toString()}`, { replaceState: true });
	}
	
	// Load subjects for selected section
	async function loadSubjects() {
		if (!selectedSectionId) return;
		
		try {
			const response = await fetch(`/api/attendance/sections/${selectedSectionId}`, {
				credentials: 'include'
			});
			
			if (response.ok) {
				const result = await response.json();
				availableSubjects = result.subjects || [];
			} else {
				console.error('Failed to load subjects');
				availableSubjects = [];
			}
		} catch (err) {
			availableSubjects = [];
		}
	}
	
	// Load real attendance data from database
	async function loadAttendanceData() {
		if (!selectedSectionId || !selectedSubjectId || !selectedMonth || !selectedYear) return;
		
		loading = true;
		error = null;
		
		try {
			// Check if records exist, if not generate them
			const existsResponse = await fetch(`/api/attendance?sectionId=${selectedSectionId}&subjectId=${selectedSubjectId}&year=${selectedYear}&month=${selectedMonth}&action=exists`, {
				credentials: 'include'
			});
			
			if (existsResponse.ok) {
				const existsResult = await existsResponse.json();
				
				if (!existsResult.data.exists) {
					// Generate attendance records for this month
					await generateAttendanceRecords();
				}
			}
			
			// Load attendance records
			const [recordsResponse, studentsResponse, statsResponse] = await Promise.all([
				fetch(`/api/attendance?sectionId=${selectedSectionId}&subjectId=${selectedSubjectId}&year=${selectedYear}&month=${selectedMonth}&action=records`, {
					credentials: 'include'
				}),
				fetch(`/api/attendance?sectionId=${selectedSectionId}&subjectId=${selectedSubjectId}&year=${selectedYear}&month=${selectedMonth}&action=students`, {
					credentials: 'include'
				}),
				fetch(`/api/attendance?sectionId=${selectedSectionId}&subjectId=${selectedSubjectId}&year=${selectedYear}&month=${selectedMonth}&action=statistics`, {
					credentials: 'include'
				})
			]);
			
			if (recordsResponse.ok && studentsResponse.ok && statsResponse.ok) {
				const recordsResult = await recordsResponse.json();
				const studentsResult = await studentsResponse.json();
				const statsResult = await statsResponse.json();
				
				// Process attendance data
				const attendanceRecords = recordsResult.data;
				const tempAttendanceData = {};
				enrolledStudents = studentsResult.data;
				attendanceStatistics = statsResult.data;
				
				// Convert database format to UI format
				Object.keys(attendanceRecords).forEach(studentId => {
					const studentIdStr = studentId.toString();
					tempAttendanceData[studentIdStr] = {};
					
					if (attendanceRecords[studentId].attendance) {
						Object.keys(attendanceRecords[studentId].attendance).forEach(date => {
							tempAttendanceData[studentIdStr][date] = attendanceRecords[studentId].attendance[date].status;
						});
					}
				});
				
				// Ensure all enrolled students have entries (even if no attendance records)
				enrolledStudents.forEach(student => {
					const studentIdStr = student.StudentID.toString();
					if (!tempAttendanceData[studentIdStr]) {
						tempAttendanceData[studentIdStr] = {};
					}
					
					// Fill in missing dates with 'absent' for UI consistency
					calendarDays.forEach(day => {
						if (!tempAttendanceData[studentIdStr][day.date]) {
							tempAttendanceData[studentIdStr][day.date] = 'absent';
						}
					});
				});
				
				// Update attendance data with new reference for reactivity
				attendanceData = tempAttendanceData;
				showAttendanceTable = true;
			} else {
				throw new Error('Failed to load attendance data');
			}
		} catch (err) {
			error = err.message;
			showAttendanceTable = false;
		} finally {
			loading = false;
		}
	}
	
	// Generate attendance records for a new month
	async function generateAttendanceRecords() {
		try {
			const response = await fetch('/api/attendance', {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json'
				},
				credentials: 'include',
				body: JSON.stringify({
					action: 'generate',
					sectionId: parseInt(selectedSectionId),
					subjectId: parseInt(selectedSubjectId),
					year: selectedYear,
					month: selectedMonth
				})
			});
			
			if (!response.ok) {
				throw new Error('Failed to generate attendance records');
			}
		} catch (err) {
			// Silent error handling for generate function
		}
	}
	
	// Toggle attendance status
	async function toggleAttendance(studentId, date) {
		if (updating) return; // Prevent multiple simultaneous updates
		
		const studentIdStr = studentId.toString();
		const current = attendanceData[studentIdStr]?.[date] || 'absent';
		const newStatus = current === 'present' ? 'Absent' : 'Present'; // Database expects capitalized
		
		updating = true;
		
		try {
			const requestBody = {
				action: 'update',
				studentId: parseInt(studentId),
				subjectId: parseInt(selectedSubjectId),
				sectionId: parseInt(selectedSectionId),
				date: date,
				status: newStatus
			};
			
			const response = await fetch('/api/attendance', {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json'
				},
				credentials: 'include',
				body: JSON.stringify(requestBody)
			});
			
			if (response.ok) {
				// Optimistically update the UI immediately for better UX
				if (!attendanceData[studentIdStr]) {
					attendanceData[studentIdStr] = {};
				}
				attendanceData[studentIdStr][date] = newStatus.toLowerCase();
				
				// Trigger reactivity
				attendanceData = { ...attendanceData };
				
				// Also reload data in background to ensure consistency
				setTimeout(() => loadAttendanceData(), 100);
			} else {
				const errorResult = await response.json();
				throw new Error(errorResult.error || 'Failed to update attendance');
			}
		} catch (err) {
			error = `Failed to update attendance: ${err.message}`;
			
			// Clear error message after 3 seconds
			setTimeout(() => {
				error = null;
			}, 3000);
		} finally {
			updating = false;
		}
	}
	
	// Force refresh attendance data
	async function refreshAttendanceData() {
		await loadAttendanceData();
	}
	
	function resetSelection() {
		selectedSectionId = null;
		selectedSubjectId = null;
		selectedMonth = null;
		showAttendanceTable = false;
		goto('/attendance');
	}
	
	// Get month name
	function getMonthName(monthValue) {
		const month = months.find(m => m.value === monthValue);
		return month ? month.label : '';
	}
	
	// Count attendance statistics
	function getAttendanceStats(studentId) {
		if (!attendanceData[studentId]) return { present: 0, absent: 0, total: 0 };
		
		const records = Object.values(attendanceData[studentId]);
		const present = records.filter(status => status === 'present').length;
		const absent = records.filter(status => status === 'absent').length;
		
		return { present, absent, total: records.length };
	}
	
	onMount(() => {
		// Auto-load attendance if all parameters are present
		if (selectedSectionId && selectedSubjectId && selectedMonth && selectedYear) {
			loadAttendanceData();
		}
		
		// Load subjects if section is selected
		if (selectedSectionId && !selectedSubjectId) {
			loadSubjects();
		}
	});
</script>

<svelte:head>
	<title>Attendance Management - School Management System</title>
</svelte:head>

<div class="attendance-page">
	<!-- Breadcrumb Navigation -->
	<div class="breadcrumb">
		<button class="breadcrumb-item" class:active={!selectedSectionId} on:click={resetSelection}>
			Attendance
		</button>
		{#if selectedSection}
			<span class="breadcrumb-separator">›</span>
			<button class="breadcrumb-item" class:active={selectedSectionId && !selectedSubjectId} on:click={() => selectSection(selectedSectionId)}>
				{selectedSection.SectionName}
			</button>
		{/if}
		{#if selectedSubject}
			<span class="breadcrumb-separator">›</span>
			<button class="breadcrumb-item" class:active={selectedSubjectId && !selectedMonth} on:click={() => selectSubject(selectedSubjectId)}>
				{selectedSubject.SubjectName}
			</button>
		{/if}
		{#if selectedMonth}
			<span class="breadcrumb-separator">›</span>
			<span class="breadcrumb-item active">
				{getMonthName(selectedMonth)} {selectedYear}
			</span>
		{/if}
	</div>

	{#if data.error}
		<div class="error-message">{data.error}</div>
	{/if}
	
	{#if error}
		<div class="error-message">{error}</div>
	{/if}

	<!-- Step 1: Section Selection -->
	{#if !selectedSectionId}
		<div class="step-container">
			<div class="step-header">
				<h1>📋 Attendance Management</h1>
				<p class="step-description">Select a section to manage attendance</p>
			</div>
			
			<div class="selection-grid">
				{#each availableSections as section}
					<div class="selection-card" on:click={() => selectSection(section.SectionID.toString())}>
						<div class="card-icon">🏫</div>
						<h3>{section.SectionName}</h3>
						<p class="card-subtitle">{section.YearLevel}</p>
						<div class="card-stats">
							<span class="stat">📚 {availableSubjects.length} Subjects</span>
							<span class="stat">👥 {section.TotalStudents || 0} Students</span>
						</div>
					</div>
				{:else}
					<div class="empty-state">
						<h3>No sections available</h3>
						<p>You don't have access to any sections.</p>
					</div>
				{/each}
			</div>
		</div>

	<!-- Step 2: Subject Selection -->
	{:else if !selectedSubjectId}
		<div class="step-container">
			<div class="step-header">
				<h2>📚 Select Subject</h2>
				<p class="step-description">Choose a subject in {selectedSection.SectionName}</p>
			</div>
			
			<div class="selection-grid">
				{#each availableSubjects as subject}
					<div class="selection-card" on:click={() => selectSubject(subject.SubjectID.toString())}>
						<div class="card-icon">📖</div>
						<h3>{subject.SubjectName}</h3>
						<p class="card-subtitle">{subject.SubjectCode}</p>
						<div class="card-action">
							<span>View Attendance →</span>
						</div>
					</div>
				{:else}
					<div class="empty-state">
						<h3>No subjects found</h3>
						<p>No subjects are assigned to this section.</p>
					</div>
				{/each}
			</div>
		</div>

	<!-- Step 3: Month/Year Selection -->
	{:else if !selectedMonth}
		<div class="step-container">
			<div class="step-header">
				<h2>📅 Select Month</h2>
				<p class="step-description">Choose month and year for {selectedSubject.SubjectName} attendance</p>
			</div>
			
			<!-- Year Selector -->
			<div class="year-selector">
				<label for="year-select">Year:</label>
				<select id="year-select" bind:value={selectedYear} on:change={() => selectYear(selectedYear)}>
					{#each years as year}
						<option value={year}>{year}</option>
					{/each}
				</select>
			</div>
			
			<!-- Month Grid -->
			<div class="month-grid">
				{#each months as month}
					<div class="month-card" on:click={() => selectMonth(month.value)}>
						<h3>{month.label}</h3>
						<p>{selectedYear}</p>
					</div>
				{/each}
			</div>
		</div>

	<!-- Step 4: Attendance Table -->
	{:else}
		<div class="attendance-container">
			<div class="attendance-header">
				<div class="header-info">
					<h2>📋 Attendance Record</h2>
					<div class="header-details">
						<span class="detail">🏫 {selectedSection.SectionName}</span>
						<span class="detail">📚 {selectedSubject.SubjectName}</span>
						<span class="detail">📅 {getMonthName(selectedMonth)} {selectedYear}</span>
					</div>
				</div>
				
				<div class="header-actions">
					<button class="btn btn-secondary" on:click={refreshAttendanceData} disabled={loading}>
						{#if loading}
							🔄 Loading...
						{:else}
							🔄 Refresh
						{/if}
					</button>
					<button class="btn btn-secondary" on:click={() => { selectedMonth = null; showAttendanceTable = false; }}>
						Change Month
					</button>
				</div>
			</div>

			{#if loading}
				<div class="loading-state">
					<div class="spinner"></div>
					<p>Loading attendance data...</p>
				</div>
			{:else if showAttendanceTable}
				<div class="attendance-table-container">
					<!-- Attendance Statistics Summary -->
					<div class="stats-summary">
						<div class="stat-card">
							<span class="stat-number">{enrolledStudents.length}</span>
							<span class="stat-label">Students</span>
						</div>
						<div class="stat-card">
							<span class="stat-number">{calendarDays.length}</span>
							<span class="stat-label">School Days</span>
						</div>
						<div class="stat-card">
							<span class="stat-number">
								{attendanceStatistics.attendance_percentage || 0}%
							</span>
							<span class="stat-label">Avg Attendance</span>
						</div>
					</div>

					<!-- Attendance Table -->
					<div class="table-wrapper">
						<table class="attendance-table">
							<thead>
								<tr>
									<th class="student-column">Student</th>
									{#each calendarDays as day}
										<th class="date-column">
											<div class="date-header">
												<span class="day-name">{day.dayName}</span>
												<span class="day-number">{day.day}</span>
											</div>
										</th>
									{/each}
									<th class="stats-column">Stats</th>
								</tr>
							</thead>
							<tbody>
								{#each enrolledStudents as student}
									{@const stats = getAttendanceStats(student.StudentID)}
									<tr>
										<td class="student-cell">
											<div class="student-info">
												<span class="student-name">{student.FirstName} {student.LastName}</span>
												<span class="student-id">{student.StudentID}</span>
											</div>
										</td>
										{#each calendarDays as day, dayIndex}
											{@const status = attendanceData[student.StudentID]?.[day.date] || 'absent'}
											<td class="attendance-cell">
												<button 
													class="attendance-btn {status}"
													on:click={(e) => {
														e.preventDefault();
														e.stopPropagation();
														toggleAttendance(student.StudentID, day.date);
													}}
													title="Click to toggle attendance for {day.dayName} {day.day} - Current: {status}"
													disabled={updating}
												>
													{status === 'present' ? '✅' : '❌'}
												</button>
											</td>
										{/each}
										<td class="stats-cell">
											<div class="student-stats">
												<span class="present-count">✅ {stats.present}</span>
												<span class="absent-count">❌ {stats.absent}</span>
												<span class="percentage">
													{stats.total > 0 ? Math.round((stats.present / stats.total) * 100) : 0}%
												</span>
											</div>
										</td>
									</tr>
								{:else}
									<tr>
										<td colspan="{calendarDays.length + 2}" class="no-students">
											No students enrolled in this subject.
										</td>
									</tr>
								{/each}
							</tbody>
						</table>
					</div>
				</div>
			{/if}
		</div>
	{/if}
</div>

<style>
	.attendance-page {
		max-width: 1400px;
		margin: 0 auto;
		padding: 1rem;
	}
	
	/* Breadcrumb Navigation */
	.breadcrumb {
		display: flex;
		align-items: center;
		margin-bottom: 2rem;
		padding: 1rem;
		background: white;
		border-radius: 8px;
		box-shadow: 0 2px 4px rgba(0,0,0,0.1);
	}
	
	.breadcrumb-item {
		background: none;
		border: none;
		color: #3498db;
		cursor: pointer;
		font-size: 1rem;
		text-decoration: underline;
		padding: 0.25rem 0.5rem;
		border-radius: 4px;
		transition: background-color 0.2s;
	}
	
	.breadcrumb-item:hover {
		background: #f8f9fa;
	}
	
	.breadcrumb-item.active {
		color: #2c3e50;
		cursor: default;
		text-decoration: none;
		font-weight: 500;
	}
	
	.breadcrumb-separator {
		margin: 0 0.5rem;
		color: #bdc3c7;
	}
	
	/* Step Container */
	.step-container {
		background: white;
		border-radius: 12px;
		box-shadow: 0 4px 20px rgba(0,0,0,0.1);
		overflow: hidden;
	}
	
	.step-header {
		padding: 2rem;
		background: linear-gradient(135deg, #3498db, #2980b9);
		color: white;
		text-align: center;
	}
	
	.step-header h1, .step-header h2 {
		margin: 0 0 0.5rem 0;
		font-size: 2rem;
	}
	
	.step-description {
		margin: 0;
		opacity: 0.9;
		font-size: 1.1rem;
	}
	
	/* Selection Grids */
	.selection-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
		gap: 1.5rem;
		padding: 2rem;
	}
	
	.selection-card {
		background: white;
		border: 2px solid #ecf0f1;
		border-radius: 12px;
		padding: 1.5rem;
		cursor: pointer;
		transition: all 0.3s ease;
		text-align: center;
	}
	
	.selection-card:hover {
		border-color: #3498db;
		transform: translateY(-4px);
		box-shadow: 0 8px 25px rgba(52, 152, 219, 0.15);
	}
	
	.card-icon {
		font-size: 3rem;
		margin-bottom: 1rem;
	}
	
	.selection-card h3 {
		margin: 0 0 0.5rem 0;
		color: #2c3e50;
		font-size: 1.3rem;
	}
	
	.card-subtitle {
		color: #7f8c8d;
		margin: 0 0 1rem 0;
	}
	
	.card-stats {
		display: flex;
		justify-content: center;
		gap: 1rem;
		flex-wrap: wrap;
	}
	
	.stat {
		background: #f8f9fa;
		padding: 0.25rem 0.75rem;
		border-radius: 20px;
		font-size: 0.9rem;
		color: #5a6c7d;
	}
	
	.card-action {
		color: #3498db;
		font-weight: 500;
		margin-top: 1rem;
	}
	
	/* Year Selector */
	.year-selector {
		text-align: center;
		padding: 2rem;
		border-bottom: 1px solid #ecf0f1;
	}
	
	.year-selector label {
		font-weight: 500;
		margin-right: 1rem;
		color: #2c3e50;
	}
	
	.year-selector select {
		padding: 0.5rem 1rem;
		border: 2px solid #ecf0f1;
		border-radius: 6px;
		font-size: 1rem;
		background: white;
	}
	
	/* Month Grid */
	.month-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
		gap: 1rem;
		padding: 2rem;
	}
	
	.month-card {
		background: white;
		border: 2px solid #ecf0f1;
		border-radius: 8px;
		padding: 1rem;
		cursor: pointer;
		text-align: center;
		transition: all 0.2s ease;
	}
	
	.month-card:hover {
		border-color: #3498db;
		background: #f8f9fa;
	}
	
	.month-card h3 {
		margin: 0 0 0.5rem 0;
		color: #2c3e50;
		font-size: 1.1rem;
	}
	
	.month-card p {
		margin: 0;
		color: #7f8c8d;
		font-size: 0.9rem;
	}
	
	/* Attendance Container */
	.attendance-container {
		background: white;
		border-radius: 12px;
		box-shadow: 0 4px 20px rgba(0,0,0,0.1);
		overflow: hidden;
	}
	
	.attendance-header {
		padding: 2rem;
		background: linear-gradient(135deg, #27ae60, #2ecc71);
		color: white;
		display: flex;
		justify-content: space-between;
		align-items: center;
		flex-wrap: wrap;
		gap: 1rem;
	}
	
	.attendance-header h2 {
		margin: 0 0 0.5rem 0;
		font-size: 1.8rem;
	}
	
	.header-details {
		display: flex;
		gap: 1rem;
		flex-wrap: wrap;
	}
	
	.detail {
		background: rgba(255,255,255,0.2);
		padding: 0.25rem 0.75rem;
		border-radius: 20px;
		font-size: 0.9rem;
	}
	
	/* Statistics Summary */
	.stats-summary {
		display: flex;
		gap: 1rem;
		padding: 2rem;
		justify-content: center;
	}
	
	.stat-card {
		background: #f8f9fa;
		padding: 1rem 1.5rem;
		border-radius: 8px;
		text-align: center;
		min-width: 100px;
	}
	
	.stat-number {
		display: block;
		font-size: 1.8rem;
		font-weight: bold;
		color: #2c3e50;
	}
	
	.stat-label {
		display: block;
		font-size: 0.9rem;
		color: #7f8c8d;
		margin-top: 0.25rem;
	}
	
	/* Attendance Table */
	.table-wrapper {
		overflow-x: auto;
		padding: 0 2rem 2rem;
	}
	
	.attendance-table {
		width: 100%;
		border-collapse: collapse;
		background: white;
		border-radius: 8px;
		overflow: hidden;
		box-shadow: 0 2px 10px rgba(0,0,0,0.1);
	}
	
	.attendance-table th {
		background: #34495e;
		color: white;
		padding: 1rem 0.5rem;
		text-align: center;
		font-weight: 500;
		border: 1px solid #2c3e50;
	}
	
	.student-column {
		min-width: 200px;
		text-align: left !important;
	}
	
	.date-column {
		min-width: 60px;
	}
	
	.stats-column {
		min-width: 120px;
	}
	
	.date-header {
		display: flex;
		flex-direction: column;
		gap: 0.25rem;
	}
	
	.day-name {
		font-size: 0.8rem;
		opacity: 0.8;
	}
	
	.day-number {
		font-size: 1rem;
		font-weight: bold;
	}
	
	.attendance-table td {
		padding: 0.75rem 0.5rem;
		border: 1px solid #ecf0f1;
		text-align: center;
	}
	
	.student-cell {
		text-align: left !important;
		background: #f8f9fa;
	}
	
	.student-info {
		display: flex;
		flex-direction: column;
		gap: 0.25rem;
	}
	
	.student-name {
		font-weight: 500;
		color: #2c3e50;
	}
	
	.student-id {
		font-size: 0.8rem;
		color: #7f8c8d;
	}
	
	.attendance-btn {
		background: none;
		border: none;
		font-size: 1.2rem;
		cursor: pointer;
		padding: 0.25rem;
		border-radius: 4px;
		transition: all 0.2s ease;
		width: 32px;
		height: 32px;
		display: flex;
		align-items: center;
		justify-content: center;
	}
	
	.attendance-btn:hover {
		background: #f8f9fa;
		transform: scale(1.1);
	}
	
	.attendance-btn.present {
		background: #d4edda;
	}
	
	.attendance-btn.absent {
		background: rgba(231, 76, 60, 0.1);
	}
	
	.attendance-btn:disabled {
		opacity: 0.6;
		cursor: not-allowed;
		background: rgba(255, 193, 7, 0.2);
	}
	
	.student-stats {
		display: flex;
		flex-direction: column;
		gap: 0.25rem;
		font-size: 0.9rem;
	}
	
	.present-count {
		color: #27ae60;
	}
	
	.absent-count {
		color: #e74c3c;
	}
	
	.percentage {
		font-weight: bold;
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
	
	.btn-secondary {
		background: #6c757d;
		color: white;
	}
	
	.btn-secondary:hover {
		background: #545b62;
	}
	
	/* Responsive Design */
	@media (max-width: 768px) {
		.attendance-page {
			padding: 0.5rem;
		}
		
		.selection-grid {
			grid-template-columns: 1fr;
			padding: 1rem;
		}
		
		.month-grid {
			grid-template-columns: repeat(2, 1fr);
			padding: 1rem;
		}
		
		.attendance-header {
			flex-direction: column;
			align-items: flex-start;
		}
		
		.header-details {
			flex-direction: column;
			gap: 0.5rem;
		}
		
		.stats-summary {
			flex-direction: column;
			align-items: center;
		}
		
		.table-wrapper {
			padding: 0 1rem 1rem;
		}
		
		.attendance-table {
			font-size: 0.9rem;
		}
		
		.date-column {
			min-width: 50px;
		}
		
		.attendance-btn {
			width: 28px;
			height: 28px;
			font-size: 1rem;
		}
	}
</style>