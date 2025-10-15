<script>
	// Reports page component
	import { browser } from '$app/environment';
	import { onMount } from 'svelte';
	
	/** @type {import('./$types').PageData} */
	export let data;
	
	$: session = data.session;
	$: sections = data.sections || [];
	
	let selectedSection = null;
	let sectionStudents = [];
	let loading = false;
	let showModal = false;
	
	// Load jsPDF dynamically when needed
	let jsPDF = null;
	let autoTable = null;
	
	async function loadPDFLibs() {
		if (typeof window !== 'undefined' && !jsPDF) {
			try {
				const jsPDFModule = await import('jspdf');
				const autoTableModule = await import('jspdf-autotable');
				jsPDF = jsPDFModule.default;
				// autoTable is automatically added to jsPDF prototype
			} catch (error) {
				console.error('Failed to load PDF libraries:', error);
				alert('PDF export feature is not available');
			}
		}
	}
	
	async function viewSectionReport(section) {
		selectedSection = section;
		loading = true;
		showModal = true;
		
		try {
			const response = await fetch(`/api/sections/${section.SectionID}/students`);
			const data = await response.json();
			
			if (response.ok) {
				sectionStudents = data.students || [];
			} else {
				alert('Failed to load section data');
				closeModal();
			}
		} catch (error) {
			console.error('Load section report error:', error);
			alert('An error occurred while loading section data');
			closeModal();
		} finally {
			loading = false;
		}
	}
	
	function closeModal() {
		showModal = false;
		selectedSection = null;
		sectionStudents = [];
	}
	
	async function exportToPDF() {
		if (!browser || !selectedSection || !sectionStudents) return;
		
		await loadPDFLibs();
		
		if (!jsPDF) {
			alert('PDF export is not available');
			return;
		}
		
		try {
			const doc = new jsPDF();
			
			// Add title
			doc.setFontSize(20);
			doc.setTextColor(44, 62, 80); // Dark blue color
			doc.text('School Management System', 20, 20);
			
			// Add section header
			doc.setFontSize(16);
			doc.text(`Section Report: ${selectedSection.SectionName}`, 20, 35);
			
			// Add generated date
			doc.setFontSize(10);
			doc.setTextColor(127, 140, 141); // Gray color
			doc.text(`Generated on: ${new Date().toLocaleDateString()}`, 20, 45);
			
			// Add summary
			doc.setFontSize(12);
			doc.setTextColor(44, 62, 80);
			doc.text(`Total Students: ${sectionStudents.length}`, 20, 60);
			
			// Prepare table data
			const tableHeaders = ['Student ID', 'Name', 'Year Level', 'Status'];
			const tableData = sectionStudents.map(student => [
				student.StudentID,
				`${student.FirstName} ${student.MiddleName ? student.MiddleName + ' ' : ''}${student.LastName}`,
				student.YearLevel,
				student.StatusName
			]);
			
			// Add table using autoTable
			doc.autoTable({
				head: [tableHeaders],
				body: tableData,
				startY: 70,
				theme: 'grid',
				headStyles: {
					fillColor: [52, 152, 219], // Blue header
					textColor: 255,
					fontSize: 11,
					fontStyle: 'bold'
				},
				bodyStyles: {
					fontSize: 10,
					textColor: [44, 62, 80]
				},
				alternateRowStyles: {
					fillColor: [248, 249, 250] // Light gray for alternate rows
				},
				columnStyles: {
					0: { cellWidth: 30 }, // Student ID
					1: { cellWidth: 60 }, // Name
					2: { cellWidth: 30 }, // Year Level
					3: { cellWidth: 30 }  // Status
				}
			});
			
			// Add footer
			const pageCount = doc.internal.getNumberOfPages();
			for (let i = 1; i <= pageCount; i++) {
				doc.setPage(i);
				doc.setFontSize(8);
				doc.setTextColor(127, 140, 141);
				doc.text(
					`Page ${i} of ${pageCount}`,
					doc.internal.pageSize.width - 30,
					doc.internal.pageSize.height - 10
				);
			}
			
			// Save the PDF
			const fileName = `${selectedSection.SectionName.replace(/[^a-zA-Z0-9]/g, '_')}_Report.pdf`;
			doc.save(fileName);
			
		} catch (error) {
			console.error('PDF export error:', error);
			alert('An error occurred while generating the PDF');
		}
	}
</script>

<svelte:head>
	<title>Reports - School Management System</title>
</svelte:head>

