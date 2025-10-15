<script>
	import { calculateAttendanceStats } from '../attendance.js';
	
	export let students = [];
	export let attendanceData = {};
	export let sectionName = '';
	export let subjectName = '';
	export let monthName = '';
	export let year = '';
	export let totalDays = 0;
	
	// Calculate overall statistics
	$: overallStats = students.length > 0 ? {
		totalStudents: students.length,
		totalDays: totalDays,
		averageAttendance: Math.round(
			students.reduce((acc, student) => {
				const stats = calculateAttendanceStats(attendanceData[student.StudentID]);
				return acc + stats.percentage;
			}, 0) / students.length
		),
		totalPresent: students.reduce((acc, student) => {
			const stats = calculateAttendanceStats(attendanceData[student.StudentID]);
			return acc + stats.present;
		}, 0),
		totalAbsent: students.reduce((acc, student) => {
			const stats = calculateAttendanceStats(attendanceData[student.StudentID]);
			return acc + stats.absent;
		}, 0),
		perfectAttendance: students.filter(student => {
			const stats = calculateAttendanceStats(attendanceData[student.StudentID]);
			return stats.percentage === 100;
		}).length,
		lowAttendance: students.filter(student => {
			const stats = calculateAttendanceStats(attendanceData[student.StudentID]);
			return stats.percentage < 75;
		}).length
	} : {
		totalStudents: 0,
		totalDays: 0,
		averageAttendance: 0,
		totalPresent: 0,
		totalAbsent: 0,
		perfectAttendance: 0,
		lowAttendance: 0
	};
	
	// Get attendance grade
	$: attendanceGrade = getAttendanceGrade(overallStats.averageAttendance);
	
	function getAttendanceGrade(percentage) {
		if (percentage >= 95) return { grade: 'A', color: '#27ae60', description: 'Excellent' };
		if (percentage >= 85) return { grade: 'B', color: '#2ecc71', description: 'Good' };
		if (percentage >= 75) return { grade: 'C', color: '#f39c12', description: 'Fair' };
		if (percentage >= 65) return { grade: 'D', color: '#e67e22', description: 'Poor' };
		return { grade: 'F', color: '#e74c3c', description: 'Critical' };
	}
</script>

