<script>
	// Students management page
	import { onMount } from "svelte";
	import { browser } from "$app/environment";

	/** @type {import('./$types').PageData} */
	export let data;

	$: session = data.session;
	$: students = data.students || [];
	$: statusList = data.statusList || [];

	// Premium loading states
	let isLoading = true;
	let loadingProgress = 0;
	let loadingText = "Initializing";
	let loadingFadeOut = false;
	let pageVisible = false;
	let statsVisible = false;
	let cardsVisible = false;
	let scrollY = 0;

	onMount(() => {
		const loadingSteps = [
			{ progress: 25, text: "Loading students data", delay: 300 },
			{ progress: 50, text: "Processing records", delay: 600 },
			{ progress: 75, text: "Preparing interface", delay: 900 },
			{ progress: 100, text: "Almost ready", delay: 1200 },
		];

		const runLoadingStep = (index) => {
			if (index >= loadingSteps.length) {
				setTimeout(() => {
					loadingFadeOut = true;
					setTimeout(() => {
						isLoading = false;
						pageVisible = true;
						setTimeout(() => {
							statsVisible = true;
						}, 200);
						setTimeout(() => {
							cardsVisible = true;
						}, 400);
					}, 800);
				}, 300);
				return;
			}

			const step = loadingSteps[index];
			loadingProgress = step.progress;
			loadingText = step.text;

			setTimeout(() => runLoadingStep(index + 1), step.delay);
		};

		runLoadingStep(0);

		const handleScroll = () => {
			scrollY = window.scrollY;
		};

		window.addEventListener("scroll", handleScroll);

		return () => {
			window.removeEventListener("scroll", handleScroll);
		};
	});

	let showModal = false;
	let editingStudent = null;
	let loading = false;
	let searchTerm = "";

	// Form data
	let formData = {
		studentId: "",
		firstName: "",
		lastName: "",
		middleName: "",
		statusId: "",
		yearLevel: "",
	};

	const yearLevels = [
		"Grade 7",
		"Grade 8",
		"Grade 9",
		"Grade 10",
		"Grade 11",
		"Grade 12",
	];

	// Filter students based on search term
	$: filteredStudents = students.filter(
		(student) =>
			student.StudentID.toLowerCase().includes(
				searchTerm.toLowerCase(),
			) ||
			student.FirstName.toLowerCase().includes(
				searchTerm.toLowerCase(),
			) ||
			student.LastName.toLowerCase().includes(searchTerm.toLowerCase()) ||
			student.YearLevel.toLowerCase().includes(searchTerm.toLowerCase()),
	);

	function openModal(student = null) {
		editingStudent = student;
		if (student) {
			formData = {
				studentId: student.StudentID,
				firstName: student.FirstName,
				lastName: student.LastName,
				middleName: student.MiddleName || "",
				statusId: student.StatusID.toString(),
				yearLevel: student.YearLevel,
			};
		} else {
			formData = {
				studentId: "",
				firstName: "",
				lastName: "",
				middleName: "",
				statusId: "1",
				yearLevel: "",
			};
		}
		showModal = true;
	}

	function closeModal() {
		showModal = false;
		editingStudent = null;
	}

	async function handleSubmit() {
		if (!browser) return;

		loading = true;

		try {
			const method = editingStudent ? "PUT" : "POST";
			const response = await fetch("/api/students", {
				method,
				headers: {
					"Content-Type": "application/json",
				},
				body: JSON.stringify({
					...formData,
					statusId: parseInt(formData.statusId),
				}),
			});

			const result = await response.json();

			if (response.ok) {
				// Reload the page to refresh data
				window.location.reload();
			} else {
				alert(result.error || "An error occurred");
			}
		} catch (error) {
			console.error("Submit error:", error);
			alert("An error occurred while saving");
		} finally {
			loading = false;
		}
	}

	async function handleDelete(studentId) {
		if (!browser) return;

		if (!confirm("Are you sure you want to delete this student?")) {
			return;
		}

		try {
			const response = await fetch("/api/students", {
				method: "DELETE",
				headers: {
					"Content-Type": "application/json",
				},
				body: JSON.stringify({ studentId }),
			});

			const result = await response.json();

			if (response.ok) {
				window.location.reload();
			} else {
				alert(result.error || "Failed to delete student");
			}
		} catch (error) {
			console.error("Delete error:", error);
			alert("An error occurred while deleting");
		}
	}
</script>

<svelte:head>
	<title>Students - School Management System</title>
</svelte:head>