<div class="page">
	<div class="page-header">
		<h1>Section Reports</h1>
	</div>
	
	{#if data.error}
		<div class="error-message mb-2">{data.error}</div>
	{/if}
	
	<div class="card">
		<div class="card-header">
			<h3 class="card-title">Available Sections</h3>
			<p>Click on a section to view its student report</p>
		</div>
		
		<div class="sections-grid">
			{#each sections as section}
				<div class="section-card" on:click={() => viewSectionReport(section)}>
					<h4>{section.SectionName}</h4>
					<p class="student-count">{section.StudentCount || 0} students enrolled</p>
					<div class="card-actions">
						<span class="view-report-btn">View Report →</span>
					</div>
				</div>
			{:else}
				<div class="no-data">
					<p>No sections available</p>
				</div>
			{/each}
		</div>
	</div>
</div>

<!-- Report Modal -->
{#if showModal}
	<div class="modal-overlay" on:click={closeModal}>
		<div class="modal-content large-modal" on:click|stopPropagation>
			<div class="modal-header">
				<h3 class="modal-title">
					{selectedSection?.SectionName} - Student Report
				</h3>
				<button class="close-btn" on:click={closeModal}>&times;</button>
			</div>
			
			{#if loading}
				<div class="loading">
					<span class="spinner"></span>
					Loading report data...
				</div>
			{:else}
				<div class="report-content">
					<div class="report-summary">
						<div class="summary-item">
							<span class="label">Section:</span>
							<span class="value">{selectedSection?.SectionName}</span>
						</div>
						<div class="summary-item">
							<span class="label">Total Students:</span>
							<span class="value">{sectionStudents.length}</span>
						</div>
						<div class="summary-item">
							<span class="label">Generated:</span>
							<span class="value">{new Date().toLocaleDateString()}</span>
						</div>
					</div>
					
					<div class="report-actions">
						<button class="btn btn-primary" on:click={exportToPDF}>
							📄 Export to PDF
						</button>
					</div>
					
					<div class="table-container">
						<table>
							<thead>
								<tr>
									<th>Student ID</th>
									<th>Name</th>
									<th>Year Level</th>
									<th>Status</th>
								</tr>
							</thead>
							<tbody>
								{#each sectionStudents as student}
									<tr>
										<td>{student.StudentID}</td>
										<td>
											{student.FirstName} 
											{student.MiddleName ? student.MiddleName + ' ' : ''}
											{student.LastName}
										</td>
										<td>{student.YearLevel}</td>
										<td>
											<span class="status-badge status-{student.StatusName?.toLowerCase()}">
												{student.StatusName}
											</span>
										</td>
									</tr>
								{:else}
									<tr>
										<td colspan="4" class="text-center">No students enrolled</td>
									</tr>
								{/each}
							</tbody>
						</table>
					</div>
				</div>
			{/if}
		</div>
	</div>
{/if}

<style>
	.page {
		max-width: 1200px;
		margin: 0 auto;
	}
	
	.page-header {
		margin-bottom: 2rem;
	}
	
	.page-header h1 {
		margin: 0;
		color: #2c3e50;
	}
	
	.sections-grid {
		display: grid;
		grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
		gap: 1rem;
		margin-top: 1rem;
	}
	
	.section-card {
		background: white;
		border: 1px solid #ecf0f1;
		border-radius: 8px;
		padding: 1.5rem;
		cursor: pointer;
		transition: all 0.2s;
		box-shadow: 0 2px 4px rgba(0,0,0,0.1);
	}
	
	.section-card:hover {
		box-shadow: 0 4px 12px rgba(0,0,0,0.15);
		transform: translateY(-2px);
		border-color: #3498db;
	}
	
	.section-card h4 {
		margin: 0 0 0.5rem 0;
		color: #2c3e50;
		font-size: 1.1rem;
	}
	
	.student-count {
		color: #7f8c8d;
		margin: 0 0 1rem 0;
		font-size: 0.9rem;
	}
	
	.view-report-btn {
		color: #3498db;
		font-weight: 600;
		font-size: 0.9rem;
	}
	
	.no-data {
		grid-column: 1 / -1;
		text-align: center;
		padding: 2rem;
		color: #7f8c8d;
	}
	
	.large-modal {
		max-width: 900px;
		width: 90%;
	}
	
	.report-content {
		margin-top: 1rem;
	}
	
	.report-summary {
		background: #f8f9fa;
		padding: 1rem;
		border-radius: 4px;
		margin-bottom: 1rem;
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
		gap: 1rem;
	}
	
	.summary-item {
		display: flex;
		flex-direction: column;
		gap: 0.25rem;
	}
	
	.summary-item .label {
		font-weight: 600;
		color: #7f8c8d;
		font-size: 0.9rem;
	}
	
	.summary-item .value {
		color: #2c3e50;
		font-size: 1rem;
	}
	
	.report-actions {
		margin-bottom: 1rem;
		text-align: right;
	}
	
	.status-badge {
		padding: 0.25rem 0.5rem;
		border-radius: 12px;
		font-size: 0.8rem;
		font-weight: 600;
		text-transform: uppercase;
	}
	
	.status-active {
		background: #d4edda;
		color: #155724;
	}
	
	.status-inactive {
		background: #f8d7da;
		color: #721c24;
	}
	
	.status-suspended {
		background: #fff3cd;
		color: #856404;
	}
	
	.status-graduated {
		background: #d1ecf1;
		color: #0c5460;
	}
	
	@media (max-width: 768px) {
		.sections-grid {
			grid-template-columns: 1fr;
		}
		
		.large-modal {
			width: 95%;
		}
		
		.report-summary {
			grid-template-columns: 1fr;
		}
		
		.report-actions {
			text-align: center;
		}
	}
</style>