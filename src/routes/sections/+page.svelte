<script>
	import { browser } from "$app/environment";
	import { onMount } from "svelte";
	import { invalidateAll } from "$app/navigation";
	import { enhance } from "$app/forms";

	export let data;

	$: session = data.session;
	$: sections = data.sections || [];
	$: statuses = data.statuses || [];
	$: subjects = data.subjects || [];
	$: teachers = data.teachers || [];
	$: students = data.students || [];
	$: rooms = data.rooms || [];

	let sectionSubjects = [];

	let showCreateModal = false;
	let showSubjectModal = false;
	let showStudentModal = false;
	let showSubjectSelectionModal = false;
	let editingSection = null;
	let editingSubject = null;
	let selectedSection = null;
	let selectedSubject = null;
	let selectedCount = 0;
	let loading = false;
	let searching = false;
	let selecting = false;
	let enrolling = false;

	let searchTerm = "";
	let isLoading = true;
	let loadingProgress = 0;
	let loadingText = "Initializing...";
	let loadingFadeOut = false;
	let pageVisible = false;
	let statsVisible = false;
	let cardsVisible = false;
	let scrollY = 0;
	let selectedStudents = new Set();
	let enrolledStudents = [];
	let studentSearchTerm = "";

	$: availableStudents = students.filter((student) => {
		const isEnrolled = enrolledStudents.some(
			(e) => e.StudentID === student.StudentID,
		);
		const matchesSearch =
			studentSearchTerm === "" ||
			`${student.FirstName} ${student.LastName}`
				.toLowerCase()
				.includes(studentSearchTerm.toLowerCase()) ||
			student.StudentID.toLowerCase().includes(
				studentSearchTerm.toLowerCase(),
			);
		return !isEnrolled && matchesSearch;
	});

	$: filteredEnrolledStudents = enrolledStudents.filter((student) => {
		const matchesSearch =
			studentSearchTerm === "" ||
			`${student.FirstName} ${student.LastName}`
				.toLowerCase()
				.includes(studentSearchTerm.toLowerCase()) ||
			student.StudentID.toLowerCase().includes(
				studentSearchTerm.toLowerCase(),
			);
		return matchesSearch;
	});

	onMount(() => {
		const loadingSteps = [
			{ progress: 25, text: "Loading sections..." },
			{ progress: 50, text: "Preparing interface..." },
			{ progress: 75, text: "Finishing up..." },
			{ progress: 100, text: "Ready!" },
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
			window.addEventListener("scroll", handleScroll);
			return () => window.removeEventListener("scroll", handleScroll);
		}
	});

	function openCreateModal() {
		editingSection = null;
		showCreateModal = true;
	}

	function closeCreateModal() {
		showCreateModal = false;
		editingSection = null;
	}

	function editSection(section) {
		editingSection = section;
		showCreateModal = true;
	}

	function selectSectionItem(sectionId) {
		selectedSection = sections.find((s) => s.SectionID === sectionId);
		selectedStudents.clear();
		loadSectionSubjects(sectionId);
	}

	async function loadSectionSubjects(sectionId) {
		try {
			const response = await fetch(`/api/sections/${sectionId}/subjects`);
			if (response.ok) {
				sectionSubjects = await response.json();
			} else {
				sectionSubjects = [];
			}
		} catch (error) {
			console.error("Error loading section subjects:", error);
			sectionSubjects = [];
		}
	}

	function openSubjectModal() {
		editingSubject = null;
		showSubjectModal = true;
	}

	function closeSubjectModal() {
		showSubjectModal = false;
		editingSubject = null;
	}

	function editSectionSubject(subject) {
		closeSubjectSelectionModal();
		editingSubject = subject;
		showSubjectModal = true;
	}

	function openStudentModal() {
		showStudentModal = true;
	}

	function closeStudentModal() {
		showStudentModal = false;
		selectedStudents.clear();
		selectedCount = 0;
		studentSearchTerm = "";
	}

	function openSubjectSelectionModal() {
		console.log("Opening subject selection modal");
		showSubjectSelectionModal = true;
	}

	function closeSubjectSelectionModal() {
		console.log("Closing subject selection modal");
		showSubjectSelectionModal = false;
	}

	function selectSubjectForEnrollment(subject) {
		console.log("Subject selected:", subject);
		selectedSubject = subject;
		closeSubjectSelectionModal();
		loadEnrolledStudents();
		openStudentModal();
	}

	async function loadEnrolledStudents() {
		if (!selectedSection || !selectedSubject) return;

		try {
			const response = await fetch(
				`/api/sections/${selectedSection.SectionID}/subjects/${selectedSubject.SubjectID}`,
			);
			if (response.ok) {
				enrolledStudents = await response.json();
			} else {
				enrolledStudents = [];
			}
		} catch (error) {
			console.error("Error loading enrolled students:", error);
			enrolledStudents = [];
		}
	}

	function handleEnrollClick(event, sectionId) {
		console.log("Enroll button clicked for section:", sectionId);
		event.stopPropagation();
		selectSectionItem(sectionId);
		openSubjectSelectionModal();
	}

	function handleEditClick(event, section) {
		console.log("Edit button clicked for section:", section);
		event.stopPropagation();
		editSection(section);
	}

	$: filteredSections = sections.filter((section) =>
		section.SectionName.toLowerCase().includes(searchTerm.toLowerCase()),
	);

	function toggleStudent(studentId) {
		if (selectedStudents.has(studentId)) {
			selectedStudents.delete(studentId);
		} else {
			selectedStudents.add(studentId);
		}
		selectedStudents = selectedStudents;
		selectedCount = selectedStudents.size;
	}

	async function handleEnrollStudents() {
		if (selectedStudents.size === 0) {
			alert("Please select at least one student to enroll");
			return;
		}

		if (!selectedSubject) {
			alert("Please select a subject");
			return;
		}

		enrolling = true;

		const formData = new FormData();
		formData.append("sectionId", selectedSection.SectionID);
		formData.append("subjectId", selectedSubject.SubjectID);
		formData.append(
			"studentIds",
			JSON.stringify(Array.from(selectedStudents)),
		);

		try {
			const response = await fetch("?/enrollStudents", {
				method: "POST",
				body: formData,
			});

			const result = await response.json();

			if (result.type === "success") {
				selectedStudents.clear();
				selectedCount = 0;
				await loadEnrolledStudents();
				await invalidateAll();
			} else {
				alert(result.data?.error || "Failed to enroll students");
			}
		} catch (error) {
			console.error("Enrollment error:", error);
			alert("An error occurred while enrolling students");
		} finally {
			enrolling = false;
		}
	}

	async function handleUnenrollStudent(studentId) {
		if (!confirm("Are you sure you want to unenroll this student?")) {
			return;
		}

		try {
			const formData = new FormData();
			formData.append("sectionId", selectedSection.SectionID);
			formData.append("subjectId", selectedSubject.SubjectID);
			formData.append("studentId", studentId);

			const response = await fetch("?/unenrollStudent", {
				method: "POST",
				body: formData,
			});

			const result = await response.json();

			if (result.type === "success") {
				await loadEnrolledStudents();
				await invalidateAll();
			} else {
				alert(result.data?.error || "Failed to unenroll student");
			}
		} catch (error) {
			console.error("Unenroll error:", error);
			alert("An error occurred while unenrolling student");
		}
	}
</script>

<svelte:head>
	<title>Sections - School Management System</title>
</svelte:head>

