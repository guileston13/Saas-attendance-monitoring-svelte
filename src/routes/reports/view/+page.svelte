<script>
	import { browser } from "$app/environment";
	import { onMount } from "svelte";
	import { page } from "$app/stores";

	let loading = true;
	let error = null;
	let reportData = null;
	let pdfBlob = null;
	let pdfUrl = null;

	// Get URL parameters
	$: sectionId = $page.url.searchParams.get("sectionId");
	$: subjectId = $page.url.searchParams.get("subjectId");
	$: startDate = $page.url.searchParams.get("startDate");
	$: endDate = $page.url.searchParams.get("endDate");
	$: teacherId = $page.url.searchParams.get("teacherId");

	onMount(async () => {
		if (!sectionId || !subjectId || !startDate || !endDate) {
			error = "Missing required parameters";
			loading = false;
			return;
		}

		await loadReportData();
	});

	async function loadReportData() {
		loading = true;
		error = null;

		try {
			const response = await fetch("/api/reports/attendance", {
				method: "POST",
				headers: { "Content-Type": "application/json" },
				body: JSON.stringify({
					sectionId: parseInt(sectionId),
					subjectId: parseInt(subjectId),
					startDate,
					endDate,
					teacherId: teacherId ? parseInt(teacherId) : null,
				}),
			});

			const result = await response.json();

			if (response.ok && result.success) {
				reportData = result.reportData;
				console.log("Report Data:", reportData);
				console.log("Attendance Dates:", reportData.attendanceDates);
				console.log("Students:", reportData.students);
				if (reportData.students && reportData.students.length > 0) {
					console.log(
						"First student attendance:",
						reportData.students[0].attendance,
					);
				}
				await generatePDF();
			} else {
				error = result.error || "Failed to load report data";
			}
		} catch (err) {
			console.error("Load report error:", err);
			error = "An error occurred while loading the report";
		} finally {
			loading = false;
		}
	}

	async function generatePDF() {
		try {
			// Dynamically import pdfmake
			const pdfMakeModule = await import("pdfmake/build/pdfmake");
			const pdfFontsModule = await import("pdfmake/build/vfs_fonts");

			// Handle different module structures
			const pdfMake = pdfMakeModule.default || pdfMakeModule;
			const pdfFonts = pdfFontsModule.default || pdfFontsModule;

			// Set fonts
			pdfMake.vfs = pdfFonts.pdfMake
				? pdfFonts.pdfMake.vfs
				: pdfFonts.vfs;

			// Load the logo
			console.log("Loading logo...");
			const logoBase64 = await loadLogoAsBase64();
			console.log(
				"Logo loaded:",
				logoBase64 ? "Success" : "Failed (will continue without logo)",
			);

			const docDefinition = createDocumentDefinition(logoBase64);
			const pdfDocGenerator = pdfMake.createPdf(docDefinition);

			// Generate blob for preview
			pdfDocGenerator.getBlob(
				(blob) => {
					pdfBlob = blob;
					pdfUrl = URL.createObjectURL(blob);
					console.log("PDF generated successfully");
				},
				(error) => {
					console.error("PDF generation callback error:", error);
					throw error;
				},
			);
		} catch (err) {
			console.error("PDF generation error:", err);
			error = "Failed to generate PDF: " + err.message;
		}
	}

	async function loadLogoAsBase64() {
		try {
			const response = await fetch("/logo2.jpg");
			if (!response.ok) {
				throw new Error(`Failed to fetch logo: ${response.status}`);
			}
			const blob = await response.blob();
			return new Promise((resolve, reject) => {
				const reader = new FileReader();
				reader.onloadend = () => {
					const result = reader.result;
					// Ensure it's a valid data URL with image/png MIME type
					if (
						result &&
						typeof result === "string" &&
						result.startsWith("data:image/")
					) {
						console.log("Logo loaded successfully");
						resolve(result);
					} else {
						console.error(
							"Invalid image data format:",
							result ? result.substring(0, 50) : "null",
						);
						reject(new Error("Invalid image data"));
					}
				};
				reader.onerror = (error) => {
					console.error("FileReader error:", error);
					reject(error);
				};
				reader.readAsDataURL(blob);
			});
		} catch (err) {
			console.error("Error loading logo:", err);
			// Return null to continue without logo
			return null;
		}
	}

	function createDocumentDefinition(logoBase64) {
		const {
			section,
			subject,
			dateRange,
			attendanceDates,
			students,
			teacher,
			schedule,
		} = reportData;

		// Format date helper
		const formatDate = (dateStr) => {
			const date = new Date(dateStr);
			const month = String(date.getMonth() + 1).padStart(2, "0");
			const day = String(date.getDate()).padStart(2, "0");
			return `${month}/${day}`;
		};

		const formatFullDate = (dateStr) => {
			const date = new Date(dateStr);
			const month = String(date.getMonth() + 1).padStart(2, "0");
			const day = String(date.getDate()).padStart(2, "0");
			const year = date.getFullYear();
			return `${month}-${day}-${year}`;
		};

		// Get schedule time
		const scheduleTime =
			schedule && schedule.length > 0
				? `${schedule[0].startTime || ""} - ${schedule[0].endTime || ""}`
				: "Friday 9:00 AM - 12:00 PM";

		// Ensure we have at least 10 date columns
		const minDateColumns = 10;
		const dateColumnsToShow = [];

		console.log("Original attendance dates:", attendanceDates);

		// Add actual attendance dates
		attendanceDates.forEach((date) => {
			dateColumnsToShow.push({ date, hasData: true });
		});

		console.log(
			"Date columns to show (after adding attendance dates):",
			dateColumnsToShow,
		);

		// Fill with empty columns if less than 10
		while (dateColumnsToShow.length < minDateColumns) {
			dateColumnsToShow.push({ date: null, hasData: false });
		}

		console.log("Final date columns to show:", dateColumnsToShow);

		// Prepare table headers - exactly like full.png
		const tableHeaders = [
			{
				text: "No.",
				style: "tableHeader",
				alignment: "center",
				rowSpan: 2,
				margin: [0, 8, 0, 0],
			},
			{
				text: "Name of Student",
				style: "tableHeader",
				alignment: "center",
				rowSpan: 2,
				margin: [0, 8, 0, 0],
			},
			{
				text: "Course & Year",
				style: "tableHeader",
				alignment: "center",
				rowSpan: 2,
				margin: [0, 8, 0, 0],
			},
		];

		// Add date columns header
		tableHeaders.push({
			text: "Indicate the date and put a checkmark if student is present",
			style: "tableHeader",
			alignment: "left",
			colSpan: dateColumnsToShow.length,
			fontSize: 8,
			margin: [2, 2, 2, 2],
		});

		// Fill remaining header cells
		for (let i = 1; i < dateColumnsToShow.length; i++) {
			tableHeaders.push({});
		}

		// Second header row with individual dates
		const dateHeaders = [
			{}, // No. (spanned from row 1)
			{}, // Name (spanned from row 1)
			{}, // Course & Year (spanned from row 1)
		];

		dateColumnsToShow.forEach((dateCol) => {
			const formattedDate = dateCol.hasData
				? formatDate(dateCol.date)
				: "";
			dateHeaders.push({
				text: formattedDate,
				style: "dateHeader",
				alignment: "left",
				fontSize: 8,
				margin: [2, 2, 2, 2],
			});
		});

		// Prepare table body
		const tableBody = [tableHeaders, dateHeaders];

		// Add student rows
		students.forEach((studentData, index) => {
			const student = studentData.student;
			const attendance = studentData.attendance;

			const fullName =
				`${student.LastName}, ${student.FirstName} ${student.MiddleName ? student.MiddleName.charAt(0) + "." : ""}`.trim();

			const row = [
				{
					text: (index + 1).toString(),
					alignment: "center",
					fontSize: 9,
					margin: [2, 5, 2, 5],
				},
				{
					text: fullName,
					alignment: "left",
					fontSize: 9,
					margin: [2, 5, 2, 5],
				},
				{
					text: subject.code || "TN401",
					alignment: "left",
					fontSize: 9,
					margin: [2, 5, 2, 5],
				},
			];

			// Add attendance checkmarks for each date column
			dateColumnsToShow.forEach((dateCol) => {
				let cellText = "";

				if (dateCol.hasData) {
					const record = attendance[dateCol.date];
					if (
						record &&
						(record.displayStatus === "P" ||
							record.displayStatus === "L")
					) {
						cellText = "√";
					} else if (record && record.displayStatus === "A") {
						cellText = "x";
					}
				}

				row.push({
					text: cellText,
					alignment: "left",
					fontSize: 9,
					margin: [2, 5, 2, 5],
				});
			});

			tableBody.push(row);
		});

		// Add empty rows to fill the page - calculate dynamically based on page size
		// Legal landscape has about 600 points available height after header
		// Each row is about 20 points, so we can fit about 25-30 rows
		const totalRows = 25;
		const remainingRows = Math.max(0, totalRows - students.length);

		for (let i = 0; i < remainingRows; i++) {
			const emptyRow = [
				{ text: "", fontSize: 9, margin: [2, 5, 2, 5] },
				{ text: "", fontSize: 9, margin: [2, 5, 2, 5] },
				{ text: "", fontSize: 9, margin: [2, 5, 2, 5] },
			];

			dateColumnsToShow.forEach(() => {
				emptyRow.push({ text: "", fontSize: 9, margin: [2, 5, 2, 5] });
			});

			tableBody.push(emptyRow);
		}

		// Calculate column widths to fill the page width
		// Legal landscape width is 1008 points, minus margins (40 + 40 = 80) = 928 points
		// Table margin removed to align with header
		const availableWidth = 810;
		const noWidth = 25;
		const nameWidth = 200;
		const courseWidth = 60;
		const remainingWidth =
			availableWidth - noWidth - nameWidth - courseWidth;
		const dateColumnWidth = remainingWidth / dateColumnsToShow.length;

		const columnWidths = [noWidth, nameWidth, courseWidth];

		// Add date columns
		dateColumnsToShow.forEach(() => {
			columnWidths.push(dateColumnWidth);
		});

		// Document definition - matching full.png exactly
		return {
			pageSize: "LEGAL",
			pageOrientation: "landscape",
			pageMargins: [40, 140, 40, 40],

			header: function (currentPage, pageCount) {
				// ONLY render header on page 1
				if (currentPage !== 1) {
					return { text: "", margin: [0, 0, 0, 0] };
				}

				return {
					stack: [
						{
							columns: [
								// Logo on left
								logoBase64
									? {
											image: logoBase64,
											width: 90,
											margin: [40, 20, 0, 0],
										}
									: {
											text: "",
											width: 90,
											margin: [40, 20, 0, 0],
										},
								// Center text
								{
									width: "*",
									stack: [
										{
											text: "UNIVERSITY OF SCIENCE AND TECHNOLOGY",
											style: "headerTitle",
											alignment: "center",
											margin: [0, 44, 0, 0],
										},
										{
											text: "OF SOUTHERN PHILIPPINES",
											style: "headerTitle",
											alignment: "center",
											margin: [0, 0, 0, 0],
										},
										{
											text: "Alubijid | Balubal |Cagayan de Oro | Claveria | Jasaan | Oroquieta | Panaon | Villanueva",
											fontSize: 7,
											alignment: "center",
											margin: [0, 3, 0, 0],
										},
									],
								},
								// Document Code box on right - matching header.PNG exactly
								{
									table: {
										widths: [25, 45, 30],
										body: [
											// Row 1: Document Code No. (Blue Header)
											[
												{
													text: "Document Code No.",
													fontSize: 7,
													bold: true,
													alignment: "center",
													fillColor: "#1a3a6b",
													color: "white",
													colSpan: 3,
													margin: [0, 2, 0, 2],
												},
												{},
												{},
											],
											// Row 2: FM-USTP-ACAD-05 (White Content)
											[
												{
													text: "FM-USTP-ACAD-06",
													fontSize: 9,
													bold: true,
													alignment: "center",
													colSpan: 3,
													margin: [0, 2, 0, 2],
												},
												{},
												{},
											],
											// Row 3: Headers (Blue)
											[
												{
													text: "Rev. No.",
													fontSize: 6,
													alignment: "center",
													fillColor: "#1a3a6b",
													color: "white",
													margin: [0, 2, 0, 2],
												},
												{
													text: "Effective Date",
													fontSize: 6,
													alignment: "center",
													fillColor: "#1a3a6b",
													color: "white",
													margin: [0, 2, 0, 2],
												},
												{
													text: "Page No.",
													fontSize: 6,
													alignment: "center",
													fillColor: "#1a3a6b",
													color: "white",
													margin: [0, 2, 0, 2],
												},
											],
											// Row 4: Values
											[
												{
													text: "01",
													fontSize: 7,
													alignment: "center",
													margin: [0, 2, 0, 2],
												},
												{
													text: "12.01.21",
													fontSize: 7,
													alignment: "center",
													margin: [0, 2, 0, 2],
												},
												{
													text: `${currentPage} of ${pageCount}`,
													fontSize: 7,
													alignment: "center",
													margin: [0, 2, 0, 2],
												},
											],
										],
									},
									layout: {
										hLineWidth: function (i, node) {
											return 0.5;
										},
										vLineWidth: function (i, node) {
											return 0.5;
										},
										hLineColor: function (i, node) {
											return "black";
										},
										vLineColor: function (i, node) {
											return "black";
										},
									},
									width: "auto",
									margin: [0, 20, 40, 0],
								},
							],
						},
					],
				};
			},

			content: [
				// Attendance Table
				{
					table: {
						headerRows: 2,
						widths: columnWidths,
						body: tableBody,
					},
					layout: {
						hLineWidth: function (i, node) {
							return 1;
						},
						vLineWidth: function (i, node) {
							return 1;
						},
						hLineColor: function (i, node) {
							return "black";
						},
						vLineColor: function (i, node) {
							return "black";
						},
						paddingLeft: function (i, node) {
							return 4;
						},
						paddingRight: function (i, node) {
							return 4;
						},
						paddingTop: function (i, node) {
							return 4;
						},
						paddingBottom: function (i, node) {
							return 4;
						},
					},
					margin: [0, 0, 0, 20],
				},
				// Footer signature section
				{
					columns: [
						{
							width: "50%",
							stack: [
								{
									text: `Checked by: ${teacher ? teacher.toUpperCase() : '_____________________'}`,
									fontSize: 9,
									alignment: "center",
									decoration: "underline",
									margin: [0, 30, 0, 2],
								},
								{
									text: "Subject Instructor/Professor",
									fontSize: 9,
									alignment: "center",
									margin: [0, 0, 0, 0],
								},
							],
						},
						{
							width: "50%",
							stack: [
								{
									text: "Submitted to: TROADIO M. BARBOSA, MTTE",
									fontSize: 9,
									alignment: "center",
									decoration: "underline",
									margin: [0, 30, 0, 2],
								},
								{
									text: [
										{ text: "Date Submitted: ", fontSize: 9 },
										{
											text: new Date().toLocaleDateString('en-US', { month: '2-digit', day: '2-digit', year: 'numeric' }).replace(/\//g, '-'),
											fontSize: 9,
											decoration: "underline",
										},
									],
									alignment: "center",
									margin: [0, 0, 0, 0],
								},
							],
						},
					],
					margin: [40, 20, 40, 0],
				},
			],

			footer: function (currentPage, pageCount) {
				return {};
			},

			styles: {
				headerTitle: {
					fontSize: 10,
					bold: true,
					color: "black",
				},
				headerSubtitle: {
					fontSize: 11,
					bold: true,
					color: "black",
				},
				tableHeader: {
					fontSize: 9,
					bold: false,
					color: "black",
					alignment: "center",
				},
				dateHeader: {
					fontSize: 8,
					bold: false,
					color: "black",
					alignment: "left",
				},
			},
		};
	}

	function downloadPDF() {
		if (!pdfBlob) return;

		const link = document.createElement("a");
		link.href = pdfUrl;
		const fileName = `Attendance_Report_${reportData.subject.name}${reportData.subject.code ? "_" + reportData.subject.code : ""}_${reportData.section.name}_${startDate}_to_${endDate}.pdf`;
		link.download = fileName.replace(/[^a-zA-Z0-9_.-]/g, "_");
		link.click();
	}

	function printPDF() {
		if (pdfUrl) {
			window.open(pdfUrl, "_blank");
		}
	}
</script>

<svelte:head>
	<title>Attendance Report - PDF Viewer</title>
</svelte:head>

<div class="pdf-viewer-page">
	{#if loading}
		<div class="loading-container">
			<div class="spinner-large"></div>
			<p>Generating attendance report...</p>
		</div>
	{:else if error}
		<div class="error-container">
			<div class="error-icon">⚠️</div>
			<h2>Error Loading Report</h2>
			<p>{error}</p>
			<button class="btn btn-primary" on:click={() => window.close()}>
				Close Window
			</button>
		</div>
	{:else if pdfUrl}
		<div class="pdf-controls">
			<div class="controls-left">
				<h3>📄 Attendance Report</h3>
				{#if reportData}
					<p class="report-details">
						{reportData.subject.name} - {reportData.section.name}
						<span class="date-range">
							({new Date(startDate).toLocaleDateString()} - {new Date(
								endDate,
							).toLocaleDateString()})
						</span>
					</p>
				{/if}
			</div>
			<div class="controls-right">
				<button class="btn btn-secondary" on:click={printPDF}>
					🖨️ Print
				</button>
				<button class="btn btn-primary" on:click={downloadPDF}>
					⬇️ Download PDF
				</button>
			</div>
		</div>

		<div class="pdf-container">
			<iframe src={pdfUrl} title="Attendance Report PDF" class="pdf-frame"
			></iframe>
		</div>
	{/if}
</div>

<style>
	.pdf-viewer-page {
		width: 100vw;
		height: 100vh;
		display: flex;
		flex-direction: column;
		background: #ecf0f1;
		overflow: hidden;
	}

	.loading-container,
	.error-container {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		height: 100vh;
		text-align: center;
		padding: 2rem;
	}

	.spinner-large {
		width: 60px;
		height: 60px;
		border: 6px solid #ecf0f1;
		border-top: 6px solid #3498db;
		border-radius: 50%;
		animation: spin 1s linear infinite;
		margin-bottom: 1rem;
	}

	@keyframes spin {
		0% {
			transform: rotate(0deg);
		}
		100% {
			transform: rotate(360deg);
		}
	}

	.error-icon {
		font-size: 4rem;
		margin-bottom: 1rem;
	}

	.error-container h2 {
		color: #e74c3c;
		margin-bottom: 1rem;
	}

	.pdf-controls {
		background: white;
		padding: 1rem 2rem;
		border-bottom: 2px solid #dee2e6;
		display: flex;
		justify-content: space-between;
		align-items: center;
		box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
		z-index: 10;
	}

	.controls-left h3 {
		margin: 0 0 0.25rem 0;
		color: #2c3e50;
		font-size: 1.2rem;
	}

	.report-details {
		margin: 0;
		color: #7f8c8d;
		font-size: 0.9rem;
	}

	.date-range {
		font-style: italic;
		color: #95a5a6;
	}

	.controls-right {
		display: flex;
		gap: 0.75rem;
	}

	.pdf-container {
		flex: 1;
		display: flex;
		background: #95a5a6;
		padding: 1rem;
		overflow: hidden;
	}

	.pdf-frame {
		width: 100%;
		height: 100%;
		border: none;
		background: white;
		box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
		border-radius: 4px;
	}

	@media (max-width: 768px) {
		.pdf-controls {
			flex-direction: column;
			align-items: flex-start;
			gap: 1rem;
		}

		.controls-right {
			width: 100%;
		}

		.controls-right button {
			flex: 1;
		}
	}
</style>
