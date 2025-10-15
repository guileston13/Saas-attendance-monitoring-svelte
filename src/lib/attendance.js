// Attendance utility functions and constants

/**
 * Generate calendar days for a given month/year (excluding weekends)
 * @param {string} year - Year (YYYY)
 * @param {string} month - Month (MM)
 * @returns {Array} Array of day objects
 */
export function generateSchoolDays(year, month) {
	const daysInMonth = new Date(parseInt(year), parseInt(month), 0).getDate();
	const days = [];
	
	for (let day = 1; day <= daysInMonth; day++) {
		const date = new Date(parseInt(year), parseInt(month) - 1, day);
		const dayOfWeek = date.getDay();
		
		// Skip weekends (Sunday = 0, Saturday = 6)
		if (dayOfWeek !== 0 && dayOfWeek !== 6) {
			days.push({
				day: day.toString().padStart(2, '0'),
				date: `${year}-${month.padStart(2, '0')}-${day.toString().padStart(2, '0')}`,
				dayName: date.toLocaleDateString('en-US', { weekday: 'short' }),
				dayOfWeek: dayOfWeek
			});
		}
	}
	
	return days;
}

/**
 * Calculate attendance statistics for a student
 * @param {Object} attendanceRecord - Student's attendance record
 * @returns {Object} Statistics object
 */
export function calculateAttendanceStats(attendanceRecord) {
	if (!attendanceRecord || typeof attendanceRecord !== 'object') {
		return { present: 0, absent: 0, total: 0, percentage: 0 };
	}
	
	const records = Object.values(attendanceRecord);
	const present = records.filter(status => status === 'present').length;
	const absent = records.filter(status => status === 'absent').length;
	const total = records.length;
	const percentage = total > 0 ? Math.round((present / total) * 100) : 0;
	
	return { present, absent, total, percentage };
}

/**
 * Generate mock attendance data for demo purposes
 * @param {Array} students - Array of student objects
 * @param {Array} days - Array of day objects
 * @param {number} presentRate - Rate of attendance (0-1)
 * @returns {Object} Mock attendance data
 */
export function generateMockAttendance(students, days, presentRate = 0.85) {
	const attendanceData = {};
	
	students.forEach(student => {
		attendanceData[student.StudentID] = {};
		days.forEach(day => {
			// Generate random attendance based on present rate
			const isPresent = Math.random() < presentRate;
			attendanceData[student.StudentID][day.date] = isPresent ? 'present' : 'absent';
		});
	});
	
	return attendanceData;
}

/**
 * Export attendance data to CSV format
 * @param {Array} students - Array of student objects
 * @param {Array} days - Array of day objects
 * @param {Object} attendanceData - Attendance records
 * @param {Object} metadata - Additional information
 * @returns {string} CSV string
 */
export function exportToCSV(students, days, attendanceData, metadata = {}) {
	const headers = ['Student ID', 'Student Name', ...days.map(day => day.date), 'Present', 'Absent', 'Total', 'Percentage'];
	
	const rows = students.map(student => {
		const stats = calculateAttendanceStats(attendanceData[student.StudentID]);
		const attendanceRow = days.map(day => {
			const status = attendanceData[student.StudentID]?.[day.date] || 'absent';
			return status === 'present' ? 'P' : 'A';
		});
		
		return [
			student.StudentID,
			`${student.FirstName} ${student.LastName}`,
			...attendanceRow,
			stats.present,
			stats.absent,
			stats.total,
			`${stats.percentage}%`
		];
	});
	
	const csvContent = [headers, ...rows]
		.map(row => row.map(field => `"${field}"`).join(','))
		.join('\n');
	
	return csvContent;
}

/**
 * Get attendance status color
 * @param {string} status - Attendance status
 * @returns {string} Color code
 */
export function getAttendanceColor(status) {
	switch (status) {
		case 'present':
			return '#27ae60';
		case 'absent':
			return '#e74c3c';
		case 'late':
			return '#f39c12';
		case 'excused':
			return '#3498db';
		default:
			return '#95a5a6';
	}
}

/**
 * Format date for display
 * @param {string} dateString - Date string (YYYY-MM-DD)
 * @returns {string} Formatted date
 */
export function formatDate(dateString) {
	const date = new Date(dateString);
	return date.toLocaleDateString('en-US', { 
		weekday: 'short', 
		month: 'short', 
		day: 'numeric' 
	});
}

/**
 * Get month name from month number
 * @param {string|number} monthNumber - Month number (1-12)
 * @returns {string} Month name
 */
export function getMonthName(monthNumber) {
	const months = [
		'January', 'February', 'March', 'April', 'May', 'June',
		'July', 'August', 'September', 'October', 'November', 'December'
	];
	const index = parseInt(monthNumber) - 1;
	return months[index] || '';
}

/**
 * Validate attendance permissions
 * @param {Object} session - User session
 * @param {string} action - Action being performed
 * @returns {boolean} Whether user has permission
 */
export function hasAttendancePermission(session, action = 'view') {
	if (!session || !session.role) return false;
	
	const role = session.role;
	
	switch (action) {
		case 'view':
			return ['Admin', 'Teacher'].includes(role);
		case 'edit':
			return ['Admin', 'Teacher'].includes(role);
		case 'delete':
			return role === 'Admin';
		case 'export':
			return ['Admin', 'Teacher'].includes(role);
		default:
			return false;
	}
}

/**
 * Filter sections based on user role
 * @param {Array} sections - All sections
 * @param {Object} session - User session
 * @returns {Array} Filtered sections
 */
export function filterSectionsByRole(sections, session) {
	if (!session || !session.role) return [];
	
	if (session.role === 'Admin') {
		return sections;
	}
	
	if (session.role === 'Teacher') {
		// In a real implementation, this would filter by teacher assignments
		// For now, return all sections (mock behavior)
		return sections;
	}
	
	// Students have no access to attendance
	return [];
}

// Constants
export const ATTENDANCE_STATUS = {
	PRESENT: 'present',
	ABSENT: 'absent',
	LATE: 'late',
	EXCUSED: 'excused'
};

export const ATTENDANCE_COLORS = {
	[ATTENDANCE_STATUS.PRESENT]: '#27ae60',
	[ATTENDANCE_STATUS.ABSENT]: '#e74c3c',
	[ATTENDANCE_STATUS.LATE]: '#f39c12',
	[ATTENDANCE_STATUS.EXCUSED]: '#3498db'
};

export const MONTH_OPTIONS = [
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

export default {
	generateSchoolDays,
	calculateAttendanceStats,
	generateMockAttendance,
	exportToCSV,
	getAttendanceColor,
	formatDate,
	getMonthName,
	hasAttendancePermission,
	filterSectionsByRole,
	ATTENDANCE_STATUS,
	ATTENDANCE_COLORS,
	MONTH_OPTIONS
};