<div class="attendance-summary">
	<div class="summary-header">
		<div class="header-info">
			<h2>📊 Attendance Summary</h2>
			<div class="header-details">
				{#if sectionName}
					<span class="detail-item">🏫 {sectionName}</span>
				{/if}
				{#if subjectName}
					<span class="detail-item">📚 {subjectName}</span>
				{/if}
				{#if monthName && year}
					<span class="detail-item">📅 {monthName} {year}</span>
				{/if}
			</div>
		</div>
		
		<div class="grade-display">
			<div class="grade-circle" style="border-color: {attendanceGrade.color}; color: {attendanceGrade.color};">
				<span class="grade-letter">{attendanceGrade.grade}</span>
			</div>
			<div class="grade-info">
				<div class="grade-percentage">{overallStats.averageAttendance}%</div>
				<div class="grade-description">{attendanceGrade.description}</div>
			</div>
		</div>
	</div>
	
	<div class="summary-stats">
		<div class="stat-group">
			<h4>📋 Overview</h4>
			<div class="stats-grid">
				<div class="stat-card">
					<span class="stat-number">{overallStats.totalStudents}</span>
					<span class="stat-label">Total Students</span>
				</div>
				<div class="stat-card">
					<span class="stat-number">{overallStats.totalDays}</span>
					<span class="stat-label">School Days</span>
				</div>
				<div class="stat-card">
					<span class="stat-number">{overallStats.totalStudents * overallStats.totalDays}</span>
					<span class="stat-label">Total Records</span>
				</div>
			</div>
		</div>
		
		<div class="stat-group">
			<h4>📈 Attendance</h4>
			<div class="stats-grid">
				<div class="stat-card positive">
					<span class="stat-number">{overallStats.totalPresent}</span>
					<span class="stat-label">Present</span>
					<span class="stat-icon">✅</span>
				</div>
				<div class="stat-card negative">
					<span class="stat-number">{overallStats.totalAbsent}</span>
					<span class="stat-label">Absent</span>
					<span class="stat-icon">❌</span>
				</div>
				<div class="stat-card">
					<span class="stat-number">{overallStats.averageAttendance}%</span>
					<span class="stat-label">Average</span>
					<span class="stat-icon">📊</span>
				</div>
			</div>
		</div>
		
		<div class="stat-group">
			<h4>🎯 Performance</h4>
			<div class="stats-grid">
				<div class="stat-card excellent">
					<span class="stat-number">{overallStats.perfectAttendance}</span>
					<span class="stat-label">Perfect Attendance</span>
					<span class="stat-icon">🏆</span>
				</div>
				<div class="stat-card warning">
					<span class="stat-number">{overallStats.lowAttendance}</span>
					<span class="stat-label">Low Attendance</span>
					<span class="stat-icon">⚠️</span>
				</div>
				<div class="stat-card">
					<span class="stat-number">{overallStats.totalStudents - overallStats.lowAttendance - overallStats.perfectAttendance}</span>
					<span class="stat-label">Regular</span>
					<span class="stat-icon">👥</span>
				</div>
			</div>
		</div>
	</div>
</div>

<style>
	.attendance-summary {
		background: white;
		border-radius: 12px;
		box-shadow: 0 4px 20px rgba(0,0,0,0.1);
		overflow: hidden;
		margin-bottom: 2rem;
	}
	
	.summary-header {
		background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
		color: white;
		padding: 2rem;
		display: flex;
		justify-content: space-between;
		align-items: center;
		flex-wrap: wrap;
		gap: 1.5rem;
	}
	
	.header-info h2 {
		margin: 0 0 1rem 0;
		font-size: 1.8rem;
		font-weight: 600;
	}
	
	.header-details {
		display: flex;
		gap: 1rem;
		flex-wrap: wrap;
	}
	
	.detail-item {
		background: rgba(255,255,255,0.2);
		padding: 0.5rem 1rem;
		border-radius: 20px;
		font-size: 0.9rem;
		backdrop-filter: blur(10px);
	}
	
	.grade-display {
		display: flex;
		align-items: center;
		gap: 1rem;
	}
	
	.grade-circle {
		width: 80px;
		height: 80px;
		border: 4px solid;
		border-radius: 50%;
		display: flex;
		align-items: center;
		justify-content: center;
		background: rgba(255,255,255,0.1);
		backdrop-filter: blur(10px);
	}
	
	.grade-letter {
		font-size: 2rem;
		font-weight: bold;
	}
	
	.grade-info {
		text-align: center;
	}
	
	.grade-percentage {
		font-size: 1.5rem;
		font-weight: bold;
		margin-bottom: 0.25rem;
	}
	
	.grade-description {
		font-size: 0.9rem;
		opacity: 0.9;
	}
	
	.summary-stats {
		padding: 2rem;
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
		gap: 2rem;
	}
	
	.stat-group h4 {
		margin: 0 0 1rem 0;
		color: #2c3e50;
		font-size: 1.1rem;
		font-weight: 600;
		display: flex;
		align-items: center;
		gap: 0.5rem;
	}
	
	.stats-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
		gap: 1rem;
	}
	
	.stat-card {
		background: #f8f9fa;
		padding: 1.5rem 1rem;
		border-radius: 8px;
		text-align: center;
		position: relative;
		border: 2px solid transparent;
		transition: all 0.3s ease;
	}
	
	.stat-card:hover {
		transform: translateY(-2px);
		box-shadow: 0 4px 15px rgba(0,0,0,0.1);
	}
	
	.stat-card.positive {
		background: rgba(39, 174, 96, 0.1);
		border-color: rgba(39, 174, 96, 0.3);
	}
	
	.stat-card.negative {
		background: rgba(231, 76, 60, 0.1);
		border-color: rgba(231, 76, 60, 0.3);
	}
	
	.stat-card.excellent {
		background: rgba(241, 196, 15, 0.1);
		border-color: rgba(241, 196, 15, 0.3);
	}
	
	.stat-card.warning {
		background: rgba(230, 126, 34, 0.1);
		border-color: rgba(230, 126, 34, 0.3);
	}
	
	.stat-number {
		display: block;
		font-size: 2rem;
		font-weight: bold;
		color: #2c3e50;
		margin-bottom: 0.5rem;
	}
	
	.stat-label {
		display: block;
		font-size: 0.85rem;
		color: #6c757d;
		margin-bottom: 0.25rem;
	}
	
	.stat-icon {
		position: absolute;
		top: 0.5rem;
		right: 0.5rem;
		font-size: 1.2rem;
		opacity: 0.7;
	}
	
	/* Responsive Design */
	@media (max-width: 768px) {
		.summary-header {
			flex-direction: column;
			text-align: center;
			padding: 1.5rem;
		}
		
		.header-details {
			justify-content: center;
		}
		
		.grade-display {
			flex-direction: column;
			gap: 0.5rem;
		}
		
		.grade-circle {
			width: 60px;
			height: 60px;
		}
		
		.grade-letter {
			font-size: 1.5rem;
		}
		
		.summary-stats {
			padding: 1.5rem;
			grid-template-columns: 1fr;
			gap: 1.5rem;
		}
		
		.stats-grid {
			grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
		}
		
		.stat-card {
			padding: 1rem 0.75rem;
		}
		
		.stat-number {
			font-size: 1.5rem;
		}
	}
</style>