{#if isLoading}
	<div class="loading-screen" class:fade-out={loadingFadeOut}>
		<div class="particles-container">
			{#each Array(20) as _, i}
				<div class="particle particle-{(i % 4) + 1}"></div>
			{/each}
		</div>

		<div class="loading-content">
			<div class="loading-logo">
				<div class="logo-pulse"></div>
				<svg
					class="logo-svg"
					viewBox="0 0 100 100"
					xmlns="http://www.w3.org/2000/svg"
				>
					<defs>
						<linearGradient
							id="gradientLogo"
							x1="0%"
							y1="0%"
							x2="100%"
							y2="100%"
						>
							<stop
								offset="0%"
								style="stop-color:#3B82F6;stop-opacity:1"
							/>
							<stop
								offset="100%"
								style="stop-color:#A855F7;stop-opacity:1"
							/>
						</linearGradient>
					</defs>
					<rect
						x="20"
						y="20"
						width="60"
						height="60"
						rx="10"
						fill="url(#gradientLogo)"
					/>
					<text
						x="50"
						y="65"
						font-size="40"
						font-weight="bold"
						text-anchor="middle"
						fill="white">🏫</text
					>
				</svg>
			</div>

			<div class="loading-brand">
				<div class="brand-main">School Management</div>
				<div class="brand-tagline">SECTIONS MODULE</div>
			</div>

			<div class="loading-progress">
				<div class="progress-bar">
					<div
						class="progress-fill"
						style="width: {loadingProgress}%"
					></div>
					<div
						class="progress-glow"
						style="left: {loadingProgress}%"
					></div>
				</div>
				<div class="progress-text">
					<span class="progress-percentage">{loadingProgress}%</span>
					<span> - {loadingText}</span>
				</div>
			</div>

			<div class="loading-dots">
				<span class="dot dot-1"></span>
				<span class="dot dot-2"></span>
				<span class="dot dot-3"></span>
			</div>

			<div class="loading-orbs">
				<div class="orb orb-1"></div>
				<div class="orb orb-2"></div>
				<div class="orb orb-3"></div>
				<div class="orb orb-4"></div>
			</div>
		</div>
	</div>
{/if}

<div
	class="animated-background"
	style="transform: translateY({scrollY * 0.3}px);"
>
	<div class="dot-pattern"></div>
	<div class="floating-orb orb-bg-1"></div>
	<div class="floating-orb orb-bg-2"></div>
	<div class="floating-orb orb-bg-3"></div>
</div>

<div class="sections-page" class:visible={pageVisible}>
	<div class="page-header" class:visible={pageVisible}>
		<div class="header-icon-wrapper">
			<svg
				class="header-icon"
				viewBox="0 0 24 24"
				fill="none"
				stroke="currentColor"
				stroke-width="2"
			>
				<rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect>
				<line x1="9" y1="3" x2="9" y2="21"></line>
				<line x1="3" y1="9" x2="21" y2="9"></line>
			</svg>
		</div>
		<div class="header-content">
			<h1>Sections Management</h1>
			<p class="subtitle">
				Organize classes and manage section assignments
			</p>
		</div>
		<button class="btn btn-primary" on:click={openCreateModal}>
			<svg
				width="20"
				height="20"
				viewBox="0 0 24 24"
				fill="none"
				stroke="currentColor"
				stroke-width="2"
			>
				<line x1="12" y1="5" x2="12" y2="19"></line>
				<line x1="5" y1="12" x2="19" y2="12"></line>
			</svg>
			Add New Section
		</button>
	</div>

	<div class="stats-grid" class:visible={statsVisible}>
		<div class="stat-card stat-card-1">
			<div class="stat-glow"></div>
			<div class="stat-icon-wrapper">
				<svg
					class="stat-icon"
					viewBox="0 0 24 24"
					fill="none"
					stroke="currentColor"
					stroke-width="2"
				>
					<rect x="3" y="3" width="18" height="18" rx="2" ry="2"
					></rect>
					<line x1="9" y1="3" x2="9" y2="21"></line>
					<line x1="3" y1="9" x2="21" y2="9"></line>
				</svg>
			</div>
			<div class="stat-content">
				<div class="stat-number">{sections.length}</div>
				<div class="stat-label">Total Sections</div>
			</div>
		</div>
		<div class="stat-card stat-card-2">
			<div class="stat-glow"></div>
			<div class="stat-icon-wrapper">
				<svg
					class="stat-icon"
					viewBox="0 0 24 24"
					fill="none"
					stroke="currentColor"
					stroke-width="2"
				>
					<path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
					<circle cx="12" cy="7" r="4"></circle>
				</svg>
			</div>
			<div class="stat-content">
				<div class="stat-number">
					{sections.reduce(
						(total, section) =>
							total + (section.TotalStudents || 0),
						0,
					)}
				</div>
				<div class="stat-label">Total Students</div>
			</div>
		</div>
		<div class="stat-card stat-card-3">
			<div class="stat-glow"></div>
			<div class="stat-icon-wrapper">
				<svg
					class="stat-icon"
					viewBox="0 0 24 24"
					fill="none"
					stroke="currentColor"
					stroke-width="2"
				>
					<path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path>
					<path
						d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"
					></path>
				</svg>
			</div>
			<div class="stat-content">
				<div class="stat-number">{subjects.length}</div>
				<div class="stat-label">Total Subjects</div>
			</div>
		</div>
		<div class="stat-card stat-card-4">
			<div class="stat-glow"></div>
			<div class="stat-icon-wrapper">
				<svg
					class="stat-icon"
					viewBox="0 0 24 24"
					fill="none"
					stroke="currentColor"
					stroke-width="2"
				>
					<path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"
					></path>
					<polyline points="9 22 9 12 15 12 15 22"></polyline>
				</svg>
			</div>
			<div class="stat-content">
				<div class="stat-number">{teachers.length}</div>
				<div class="stat-label">Teachers</div>
			</div>
		</div>
	</div>

	<!-- Search and Sections Grid -->
	<div class="content-section" class:visible={cardsVisible}>
		<div class="section-card">
			<div class="card-header">
				<h3 class="card-title">📚 Section Records</h3>
			</div>

			<div class="card-content">
				<!-- Search bar -->
				<div class="search-container">
					<input
						type="text"
						bind:value={searchTerm}
						placeholder="🔍 Search by section name..."
						class="search-input"
					/>
				</div>

				<!-- Sections Grid -->
				<div class="sections-grid">
					{#each filteredSections as section (section.SectionID)}
						<div
							class="section-card-item"
							on:click={() =>
								selectSectionItem(section.SectionID)}
							on:keydown={(e) =>
								(e.key === "Enter" || e.key === " ") &&
								selectSectionItem(section.SectionID)}
							role="button"
							tabindex="0"
						>
							<div class="card-glow"></div>
							<div class="card-header-mini">
								<div class="card-title-section">
									<h3>{section.SectionName}</h3>
									<span
										class="status-badge {(
											section.StatusName || 'unknown'
										).toLowerCase()}"
									>
										{section.StatusName || "Unknown"}
									</span>
								</div>
							</div>
							<div class="card-stats">
								<div class="stat-item">
									<span class="stat-icon-mini">👥</span>
									<span class="stat-text"
										>{section.TotalStudents || 0} students</span
									>
								</div>
								<div class="stat-item">
									<span class="stat-icon-mini">📖</span>
									<span class="stat-text"
										>{section.SubjectCount || 0} subjects</span
									>
								</div>
							</div>
							<div class="card-actions">
								<button
									type="button"
									class="btn btn-secondary"
									on:click={(e) =>
										handleEditClick(e, section)}
								>
									<svg
										width="16"
										height="16"
										viewBox="0 0 24 24"
										fill="none"
										stroke="currentColor"
										stroke-width="2"
									>
										<path
											d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"
										></path>
										<path
											d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"
										></path>
									</svg>
									Edit
								</button>
								<button
									type="button"
									class="btn btn-success"
									on:click={(e) => {
										e.stopPropagation();
										selectSectionItem(section.SectionID);
										openSubjectModal();
									}}
								>
									<svg
										width="16"
										height="16"
										viewBox="0 0 24 24"
										fill="none"
										stroke="currentColor"
										stroke-width="2"
									>
										<path
											d="M12 5v14M5 12h14"
										></path>
									</svg>
									Add Subject
								</button>
								<button
									type="button"
									class="btn btn-primary"
									on:click={(e) =>
										handleEnrollClick(e, section.SectionID)}
								>
									<svg
										width="16"
										height="16"
										viewBox="0 0 24 24"
										fill="none"
										stroke="currentColor"
										stroke-width="2"
									>
										<path
											d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"
										></path>
										<circle cx="12" cy="7" r="4"></circle>
									</svg>
									Enroll
								</button>
							</div>
						</div>
					{:else}
						<div class="empty-state">
							<h3>No sections found</h3>
							<p>
								{searchTerm
									? "Try adjusting your search terms"
									: "No section records available"}
							</p>
						</div>
					{/each}
				</div>
			</div>
		</div>
	</div>
</div>

<!-- Create/Edit Section Modal -->
{#if showCreateModal}
	<div
		class="modal-overlay"
		on:click={closeCreateModal}
		on:keydown={(e) => e.key === "Escape" && closeCreateModal()}
		role="button"
		tabindex="0"
		aria-label="Close modal"
	>
		<div
			class="modal-content"
			on:click|stopPropagation
			role="document"
			tabindex="-1"
		>
			<div class="modal-header">
				<h3>
					{editingSection ? "Edit Section" : "Create New Section"}
				</h3>
				<button class="close-btn" on:click={closeCreateModal}
					>&times;</button
				>
			</div>

			<form
				method="POST"
				action={editingSection ? "?/updateSection" : "?/createSection"}
				use:enhance={() => {
					loading = true;
					return async ({ result }) => {
						loading = false;
						if (result.type === "success") {
							closeCreateModal();
							await invalidateAll();
						}
					};
				}}
			>
				{#if editingSection}
					<input
						type="hidden"
						name="sectionId"
						value={editingSection.SectionID}
					/>
				{/if}

				<div class="form-group">
					<label for="sectionName">Section Name:</label>
					<input
						type="text"
						id="sectionName"
						name="sectionName"
						required
						value={editingSection ? editingSection.SectionName : ""}
						placeholder="e.g., Grade 10 - Section A"
					/>
				</div>

				{#if editingSection}
					<div class="form-group">
						<label for="statusId">Status:</label>
						<select
							id="statusId"
							name="statusId"
							bind:value={editingSection.StatusID}
						>
							{#each statuses as status}
								<option value={status.StatusID}
									>{status.StatusName}</option
								>
							{/each}
						</select>
					</div>
				{/if}

				<div class="modal-actions">
					<button
						type="button"
						class="btn btn-secondary"
						on:click={closeCreateModal}
					>
						Cancel
					</button>
					<button
						type="submit"
						class="btn btn-primary"
						disabled={loading}
					>
						{#if loading}
							<span class="spinner"></span>
							Saving...
						{:else}
							{editingSection
								? "Update Section"
								: "Create Section"}
						{/if}
					</button>
				</div>
			</form>
		</div>
	</div>
{/if}

<!-- Add/Edit Subject Modal -->
{#if showSubjectModal}
	<div
		class="modal-overlay"
		on:click={closeSubjectModal}
		on:keydown={(e) => e.key === "Escape" && closeSubjectModal()}
		role="button"
		tabindex="0"
		aria-label="Close modal"
	>
		<div
			class="modal-content modal-schedule-large"
			on:click|stopPropagation
			role="document"
			tabindex="-1"
		>
			<div class="modal-header">
				<h3>
					{editingSubject ? "Edit Subject" : "Add Subject to"}
					{selectedSection?.SectionName}
				</h3>
				<button class="close-btn" on:click={closeSubjectModal}
					>&times;</button
				>
			</div>

			<form
				method="POST"
				action={editingSubject
					? "?/updateSectionSubject"
					: "?/addSubject"}
				use:enhance={() => {
					loading = true;
					return async ({ result }) => {
						loading = false;
						console.log('Form result:', result);
						if (result.type === "success") {
							closeSubjectModal();
							await loadSectionSubjects(
								selectedSection.SectionID,
							);
							await invalidateAll();
						} else if (result.type === "failure") {
							alert(result.data?.error || "Failed to save subject");
						}
					};
				}}
			>
				<input
					type="hidden"
					name="sectionId"
					value={selectedSection?.SectionID}
				/>
				{#if editingSubject}
					<input
						type="hidden"
						name="subjectId"
						value={editingSubject.SubjectID}
					/>
				{/if}

				{#if !editingSubject}
					<div class="form-group">
						<label for="subjectId">Subject:</label>
						<select id="subjectId" name="subjectId" required>
							<option value="">Select Subject</option>
							{#each subjects as subject}
								<option value={subject.SubjectID}>
									{subject.subject_name}
									{#if subject.subject_code}({subject.subject_code}){/if}
								</option>
							{/each}
						</select>
					</div>
				{:else}
					<div class="form-group">
						<label>Subject:</label>
						<div class="readonly-field">
							{editingSubject.subject_name}
							{#if editingSubject.subject_code}({editingSubject.subject_code}){/if}
						</div>
					</div>
				{/if}

				<div class="form-group">
					<label>Schedule Days:</label>
					<div class="schedule-days">
						<label class="day-checkbox">
							<input
								type="checkbox"
								name="monday"
								checked={editingSubject?.Monday || false}
							/>
							<span>Monday</span>
						</label>
						<label class="day-checkbox">
							<input
								type="checkbox"
								name="tuesday"
								checked={editingSubject?.Tuesday || false}
							/>
							<span>Tuesday</span>
						</label>
						<label class="day-checkbox">
							<input
								type="checkbox"
								name="wednesday"
								checked={editingSubject?.Wednesday || false}
							/>
							<span>Wednesday</span>
						</label>
						<label class="day-checkbox">
							<input
								type="checkbox"
								name="thursday"
								checked={editingSubject?.Thursday || false}
							/>
							<span>Thursday</span>
						</label>
						<label class="day-checkbox">
							<input
								type="checkbox"
								name="friday"
								checked={editingSubject?.Friday || false}
							/>
							<span>Friday</span>
						</label>
					</div>
				</div>

				<!-- Per-Day Schedule Section -->
				<div class="form-group">
					<label>📅 Per-Day Schedule</label>
					<p class="form-hint">
						Set specific time slots for each day. Leave empty if not
						scheduled.
					</p>
				</div>

				<!-- Monday Schedule -->
				<div class="day-schedule-row">
					<div class="day-label">
						<span class="day-icon">📅</span>
						<strong>Monday</strong>
					</div>
					<div class="time-inputs">
						<div class="time-input-group">
							<label for="mondayStart">Start:</label>
							<input
								type="time"
								id="mondayStart"
								name="mondayStart"
								value={editingSubject?.MondayStart || ""}
							/>
						</div>
						<span class="time-separator">→</span>
						<div class="time-input-group">
							<label for="mondayEnd">End:</label>
							<input
								type="time"
								id="mondayEnd"
								name="mondayEnd"
								value={editingSubject?.MondayEnd || ""}
							/>
						</div>
						<div class="teacher-input-group">
							<label for="mondayTeacher">Teacher:</label>
							<select
								id="mondayTeacher"
								name="mondayTeacher"
								value={editingSubject?.MondayTeacher || ""}
							>
								<option value="">None</option>
								{#each teachers as teacher}
									<option value={teacher.TeacherID}>
										{teacher.FirstName}
										{teacher.LastName}
									</option>
								{/each}
							</select>
						</div>
						<div class="room-input-group">
							<label for="mondayRoom">Room:</label>
							<select
								id="mondayRoom"
								name="mondayRoom"
								value={editingSubject?.MondayRoom || ""}
							>
								<option value="">None</option>
								{#each rooms as room}
									<option value={room.RoomID}>
										{room.RoomName}
									</option>
								{/each}
							</select>
						</div>
					</div>
				</div>

				<!-- Tuesday Schedule -->
				<div class="day-schedule-row">
					<div class="day-label">
						<span class="day-icon">📅</span>
						<strong>Tuesday</strong>
					</div>
					<div class="time-inputs">
						<div class="time-input-group">
							<label for="tuesdayStart">Start:</label>
							<input
								type="time"
								id="tuesdayStart"
								name="tuesdayStart"
								value={editingSubject?.TuesdayStart || ""}
							/>
						</div>
						<span class="time-separator">→</span>
						<div class="time-input-group">
							<label for="tuesdayEnd">End:</label>
							<input
								type="time"
								id="tuesdayEnd"
								name="tuesdayEnd"
								value={editingSubject?.TuesdayEnd || ""}
							/>
						</div>
						<div class="teacher-input-group">
							<label for="tuesdayTeacher">Teacher:</label>
							<select
								id="tuesdayTeacher"
								name="tuesdayTeacher"
								value={editingSubject?.TuesdayTeacher || ""}
							>
								<option value="">None</option>
								{#each teachers as teacher}
									<option value={teacher.TeacherID}>
										{teacher.FirstName}
										{teacher.LastName}
									</option>
								{/each}
							</select>
						</div>
						<div class="room-input-group">
							<label for="tuesdayRoom">Room:</label>
							<select
								id="tuesdayRoom"
								name="tuesdayRoom"
								value={editingSubject?.TuesdayRoom || ""}
							>
								<option value="">None</option>
								{#each rooms as room}
									<option value={room.RoomID}>
										{room.RoomName}
									</option>
								{/each}
							</select>
						</div>
					</div>
				</div>

				<!-- Wednesday Schedule -->
				<div class="day-schedule-row">
					<div class="day-label">
						<span class="day-icon">📅</span>
						<strong>Wednesday</strong>
					</div>
					<div class="time-inputs">
						<div class="time-input-group">
							<label for="wednesdayStart">Start:</label>
							<input
								type="time"
								id="wednesdayStart"
								name="wednesdayStart"
								value={editingSubject?.WednesdayStart || ""}
							/>
						</div>
						<span class="time-separator">→</span>
						<div class="time-input-group">
							<label for="wednesdayEnd">End:</label>
							<input
								type="time"
								id="wednesdayEnd"
								name="wednesdayEnd"
								value={editingSubject?.WednesdayEnd || ""}
							/>
						</div>
						<div class="teacher-input-group">
							<label for="wednesdayTeacher">Teacher:</label>
							<select
								id="wednesdayTeacher"
								name="wednesdayTeacher"
								value={editingSubject?.WednesdayTeacher || ""}
							>
								<option value="">None</option>
								{#each teachers as teacher}
									<option value={teacher.TeacherID}>
										{teacher.FirstName}
										{teacher.LastName}
									</option>
								{/each}
							</select>
						</div>
						<div class="room-input-group">
							<label for="wednesdayRoom">Room:</label>
							<select
								id="wednesdayRoom"
								name="wednesdayRoom"
								value={editingSubject?.WednesdayRoom || ""}
							>
								<option value="">None</option>
								{#each rooms as room}
									<option value={room.RoomID}>
										{room.RoomName}
									</option>
								{/each}
							</select>
						</div>
					</div>
				</div>

				<!-- Thursday Schedule -->
				<div class="day-schedule-row">
					<div class="day-label">
						<span class="day-icon">📅</span>
						<strong>Thursday</strong>
					</div>
					<div class="time-inputs">
						<div class="time-input-group">
							<label for="thursdayStart">Start:</label>
							<input
								type="time"
								id="thursdayStart"
								name="thursdayStart"
								value={editingSubject?.ThursdayStart || ""}
							/>
						</div>
						<span class="time-separator">→</span>
						<div class="time-input-group">
							<label for="thursdayEnd">End:</label>
							<input
								type="time"
								id="thursdayEnd"
								name="thursdayEnd"
								value={editingSubject?.ThursdayEnd || ""}
							/>
						</div>
						<div class="teacher-input-group">
							<label for="thursdayTeacher">Teacher:</label>
							<select
								id="thursdayTeacher"
								name="thursdayTeacher"
								value={editingSubject?.ThursdayTeacher || ""}
							>
								<option value="">None</option>
								{#each teachers as teacher}
									<option value={teacher.TeacherID}>
										{teacher.FirstName}
										{teacher.LastName}
									</option>
								{/each}
							</select>
						</div>
						<div class="room-input-group">
							<label for="thursdayRoom">Room:</label>
							<select
								id="thursdayRoom"
								name="thursdayRoom"
								value={editingSubject?.ThursdayRoom || ""}
							>
								<option value="">None</option>
								{#each rooms as room}
									<option value={room.RoomID}>
										{room.RoomName}
									</option>
								{/each}
							</select>
						</div>
					</div>
				</div>

				<!-- Friday Schedule -->
				<div class="day-schedule-row">
					<div class="day-label">
						<span class="day-icon">📅</span>
						<strong>Friday</strong>
					</div>
					<div class="time-inputs">
						<div class="time-input-group">
							<label for="fridayStart">Start:</label>
							<input
								type="time"
								id="fridayStart"
								name="fridayStart"
								value={editingSubject?.FridayStart || ""}
							/>
						</div>
						<span class="time-separator">→</span>
						<div class="time-input-group">
							<label for="fridayEnd">End:</label>
							<input
								type="time"
								id="fridayEnd"
								name="fridayEnd"
								value={editingSubject?.FridayEnd || ""}
							/>
						</div>
						<div class="teacher-input-group">
							<label for="fridayTeacher">Teacher:</label>
							<select
								id="fridayTeacher"
								name="fridayTeacher"
								value={editingSubject?.FridayTeacher || ""}
							>
								<option value="">None</option>
								{#each teachers as teacher}
									<option value={teacher.TeacherID}>
										{teacher.FirstName}
										{teacher.LastName}
									</option>
								{/each}
							</select>
						</div>
						<div class="room-input-group">
							<label for="fridayRoom">Room:</label>
							<select
								id="fridayRoom"
								name="fridayRoom"
								value={editingSubject?.FridayRoom || ""}
							>
								<option value="">None</option>
								{#each rooms as room}
									<option value={room.RoomID}>
										{room.RoomName}
									</option>
								{/each}
							</select>
						</div>
					</div>
				</div>

				<div class="modal-actions">
					<button
						type="button"
						class="btn btn-secondary"
						on:click={closeSubjectModal}
					>
						Cancel
					</button>
					<button
						type="submit"
						class="btn btn-primary"
						disabled={loading}
					>
						{#if loading}
							<span class="spinner"></span>
							Saving...
						{:else}
							{editingSubject ? "Update Subject" : "Add Subject"}
						{/if}
					</button>
				</div>
			</form>
		</div>
	</div>
{/if}

<!-- Subject Selection Modal for Enrollment -->
{#if showSubjectSelectionModal}
	<div
		class="modal-overlay"
		on:click={closeSubjectSelectionModal}
		on:keydown={(e) => e.key === "Escape" && closeSubjectSelectionModal()}
		role="button"
		tabindex="0"
		aria-label="Close modal"
	>
		<div
			class="modal-content"
			on:click|stopPropagation
			role="document"
			tabindex="-1"
		>
			<div class="modal-header">
				<h3>Select Subject - {selectedSection?.SectionName || ""}</h3>
				<button class="close-btn" on:click={closeSubjectSelectionModal}
					>&times;</button
				>
			</div>

			<div class="modal-body">
				<div class="subjects-list">
					{#if sectionSubjects.length === 0}
						<div class="empty-state">
							<p>
								No subjects available in this section. Please
								add subjects first.
							</p>
						</div>
					{:else}
						{#each sectionSubjects as subject (subject.SubjectID)}
							<div class="subject-item-card">
								<div
									class="subject-item-clickable"
									on:click={() =>
										selectSubjectForEnrollment(subject)}
									on:keydown={(e) =>
										(e.key === "Enter" || e.key === " ") &&
										selectSubjectForEnrollment(subject)}
									role="button"
									tabindex="0"
								>
									<div class="subject-info">
										<div class="subject-name">
											{subject.subject_name}
										</div>
										<div class="subject-code">
											{subject.subject_code || ""}
										</div>
										{#if subject.TeacherName}
											<div class="subject-teacher">
												👨‍🏫 {subject.TeacherName}
											</div>
										{/if}
										{#if subject.StartTime && subject.EndTime}
											<div class="subject-schedule">
												🕐 {subject.StartTime} - {subject.EndTime}
											</div>
										{/if}
										{#if subject.Monday || subject.Tuesday || subject.Wednesday || subject.Thursday || subject.Friday}
											<div class="subject-days">
												📅
												{#if subject.Monday}M{/if}
												{#if subject.Tuesday}T{/if}
												{#if subject.Wednesday}W{/if}
												{#if subject.Thursday}Th{/if}
												{#if subject.Friday}F{/if}
											</div>
										{/if}
									</div>
									<svg
										width="20"
										height="20"
										viewBox="0 0 24 24"
										fill="none"
										stroke="currentColor"
										stroke-width="2"
									>
										<polyline points="9 18 15 12 9 6"
										></polyline>
									</svg>
								</div>
								<button
									type="button"
									class="btn-edit-subject"
									on:click={(e) => {
										e.stopPropagation();
										editSectionSubject(subject);
									}}
									title="Edit subject schedule"
								>
									<svg
										width="16"
										height="16"
										viewBox="0 0 24 24"
										fill="none"
										stroke="currentColor"
										stroke-width="2"
									>
										<path
											d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"
										></path>
										<path
											d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"
										></path>
									</svg>
								</button>
							</div>
						{/each}
					{/if}
				</div>
			</div>

			<div class="modal-actions">
				<button
					type="button"
					class="btn btn-secondary"
					on:click={closeSubjectSelectionModal}
				>
					Cancel
				</button>
			</div>
		</div>
	</div>
{/if}

<!-- Enroll Students Modal -->
{#if showStudentModal}
	<div
		class="modal-overlay"
		on:click={closeStudentModal}
		on:keydown={(e) => e.key === "Escape" && closeStudentModal()}
		role="button"
		tabindex="0"
		aria-label="Close modal"
	>
		<div
			class="modal-content modal-extra-large"
			on:click|stopPropagation
			role="document"
			tabindex="-1"
		>
			<div class="modal-header">
				<div class="modal-header-content">
					<div class="modal-title-section">
						<h3>Manage Enrollments</h3>
						<div class="modal-subtitle">
							<span class="badge badge-blue"
								>{selectedSection?.SectionName}</span
							>
							<span class="separator">›</span>
							<span class="badge badge-purple"
								>{selectedSubject?.SubjectName}</span
							>
						</div>
					</div>
					<div class="enrollment-stats">
						<div class="stat-badge">
							<span class="stat-value"
								>{enrolledStudents.length}</span
							>
							<span class="stat-label">Enrolled</span>
						</div>
						<div class="stat-badge">
							<span class="stat-value"
								>{availableStudents.length}</span
							>
							<span class="stat-label">Available</span>
						</div>
					</div>
				</div>
				<button class="close-btn" on:click={closeStudentModal}
					>&times;</button
				>
			</div>

			<div class="modal-body-split">
				<!-- Search Bar -->
				<div class="search-section">
					<div class="search-wrapper">
						<svg
							class="search-icon"
							width="20"
							height="20"
							viewBox="0 0 24 24"
							fill="none"
							stroke="currentColor"
							stroke-width="2"
						>
							<circle cx="11" cy="11" r="8"></circle>
							<path d="m21 21-4.35-4.35"></path>
						</svg>
						<input
							type="text"
							bind:value={studentSearchTerm}
							placeholder="Search students by name or ID..."
							class="search-input-modern"
						/>
						{#if studentSearchTerm}
							<button
								class="clear-search"
								on:click={() => (studentSearchTerm = "")}
							>
								<svg
									width="16"
									height="16"
									viewBox="0 0 24 24"
									fill="none"
									stroke="currentColor"
									stroke-width="2"
								>
									<line x1="18" y1="6" x2="6" y2="18"></line>
									<line x1="6" y1="6" x2="18" y2="18"></line>
								</svg>
							</button>
						{/if}
					</div>
				</div>

				<!-- Split View Container -->
				<div class="split-container">
					<!-- Enrolled Students (Left) -->
					<div class="panel panel-enrolled">
						<div class="panel-header">
							<div class="panel-title">
								<svg
									width="18"
									height="18"
									viewBox="0 0 24 24"
									fill="none"
									stroke="currentColor"
									stroke-width="2"
								>
									<path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"
									></path>
									<polyline points="22 4 12 14.01 9 11.01"
									></polyline>
								</svg>
								<span>Enrolled Students</span>
							</div>
							<span class="count-badge"
								>{filteredEnrolledStudents.length}</span
							>
						</div>
						<div class="panel-body">
							{#if enrolledStudents.length === 0}
								<div class="empty-panel">
									<svg
										width="48"
										height="48"
										viewBox="0 0 24 24"
										fill="none"
										stroke="currentColor"
										stroke-width="1"
									>
										<path
											d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"
										></path>
										<circle cx="12" cy="7" r="4"></circle>
									</svg>
									<p>No students enrolled yet</p>
								</div>
							{:else if filteredEnrolledStudents.length === 0}
								<div class="empty-panel">
									<p>No results found</p>
								</div>
							{:else}
								<div class="students-grid">
									{#each filteredEnrolledStudents as student (student.StudentID)}
										<div class="student-card enrolled">
											<div class="student-avatar">
												<span
													>{student.FirstName.charAt(
														0,
													)}{student.LastName.charAt(
														0,
													)}</span
												>
											</div>
											<div class="student-details">
												<div class="student-name">
													{student.FirstName}
													{student.LastName}
												</div>
												<div class="student-meta">
													<span class="student-id"
														>#{student.StudentID}</span
													>
													{#if student.YearLevel}
														<span
															class="separator-dot"
															>•</span
														>
														<span class="year-level"
															>Year {student.YearLevel}</span
														>
													{/if}
												</div>
											</div>
											<button
												type="button"
												class="action-btn btn-remove"
												on:click={() =>
													handleUnenrollStudent(
														student.StudentID,
													)}
												title="Unenroll student"
											>
												<svg
													width="16"
													height="16"
													viewBox="0 0 24 24"
													fill="none"
													stroke="currentColor"
													stroke-width="2"
												>
													<line
														x1="18"
														y1="6"
														x2="6"
														y2="18"
													></line>
													<line
														x1="6"
														y1="6"
														x2="18"
														y2="18"
													></line>
												</svg>
											</button>
										</div>
									{/each}
								</div>
							{/if}
						</div>
					</div>

					<!-- Available Students (Right) -->
					<div class="panel panel-available">
						<div class="panel-header">
							<div class="panel-title">
								<svg
									width="18"
									height="18"
									viewBox="0 0 24 24"
									fill="none"
									stroke="currentColor"
									stroke-width="2"
								>
									<path
										d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"
									></path>
									<circle cx="12" cy="7" r="4"></circle>
								</svg>
								<span>Available Students</span>
							</div>
							<span class="count-badge"
								>{availableStudents.length}</span
							>
						</div>
						<div class="panel-body">
							{#if students.length === 0}
								<div class="empty-panel">
									<svg
										width="48"
										height="48"
										viewBox="0 0 24 24"
										fill="none"
										stroke="currentColor"
										stroke-width="1"
									>
										<path
											d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"
										></path>
										<circle cx="12" cy="7" r="4"></circle>
									</svg>
									<p>No students available</p>
								</div>
							{:else if availableStudents.length === 0}
								<div class="empty-panel">
									<p>All students enrolled or no results</p>
								</div>
							{:else}
								<div class="students-grid">
									{#each availableStudents as student (student.StudentID)}
										<div
											class="student-card available"
											class:selected={selectedStudents.has(
												student.StudentID,
											)}
											on:click={() =>
												toggleStudent(
													student.StudentID,
												)}
											on:keydown={(e) =>
												(e.key === "Enter" ||
													e.key === " ") &&
												toggleStudent(
													student.StudentID,
												)}
											role="button"
											tabindex="0"
										>
											<div
												class="student-checkbox-modern"
											>
												<input
													type="checkbox"
													checked={selectedStudents.has(
														student.StudentID,
													)}
													on:click|stopPropagation
													on:change={() =>
														toggleStudent(
															student.StudentID,
														)}
												/>
												<span class="checkmark"></span>
											</div>
											<div class="student-avatar">
												<span
													>{student.FirstName.charAt(
														0,
													)}{student.LastName.charAt(
														0,
													)}</span
												>
											</div>
											<div class="student-details">
												<div class="student-name">
													{student.FirstName}
													{student.LastName}
												</div>
												<div class="student-meta">
													<span class="student-id"
														>#{student.StudentID}</span
													>
													{#if student.YearLevel}
														<span
															class="separator-dot"
															>•</span
														>
														<span class="year-level"
															>Year {student.YearLevel}</span
														>
													{/if}
												</div>
											</div>
										</div>
									{/each}
								</div>
							{/if}
						</div>
					</div>
				</div>
			</div>

			<div class="modal-footer">
				<div class="footer-info">
					{#if selectedCount > 0}
						<span class="selection-info">
							<svg
								width="16"
								height="16"
								viewBox="0 0 24 24"
								fill="none"
								stroke="currentColor"
								stroke-width="2"
							>
								<polyline points="20 6 9 17 4 12"></polyline>
							</svg>
							{selectedCount} student{selectedCount !== 1
								? "s"
								: ""} selected
						</span>
					{:else}
						<span class="hint-text"
							>Select students from the right panel to enroll</span
						>
					{/if}
				</div>
				<div class="footer-actions">
					<button
						type="button"
						class="btn btn-secondary"
						on:click={closeStudentModal}
					>
						<svg
							width="16"
							height="16"
							viewBox="0 0 24 24"
							fill="none"
							stroke="currentColor"
							stroke-width="2"
						>
							<line x1="18" y1="6" x2="6" y2="18"></line>
							<line x1="6" y1="6" x2="18" y2="18"></line>
						</svg>
						Close
					</button>
					<button
						type="button"
						class="btn btn-primary btn-large"
						disabled={enrolling || selectedCount === 0}
						on:click={handleEnrollStudents}
					>
						{#if enrolling}
							<span class="spinner"></span>
							Enrolling...
						{:else}
							<svg
								width="16"
								height="16"
								viewBox="0 0 24 24"
								fill="none"
								stroke="currentColor"
								stroke-width="2"
							>
								<path
									d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"
								></path>
								<circle cx="8.5" cy="7" r="4"></circle>
								<line x1="20" y1="8" x2="20" y2="14"></line>
								<line x1="23" y1="11" x2="17" y2="11"></line>
							</svg>
							Enroll {selectedCount} Student{selectedCount !== 1
								? "s"
								: ""}
						{/if}
					</button>
				</div>
			</div>
		</div>
	</div>
{/if}
```

<style>
	/* ===== LOADING SCREEN ===== */
	:global(body) {
		margin: 0;
		padding: 0;
		overflow-x: hidden;
	}

	.loading-screen {
		position: fixed;
		top: 0;
		left: 0;
		width: 100%;
		height: 100vh;
		background: linear-gradient(135deg, #f5f7fa 0%, #f1f5f9 100%);
		display: flex;
		align-items: center;
		justify-content: center;
		z-index: 9999;
		overflow: hidden;
		transition: opacity 0.8s ease-out;
	}

	.loading-screen.fade-out {
		opacity: 0;
		pointer-events: none;
	}

	.particles-container {
		position: absolute;
		width: 100%;
		height: 100%;
		overflow: hidden;
	}

	.particle {
		position: absolute;
		width: 6px;
		height: 6px;
		background: radial-gradient(
			circle,
			rgba(59, 130, 246, 0.6),
			rgba(59, 130, 246, 0.2)
		);
		border-radius: 50%;
		animation: particleFloat 4s ease-in-out infinite;
	}

	.particle-1 {
		width: 4px;
		height: 4px;
		animation-delay: 0s;
		left: 10%;
		top: 20%;
	}
	.particle-2 {
		width: 6px;
		height: 6px;
		animation-delay: 1s;
		left: 80%;
		top: 60%;
	}
	.particle-3 {
		width: 5px;
		height: 5px;
		animation-delay: 2s;
		left: 30%;
		top: 70%;
	}
	.particle-4 {
		width: 7px;
		height: 7px;
		animation-delay: 3s;
		left: 60%;
		top: 10%;
	}

	@keyframes particleFloat {
		0%,
		100% {
			transform: translateY(0px) translateX(0px);
			opacity: 0;
		}
		50% {
			transform: translateY(-20px) translateX(10px);
			opacity: 0.6;
		}
	}

	.loading-content {
		position: relative;
		z-index: 10;
		text-align: center;
	}

	.loading-logo {
		position: relative;
		width: 100px;
		height: 100px;
		margin: 0 auto 30px;
	}

	.logo-pulse {
		position: absolute;
		inset: 0;
		border-radius: 20px;
		background: linear-gradient(
			135deg,
			rgba(59, 130, 246, 0.3),
			rgba(168, 85, 247, 0.3)
		);
		animation: pulse-scale 2s ease-in-out infinite;
	}

	.logo-svg {
		position: relative;
		width: 100%;
		height: 100%;
		z-index: 2;
	}

	@keyframes pulse-scale {
		0%,
		100% {
			transform: scale(1);
			opacity: 0.5;
		}
		50% {
			transform: scale(1.1);
			opacity: 1;
		}
	}

	.loading-brand {
		margin-bottom: 30px;
	}

	.brand-main {
		font-size: 28px;
		font-weight: 700;
		background: linear-gradient(135deg, #3b82f6, #a855f7);
		-webkit-background-clip: text;
		-webkit-text-fill-color: transparent;
		background-clip: text;
		letter-spacing: -0.5px;
	}

	.brand-tagline {
		font-size: 12px;
		color: #64748b;
		text-transform: uppercase;
		letter-spacing: 2px;
		margin-top: 8px;
		font-weight: 600;
	}

	.loading-progress {
		width: 280px;
		margin: 0 auto 20px;
	}

	.progress-bar {
		position: relative;
		height: 6px;
		background: rgba(15, 23, 42, 0.1);
		border-radius: 10px;
		overflow: hidden;
		margin-bottom: 8px;
	}

	.progress-fill {
		height: 100%;
		background: linear-gradient(90deg, #3b82f6, #a855f7);
		border-radius: 10px;
		transition: width 0.3s ease-out;
	}

	.progress-glow {
		position: absolute;
		top: 0;
		height: 100%;
		width: 30px;
		background: linear-gradient(
			90deg,
			transparent,
			rgba(255, 255, 255, 0.8),
			transparent
		);
		filter: blur(8px);
		animation: glow-shift 1.5s ease-in-out infinite;
	}

	@keyframes glow-shift {
		0%,
		100% {
			opacity: 0;
		}
		50% {
			opacity: 1;
		}
	}

	.progress-text {
		font-size: 12px;
		color: #475569;
		text-align: center;
		font-weight: 500;
	}

	.progress-percentage {
		font-weight: 700;
		color: #1e293b;
	}

	.loading-dots {
		display: flex;
		gap: 8px;
		justify-content: center;
		margin-bottom: 20px;
	}

	.dot {
		width: 8px;
		height: 8px;
		border-radius: 50%;
		background: #cbd5e1;
		animation: dot-bounce 1s ease-in-out infinite;
	}

	.dot-1 {
		animation-delay: 0s;
	}
	.dot-2 {
		animation-delay: 0.15s;
	}
	.dot-3 {
		animation-delay: 0.3s;
	}

	@keyframes dot-bounce {
		0%,
		100% {
			transform: translateY(0);
			opacity: 0.5;
		}
		50% {
			transform: translateY(-8px);
			opacity: 1;
		}
	}

	.loading-orbs {
		position: absolute;
		inset: 0;
		width: 100%;
		height: 100%;
		pointer-events: none;
	}

	.orb {
		position: absolute;
		border-radius: 50%;
		filter: blur(60px);
		opacity: 0.1;
	}

	.orb-1 {
		width: 150px;
		height: 150px;
		background: #3b82f6;
		top: 20%;
		left: 10%;
	}
	.orb-2 {
		width: 200px;
		height: 200px;
		background: #a855f7;
		bottom: 20%;
		right: 10%;
	}
	.orb-3 {
		width: 120px;
		height: 120px;
		background: #22c55e;
		top: 50%;
		left: 50%;
	}
	.orb-4 {
		width: 180px;
		height: 180px;
		background: #f97316;
		bottom: 30%;
		left: 20%;
	}

	/* ===== ANIMATED BACKGROUND ===== */
	.animated-background {
		position: fixed;
		top: 0;
		left: 0;
		width: 100%;
		height: 100%;
		z-index: -1;
		pointer-events: none;
	}

	.dot-pattern {
		position: absolute;
		inset: 0;
		background-image: radial-gradient(circle, #d0d0d0 1px, transparent 1px);
		background-size: 30px 30px;
		opacity: 0.6;
	}

	.floating-orb {
		position: absolute;
		border-radius: 50%;
		filter: blur(80px);
		opacity: 0.15;
	}

	.orb-bg-1 {
		width: 400px;
		height: 400px;
		background: linear-gradient(135deg, #3b82f6, #60a5fa);
		top: 10%;
		left: 10%;
		animation: float-8s 8s ease-in-out infinite;
	}

	.orb-bg-2 {
		width: 500px;
		height: 500px;
		background: linear-gradient(135deg, #a855f7, #d8b4fe);
		bottom: 5%;
		right: 5%;
		animation: float-10s-reverse 10s ease-in-out infinite;
	}

	.orb-bg-3 {
		width: 350px;
		height: 350px;
		background: linear-gradient(135deg, #22c55e, #86efac);
		top: 50%;
		right: 10%;
		animation: float-12s 12s ease-in-out infinite;
	}

	@keyframes float-8s {
		0%,
		100% {
			transform: translate(0, 0);
		}
		25% {
			transform: translate(30px, -30px);
		}
		50% {
			transform: translate(0, -40px);
		}
		75% {
			transform: translate(-30px, -20px);
		}
	}

	@keyframes float-10s-reverse {
		0%,
		100% {
			transform: translate(0, 0);
		}
		25% {
			transform: translate(-30px, 30px);
		}
		50% {
			transform: translate(0, 40px);
		}
		75% {
			transform: translate(30px, 20px);
		}
	}

	@keyframes float-12s {
		0%,
		100% {
			transform: translate(0, 0);
		}
		33% {
			transform: translate(20px, -40px);
		}
		66% {
			transform: translate(-20px, 20px);
		}
	}

	/* ===== PAGE STRUCTURE ===== */
	.sections-page {
		position: relative;
		z-index: 1;
		padding: 40px 20px;
		min-height: 100vh;
		opacity: 0;
		transform: translateY(20px);
		transition: all 0.6s cubic-bezier(0.4, 0, 0.2, 1);
	}

	.sections-page.visible {
		opacity: 1;
		transform: translateY(0);
	}

	/* ===== PAGE HEADER ===== */
	.page-header {
		display: flex;
		align-items: center;
		gap: 24px;
		background: rgba(255, 255, 255, 0.4);
		backdrop-filter: blur(20px);
		border: 1px solid rgba(255, 255, 255, 0.6);
		border-radius: 20px;
		padding: 30px 32px;
		margin-bottom: 40px;
		position: relative;
		overflow: hidden;
		opacity: 0;
		transform: translateY(-20px);
		transition: all 0.6s cubic-bezier(0.4, 0, 0.2, 1);
	}

	.page-header.visible {
		opacity: 1;
		transform: translateY(0);
	}

	.page-header::before {
		content: "";
		position: absolute;
		top: 0;
		left: 0;
		right: 0;
		height: 1px;
		background: linear-gradient(
			90deg,
			transparent,
			rgba(255, 255, 255, 0.8),
			transparent
		);
	}

	.header-icon-wrapper {
		display: flex;
		align-items: center;
		justify-content: center;
		width: 80px;
		height: 80px;
		background: linear-gradient(135deg, #3b82f6, #a855f7);
		border-radius: 16px;
		flex-shrink: 0;
		animation: pulse-slow 3s ease-in-out infinite;
	}

	.header-icon {
		width: 40px;
		height: 40px;
		color: white;
	}

	@keyframes pulse-slow {
		0%,
		100% {
			box-shadow: 0 0 0 0 rgba(59, 130, 246, 0.7);
		}
		50% {
			box-shadow: 0 0 0 20px rgba(59, 130, 246, 0);
		}
	}

	.header-content {
		flex: 1;
	}

	.header-content h1 {
		font-size: 32px;
		font-weight: 700;
		margin: 0 0 8px 0;
		background: linear-gradient(135deg, #1e293b, #3b82f6);
		-webkit-background-clip: text;
		-webkit-text-fill-color: transparent;
		background-clip: text;
	}

	.header-content .subtitle {
		font-size: 14px;
		color: #64748b;
		margin: 0;
	}

	/* ===== STATS GRID ===== */
	.stats-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
		gap: 20px;
		margin-bottom: 40px;
		opacity: 0;
		transform: translateY(20px);
		transition: all 0.6s cubic-bezier(0.4, 0, 0.2, 1);
	}

	.stats-grid.visible {
		opacity: 1;
		transform: translateY(0);
	}

	.stat-card {
		position: relative;
		background: rgba(255, 255, 255, 0.4);
		backdrop-filter: blur(20px);
		border: 1px solid rgba(255, 255, 255, 0.6);
		border-radius: 16px;
		padding: 24px;
		overflow: hidden;
		transition: all 0.3s ease-out;
		animation: cascadeIn 0.5s ease-out forwards;
	}

	.stat-card-1 {
		animation-delay: 0.1s;
	}
	.stat-card-2 {
		animation-delay: 0.2s;
	}
	.stat-card-3 {
		animation-delay: 0.3s;
	}
	.stat-card-4 {
		animation-delay: 0.4s;
	}

	@keyframes cascadeIn {
		from {
			opacity: 0;
			transform: translateY(20px);
		}
		to {
			opacity: 1;
			transform: translateY(0);
		}
	}

	.stat-card::before {
		content: "";
		position: absolute;
		top: 0;
		left: 0;
		right: 0;
		height: 2px;
		background: linear-gradient(
			90deg,
			transparent,
			rgba(255, 255, 255, 0.8),
			transparent
		);
	}

	.stat-card:hover {
		transform: translateY(-8px) scale(1.02);
		box-shadow: 0 20px 40px rgba(59, 130, 246, 0.1);
	}

	.stat-glow {
		position: absolute;
		inset: -50%;
		background: radial-gradient(
			circle,
			rgba(59, 130, 246, 0.2),
			transparent
		);
		animation: glowPulse 3s ease-in-out infinite;
		pointer-events: none;
	}

	@keyframes glowPulse {
		0%,
		100% {
			opacity: 0.5;
		}
		50% {
			opacity: 1;
		}
	}

	.stat-icon-wrapper {
		display: flex;
		align-items: center;
		justify-content: center;
		width: 60px;
		height: 60px;
		background: linear-gradient(135deg, #3b82f6, #60a5fa);
		border-radius: 12px;
		margin-bottom: 16px;
	}

	.stat-card-2 .stat-icon-wrapper {
		background: linear-gradient(135deg, #a855f7, #d8b4fe);
	}

	.stat-card-3 .stat-icon-wrapper {
		background: linear-gradient(135deg, #22c55e, #86efac);
	}

	.stat-card-4 .stat-icon-wrapper {
		background: linear-gradient(135deg, #f97316, #fbbd23);
	}

	.stat-icon {
		width: 30px;
		height: 30px;
		color: white;
	}

	.stat-content {
		position: relative;
		z-index: 2;
	}

	.stat-number {
		font-size: 32px;
		font-weight: 700;
		color: #1e293b;
		margin-bottom: 4px;
	}

	.stat-label {
		font-size: 13px;
		color: #64748b;
		font-weight: 500;
		text-transform: uppercase;
		letter-spacing: 0.5px;
	}

	/* ===== CONTENT SECTION ===== */
	.content-section {
		opacity: 0;
		transform: translateY(20px);
		transition: all 0.6s cubic-bezier(0.4, 0, 0.2, 1);
	}

	.content-section.visible {
		opacity: 1;
		transform: translateY(0);
	}

	.section-card {
		background: rgba(255, 255, 255, 0.4);
		backdrop-filter: blur(20px);
		border: 1px solid rgba(255, 255, 255, 0.6);
		border-radius: 16px;
		overflow: hidden;
		position: relative;
	}

	.section-card::before {
		content: "";
		position: absolute;
		top: 0;
		left: 0;
		right: 0;
		height: 3px;
		background: linear-gradient(90deg, #3b82f6, #a855f7, #22c55e);
	}

	.card-header {
		padding: 24px 32px;
		border-bottom: 1px solid rgba(255, 255, 255, 0.3);
	}

	.card-title {
		margin: 0;
		font-size: 20px;
		font-weight: 600;
		color: #1e293b;
	}

	.card-content {
		padding: 24px 32px;
	}

	/* ===== SEARCH BAR ===== */
	.search-container {
		margin-bottom: 24px;
	}

	.search-input {
		width: 100%;
		padding: 12px 16px;
		background: rgba(255, 255, 255, 0.5);
		border: 1px solid rgba(255, 255, 255, 0.5);
		border-radius: 12px;
		font-size: 14px;
		color: #1e293b;
		transition: all 0.3s ease-out;
		backdrop-filter: blur(10px);
		font-family: inherit;
	}

	.search-input::placeholder {
		color: #94a3b8;
	}

	.search-input:focus {
		outline: none;
		background: rgba(255, 255, 255, 0.7);
		border-color: rgba(59, 130, 246, 0.5);
		box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
	}

	/* ===== SECTIONS GRID ===== */
	   .sections-grid {
		   display: grid;
		   grid-template-columns: repeat(auto-fill, minmax(370px, 1fr));
		   gap: 24px;
	   }

	   .section-card-item {
		   background: rgba(255, 255, 255, 0.3);
		   border: 1px solid rgba(255, 255, 255, 0.4);
		   border-radius: 12px;
		   padding: 32px 28px 28px 28px;
		   cursor: pointer;
		   transition: all 0.3s ease-out;
		   position: relative;
		   overflow: hidden;
		   animation: cascadeIn 0.5s ease-out forwards;
	   }

	.section-card-item::before {
		content: "";
		position: absolute;
		top: 0;
		left: 0;
		right: 0;
		height: 2px;
		background: linear-gradient(
			90deg,
			transparent,
			rgba(59, 130, 246, 0.6),
			transparent
		);
	}

	.section-card-item:hover {
		background: rgba(255, 255, 255, 0.5);
		border-color: rgba(59, 130, 246, 0.3);
		transform: translateY(-4px);
		box-shadow: 0 12px 24px rgba(59, 130, 246, 0.15);
	}

	.card-glow {
		position: absolute;
		inset: 0;
		background: radial-gradient(
			circle at center,
			rgba(59, 130, 246, 0.1),
			transparent
		);
		opacity: 0;
		transition: opacity 0.3s ease-out;
		pointer-events: none;
	}

	.section-card-item:hover .card-glow {
		opacity: 1;
	}

	.card-header-mini {
		margin-bottom: 16px;
	}

	.card-title-section {
		display: flex;
		align-items: center;
		justify-content: space-between;
		gap: 12px;
		margin-bottom: 12px;
	}

	.card-title-section h3 {
		margin: 0;
		font-size: 16px;
		font-weight: 600;
		color: #1e293b;
	}

	.status-badge {
		display: inline-block;
		padding: 4px 12px;
		border-radius: 20px;
		font-size: 11px;
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.5px;
	}

	.status-badge.active {
		background: rgba(34, 197, 94, 0.2);
		color: #16a34a;
	}

	.status-badge.inactive {
		background: rgba(148, 163, 184, 0.2);
		color: #64748b;
	}

	.card-stats {
		display: flex;
		gap: 12px;
		margin-bottom: 16px;
	}

	.stat-item {
		display: flex;
		align-items: center;
		gap: 6px;
		font-size: 13px;
		color: #64748b;
	}

	.stat-icon-mini {
		font-size: 16px;
	}

	.card-actions {
		display: flex;
		gap: 8px;
		position: relative;
		z-index: 10;
	}

	/* ===== BUTTONS ===== */
	.btn {
		display: inline-flex;
		align-items: center;
		justify-content: center;
		gap: 8px;
		padding: 10px 16px;
		border: none;
		border-radius: 8px;
		font-size: 13px;
		font-weight: 600;
		cursor: pointer;
		transition: all 0.3s ease-out;
		text-transform: uppercase;
		letter-spacing: 0.5px;
		font-family: inherit;
		position: relative;
		z-index: 10;
		pointer-events: auto;
	}

	.btn-primary {
		background: linear-gradient(135deg, #3b82f6, #2563eb);
		color: white;
		box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
	}

	.btn-primary:hover {
		transform: translateY(-2px);
		box-shadow: 0 6px 20px rgba(59, 130, 246, 0.4);
	}

	.btn-primary:active {
		transform: translateY(0);
	}

	.btn-secondary {
		background: rgba(255, 255, 255, 0.3);
		color: #1e293b;
		border: 1px solid rgba(255, 255, 255, 0.4);
		backdrop-filter: blur(10px);
	}

	.btn-secondary:hover {
		background: rgba(255, 255, 255, 0.5);
		border-color: rgba(59, 130, 246, 0.3);
		transform: translateY(-2px);
	}

	.btn:disabled {
		opacity: 0.6;
		cursor: not-allowed;
	}

	.spinner {
		display: inline-block;
		width: 12px;
		height: 12px;
		border: 2px solid rgba(255, 255, 255, 0.3);
		border-top-color: white;
		border-radius: 50%;
		animation: spin 0.8s linear infinite;
	}

	.modal-extra-large {
		max-width: 1200px;
		max-height: 90vh;
	}

	.modal-schedule-large {
		max-width: 1000px;
		max-height: 85vh;
	}

	@keyframes slideUp {
		from {
			opacity: 0;
			transform: translateY(20px);
		}
		to {
			opacity: 1;
			transform: translateY(0);
		}
	}

	.modal-header {
		display: flex;
		align-items: center;
		justify-content: space-between;
		margin-bottom: 24px;
		padding-bottom: 20px;
		border-bottom: 1px solid rgba(255, 255, 255, 0.2);
	}

	.modal-header-content {
		flex: 1;
		display: flex;
		align-items: center;
		justify-content: space-between;
		gap: 20px;
	}

	.modal-title-section {
		flex: 1;
	}

	.modal-subtitle {
		display: flex;
		align-items: center;
		gap: 8px;
		margin-top: 8px;
	}

	.badge {
		display: inline-block;
		padding: 4px 12px;
		border-radius: 20px;
		font-size: 11px;
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.5px;
	}

	.badge-blue {
		background: rgba(59, 130, 246, 0.2);
		color: #2563eb;
	}

	.badge-purple {
		background: rgba(168, 85, 247, 0.2);
		color: #9333ea;
	}

	.separator {
		color: #94a3b8;
		font-size: 18px;
	}

	.enrollment-stats {
		display: flex;
		gap: 12px;
	}

	.stat-badge {
		display: flex;
		flex-direction: column;
		align-items: center;
		padding: 8px 16px;
		background: rgba(255, 255, 255, 0.3);
		border-radius: 8px;
		min-width: 80px;
	}

	.stat-value {
		font-size: 24px;
		font-weight: 700;
		color: #1e293b;
		line-height: 1;
	}

	.stat-label {
		font-size: 11px;
		color: #64748b;
		text-transform: uppercase;
		letter-spacing: 0.5px;
		margin-top: 4px;
	}

	.modal-header h3 {
		margin: 0;
		font-size: 20px;
		font-weight: 600;
		color: #1e293b;
	}

	.close-btn {
		background: none;
		border: none;
		font-size: 28px;
		color: #64748b;
		cursor: pointer;
		transition: color 0.3s ease-out;
		font-family: inherit;
	}

	.close-btn:hover {
		color: #1e293b;
	}

	/* ===== FORM ===== */
	.form-group {
		margin-bottom: 20px;
	}

	.form-group label {
		display: block;
		margin-bottom: 8px;
		font-size: 13px;
		font-weight: 600;
		color: #1e293b;
		text-transform: uppercase;
		letter-spacing: 0.5px;
	}

	.form-group input,
	.form-group select {
		width: 100%;
		padding: 12px 16px;
		background: rgba(255, 255, 255, 0.5);
		border: 1px solid rgba(255, 255, 255, 0.5);
		border-radius: 8px;
		font-size: 14px;
		color: #1e293b;
		transition: all 0.3s ease-out;
		font-family: inherit;
		box-sizing: border-box;
	}

	.form-group input::placeholder {
		color: #94a3b8;
	}

	.form-group input:focus,
	.form-group select:focus {
		outline: none;
		background: rgba(255, 255, 255, 0.7);
		border-color: rgba(59, 130, 246, 0.5);
		box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
	}

	.form-row {
		display: grid;
		grid-template-columns: 1fr 1fr;
		gap: 16px;
	}

	.schedule-days {
		display: flex;
		flex-wrap: wrap;
		gap: 12px;
		margin-top: 8px;
	}

	.day-checkbox {
		display: flex;
		align-items: center;
		gap: 8px;
		padding: 8px 16px;
		background: rgba(255, 255, 255, 0.4);
		border: 2px solid rgba(255, 255, 255, 0.5);
		border-radius: 8px;
		cursor: pointer;
		transition: all 0.3s ease-out;
		font-size: 13px;
		font-weight: 500;
		color: #1e293b;
		text-transform: none;
		letter-spacing: normal;
	}

	.day-checkbox:hover {
		background: rgba(255, 255, 255, 0.6);
		border-color: rgba(59, 130, 246, 0.3);
	}

	.day-checkbox input[type="checkbox"] {
		width: auto;
		margin: 0;
		cursor: pointer;
	}

	.day-checkbox input[type="checkbox"]:checked + span {
		color: #3b82f6;
		font-weight: 600;
	}

	/* ===== MODAL ACTIONS ===== */
	.modal-actions {
		display: flex;
		gap: 12px;
		justify-content: flex-end;
		margin-top: 28px;
		padding-top: 20px;
		border-top: 1px solid rgba(255, 255, 255, 0.2);
	}

	.modal-body {
		margin-bottom: 20px;
	}

	/* ===== SPLIT VIEW MODAL ===== */
	.modal-body-split {
		display: flex;
		flex-direction: column;
		gap: 16px;
	}

	.search-section {
		padding: 0;
	}

	.search-wrapper {
		position: relative;
		display: flex;
		align-items: center;
	}

	.search-icon {
		position: absolute;
		left: 16px;
		color: #64748b;
		pointer-events: none;
	}

	.search-input-modern {
		width: 100%;
		padding: 14px 48px 14px 48px;
		background: rgba(255, 255, 255, 0.5);
		border: 2px solid rgba(255, 255, 255, 0.5);
		border-radius: 12px;
		font-size: 14px;
		color: #1e293b;
		transition: all 0.3s ease-out;
		font-family: inherit;
		box-sizing: border-box;
	}

	.search-input-modern::placeholder {
		color: #94a3b8;
	}

	.search-input-modern:focus {
		outline: none;
		background: rgba(255, 255, 255, 0.8);
		border-color: rgba(59, 130, 246, 0.5);
		box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.1);
	}

	.clear-search {
		position: absolute;
		right: 12px;
		background: rgba(100, 116, 139, 0.1);
		border: none;
		border-radius: 6px;
		padding: 6px;
		cursor: pointer;
		display: flex;
		align-items: center;
		justify-content: center;
		transition: all 0.2s ease-out;
	}

	.clear-search:hover {
		background: rgba(100, 116, 139, 0.2);
	}

	.split-container {
		display: grid;
		grid-template-columns: 1fr 1fr;
		gap: 16px;
		min-height: 500px;
	}

	.panel {
		display: flex;
		flex-direction: column;
		background: rgba(255, 255, 255, 0.3);
		border: 1px solid rgba(255, 255, 255, 0.4);
		border-radius: 12px;
		overflow: hidden;
	}

	.panel-enrolled {
		border-left: 3px solid #22c55e;
	}

	.panel-available {
		border-left: 3px solid #3b82f6;
	}

	.panel-header {
		display: flex;
		align-items: center;
		justify-content: space-between;
		padding: 16px 20px;
		background: rgba(255, 255, 255, 0.3);
		border-bottom: 1px solid rgba(255, 255, 255, 0.3);
	}

	.panel-title {
		display: flex;
		align-items: center;
		gap: 8px;
		font-size: 14px;
		font-weight: 600;
		color: #1e293b;
		text-transform: uppercase;
		letter-spacing: 0.5px;
	}

	.count-badge {
		display: inline-flex;
		align-items: center;
		justify-content: center;
		min-width: 28px;
		height: 28px;
		padding: 0 8px;
		background: rgba(59, 130, 246, 0.2);
		color: #2563eb;
		border-radius: 14px;
		font-size: 12px;
		font-weight: 700;
	}

	.panel-body {
		flex: 1;
		overflow-y: auto;
		padding: 16px;
	}

	.empty-panel {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		height: 100%;
		min-height: 300px;
		color: #94a3b8;
		text-align: center;
	}

	.empty-panel svg {
		margin-bottom: 16px;
		opacity: 0.3;
	}

	.empty-panel p {
		margin: 0;
		font-size: 14px;
	}

	.students-grid {
		display: flex;
		flex-direction: column;
		gap: 8px;
	}

	.student-card {
		display: flex;
		align-items: center;
		gap: 12px;
		padding: 12px;
		background: rgba(255, 255, 255, 0.4);
		border: 2px solid rgba(255, 255, 255, 0.4);
		border-radius: 10px;
		transition: all 0.3s ease-out;
	}

	.student-card.available {
		cursor: pointer;
	}

	.student-card.available:hover {
		background: rgba(255, 255, 255, 0.6);
		border-color: rgba(59, 130, 246, 0.3);
		transform: translateX(4px);
	}

	.student-card.selected {
		background: rgba(59, 130, 246, 0.15);
		border-color: rgba(59, 130, 246, 0.5);
	}

	.student-card.enrolled {
		background: rgba(34, 197, 94, 0.1);
		border-color: rgba(34, 197, 94, 0.2);
	}

	.student-avatar {
		display: flex;
		align-items: center;
		justify-content: center;
		width: 40px;
		height: 40px;
		background: linear-gradient(135deg, #3b82f6, #8b5cf6);
		border-radius: 50%;
		color: white;
		font-size: 14px;
		font-weight: 600;
		flex-shrink: 0;
	}

	.student-card.enrolled .student-avatar {
		background: linear-gradient(135deg, #22c55e, #10b981);
	}

	.student-details {
		flex: 1;
		min-width: 0;
	}

	.student-name {
		font-size: 14px;
		font-weight: 600;
		color: #1e293b;
		margin-bottom: 4px;
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
	}

	.student-meta {
		display: flex;
		align-items: center;
		gap: 6px;
		font-size: 12px;
		color: #64748b;
	}

	.separator-dot {
		color: #cbd5e1;
	}

	.student-checkbox-modern {
		position: relative;
		width: 20px;
		height: 20px;
		flex-shrink: 0;
	}

	.student-checkbox-modern input[type="checkbox"] {
		position: absolute;
		opacity: 0;
		cursor: pointer;
		width: 100%;
		height: 100%;
		z-index: 2;
	}

	.student-checkbox-modern .checkmark {
		position: absolute;
		top: 0;
		left: 0;
		height: 20px;
		width: 20px;
		background: rgba(255, 255, 255, 0.5);
		border: 2px solid rgba(100, 116, 139, 0.3);
		border-radius: 6px;
		transition: all 0.3s ease-out;
	}

	.student-checkbox-modern input:checked ~ .checkmark {
		background: linear-gradient(135deg, #3b82f6, #2563eb);
		border-color: #3b82f6;
	}

	.student-checkbox-modern .checkmark:after {
		content: "";
		position: absolute;
		display: none;
		left: 6px;
		top: 2px;
		width: 5px;
		height: 10px;
		border: solid white;
		border-width: 0 2px 2px 0;
		transform: rotate(45deg);
	}

	.student-checkbox-modern input:checked ~ .checkmark:after {
		display: block;
	}

	.action-btn {
		display: flex;
		align-items: center;
		justify-content: center;
		width: 32px;
		height: 32px;
		border: none;
		border-radius: 8px;
		cursor: pointer;
		transition: all 0.3s ease-out;
		flex-shrink: 0;
	}

	.btn-remove {
		background: rgba(239, 68, 68, 0.1);
		color: #dc2626;
	}

	.btn-remove:hover {
		background: rgba(239, 68, 68, 0.2);
		transform: scale(1.1);
	}

	/* ===== MODAL FOOTER ===== */
	.modal-footer {
		display: flex;
		align-items: center;
		justify-content: space-between;
		padding-top: 20px;
		border-top: 1px solid rgba(255, 255, 255, 0.2);
		margin-top: 16px;
	}

	.footer-info {
		flex: 1;
	}

	.selection-info {
		display: inline-flex;
		align-items: center;
		gap: 8px;
		padding: 8px 16px;
		background: rgba(59, 130, 246, 0.1);
		color: #2563eb;
		border-radius: 8px;
		font-size: 13px;
		font-weight: 600;
	}

	.hint-text {
		color: #94a3b8;
		font-size: 13px;
	}

	.footer-actions {
		display: flex;
		gap: 12px;
	}

	.btn-large {
		padding: 12px 24px;
		font-size: 14px;
	}

	/* ===== STUDENTS LIST ===== */
	.students-list {
		max-height: 400px;
		overflow-y: auto;
		margin-top: 16px;
		border-radius: 8px;
		background: rgba(255, 255, 255, 0.2);
		padding: 8px;
	}

	.student-item {
		display: flex;
		align-items: center;
		gap: 12px;
		padding: 12px 16px;
		background: rgba(255, 255, 255, 0.3);
		border: 1px solid rgba(255, 255, 255, 0.4);
		border-radius: 8px;
		margin-bottom: 8px;
		cursor: pointer;
		transition: all 0.3s ease-out;
	}

	.student-item:hover {
		background: rgba(255, 255, 255, 0.5);
		border-color: rgba(59, 130, 246, 0.3);
		transform: translateX(4px);
	}

	.student-item.selected {
		background: rgba(59, 130, 246, 0.2);
		border-color: rgba(59, 130, 246, 0.5);
	}

	.student-checkbox {
		flex-shrink: 0;
	}

	.student-checkbox input[type="checkbox"] {
		width: 18px;
		height: 18px;
		cursor: pointer;
	}

	.student-info {
		flex: 1;
	}

	.student-name {
		font-size: 14px;
		font-weight: 600;
		color: #1e293b;
		margin-bottom: 2px;
	}

	.student-id {
		font-size: 12px;
		color: #64748b;
	}

	.students-list::-webkit-scrollbar {
		width: 8px;
	}

	.students-list::-webkit-scrollbar-track {
		background: rgba(255, 255, 255, 0.1);
		border-radius: 4px;
	}

	.students-list::-webkit-scrollbar-thumb {
		background: rgba(59, 130, 246, 0.3);
		border-radius: 4px;
	}

	.students-list::-webkit-scrollbar-thumb:hover {
		background: rgba(59, 130, 246, 0.5);
	}

	/* ===== SUBJECTS LIST ===== */
	.subjects-list {
		max-height: 400px;
		overflow-y: auto;
		margin-top: 16px;
	}

	.subject-item-card {
		position: relative;
		display: flex;
		align-items: center;
		gap: 12px;
		padding: 16px;
		background: rgba(255, 255, 255, 0.3);
		border: 1px solid rgba(255, 255, 255, 0.4);
		border-radius: 8px;
		margin-bottom: 12px;
		transition: all 0.3s ease-out;
	}

	.subject-item-card:hover {
		background: rgba(255, 255, 255, 0.5);
		border-color: rgba(59, 130, 246, 0.3);
	}

	.subject-item-clickable {
		flex: 1;
		display: flex;
		align-items: center;
		justify-content: space-between;
		gap: 12px;
		cursor: pointer;
	}

	.subject-item-clickable:hover .subject-info {
		transform: translateX(4px);
	}

	.btn-edit-subject {
		display: flex;
		align-items: center;
		justify-content: center;
		width: 36px;
		height: 36px;
		background: rgba(59, 130, 246, 0.1);
		border: 1px solid rgba(59, 130, 246, 0.3);
		border-radius: 8px;
		cursor: pointer;
		transition: all 0.3s ease-out;
		flex-shrink: 0;
		color: #3b82f6;
	}

	.btn-edit-subject:hover {
		background: rgba(59, 130, 246, 0.2);
		transform: scale(1.05);
	}

	.subject-item {
		display: flex;
		align-items: center;
		justify-content: space-between;
		gap: 12px;
		padding: 16px;
		background: rgba(255, 255, 255, 0.3);
		border: 1px solid rgba(255, 255, 255, 0.4);
		border-radius: 8px;
		margin-bottom: 12px;
		cursor: pointer;
		transition: all 0.3s ease-out;
	}

	.subject-item:hover {
		background: rgba(255, 255, 255, 0.5);
		border-color: rgba(59, 130, 246, 0.3);
		transform: translateX(4px);
	}

	.subject-info {
		flex: 1;
		transition: transform 0.3s ease-out;
	}

	.subject-name {
		font-size: 16px;
		font-weight: 600;
		color: #1e293b;
		margin-bottom: 4px;
	}

	.subject-code {
		font-size: 12px;
		color: #64748b;
		margin-bottom: 4px;
	}

	.subject-teacher {
		font-size: 13px;
		color: #3b82f6;
		margin-top: 4px;
	}

	.subject-schedule {
		font-size: 12px;
		color: #22c55e;
		margin-top: 4px;
	}

	.subject-days {
		font-size: 12px;
		color: #a855f7;
		margin-top: 4px;
		font-weight: 600;
	}

	.readonly-field {
		padding: 12px 16px;
		background: rgba(255, 255, 255, 0.3);
		border: 1px solid rgba(255, 255, 255, 0.3);
		border-radius: 8px;
		font-size: 14px;
		color: #1e293b;
		font-weight: 500;
	}

	/* ===== EMPTY STATE ===== */
	.empty-state {
		padding: 60px 20px;
		text-align: center;
		grid-column: 1 / -1;
	}

	.empty-state h3 {
		margin: 0 0 8px 0;
		font-size: 18px;
		font-weight: 600;
		color: #1e293b;
	}

	.empty-state p {
		margin: 0;
		font-size: 14px;
		color: #64748b;
	}

	/* ===== RESPONSIVE DESIGN ===== */
	@media (max-width: 768px) {
		.sections-page {
			padding: 20px 16px;
		}

		.page-header {
			flex-direction: column;
			text-align: center;
			padding: 20px 16px;
		}

		.header-content h1 {
			font-size: 24px;
		}

		.stats-grid {
			grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
			gap: 16px;
		}

		.modal-content {
			max-width: 90%;
		}

		.card-actions {
			flex-direction: column;
		}

		.btn {
			width: 100%;
		}
	}

	@media (max-width: 480px) {
		.loading-brand .brand-main {
			font-size: 22px;
		}

		.page-header {
			padding: 16px 12px;
		}

		.header-content h1 {
			font-size: 20px;
		}

		.stats-grid {
			grid-template-columns: 1fr;
		}

		.sections-grid {
			grid-template-columns: 1fr;
		}

		.modal-content {
			padding: 20px;
		}

		.split-container {
			grid-template-columns: 1fr;
			min-height: 400px;
		}

		.modal-extra-large {
			max-width: 95%;
		}

		.modal-header-content {
			flex-direction: column;
			align-items: flex-start;
			gap: 12px;
		}

		.enrollment-stats {
			width: 100%;
			justify-content: space-around;
		}

		.panel-body {
			padding: 12px;
		}

		.student-card {
			padding: 10px;
		}

		.student-avatar {
			width: 36px;
			height: 36px;
			font-size: 12px;
		}

		.footer-actions {
			flex-direction: column;
			width: 100%;
		}

		.footer-actions .btn {
			width: 100%;
		}
	}

	/* ===== ACCESSIBILITY ===== */
	@media (prefers-reduced-motion: reduce) {
		* {
			animation-duration: 0.01ms !important;
			animation-iteration-count: 1 !important;
			transition-duration: 0.01ms !important;
		}
	}

	.subject-schedule {
		font-size: 12px;
		color: #22c55e;
		margin-top: 4px;
	}

	.subject-days {
		font-size: 12px;
		color: #a855f7;
		margin-top: 4px;
		font-weight: 600;
	}

	.readonly-field {
		padding: 12px 16px;
		background: rgba(255, 255, 255, 0.3);
		border: 1px solid rgba(255, 255, 255, 0.3);
		border-radius: 8px;
		font-size: 14px;
		color: #1e293b;
		font-weight: 500;
	}

	/* ===== EMPTY STATE ===== */
	.empty-state {
		padding: 60px 20px;
		text-align: center;
		grid-column: 1 / -1;
	}

	.empty-state h3 {
		margin: 0 0 8px 0;
		font-size: 18px;
		font-weight: 600;
		color: #1e293b;
	}

	.empty-state p {
		margin: 0;
		font-size: 14px;
		color: #64748b;
	}

	/* ===== RESPONSIVE DESIGN ===== */
	@media (max-width: 768px) {
		.sections-page {
			padding: 20px 16px;
		}

		.page-header {
			flex-direction: column;
			text-align: center;
			padding: 20px 16px;
		}

		.header-content h1 {
			font-size: 24px;
		}

		.stats-grid {
			grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
			gap: 16px;
		}

		.modal-content {
			max-width: 90%;
		}

		.card-actions {
			flex-direction: column;
		}

		.btn {
			width: 100%;
		}
	}

	@media (max-width: 480px) {
		.loading-brand .brand-main {
			font-size: 22px;
		}

		.page-header {
			padding: 16px 12px;
		}

		.header-content h1 {
			font-size: 20px;
		}

		.stats-grid {
			grid-template-columns: 1fr;
		}

		.sections-grid {
			grid-template-columns: 1fr;
		}

		.modal-content {
			padding: 20px;
		}

		.split-container {
			grid-template-columns: 1fr;
			min-height: 400px;
		}

		.modal-extra-large {
			max-width: 95%;
		}

		.modal-header-content {
			flex-direction: column;
			align-items: flex-start;
			gap: 12px;
		}

		.enrollment-stats {
			width: 100%;
			justify-content: space-around;
		}

		.panel-body {
			padding: 12px;
		}

		.student-card {
			padding: 10px;
		}

		.student-avatar {
			width: 36px;
			height: 36px;
			font-size: 12px;
		}

		.footer-actions {
			flex-direction: column;
			width: 100%;
		}

		.footer-actions .btn {
			width: 100%;
		}
	}

	/* ===== ACCESSIBILITY ===== */
	@media (prefers-reduced-motion: reduce) {
		* {
			animation-duration: 0.01ms !important;
			animation-iteration-count: 1 !important;
			transition-duration: 0.01ms !important;
		}
	}

	@media (prefers-color-scheme: dark) {
		.loading-screen {
			background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
		}

		.page-header,
		.stat-card,
		.section-card,
		.section-card-item {
			background: rgba(30, 41, 59, 0.4);
			border-color: rgba(148, 163, 184, 0.2);
		}

		.header-content h1,
		.card-title,
		.modal-header h3,
		.stat-number,
		.card-title-section h3 {
			color: #f1f5f9;
		}

		.search-input,
		.form-group input,
		.form-group select {
			background: rgba(30, 41, 59, 0.5);
			border-color: rgba(148, 163, 184, 0.2);
			color: #f1f5f9;
		}

		.search-input::placeholder,
		.form-group input::placeholder {
			color: #94a3b8;
		}

		/* Per-Day Schedule Styles */
		.form-hint {
			margin: 8px 0 16px 0;
			font-size: 14px;
			color: #6b7280;
			font-style: italic;
		}

		.day-schedule-row {
			display: flex;
			align-items: center;
			gap: 16px;
			padding: 12px;
			margin-bottom: 12px;
			background: rgba(249, 250, 251, 0.5);
			border-radius: 8px;
			border: 1px solid #e5e7eb;
		}

		.day-label {
			display: flex;
			align-items: center;
			gap: 8px;
			min-width: 120px;
			font-weight: 500;
			color: #374151;
		}

		.day-icon {
			font-size: 18px;
		}

		.time-inputs {
			display: flex;
			align-items: center;
			gap: 12px;
			flex: 1;
			flex-wrap: wrap;
		}

		.time-input-group {
			display: flex;
			align-items: center;
			gap: 8px;
		}

		.time-input-group label {
			font-size: 14px;
			color: #6b7280;
			min-width: 40px;
		}

		.time-input-group input[type="time"] {
			padding: 6px 12px;
			border: 1px solid #d1d5db;
			border-radius: 6px;
			font-size: 14px;
			background: white;
			transition: all 0.2s;
		}

		.time-input-group input[type="time"]:focus {
			outline: none;
			border-color: #6366f1;
			box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
		}

		.teacher-input-group {
			display: flex;
			align-items: center;
			gap: 8px;
		}

		.teacher-input-group label {
			font-size: 14px;
			color: #6b7280;
			min-width: 60px;
		}

		.teacher-input-group select {
			padding: 6px 12px;
			border: 1px solid #d1d5db;
			border-radius: 6px;
			font-size: 14px;
			background: white;
			transition: all 0.2s;
			min-width: 160px;
		}

		.teacher-input-group select:focus {
			outline: none;
			border-color: #6366f1;
			box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
		}

		.time-separator {
			color: #9ca3af;
			font-size: 18px;
			font-weight: 500;
		}
	}
</style>
