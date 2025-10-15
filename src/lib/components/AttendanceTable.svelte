<script>
	import { createEventDispatcher } from 'svelte';
	import { calculateAttendanceStats } from '../lib/attendance.js';
	
	export let students = [];
	export let days = [];
	export let attendanceData = {};
	export let readOnly = false;
	
	const dispatch = createEventDispatcher();
	
	function toggleAttendance(studentId, date) {
		if (readOnly) return;
		
		const current = attendanceData[studentId]?.[date] || 'absent';
		const newStatus = current === 'present' ? 'absent' : 'present';
		
		dispatch('attendanceChange', {
			studentId,
			date,
			status: newStatus,
			previousStatus: current
		});
	}
	
	function getAttendanceStatus(studentId, date) {
		return attendanceData[studentId]?.[date] || 'absent';
	}
	
	$: classroomStats = {
		totalStudents: students.length,
		totalDays: days.length,
		totalRecords: students.length * days.length,
		overallAttendance: students.length > 0 ? Math.round(
			students.reduce((acc, student) => {
				const stats = calculateAttendanceStats(attendanceData[student.StudentID]);
				return acc + stats.percentage;
			}, 0) / students.length
		) : 0
	};
</script>

<div class="attendance-table-component">
	<!-- Summary Statistics -->
	<div class="table-summary">
		<div class="summary-stats">
			<div class="stat-item">
				<span class="stat-number">{classroomStats.totalStudents}</span>
				<span class="stat-label">Students</span>
			</div>
			<div class="stat-item">
				<span class="stat-number">{classroomStats.totalDays}</span>
				<span class="stat-label">School Days</span>
			</div>
			<div class="stat-item">
				<span class="stat-number">{classroomStats.overallAttendance}%</span>
				<span class="stat-label">Class Average</span>
			</div>
		</div>
		
		<div class="legend">
			<div class="legend-item">
				<span class="legend-icon present">✅</span>
				<span>Present</span>
			</div>
			<div class="legend-item">
				<span class="legend-icon absent">❌</span>
				<span>Absent</span>
			</div>
		</div>
	</div>

	<!-- Attendance Table -->
	<div class="table-container">
		<table class="attendance-table">
			<thead>
				<tr>
					<th class="student-header">Student</th>
					{#each days as day}
						<th class="date-header">
							<div class="date-info">
								<span class="day-name">{day.dayName}</span>
								<span class="day-number">{day.day}</span>
							</div>
						</th>
					{/each}
					<th class="stats-header">Statistics</th>
				</tr>
			</thead>
			<tbody>
				{#each students as student}
					{@const stats = calculateAttendanceStats(attendanceData[student.StudentID])}
					<tr class="student-row">
						<td class="student-cell">
							<div class="student-info">
								<div class="student-name">{student.FirstName} {student.LastName}</div>
								<div class="student-id">{student.StudentID}</div>
							</div>
						</td>
						{#each days as day}
							{@const status = getAttendanceStatus(student.StudentID, day.date)}
							<td class="attendance-cell">
								<button 
									class="attendance-button {status}"
									class:readonly={readOnly}
									on:click={() => toggleAttendance(student.StudentID, day.date)}
									disabled={readOnly}
									title={readOnly ? `${status} (Read-only)` : `Click to mark ${status === 'present' ? 'absent' : 'present'}`}
								>
									{status === 'present' ? '✅' : '❌'}
								</button>
							</td>
						{/each}
						<td class="stats-cell">
							<div class="student-stats">
								<div class="stat-row">
									<span class="present-stat">✅ {stats.present}</span>
									<span class="absent-stat">❌ {stats.absent}</span>
								</div>
								<div class="percentage-stat" class:low={stats.percentage < 75} class:medium={stats.percentage >= 75 && stats.percentage < 90}>
									{stats.percentage}%
								</div>
							</div>
						</td>
					</tr>
				{:else}
					<tr>
						<td colspan="{days.length + 2}" class="no-data">
							No students found for this section.
						</td>
					</tr>
				{/each}
			</tbody>
		</table>
	</div>
</div>

<style>
	.attendance-table-component {
		background: white;
		border-radius: 8px;
		overflow: hidden;
		box-shadow: 0 2px 10px rgba(0,0,0,0.1);
	}
	
	.table-summary {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: 1.5rem 2rem;
		background: #f8f9fa;
		border-bottom: 1px solid #dee2e6;
		flex-wrap: wrap;
		gap: 1rem;
	}
	
	.summary-stats {
		display: flex;
		gap: 2rem;
	}
	
	.stat-item {
		text-align: center;
		min-width: 80px;
	}
	
	.stat-number {
		display: block;
		font-size: 1.5rem;
		font-weight: bold;
		color: #2c3e50;
	}
	
	.stat-label {
		display: block;
		font-size: 0.85rem;
		color: #6c757d;
		margin-top: 0.25rem;
	}
	
	.legend {
		display: flex;
		gap: 1rem;
	}
	
	.legend-item {
		display: flex;
		align-items: center;
		gap: 0.5rem;
		font-size: 0.9rem;
		color: #6c757d;
	}
	
	.legend-icon {
		font-size: 1rem;
	}
	
	.table-container {
		overflow-x: auto;
		max-height: 70vh;
		overflow-y: auto;
	}
	
	.attendance-table {
		width: 100%;
		border-collapse: collapse;
		background: white;
	}
	
	.attendance-table th {
		background: #343a40;
		color: white;
		padding: 1rem 0.5rem;
		text-align: center;
		font-weight: 500;
		font-size: 0.9rem;
		position: sticky;
		top: 0;
		z-index: 10;
	}
	
	.student-header {
		text-align: left !important;
		min-width: 200px;
		position: sticky;
		left: 0;
		z-index: 11;
	}
	
	.date-header {
		min-width: 60px;
		padding: 0.5rem 0.25rem;
	}
	
	.stats-header {
		min-width: 120px;
	}
	
	.date-info {
		display: flex;
		flex-direction: column;
		gap: 0.25rem;
		line-height: 1;
	}
	
	.day-name {
		font-size: 0.75rem;
		opacity: 0.8;
	}
	
	.day-number {
		font-size: 0.9rem;
		font-weight: bold;
	}
	
	.student-row:nth-child(even) {
		background: #f8f9fa;
	}
	
	.student-row:hover {
		background: #e3f2fd;
	}
	
	.attendance-table td {
		padding: 0.75rem 0.5rem;
		border-bottom: 1px solid #dee2e6;
		text-align: center;
		vertical-align: middle;
	}
	
	.student-cell {
		text-align: left !important;
		background: #f8f9fa;
		position: sticky;
		left: 0;
		z-index: 5;
		border-right: 2px solid #dee2e6;
	}
	
	.student-info {
		display: flex;
		flex-direction: column;
		gap: 0.25rem;
	}
	
	.student-name {
		font-weight: 500;
		color: #2c3e50;
		font-size: 0.9rem;
	}
	
	.student-id {
		font-size: 0.8rem;
		color: #6c757d;
	}
	
	.attendance-cell {
		padding: 0.5rem 0.25rem;
	}
	
	.attendance-button {
		background: none;
		border: none;
		font-size: 1.1rem;
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
	
	.attendance-button:not(.readonly):hover {
		transform: scale(1.1);
		box-shadow: 0 2px 8px rgba(0,0,0,0.15);
	}
	
	.attendance-button.present {
		background: rgba(39, 174, 96, 0.1);
	}
	
	.attendance-button.absent {
		background: rgba(231, 76, 60, 0.1);
	}
	
	.attendance-button.readonly {
		cursor: default;
		opacity: 0.7;
	}
	
	.stats-cell {
		background: #f8f9fa;
		border-left: 2px solid #dee2e6;
	}
	
	.student-stats {
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
		align-items: center;
	}
	
	.stat-row {
		display: flex;
		gap: 0.5rem;
		font-size: 0.8rem;
	}
	
	.present-stat {
		color: #27ae60;
		font-weight: 500;
	}
	
	.absent-stat {
		color: #e74c3c;
		font-weight: 500;
	}
	
	.percentage-stat {
		font-weight: bold;
		font-size: 0.9rem;
		color: #27ae60;
		padding: 0.25rem 0.5rem;
		border-radius: 12px;
		background: rgba(39, 174, 96, 0.1);
	}
	
	.percentage-stat.medium {
		color: #f39c12;
		background: rgba(243, 156, 18, 0.1);
	}
	
	.percentage-stat.low {
		color: #e74c3c;
		background: rgba(231, 76, 60, 0.1);
	}
	
	.no-data {
		text-align: center;
		color: #6c757d;
		font-style: italic;
		padding: 2rem;
	}
	
	/* Responsive Design */
	@media (max-width: 768px) {
		.table-summary {
			flex-direction: column;
			align-items: stretch;
			gap: 1rem;
		}
		
		.summary-stats {
			justify-content: center;
		}
		
		.legend {
			justify-content: center;
		}
		
		.attendance-table {
			font-size: 0.8rem;
		}
		
		.date-header {
			min-width: 45px;
			padding: 0.25rem;
		}
		
		.attendance-button {
			width: 28px;
			height: 28px;
			font-size: 0.9rem;
		}
		
		.student-name {
			font-size: 0.8rem;
		}
		
		.student-id {
			font-size: 0.7rem;
		}
	}
</style>