<!-- Premium Loading Screen -->
{#if isLoading}
	\t
	<div class="loading-screen" class:fade-out={loadingFadeOut}>
		\t\t
		<div class="particles-container">
			\t\t\t{#each Array(20) as _, i}
				\t\t\t\t
				<div class="particle particle-{(i % 4) + 1}"></div>
				\t\t\t{/each}
			\t\t
		</div>
		\t\t \t\t
		<div class="loading-content">
			\t\t\t
			<div class="loading-logo">
				\t\t\t\t
				<div class="logo-pulse"></div>
				\t\t\t\t<svg
					class="logo-svg"
					viewBox="0 0 24 24"
					fill="none"
					xmlns="http://www.w3.org/2000/svg"
				>
					\t\t\t\t\t<path
						d="M12 2L2 7L12 12L22 7L12 2Z"
						fill="url(#gradient1)"
						stroke="url(#gradient2)"
						stroke-width="2"
					/>
					\t\t\t\t\t<path
						d="M2 17L12 22L22 17"
						stroke="url(#gradient2)"
						stroke-width="2"
						stroke-linecap="round"
						stroke-linejoin="round"
					/>
					\t\t\t\t\t<path
						d="M2 12L12 17L22 12"
						stroke="url(#gradient2)"
						stroke-width="2"
						stroke-linecap="round"
						stroke-linejoin="round"
					/>
					\t\t\t\t\t<defs>
						\t\t\t\t\t\t<linearGradient
							id="gradient1"
							x1="2"
							y1="2"
							x2="22"
							y2="12"
							gradientUnits="userSpaceOnUse"
						>
							\t\t\t\t\t\t\t<stop stop-color="#3B82F6" />
							\t\t\t\t\t\t\t<stop
								offset="1"
								stop-color="#A855F7"
							/>
							\t\t\t\t\t\t</linearGradient
						>
						\t\t\t\t\t\t<linearGradient
							id="gradient2"
							x1="2"
							y1="7"
							x2="22"
							y2="17"
							gradientUnits="userSpaceOnUse"
						>
							\t\t\t\t\t\t\t<stop stop-color="#22C55E" />
							\t\t\t\t\t\t\t<stop
								offset="1"
								stop-color="#F97316"
							/>
							\t\t\t\t\t\t</linearGradient
						>
						\t\t\t\t\t</defs
					>
					\t\t\t\t</svg
				>
				\t\t\t
			</div>
			\t\t\t \t\t\t
			<div class="loading-brand">
				\t\t\t\t
				<h1 class="brand-main">Students Management</h1>
				\t\t\t\t
				<p class="brand-tagline">LOADING</p>
				\t\t\t
			</div>
			\t\t\t \t\t\t
			<div class="loading-progress">
				\t\t\t\t
				<p class="progress-text">{loadingText}...</p>
				\t\t\t\t
				<div class="progress-bar">
					\t\t\t\t\t
					<div
						class="progress-fill"
						style="width: {loadingProgress}%"
					>
						\t\t\t\t\t\t
						<div
							class="progress-glow"
							style="width: {loadingProgress}%"
						></div>
						\t\t\t\t\t
					</div>
					\t\t\t\t
				</div>
				\t\t\t\t
				<p class="progress-percentage">{loadingProgress}%</p>
				\t\t\t
			</div>
			\t\t\t \t\t\t
			<div class="loading-dots">
				\t\t\t\t<span class="dot dot-1"></span>
				\t\t\t\t<span class="dot dot-2"></span>
				\t\t\t\t<span class="dot dot-3"></span>
				\t\t\t
			</div>
			\t\t
		</div>
		\t\t \t\t
		<div class="loading-orbs">
			\t\t\t
			<div class="orb orb-1"></div>
			\t\t\t
			<div class="orb orb-2"></div>
			\t\t\t
			<div class="orb orb-3"></div>
			\t\t\t
			<div class="orb orb-4"></div>
			\t\t
		</div>
		\t
	</div>
{/if}

<!-- Animated Background -->
<div
	class="animated-background"
	style="transform: translateY({scrollY * 0.3}px)"
>
	\t
	<div class="dot-pattern"></div>
	\t
	<div class="floating-orb orb-bg-1"></div>
	\t
	<div class="floating-orb orb-bg-2"></div>
	\t
	<div class="floating-orb orb-bg-3"></div>
</div>

<div class="students-page" class:visible={pageVisible}>
	<!-- Premium Page Header with Glass Morphism -->
	<div class="page-header" class:visible={pageVisible}>
		<div class="header-icon-wrapper">
			<svg
				class="header-icon"
				viewBox="0 0 24 24"
				fill="none"
				xmlns="http://www.w3.org/2000/svg"
			>
				<path
					d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"
					stroke="currentColor"
					stroke-width="2"
					stroke-linecap="round"
					stroke-linejoin="round"
				/>
				<circle
					cx="9"
					cy="7"
					r="4"
					stroke="currentColor"
					stroke-width="2"
					stroke-linecap="round"
					stroke-linejoin="round"
				/>
				<path
					d="M23 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75"
					stroke="currentColor"
					stroke-width="2"
					stroke-linecap="round"
					stroke-linejoin="round"
				/>
			</svg>
		</div>
		<div class="header-content">
			<h1>Students Management</h1>
			<p class="subtitle">Manage student records and information</p>
		</div>
		{#if session.role === "Admin"}
			<button class="btn btn-primary" on:click={() => openModal()}>
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
				Add New Student
			</button>
		{/if}
	</div>

	{#if data.error}
		<div class="error-message error-slide-in">
			<svg
				class="error-icon"
				viewBox="0 0 24 24"
				fill="none"
				xmlns="http://www.w3.org/2000/svg"
			>
				<circle
					cx="12"
					cy="12"
					r="10"
					stroke="currentColor"
					stroke-width="2"
				/>
				<line
					x1="12"
					y1="8"
					x2="12"
					y2="12"
					stroke="currentColor"
					stroke-width="2"
					stroke-linecap="round"
				/>
				<line
					x1="12"
					y1="16"
					x2="12.01"
					y2="16"
					stroke="currentColor"
					stroke-width="2"
					stroke-linecap="round"
				/>
			</svg>
			{data.error}
		</div>
	{/if}

	<!-- Premium Stats Cards -->
	<div class="stats-grid" class:visible={statsVisible}>
		<div class="stat-card stat-card-1">
			<div class="stat-glow"></div>
			<div class="stat-icon-wrapper">
				<svg
					class="stat-icon"
					viewBox="0 0 24 24"
					fill="none"
					xmlns="http://www.w3.org/2000/svg"
				>
					<path
						d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"
						stroke="currentColor"
						stroke-width="2"
						stroke-linecap="round"
						stroke-linejoin="round"
					/>
					<circle
						cx="9"
						cy="7"
						r="4"
						stroke="currentColor"
						stroke-width="2"
					/>
					<path
						d="M23 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75"
						stroke="currentColor"
						stroke-width="2"
						stroke-linecap="round"
						stroke-linejoin="round"
					/>
				</svg>
			</div>
			<div class="stat-content">
				<span class="stat-number">{students.length}</span>
				<span class="stat-label">Total Students</span>
			</div>
		</div>
		<div class="stat-card stat-card-2">
			<div class="stat-glow"></div>
			<div class="stat-icon-wrapper">
				<svg
					class="stat-icon"
					viewBox="0 0 24 24"
					fill="none"
					xmlns="http://www.w3.org/2000/svg"
				>
					<path
						d="M22 11.08V12a10 10 0 1 1-5.93-9.14"
						stroke="currentColor"
						stroke-width="2"
						stroke-linecap="round"
						stroke-linejoin="round"
					/>
					<polyline
						points="22 4 12 14.01 9 11.01"
						stroke="currentColor"
						stroke-width="2"
						stroke-linecap="round"
						stroke-linejoin="round"
					/>
				</svg>
			</div>
			<div class="stat-content">
				<span class="stat-number"
					>{students.filter((s) => s.StatusName === "Active")
						.length}</span
				>
				<span class="stat-label">Active Students</span>
			</div>
		</div>
		<div class="stat-card stat-card-3">
			<div class="stat-glow"></div>
			<div class="stat-icon-wrapper">
				<svg
					class="stat-icon"
					viewBox="0 0 24 24"
					fill="none"
					xmlns="http://www.w3.org/2000/svg"
				>
					<path
						d="M22 10v6M2 10l10-5 10 5-10 5z"
						stroke="currentColor"
						stroke-width="2"
						stroke-linecap="round"
						stroke-linejoin="round"
					/>
					<path
						d="M6 12v5c3 3 9 3 12 0v-5"
						stroke="currentColor"
						stroke-width="2"
						stroke-linecap="round"
						stroke-linejoin="round"
					/>
				</svg>
			</div>
			<div class="stat-content">
				<span class="stat-number"
					>{new Set(students.map((s) => s.YearLevel)).size}</span
				>
				<span class="stat-label">Year Levels</span>
			</div>
		</div>
	</div>

	<!-- Search and Table Section -->
	<div class="content-section" class:visible={cardsVisible}>
		<div class="section-card">
			<div class="card-header">
				<h3 class="card-title">📋 Student Records</h3>
			</div>

			<div class="card-content">
				<!-- Search bar -->
				<div class="search-container">
					<input
						type="text"
						bind:value={searchTerm}
						placeholder="🔍 Search by ID, name, or year level..."
						class="search-input"
					/>
				</div>

				<!-- Students table -->
				<div class="table-container">
					<table class="data-table">
						<thead>
							<tr>
								<th>Student ID</th>
								<th>Full Name</th>
								<th>Year Level</th>
								<th>Status</th>
								{#if session.role === "Admin"}
									<th>Actions</th>
								{/if}
							</tr>
						</thead>
						<tbody>
							{#each filteredStudents as student}
								<tr>
									<td>
										<div class="student-id">
											<strong>{student.StudentID}</strong>
										</div>
									</td>
									<td>
										<div class="student-name">
											<strong
												>{student.FirstName}
												{student.LastName}</strong
											>
											{#if student.MiddleName}
												<small class="middle-name"
													>{student.MiddleName}</small
												>
											{/if}
										</div>
									</td>
									<td>
										<span class="year-badge"
											>{student.YearLevel}</span
										>
									</td>
									<td>
										<span
											class="status-badge {(
												student.StatusName || 'unknown'
											).toLowerCase()}"
										>
											{student.StatusName || "Unknown"}
										</span>
									</td>
									{#if session.role === "Admin"}
										<td>
											<div class="actions">
												<button
													class="btn btn-primary"
													on:click={() =>
														openModal(student)}
												>
													Edit
												</button>
												<button
													class="btn btn-danger"
													on:click={() =>
														handleDelete(
															student.StudentID,
														)}
												>
													Delete
												</button>
											</div>
										</td>
									{/if}
								</tr>
							{:else}
								<tr>
									<td
										colspan={session.role === "Admin"
											? "5"
											: "4"}
										class="text-center"
									>
										<div class="empty-state">
											<h3>No students found</h3>
											<p>
												{searchTerm
													? "Try adjusting your search terms"
													: "No student records available"}
											</p>
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

<!-- Modal for add/edit student -->
{#if showModal}
	<div
		class="modal-overlay"
		on:click={closeModal}
		on:keydown={(e) => e.key === "Escape" && closeModal()}
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
				<div class="modal-title-wrapper">
					<div class="modal-icon">
						<svg
							viewBox="0 0 24 24"
							fill="none"
							xmlns="http://www.w3.org/2000/svg"
						>
							{#if editingStudent}
								<path
									d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"
									stroke="currentColor"
									stroke-width="2"
									stroke-linecap="round"
									stroke-linejoin="round"
								/>
								<path
									d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"
									stroke="currentColor"
									stroke-width="2"
									stroke-linecap="round"
									stroke-linejoin="round"
								/>
							{:else}
								<line
									x1="12"
									y1="5"
									x2="12"
									y2="19"
									stroke="currentColor"
									stroke-width="2"
									stroke-linecap="round"
								/>
								<line
									x1="5"
									y1="12"
									x2="19"
									y2="12"
									stroke="currentColor"
									stroke-width="2"
									stroke-linecap="round"
								/>
							{/if}
						</svg>
					</div>
					<h3 class="modal-title">
						{editingStudent ? "Edit Student" : "Add New Student"}
					</h3>
				</div>
				<button class="close-btn" on:click={closeModal}>
					<svg
						viewBox="0 0 24 24"
						fill="none"
						xmlns="http://www.w3.org/2000/svg"
					>
						<line
							x1="18"
							y1="6"
							x2="6"
							y2="18"
							stroke="currentColor"
							stroke-width="2"
							stroke-linecap="round"
						/>
						<line
							x1="6"
							y1="6"
							x2="18"
							y2="18"
							stroke="currentColor"
							stroke-width="2"
							stroke-linecap="round"
						/>
					</svg>
				</button>
			</div>

			<form on:submit|preventDefault={handleSubmit}>
				<div class="form-group">
					<label for="studentId" class="form-label">Student ID:</label
					>
					<input
						type="text"
						id="studentId"
						bind:value={formData.studentId}
						required
						disabled={!!editingStudent || loading}
						placeholder="e.g., 2024001"
						class="form-input"
					/>
				</div>

				<div class="form-group">
					<label for="firstName" class="form-label">First Name:</label
					>
					<input
						type="text"
						id="firstName"
						bind:value={formData.firstName}
						required
						disabled={loading}
						class="form-input"
					/>
				</div>

				<div class="form-group">
					<label for="lastName" class="form-label">Last Name:</label>
					<input
						type="text"
						id="lastName"
						bind:value={formData.lastName}
						required
						disabled={loading}
						class="form-input"
					/>
				</div>

				<div class="form-group">
					<label for="middleName" class="form-label"
						>Middle Name:</label
					>
					<input
						type="text"
						id="middleName"
						bind:value={formData.middleName}
						disabled={loading}
						class="form-input"
					/>
				</div>

				<div class="form-group">
					<label for="yearLevel" class="form-label">Year Level:</label
					>
					<select
						id="yearLevel"
						bind:value={formData.yearLevel}
						required
						disabled={loading}
						class="form-select"
					>
						<option value="">Select Year Level</option>
						{#each yearLevels as level}
							<option value={level}>{level}</option>
						{/each}
					</select>
				</div>

				<div class="form-group">
					<label for="statusId" class="form-label">Status:</label>
					<select
						id="statusId"
						bind:value={formData.statusId}
						required
						disabled={loading}
						class="form-select"
					>
						{#each statusList as status}
							<option value={status.StatusID.toString()}>
								{status.StatusName}
							</option>
						{/each}
					</select>
				</div>

				<div class="modal-actions">
					<button
						type="button"
						class="btn btn-secondary"
						on:click={closeModal}
						disabled={loading}
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
						{/if}
						{editingStudent ? "Update Student" : "Create Student"}
					</button>
				</div>
			</form>
		</div>
	</div>
{/if}

<style>
	/* ========================================
	   PREMIUM LOADING SCREEN STYLES
	   ======================================== */

	.loading-screen {
		position: fixed;
		inset: 0;
		z-index: 9999;
		background: linear-gradient(135deg, #0f172a, #1e293b, #334155);
		display: flex;
		align-items: center;
		justify-content: center;
		overflow: hidden;
		animation: loadingFadeIn 0.5s ease-out;
	}

	.loading-screen.fade-out {
		animation: loadingFadeOut 0.8s ease-in-out forwards;
	}

	.particles-container {
		position: absolute;
		inset: 0;
		pointer-events: none;
	}

	.particle {
		position: absolute;
		border-radius: 50%;
		opacity: 0.6;
		animation: particleFloat 8s ease-in-out infinite;
	}

	.particle-1 {
		width: 4px;
		height: 4px;
		background: #3b82f6;
	}
	.particle-2 {
		width: 6px;
		height: 6px;
		background: #a855f7;
	}
	.particle-3 {
		width: 3px;
		height: 3px;
		background: #22c55e;
	}
	.particle-4 {
		width: 5px;
		height: 5px;
		background: #f97316;
	}

	.particle:nth-child(1) {
		top: 10%;
		left: 10%;
	}
	.particle:nth-child(2) {
		top: 20%;
		left: 80%;
		animation-delay: 0.5s;
	}
	.particle:nth-child(3) {
		top: 30%;
		left: 20%;
		animation-delay: 1s;
	}
	.particle:nth-child(4) {
		top: 40%;
		left: 70%;
		animation-delay: 1.5s;
	}
	.particle:nth-child(5) {
		top: 50%;
		left: 30%;
		animation-delay: 2s;
	}
	.particle:nth-child(6) {
		top: 60%;
		left: 90%;
		animation-delay: 0.3s;
	}
	.particle:nth-child(7) {
		top: 70%;
		left: 40%;
		animation-delay: 0.8s;
	}
	.particle:nth-child(8) {
		top: 80%;
		left: 60%;
		animation-delay: 1.3s;
	}
	.particle:nth-child(9) {
		top: 15%;
		left: 50%;
		animation-delay: 1.8s;
	}
	.particle:nth-child(10) {
		top: 85%;
		left: 15%;
		animation-delay: 0.6s;
	}
	.particle:nth-child(11) {
		top: 25%;
		left: 85%;
		animation-delay: 1.1s;
	}
	.particle:nth-child(12) {
		top: 75%;
		left: 25%;
		animation-delay: 1.6s;
	}
	.particle:nth-child(13) {
		top: 35%;
		left: 45%;
		animation-delay: 2.1s;
	}
	.particle:nth-child(14) {
		top: 65%;
		left: 75%;
		animation-delay: 0.4s;
	}
	.particle:nth-child(15) {
		top: 45%;
		left: 5%;
		animation-delay: 0.9s;
	}
	.particle:nth-child(16) {
		top: 55%;
		left: 95%;
		animation-delay: 1.4s;
	}
	.particle:nth-child(17) {
		top: 5%;
		left: 35%;
		animation-delay: 1.9s;
	}
	.particle:nth-child(18) {
		top: 95%;
		left: 65%;
		animation-delay: 0.7s;
	}
	.particle:nth-child(19) {
		top: 55%;
		left: 55%;
		animation-delay: 1.2s;
	}
	.particle:nth-child(20) {
		top: 75%;
		left: 85%;
		animation-delay: 1.7s;
	}

	.loading-content {
		text-align: center;
		z-index: 10;
		position: relative;
	}

	.loading-logo {
		position: relative;
		display: inline-block;
		margin-bottom: 2rem;
	}

	.logo-svg {
		width: 6rem;
		height: 6rem;
		filter: drop-shadow(0 0 20px rgba(59, 130, 246, 0.5));
		animation: logoRotate 4s ease-in-out infinite;
	}

	.logo-pulse {
		position: absolute;
		inset: -1rem;
		border-radius: 50%;
		background: radial-gradient(
			circle,
			rgba(59, 130, 246, 0.3) 0%,
			transparent 70%
		);
		animation: logoPulse 2s ease-in-out infinite;
	}

	.loading-brand {
		margin-bottom: 3rem;
	}

	.brand-main {
		font-size: 3rem;
		font-weight: 800;
		background: linear-gradient(135deg, #3b82f6, #a855f7, #22c55e, #f97316);
		-webkit-background-clip: text;
		-webkit-text-fill-color: transparent;
		background-clip: text;
		margin-bottom: 0.5rem;
		animation: textGlow 3s ease-in-out infinite alternate;
	}

	.brand-tagline {
		font-size: 1.5rem;
		font-weight: 600;
		color: #94a3b8;
		letter-spacing: 0.1em;
	}

	.loading-progress {
		margin-bottom: 2rem;
	}

	.progress-bar {
		width: 300px;
		height: 6px;
		background: rgba(255, 255, 255, 0.1);
		border-radius: 3px;
		margin: 0 auto 1rem;
		overflow: hidden;
		position: relative;
	}

	.progress-fill {
		height: 100%;
		background: linear-gradient(90deg, #3b82f6, #a855f7, #22c55e);
		border-radius: 3px;
		transition: width 0.8s cubic-bezier(0.4, 0, 0.2, 1);
		position: relative;
	}

	.progress-fill::after {
		content: "";
		position: absolute;
		top: 0;
		left: 0;
		bottom: 0;
		right: 0;
		background: linear-gradient(
			90deg,
			transparent,
			rgba(255, 255, 255, 0.4),
			transparent
		);
		animation: progressShine 2s ease-in-out infinite;
	}

	.progress-glow {
		position: absolute;
		top: 0;
		left: 0;
		height: 100%;
		background: linear-gradient(
			90deg,
			transparent,
			rgba(255, 255, 255, 0.6),
			transparent
		);
		border-radius: 3px;
		animation: progressGlow 1.5s ease-in-out infinite;
	}

	.progress-text {
		color: #cbd5e1;
		font-size: 1rem;
		font-weight: 500;
		margin-bottom: 0.5rem;
		animation: textFade 0.5s ease-in-out;
	}

	.progress-percentage {
		color: #3b82f6;
		font-size: 1.2rem;
		font-weight: 700;
		font-variant-numeric: tabular-nums;
	}

	.loading-dots {
		display: flex;
		justify-content: center;
		gap: 0.5rem;
		margin-top: 1rem;
	}

	.loading-dots .dot {
		width: 8px;
		height: 8px;
		border-radius: 50%;
		background: #3b82f6;
		animation: dotBounce 1.4s ease-in-out infinite both;
	}

	.dot-1 {
		animation-delay: -0.32s;
	}
	.dot-2 {
		animation-delay: -0.16s;
	}
	.dot-3 {
		animation-delay: 0s;
	}

	.loading-orbs {
		position: absolute;
		inset: 0;
		pointer-events: none;
	}

	.orb {
		position: absolute;
		border-radius: 50%;
		filter: blur(60px);
		opacity: 0.3;
		animation: orbFloat 6s ease-in-out infinite;
	}

	.orb-1 {
		width: 200px;
		height: 200px;
		background: #3b82f6;
		top: 10%;
		left: 10%;
		animation-delay: 0s;
	}

	.orb-2 {
		width: 300px;
		height: 300px;
		background: #a855f7;
		top: 60%;
		right: 10%;
		animation-delay: 2s;
	}

	.orb-3 {
		width: 150px;
		height: 150px;
		background: #22c55e;
		bottom: 20%;
		left: 20%;
		animation-delay: 4s;
	}

	.orb-4 {
		width: 250px;
		height: 250px;
		background: #f97316;
		top: 30%;
		right: 30%;
		animation-delay: 1s;
	}

	/* ========================================
	   ANIMATED BACKGROUND
	   ======================================== */

	.animated-background {
		position: fixed;
		inset: 0;
		z-index: -10;
		overflow: hidden;
		background: #ffffff;
		transition: transform 0.1s ease-out;
	}

	.dot-pattern {
		position: absolute;
		inset: 0;
		background-image: radial-gradient(circle, #d0d0d0 1px, transparent 1px);
		background-size: 30px 30px;
		background-position: 0 0;
		opacity: 0.6;
	}

	.floating-orb {
		position: absolute;
		border-radius: 50%;
		filter: blur(80px);
		opacity: 0.15;
	}

	.orb-bg-1 {
		top: 10%;
		left: 10%;
		width: 400px;
		height: 400px;
		background: linear-gradient(135deg, #3b82f6, #a855f7);
		animation: float 8s ease-in-out infinite;
	}

	.orb-bg-2 {
		top: 50%;
		right: 10%;
		width: 500px;
		height: 500px;
		background: linear-gradient(135deg, #22c55e, #3b82f6);
		animation: float 10s ease-in-out infinite reverse;
	}

	.orb-bg-3 {
		bottom: 10%;
		left: 30%;
		width: 350px;
		height: 350px;
		background: linear-gradient(135deg, #f97316, #a855f7);
		animation: float 12s ease-in-out infinite;
	}

	/* ========================================
	   MAIN PAGE CONTAINER
	   ======================================== */

	.students-page {
		max-width: 1400px;
		margin: 0 auto;
		padding: 2rem;
		opacity: 0;
		transform: translateY(20px);
		transition: all 0.6s cubic-bezier(0.4, 0, 0.2, 1);
	}

	.students-page.visible {
		opacity: 1;
		transform: translateY(0);
	}

	/* ========================================
	   PREMIUM PAGE HEADER WITH GLASS MORPHISM
	   ======================================== */

	.page-header {
		background: rgba(255, 255, 255, 0.4);
		backdrop-filter: blur(20px);
		-webkit-backdrop-filter: blur(20px);
		border: 1px solid rgba(255, 255, 255, 0.5);
		border-radius: 24px;
		padding: 2.5rem;
		margin-bottom: 2rem;
		box-shadow: 0 20px 60px rgba(0, 0, 0, 0.08);
		display: flex;
		align-items: center;
		gap: 2rem;
		position: relative;
		overflow: hidden;
		opacity: 0;
		transform: translateY(30px) scale(0.95);
		transition: all 0.6s cubic-bezier(0.4, 0, 0.2, 1);
	}

	.page-header.visible {
		opacity: 1;
		transform: translateY(0) scale(1);
	}

	.page-header::before {
		content: "";
		position: absolute;
		inset: 0;
		border-radius: 24px;
		padding: 2px;
		background: linear-gradient(135deg, #3b82f6, #a855f7, #22c55e);
		-webkit-mask:
			linear-gradient(#fff 0 0) content-box,
			linear-gradient(#fff 0 0);
		-webkit-mask-composite: xor;
		mask:
			linear-gradient(#fff 0 0) content-box,
			linear-gradient(#fff 0 0);
		mask-composite: exclude;
		opacity: 0.3;
	}

	.header-icon-wrapper {
		width: 80px;
		height: 80px;
		background: linear-gradient(135deg, #3b82f6, #a855f7);
		border-radius: 20px;
		display: flex;
		align-items: center;
		justify-content: center;
		flex-shrink: 0;
		box-shadow: 0 8px 20px rgba(59, 130, 246, 0.3);
		animation: pulse-slow 3s ease-in-out infinite;
	}

	.header-icon {
		width: 44px;
		height: 44px;
		color: white;
	}

	.header-content {
		flex: 1;
	}

	.page-header h1 {
		margin: 0 0 0.5rem 0;
		font-size: 3rem;
		font-weight: 700;
		background: linear-gradient(135deg, #3b82f6, #a855f7);
		-webkit-background-clip: text;
		-webkit-text-fill-color: transparent;
		background-clip: text;
	}

	.subtitle {
		margin: 0;
		color: #64748b;
		font-size: 1.25rem;
		font-weight: 500;
	}

	/* ========================================
	   ERROR MESSAGE
	   ======================================== */

	.error-message {
		display: flex;
		align-items: center;
		gap: 0.75rem;
		padding: 1.25rem 1.5rem;
		background: linear-gradient(
			135deg,
			rgba(239, 68, 68, 0.1),
			rgba(220, 38, 38, 0.1)
		);
		border: 1px solid rgba(239, 68, 68, 0.3);
		border-radius: 16px;
		color: #dc2626;
		font-size: 0.95rem;
		font-weight: 500;
		margin-bottom: 1.5rem;
	}

	.error-slide-in {
		animation:
			slideInFromTop 0.5s ease-out,
			shake 0.4s ease 0.5s;
	}

	.error-icon {
		width: 1.5rem;
		height: 1.5rem;
		flex-shrink: 0;
	}

	/* ========================================
	   PREMIUM STATS CARDS
	   ======================================== */

	.stats-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
		gap: 1.5rem;
		margin-bottom: 2rem;
		opacity: 0;
		transform: translateY(30px);
		transition: all 0.6s cubic-bezier(0.4, 0, 0.2, 1) 0.2s;
	}

	.stats-grid.visible {
		opacity: 1;
		transform: translateY(0);
	}

	.stat-card {
		background: rgba(255, 255, 255, 0.5);
		backdrop-filter: blur(20px);
		-webkit-backdrop-filter: blur(20px);
		border: 1px solid rgba(255, 255, 255, 0.6);
		border-radius: 20px;
		padding: 2rem;
		display: flex;
		align-items: center;
		gap: 1.5rem;
		transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
		position: relative;
		overflow: hidden;
		box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
		opacity: 0;
		transform: translateY(20px) scale(0.95);
	}

	.stat-card-1 {
		animation: cascadeIn 0.5s ease-out 0.1s forwards;
	}
	.stat-card-2 {
		animation: cascadeIn 0.5s ease-out 0.2s forwards;
	}
	.stat-card-3 {
		animation: cascadeIn 0.5s ease-out 0.3s forwards;
	}

	.stat-card:hover {
		transform: translateY(-8px) scale(1.02);
		box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
		border-color: rgba(59, 130, 246, 0.4);
	}

	.stat-card::before {
		content: "";
		position: absolute;
		inset: 0;
		border-radius: 20px;
		padding: 2px;
		background: linear-gradient(135deg, #3b82f6, #a855f7);
		-webkit-mask:
			linear-gradient(#fff 0 0) content-box,
			linear-gradient(#fff 0 0);
		-webkit-mask-composite: xor;
		mask:
			linear-gradient(#fff 0 0) content-box,
			linear-gradient(#fff 0 0);
		mask-composite: exclude;
		opacity: 0;
		transition: opacity 0.3s ease;
	}

	.stat-card:hover::before {
		opacity: 0.5;
	}

	.stat-glow {
		position: absolute;
		inset: -50%;
		background: radial-gradient(
			circle,
			rgba(59, 130, 246, 0.1) 0%,
			transparent 70%
		);
		opacity: 0;
		transition: opacity 0.3s ease;
		pointer-events: none;
	}

	.stat-card:hover .stat-glow {
		opacity: 1;
		animation: glowPulse 2s ease-in-out infinite;
	}

	.stat-icon-wrapper {
		width: 64px;
		height: 64px;
		background: linear-gradient(135deg, #3b82f6, #a855f7);
		border-radius: 16px;
		display: flex;
		align-items: center;
		justify-content: center;
		flex-shrink: 0;
		box-shadow: 0 8px 20px rgba(59, 130, 246, 0.3);
		transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
	}

	.stat-card:hover .stat-icon-wrapper {
		transform: scale(1.1) rotate(5deg);
	}

	.stat-icon {
		width: 32px;
		height: 32px;
		color: white;
	}

	.stat-content {
		flex: 1;
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
	}

	.stat-number {
		font-size: 2.5rem;
		font-weight: 800;
		background: linear-gradient(135deg, #2c3e50, #3b82f6);
		-webkit-background-clip: text;
		-webkit-text-fill-color: transparent;
		background-clip: text;
		line-height: 1;
	}

	.stat-label {
		color: #64748b;
		font-size: 1rem;
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.05em;
	}

	/* ========================================
	   CONTENT SECTION & CARDS
	   ======================================== */

	.content-section {
		opacity: 0;
		transform: translateY(30px);
		transition: all 0.6s cubic-bezier(0.4, 0, 0.2, 1) 0.4s;
	}

	.content-section.visible {
		opacity: 1;
		transform: translateY(0);
	}

	.section-card {
		background: rgba(255, 255, 255, 0.5);
		backdrop-filter: blur(20px);
		-webkit-backdrop-filter: blur(20px);
		border: 1px solid rgba(255, 255, 255, 0.6);
		border-radius: 24px;
		box-shadow: 0 20px 60px rgba(0, 0, 0, 0.08);
		overflow: hidden;
		transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
		position: relative;
	}

	.section-card::before {
		content: "";
		position: absolute;
		top: 0;
		left: 0;
		right: 0;
		height: 4px;
		background: linear-gradient(90deg, #3b82f6, #a855f7, #22c55e, #f97316);
	}

	.section-card:hover {
		transform: translateY(-4px);
		box-shadow: 0 25px 70px rgba(0, 0, 0, 0.12);
	}

	.card-header {
		background: linear-gradient(
			135deg,
			rgba(59, 130, 246, 0.1),
			rgba(168, 85, 247, 0.1)
		);
		backdrop-filter: blur(10px);
		padding: 2rem 2.5rem;
		border-bottom: 1px solid rgba(255, 255, 255, 0.3);
	}

	.card-title {
		margin: 0;
		font-size: 1.5rem;
		font-weight: 700;
		background: linear-gradient(135deg, #3b82f6, #a855f7);
		-webkit-background-clip: text;
		-webkit-text-fill-color: transparent;
		background-clip: text;
	}

	.card-content {
		padding: 2rem 2.5rem;
	}

	/* ========================================
	   SEARCH CONTAINER
	   ======================================== */

	.search-container {
		margin-bottom: 2rem;
	}

	.search-input {
		width: 100%;
		padding: 1rem 1.5rem;
		border: 2px solid rgba(148, 163, 184, 0.2);
		border-radius: 16px;
		font-size: 1rem;
		background: rgba(255, 255, 255, 0.5);
		backdrop-filter: blur(10px);
		transition: all 0.3s ease;
	}

	.search-input:focus {
		outline: none;
		border-color: #3b82f6;
		box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.1);
	}

	.search-input::placeholder {
		color: #94a3b8;
	}

	/* ========================================
	   TABLE STYLES
	   ======================================== */

	.table-container {
		overflow-x: auto;
		border-radius: 16px;
	}

	.data-table {
		width: 100%;
		border-collapse: collapse;
		background: rgba(255, 255, 255, 0.4);
		backdrop-filter: blur(10px);
		border-radius: 16px;
		overflow: hidden;
	}

	.data-table thead tr {
		background: linear-gradient(
			135deg,
			rgba(59, 130, 246, 0.1),
			rgba(168, 85, 247, 0.1)
		);
		backdrop-filter: blur(10px);
	}

	.data-table th {
		padding: 1.25rem 1rem;
		text-align: left;
		font-weight: 600;
		font-size: 0.875rem;
		text-transform: uppercase;
		letter-spacing: 0.05em;
		color: #475569;
		border-bottom: 2px solid rgba(148, 163, 184, 0.2);
	}

	.data-table td {
		padding: 1.25rem 1rem;
		color: #334155;
		font-size: 0.95rem;
		border-bottom: 1px solid rgba(148, 163, 184, 0.1);
	}

	.data-table tbody tr {
		transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
	}

	.data-table tbody tr:hover {
		background: rgba(59, 130, 246, 0.05);
		transform: translateX(4px);
	}

	.student-id strong {
		font-family: "Courier New", monospace;
		color: #3b82f6;
		font-weight: 600;
	}

	.student-name strong {
		color: #1e293b;
		font-weight: 600;
	}

	.middle-name {
		color: #94a3b8;
		font-size: 0.875rem;
		font-style: italic;
		margin-left: 0.5rem;
	}

	.year-badge {
		display: inline-block;
		padding: 0.5rem 1rem;
		background: linear-gradient(
			135deg,
			rgba(59, 130, 246, 0.1),
			rgba(168, 85, 247, 0.1)
		);
		border: 1px solid rgba(59, 130, 246, 0.2);
		border-radius: 12px;
		font-size: 0.875rem;
		font-weight: 600;
		color: #3b82f6;
	}

	.status-badge {
		display: inline-block;
		padding: 0.5rem 1rem;
		border-radius: 12px;
		font-size: 0.875rem;
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.05em;
	}

	.status-badge.active {
		background: linear-gradient(
			135deg,
			rgba(34, 197, 94, 0.1),
			rgba(34, 197, 94, 0.2)
		);
		border: 1px solid rgba(34, 197, 94, 0.3);
		color: #16a34a;
	}

	.status-badge.inactive {
		background: linear-gradient(
			135deg,
			rgba(239, 68, 68, 0.1),
			rgba(220, 38, 38, 0.2)
		);
		border: 1px solid rgba(239, 68, 68, 0.3);
		color: #dc2626;
	}

	.text-center {
		text-align: center;
		padding: 3rem;
	}

	.empty-state h3 {
		color: #64748b;
		font-size: 1.25rem;
		margin-bottom: 0.5rem;
	}

	.empty-state p {
		color: #94a3b8;
		font-size: 1rem;
	}

	.actions {
		display: flex;
		gap: 0.5rem;
		flex-wrap: wrap;
	}

	/* ========================================
	   BUTTON STYLES
	   ======================================== */

	.btn {
		padding: 0.75rem 1.5rem;
		border: none;
		border-radius: 12px;
		cursor: pointer;
		font-size: 0.95rem;
		font-weight: 600;
		transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
		text-decoration: none;
		display: inline-flex;
		align-items: center;
		gap: 0.5rem;
		position: relative;
		overflow: hidden;
	}

	.btn::before {
		content: "";
		position: absolute;
		inset: 0;
		background: linear-gradient(
			135deg,
			rgba(255, 255, 255, 0.2),
			rgba(255, 255, 255, 0)
		);
		opacity: 0;
		transition: opacity 0.3s ease;
	}

	.btn:hover::before {
		opacity: 1;
	}

	.btn-primary {
		background: linear-gradient(135deg, #3b82f6, #2563eb);
		color: white;
		box-shadow: 0 4px 15px rgba(59, 130, 246, 0.3);
	}

	.btn-primary:hover:not(:disabled) {
		transform: translateY(-2px) scale(1.02);
		box-shadow: 0 8px 25px rgba(59, 130, 246, 0.4);
	}

	.btn-secondary {
		background: linear-gradient(135deg, #64748b, #475569);
		color: white;
		box-shadow: 0 4px 15px rgba(100, 116, 139, 0.3);
	}

	.btn-secondary:hover:not(:disabled) {
		transform: translateY(-2px) scale(1.02);
		box-shadow: 0 8px 25px rgba(100, 116, 139, 0.4);
	}

	.btn-danger {
		background: linear-gradient(135deg, #ef4444, #dc2626);
		color: white;
		box-shadow: 0 4px 15px rgba(239, 68, 68, 0.3);
	}

	.btn-danger:hover:not(:disabled) {
		transform: translateY(-2px) scale(1.02);
		box-shadow: 0 8px 25px rgba(239, 68, 68, 0.4);
	}

	.btn:disabled {
		opacity: 0.6;
		cursor: not-allowed;
	}

	/* ========================================
	   MODAL STYLES
	   ======================================== */

	.modal-overlay {
		position: fixed;
		inset: 0;
		background: rgba(15, 23, 42, 0.7);
		backdrop-filter: blur(8px);
		display: flex;
		align-items: center;
		justify-content: center;
		z-index: 1000;
		animation: fadeIn 0.3s ease;
	}

	.modal-content {
		background: rgba(255, 255, 255, 0.95);
		backdrop-filter: blur(20px);
		-webkit-backdrop-filter: blur(20px);
		border: 1px solid rgba(255, 255, 255, 0.5);
		border-radius: 24px;
		padding: 0;
		max-width: 600px;
		width: 90%;
		max-height: 90vh;
		overflow: hidden;
		box-shadow: 0 25px 70px rgba(0, 0, 0, 0.3);
		animation: modalSlideUp 0.4s cubic-bezier(0.4, 0, 0.2, 1);
		position: relative;
	}

	.modal-content::before {
		content: "";
		position: absolute;
		top: 0;
		left: 0;
		right: 0;
		height: 4px;
		background: linear-gradient(90deg, #3b82f6, #a855f7, #22c55e, #f97316);
	}

	.modal-header {
		background: linear-gradient(
			135deg,
			rgba(59, 130, 246, 0.1),
			rgba(168, 85, 247, 0.1)
		);
		backdrop-filter: blur(10px);
		padding: 2rem 2.5rem;
		border-bottom: 1px solid rgba(255, 255, 255, 0.3);
		display: flex;
		justify-content: space-between;
		align-items: center;
	}

	.modal-title-wrapper {
		display: flex;
		align-items: center;
		gap: 1rem;
	}

	.modal-icon {
		width: 48px;
		height: 48px;
		background: linear-gradient(135deg, #3b82f6, #a855f7);
		border-radius: 12px;
		display: flex;
		align-items: center;
		justify-content: center;
		box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
	}

	.modal-icon svg {
		width: 24px;
		height: 24px;
		color: white;
	}

	.modal-title {
		margin: 0;
		font-size: 1.5rem;
		font-weight: 700;
		background: linear-gradient(135deg, #3b82f6, #a855f7);
		-webkit-background-clip: text;
		-webkit-text-fill-color: transparent;
		background-clip: text;
	}

	.close-btn {
		width: 36px;
		height: 36px;
		background: rgba(148, 163, 184, 0.1);
		border: 1px solid rgba(148, 163, 184, 0.2);
		border-radius: 8px;
		cursor: pointer;
		display: flex;
		align-items: center;
		justify-content: center;
		transition: all 0.2s ease;
	}

	.close-btn:hover {
		background: rgba(239, 68, 68, 0.1);
		border-color: rgba(239, 68, 68, 0.3);
		transform: scale(1.1);
	}

	.close-btn svg {
		width: 18px;
		height: 18px;
		color: #64748b;
	}

	.close-btn:hover svg {
		color: #ef4444;
	}

	.modal-content form {
		padding: 2rem 2.5rem;
		max-height: calc(90vh - 180px);
		overflow-y: auto;
	}

	.form-group {
		margin-bottom: 1.5rem;
	}

	.form-label {
		display: block;
		margin-bottom: 0.5rem;
		font-weight: 600;
		color: #334155;
		font-size: 0.95rem;
	}

	.form-input,
	.form-select {
		width: 100%;
		padding: 0.875rem 1.25rem;
		border: 2px solid rgba(148, 163, 184, 0.2);
		border-radius: 12px;
		font-size: 1rem;
		background: rgba(255, 255, 255, 0.5);
		backdrop-filter: blur(10px);
		transition: all 0.3s ease;
		color: #1e293b;
	}

	.form-input:focus,
	.form-select:focus {
		outline: none;
		border-color: #3b82f6;
		box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.1);
	}

	.form-input:disabled,
	.form-select:disabled {
		background: rgba(148, 163, 184, 0.1);
		color: #94a3b8;
		cursor: not-allowed;
	}

	.modal-actions {
		display: flex;
		justify-content: flex-end;
		gap: 1rem;
		padding: 1.5rem 2.5rem;
		border-top: 1px solid rgba(148, 163, 184, 0.2);
		background: rgba(248, 250, 252, 0.5);
	}

	.spinner {
		display: inline-block;
		width: 16px;
		height: 16px;
		border: 2px solid rgba(255, 255, 255, 0.3);
		border-top: 2px solid white;
		border-radius: 50%;
		animation: spin 0.8s linear infinite;
	}

	/* ========================================
	   ANIMATIONS & KEYFRAMES
	   ======================================== */

	@keyframes loadingFadeIn {
		0% {
			opacity: 0;
		}
		100% {
			opacity: 1;
		}
	}

	@keyframes loadingFadeOut {
		0% {
			opacity: 1;
			transform: scale(1);
		}
		100% {
			opacity: 0;
			transform: scale(1.05);
		}
	}

	@keyframes particleFloat {
		0%,
		100% {
			transform: translate(0, 0);
			opacity: 0.6;
		}
		25% {
			transform: translate(10px, -10px);
			opacity: 0.8;
		}
		50% {
			transform: translate(-10px, -20px);
			opacity: 0.4;
		}
		75% {
			transform: translate(-20px, 10px);
			opacity: 0.7;
		}
	}

	@keyframes logoRotate {
		0%,
		100% {
			transform: rotate(0deg) scale(1);
		}
		25% {
			transform: rotate(5deg) scale(1.05);
		}
		50% {
			transform: rotate(-5deg) scale(0.95);
		}
		75% {
			transform: rotate(3deg) scale(1.02);
		}
	}

	@keyframes logoPulse {
		0%,
		100% {
			transform: scale(1);
			opacity: 0.5;
		}
		50% {
			transform: scale(1.2);
			opacity: 0.8;
		}
	}

	@keyframes textGlow {
		0% {
			filter: drop-shadow(0 0 10px rgba(59, 130, 246, 0.5));
		}
		100% {
			filter: drop-shadow(0 0 20px rgba(59, 130, 246, 0.8));
		}
	}

	@keyframes progressShine {
		0% {
			transform: translateX(-100%);
		}
		100% {
			transform: translateX(100%);
		}
	}

	@keyframes progressGlow {
		0%,
		100% {
			opacity: 0;
			transform: translateX(-50%);
		}
		50% {
			opacity: 1;
			transform: translateX(50%);
		}
	}

	@keyframes textFade {
		0% {
			opacity: 0;
			transform: translateY(10px);
		}
		100% {
			opacity: 1;
			transform: translateY(0);
		}
	}

	@keyframes dotBounce {
		0%,
		80%,
		100% {
			transform: scale(0.8);
			opacity: 0.6;
		}
		40% {
			transform: scale(1.2);
			opacity: 1;
		}
	}

	@keyframes orbFloat {
		0%,
		100% {
			transform: translate(0, 0) scale(1);
		}
		33% {
			transform: translate(30px, -30px) scale(1.1);
		}
		66% {
			transform: translate(-20px, 20px) scale(0.9);
		}
	}

	@keyframes float {
		0%,
		100% {
			transform: translateY(0) rotate(0deg);
		}
		50% {
			transform: translateY(-30px) rotate(5deg);
		}
	}

	@keyframes pulse-slow {
		0%,
		100% {
			opacity: 1;
			transform: scale(1);
		}
		50% {
			opacity: 0.9;
			transform: scale(1.05);
		}
	}

	@keyframes shake {
		0%,
		100% {
			transform: translateX(0);
		}
		25% {
			transform: translateX(-8px);
		}
		75% {
			transform: translateX(8px);
		}
	}

	@keyframes slideInFromTop {
		0% {
			opacity: 0;
			transform: translateY(-20px);
		}
		100% {
			opacity: 1;
			transform: translateY(0);
		}
	}

	@keyframes cascadeIn {
		0% {
			opacity: 0;
			transform: translateY(20px) scale(0.95);
		}
		100% {
			opacity: 1;
			transform: translateY(0) scale(1);
		}
	}

	@keyframes glowPulse {
		0%,
		100% {
			opacity: 0.5;
			transform: scale(1);
		}
		50% {
			opacity: 1;
			transform: scale(1.1);
		}
	}

	@keyframes fadeIn {
		0% {
			opacity: 0;
		}
		100% {
			opacity: 1;
		}
	}

	@keyframes modalSlideUp {
		0% {
			opacity: 0;
			transform: translateY(50px) scale(0.9);
		}
		100% {
			opacity: 1;
			transform: translateY(0) scale(1);
		}
	}

	@keyframes spin {
		0% {
			transform: rotate(0deg);
		}
		100% {
			transform: rotate(360deg);
		}
	}

	/* ========================================
	   RESPONSIVE DESIGN
	   ======================================== */

	@media (max-width: 1024px) {
		.students-page {
			padding: 1.5rem;
		}

		.page-header {
			padding: 2rem;
		}

		.stats-grid {
			grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
		}
	}

	@media (max-width: 768px) {
		.students-page {
			padding: 1rem;
		}

		.page-header {
			flex-direction: column;
			align-items: flex-start;
			padding: 1.5rem;
			gap: 1rem;
		}

		.page-header h1 {
			font-size: 2rem;
		}

		.header-icon-wrapper {
			width: 64px;
			height: 64px;
		}

		.header-icon {
			width: 36px;
			height: 36px;
		}

		.stats-grid {
			grid-template-columns: 1fr;
			gap: 1rem;
		}

		.stat-card {
			padding: 1.5rem;
		}

		.stat-number {
			font-size: 2rem;
		}

		.card-content {
			padding: 1.5rem;
		}

		.data-table {
			font-size: 0.9rem;
		}

		.data-table th,
		.data-table td {
			padding: 1rem 0.5rem;
		}

		.actions {
			flex-direction: column;
		}

		.actions .btn {
			width: 100%;
		}

		.modal-content {
			margin: 1rem;
			width: calc(100% - 2rem);
		}

		.modal-header,
		.modal-content form,
		.modal-actions {
			padding: 1.5rem;
		}

		.brand-main {
			font-size: 2rem;
		}

		.brand-tagline {
			font-size: 1.125rem;
		}
	}

	@media (max-width: 480px) {
		.page-header h1 {
			font-size: 1.75rem;
		}

		.subtitle {
			font-size: 1rem;
		}

		.stat-icon-wrapper {
			width: 56px;
			height: 56px;
		}

		.stat-icon {
			width: 28px;
			height: 28px;
		}

		.stat-number {
			font-size: 1.75rem;
		}

		.data-table {
			font-size: 0.85rem;
		}
	}

	/* ========================================
	   ACCESSIBILITY & REDUCED MOTION
	   ======================================== */

	@media (prefers-reduced-motion: reduce) {
		*,
		*::before,
		*::after {
			animation-duration: 0.01ms !important;
			animation-iteration-count: 1 !important;
			transition-duration: 0.01ms !important;
		}
	}
</style>
