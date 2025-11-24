<script>
	// Subjects management page
	import { browser } from "$app/environment";
	import { onMount } from "svelte";

	/** @type {import('./$types').PageData} */
	export let data;

	$: session = data.session;
	$: subjects = data.subjects || [];
	$: statusList = data.statusList || [];

	let showModal = false;
	let editingSubject = null;
	let loading = false;
	let searchTerm = "";
	let isLoading = true;
	let loadingProgress = 0;
	let loadingText = "Initializing...";
	let loadingFadeOut = false;
	let pageVisible = false;
	let statsVisible = false;
	let cardsVisible = false;
	let scrollY = 0;

	onMount(() => {
		const loadingSteps = [
			{ progress: 25, text: "Loading subjects..." },
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

		window.addEventListener("scroll", handleScroll);
		return () => window.removeEventListener("scroll", handleScroll);
	});

	// Form data
	let formData = {
		subjectName: "",
		subjectCode: "",
		statusId: "",
	};

	// Filter subjects based on search term
	$: filteredSubjects = subjects.filter((subject) => {
		const term = searchTerm.toLowerCase();
		return (
			(subject.subject_name &&
				subject.subject_name.toLowerCase().includes(term)) ||
			(subject.subject_code &&
				subject.subject_code.toLowerCase().includes(term))
		);
	});

	function openModal(subject = null) {
		editingSubject = subject;
		if (subject) {
			formData = {
				subjectName: subject.subject_name,
				subjectCode: subject.subject_code || "",
				statusId: subject.StatusID.toString(),
			};
		} else {
			formData = {
				subjectName: "",
				subjectCode: "",
				statusId: "1",
			};
		}
		showModal = true;
	}

	function closeModal() {
		showModal = false;
		editingSubject = null;
		resetForm();
	}

	function handleKeydown(event) {
		if (event.key === "Escape") {
			closeModal();
		}
	}

	function resetForm() {
		formData = {
			subjectName: "",
			subjectCode: "",
			statusId: "",
		};
	}

	async function handleSubmit() {
		if (!browser) return;

		loading = true;

		try {
			const method = editingSubject ? "PUT" : "POST";
			const response = await fetch("/api/subjects", {
				method,
				headers: {
					"Content-Type": "application/json",
				},
				body: JSON.stringify({
					...formData,
					statusId: parseInt(formData.statusId),
					...(editingSubject && {
						subjectId: editingSubject.SubjectID,
					}),
				}),
			});

			const result = await response.json();

			if (response.ok) {
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

	async function handleDelete(subjectId) {
		if (!browser) return;

		if (!confirm("Are you sure you want to delete this subject?")) {
			return;
		}

		try {
			const response = await fetch("/api/subjects", {
				method: "DELETE",
				headers: {
					"Content-Type": "application/json",
				},
				body: JSON.stringify({ subjectId }),
			});

			const result = await response.json();

			if (response.ok) {
				window.location.reload();
			} else {
				alert(result.error || "Failed to delete subject");
			}
		} catch (error) {
			console.error("Delete error:", error);
			alert("An error occurred while deleting");
		}
	}
</script>

<svelte:head>
	<title>Subjects - School Management System</title>
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
						fill="white">📚</text
					>
				</svg>
			</div>

			<div class="loading-brand">
				<div class="brand-main">School Management</div>
				<div class="brand-tagline">SUBJECTS MODULE</div>
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

<div class="subjects-page" class:visible={pageVisible}>
	<div class="page-header" class:visible={pageVisible}>
		<div class="header-icon-wrapper">
			<svg
				class="header-icon"
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
		<div class="header-content">
			<h1>Subjects Management</h1>
			<p class="subtitle">Manage academic subjects</p>
		</div>
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
			Add New Subject
		</button>
	</div>

	{#if data.error}
		<div class="error-message error-slide-in">
			<svg
				class="error-icon"
				viewBox="0 0 24 24"
				fill="none"
				stroke="currentColor"
				stroke-width="2"
			>
				<circle cx="12" cy="12" r="10"></circle>
				<line x1="12" y1="8" x2="12" y2="12"></line>
				<line x1="12" y1="16" x2="12.01" y2="16"></line>
			</svg>
			<span>{data.error}</span>
		</div>
	{/if}

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
					<polyline points="20 6 9 17 4 12"></polyline>
				</svg>
			</div>
			<div class="stat-content">
				<div class="stat-number">
					{subjects.filter((s) => s.StatusName === "Active").length}
				</div>
				<div class="stat-label">Active Subjects</div>
			</div>
		</div>
	</div>

	<!-- Search and Table Section -->
	<div class="content-section" class:visible={cardsVisible}>
		<div class="section-card">
			<div class="card-header">
				<h3 class="card-title">📋 Subject Records</h3>
			</div>

			<div class="card-content">
				<!-- Search bar -->
				<div class="search-container">
					<input
						type="text"
						bind:value={searchTerm}
						placeholder="🔍 Search by name or code..."
						class="search-input"
					/>
				</div>

				<!-- Subjects table -->
				<div class="table-container">
					<table class="data-table">
						<thead>
							<tr>
								<th>Subject Code</th>
								<th>Subject Name</th>
								<th>Status</th>
								{#if session.role === "Admin"}
									<th>Actions</th>
								{/if}
							</tr>
						</thead>
						<tbody>
							{#each filteredSubjects as subject}
								<tr>
									<td
										><code
											>{subject.subject_code || "-"}</code
										></td
									>
									<td>{subject.subject_name}</td>
									<td>
										<span
											class="status-badge {(
												subject.StatusName || 'unknown'
											).toLowerCase()}"
										>
											{subject.StatusName || "Unknown"}
										</span>
									</td>
									{#if session.role === "Admin"}
										<td>
											<div class="actions">
												<button
													class="btn btn-secondary"
													on:click={() =>
														openModal(subject)}
												>
													Edit
												</button>
												<button
													class="btn btn-danger"
													on:click={() =>
														handleDelete(
															subject.SubjectID,
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
										colspan={Number(
											session.role === "Admin"
												? "4"
												: "3",
										)}
										class="text-center"
									>
										<div class="empty-state">
											<h3>No subjects found</h3>
											<p>
												{searchTerm
													? "Try adjusting your search terms"
													: "No subject records available"}
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

<!-- Modal for add/edit subject -->
{#if showModal}
	<div
		class="modal-overlay"
		on:click={closeModal}
		on:keydown={handleKeydown}
		role="button"
		tabindex="0"
		aria-label="Close modal"
	>
		<div
			class="modal-content"
			on:click|stopPropagation
			role="dialog"
			aria-modal="true"
			tabindex="-1"
		>
			<div class="modal-header">
				<div class="modal-title-wrapper">
					<div class="modal-icon">
						{#if editingSubject}
							<svg
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
						{:else}
							<svg
								viewBox="0 0 24 24"
								fill="none"
								stroke="currentColor"
								stroke-width="2"
							>
								<line x1="12" y1="5" x2="12" y2="19"></line>
								<line x1="5" y1="12" x2="19" y2="12"></line>
							</svg>
						{/if}
					</div>
					<h3 class="modal-title">
						{editingSubject ? "Edit Subject" : "Add New Subject"}
					</h3>
				</div>
				<button
					class="close-btn"
					on:click={closeModal}
					aria-label="Close modal"
				>
					<svg
						viewBox="0 0 24 24"
						fill="none"
						stroke="currentColor"
						stroke-width="2"
					>
						<line x1="18" y1="6" x2="6" y2="18"></line>
						<line x1="6" y1="6" x2="18" y2="18"></line>
					</svg>
				</button>
			</div>

			<form on:submit|preventDefault={handleSubmit}>
				<div class="form-group">
					<label for="subjectCode" class="form-label"
						>Subject Code:</label
					>
					<input
						type="text"
						id="subjectCode"
						bind:value={formData.subjectCode}
						required
						disabled={loading}
						placeholder="e.g., MATH101"
						style="text-transform: uppercase;"
						class="form-input"
					/>
				</div>

				<div class="form-group">
					<label for="subjectName" class="form-label"
						>Subject Name:</label
					>
					<input
						type="text"
						id="subjectName"
						bind:value={formData.subjectName}
						required
						disabled={loading}
						placeholder="e.g., Mathematics"
						class="form-input"
					/>
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
						{editingSubject ? "Update Subject" : "Create Subject"}
					</button>
				</div>
			</form>
		</div>
	</div>
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
							fill="white">📚</text
						>
					</svg>
				</div>

				<div class="loading-brand">
					<div class="brand-main">School Management</div>
					<div class="brand-tagline">SUBJECTS MODULE</div>
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
						<span class="progress-percentage"
							>{loadingProgress}%</span
						>
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
		top: 60%;
		right: 10%;
		width: 500px;
		height: 500px;
		background: linear-gradient(135deg, #22c55e, #f97316);
		animation: float 10s ease-in-out infinite reverse;
	}

	.orb-bg-3 {
		bottom: 10%;
		left: 30%;
		width: 300px;
		height: 300px;
		background: linear-gradient(135deg, #a855f7, #3b82f6);
		animation: float 12s ease-in-out infinite 2s;
	}

	@keyframes float {
		0%,
		100% {
			transform: translate(0, 0);
		}
		50% {
			transform: translate(20px, -20px);
		}
	}

	/* ========================================
	   MAIN PAGE STYLES
	   ======================================== */

	.subjects-page {
		padding: 24px;
		max-width: 1400px;
		margin: 0 auto;
		opacity: 0;
		transform: translateY(20px);
		transition:
			opacity 0.5s ease-out,
			transform 0.5s ease-out;
	}

	.subjects-page.visible {
		opacity: 1;
		transform: translateY(0);
	}

	.page-header {
		display: flex;
		align-items: center;
		justify-content: space-between;
		margin-bottom: 32px;
		background: rgba(255, 255, 255, 0.8);
		backdrop-filter: blur(10px);
		padding: 24px 32px;
		border-radius: 24px;
		box-shadow: 0 10px 30px -10px rgba(0, 0, 0, 0.1);
		border: 1px solid rgba(255, 255, 255, 0.5);
		opacity: 0;
		transform: translateY(-20px);
		transition:
			opacity 0.5s ease-out 0.2s,
			transform 0.5s ease-out 0.2s;
	}

	.page-header.visible {
		opacity: 1;
		transform: translateY(0);
	}

	.header-icon-wrapper {
		width: 56px;
		height: 56px;
		background: linear-gradient(135deg, #3b82f6, #a855f7);
		border-radius: 16px;
		display: flex;
		align-items: center;
		justify-content: center;
		margin-right: 20px;
		box-shadow: 0 10px 20px -5px rgba(59, 130, 246, 0.4);
		flex-shrink: 0;
	}

	.header-icon {
		width: 32px;
		height: 32px;
		color: white;
	}

	.header-content {
		flex: 1;
	}

	.header-content h1 {
		font-size: 28px;
		font-weight: 800;
		color: #1e293b;
		margin: 0 0 4px 0;
		letter-spacing: -0.5px;
	}

	.subtitle {
		color: #64748b;
		font-size: 15px;
		margin: 0;
	}

	/* ===== STATS CARDS ===== */
	.stats-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
		gap: 24px;
		margin-bottom: 32px;
		opacity: 0;
		transform: translateY(20px);
		transition:
			opacity 0.5s ease-out 0.4s,
			transform 0.5s ease-out 0.4s;
	}

	.stats-grid.visible {
		opacity: 1;
		transform: translateY(0);
	}

	.stat-card {
		background: rgba(255, 255, 255, 0.8);
		backdrop-filter: blur(10px);
		border-radius: 20px;
		padding: 24px;
		display: flex;
		align-items: center;
		gap: 20px;
		box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.05);
		border: 1px solid rgba(255, 255, 255, 0.6);
		position: relative;
		overflow: hidden;
		transition:
			transform 0.3s ease,
			box-shadow 0.3s ease;
	}

	.stat-card:hover {
		transform: translateY(-5px);
		box-shadow: 0 20px 40px -10px rgba(0, 0, 0, 0.1);
	}

	.stat-glow {
		position: absolute;
		top: -50%;
		left: -50%;
		width: 200%;
		height: 200%;
		background: radial-gradient(
			circle,
			rgba(255, 255, 255, 0.8) 0%,
			transparent 70%
		);
		opacity: 0;
		transition: opacity 0.3s ease;
		pointer-events: none;
	}

	.stat-card:hover .stat-glow {
		opacity: 1;
	}

	.stat-icon-wrapper {
		width: 60px;
		height: 60px;
		border-radius: 16px;
		display: flex;
		align-items: center;
		justify-content: center;
		flex-shrink: 0;
		position: relative;
		z-index: 1;
	}

	.stat-icon {
		width: 30px;
		height: 30px;
		color: white;
	}

	.stat-card-1 .stat-icon-wrapper {
		background: linear-gradient(135deg, #3b82f6, #2563eb);
		box-shadow: 0 8px 16px -4px rgba(59, 130, 246, 0.4);
	}
	.stat-card-2 .stat-icon-wrapper {
		background: linear-gradient(135deg, #22c55e, #16a34a);
		box-shadow: 0 8px 16px -4px rgba(34, 197, 94, 0.4);
	}
	.stat-card-3 .stat-icon-wrapper {
		background: linear-gradient(135deg, #a855f7, #9333ea);
		box-shadow: 0 8px 16px -4px rgba(168, 85, 247, 0.4);
	}
	.stat-card-4 .stat-icon-wrapper {
		background: linear-gradient(135deg, #f97316, #ea580c);
		box-shadow: 0 8px 16px -4px rgba(249, 115, 22, 0.4);
	}

	.stat-content {
		flex: 1;
		z-index: 1;
	}

	.stat-number {
		font-size: 32px;
		font-weight: 800;
		color: #1e293b;
		line-height: 1;
		margin-bottom: 4px;
	}

	.stat-label {
		font-size: 14px;
		color: #64748b;
		font-weight: 500;
	}

	/* ===== CONTENT SECTION ===== */
	.content-section {
		opacity: 0;
		transform: translateY(20px);
		transition:
			opacity 0.5s ease-out 0.6s,
			transform 0.5s ease-out 0.6s;
	}

	.content-section.visible {
		opacity: 1;
		transform: translateY(0);
	}

	.section-card {
		background: rgba(255, 255, 255, 0.8);
		backdrop-filter: blur(10px);
		border-radius: 24px;
		box-shadow: 0 20px 40px -10px rgba(0, 0, 0, 0.05);
		border: 1px solid rgba(255, 255, 255, 0.6);
		overflow: hidden;
	}

	.card-header {
		padding: 24px 32px;
		border-bottom: 1px solid rgba(226, 232, 240, 0.6);
		display: flex;
		align-items: center;
		justify-content: space-between;
	}

	.card-title {
		font-size: 20px;
		font-weight: 700;
		color: #1e293b;
		margin: 0;
		display: flex;
		align-items: center;
		gap: 12px;
	}

	.card-content {
		padding: 32px;
	}

	/* ===== SEARCH BAR ===== */
	.search-container {
		margin-bottom: 24px;
	}

	.search-input {
		width: 100%;
		padding: 16px 24px;
		border-radius: 16px;
		border: 2px solid #e2e8f0;
		font-size: 16px;
		background: rgba(255, 255, 255, 0.8);
		transition: all 0.3s ease;
		color: #1e293b;
	}

	.search-input:focus {
		outline: none;
		border-color: #3b82f6;
		box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.1);
		background: white;
	}

	/* ===== TABLE STYLES ===== */
	.table-container {
		overflow-x: auto;
		border-radius: 16px;
		border: 1px solid #e2e8f0;
	}

	.data-table {
		width: 100%;
		border-collapse: collapse;
		white-space: nowrap;
	}

	.data-table th {
		background: #f8fafc;
		padding: 16px 24px;
		text-align: left;
		font-size: 13px;
		font-weight: 600;
		color: #64748b;
		text-transform: uppercase;
		letter-spacing: 0.05em;
		border-bottom: 1px solid #e2e8f0;
	}

	.data-table td {
		padding: 16px 24px;
		color: #334155;
		font-size: 15px;
		border-bottom: 1px solid #f1f5f9;
		vertical-align: middle;
	}

	.data-table tr:last-child td {
		border-bottom: none;
	}

	.data-table tr:hover td {
		background: rgba(248, 250, 252, 0.5);
	}

	.data-table code {
		background: #eff6ff;
		color: #3b82f6;
		padding: 4px 8px;
		border-radius: 6px;
		font-family: "Monaco", "Consolas", monospace;
		font-size: 13px;
		font-weight: 600;
	}

	/* ===== STATUS BADGES ===== */
	.status-badge {
		display: inline-flex;
		align-items: center;
		padding: 6px 12px;
		border-radius: 20px;
		font-size: 13px;
		font-weight: 600;
		line-height: 1;
	}

	.status-badge.active {
		background: #dcfce7;
		color: #166534;
	}

	.status-badge.inactive {
		background: #fee2e2;
		color: #991b1b;
	}

	.status-badge.unknown {
		background: #f1f5f9;
		color: #64748b;
	}

	/* ===== BUTTONS ===== */
	.btn {
		padding: 10px 20px;
		border-radius: 12px;
		font-weight: 600;
		font-size: 14px;
		cursor: pointer;
		transition: all 0.2s ease;
		border: none;
		display: inline-flex;
		align-items: center;
		gap: 8px;
	}

	.btn-primary {
		background: linear-gradient(135deg, #3b82f6, #2563eb);
		color: white;
		box-shadow: 0 4px 12px rgba(37, 99, 235, 0.2);
	}

	.btn-primary:hover {
		transform: translateY(-2px);
		box-shadow: 0 6px 16px rgba(37, 99, 235, 0.3);
	}

	.btn-secondary {
		background: white;
		color: #334155;
		border: 1px solid #e2e8f0;
	}

	.btn-secondary:hover {
		background: #f8fafc;
		border-color: #cbd5e1;
	}

	.btn-danger {
		background: #fee2e2;
		color: #991b1b;
	}

	.btn-danger:hover {
		background: #fecaca;
	}

	.actions {
		display: flex;
		gap: 8px;
	}

	.actions .btn {
		padding: 8px 16px;
		font-size: 13px;
	}

	/* ===== MODAL ===== */
	.modal-overlay {
		position: fixed;
		inset: 0;
		background: rgba(15, 23, 42, 0.6);
		backdrop-filter: blur(8px);
		z-index: 100;
		display: flex;
		align-items: center;
		justify-content: center;
		padding: 20px;
		animation: fadeIn 0.2s ease-out;
	}

	.modal-content {
		background: white;
		border-radius: 24px;
		width: 100%;
		max-width: 500px;
		box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
		animation: slideUp 0.3s cubic-bezier(0.16, 1, 0.3, 1);
		overflow: hidden;
	}

	.modal-header {
		padding: 24px 32px;
		border-bottom: 1px solid #e2e8f0;
		display: flex;
		align-items: center;
		justify-content: space-between;
		background: #f8fafc;
	}

	.modal-title-wrapper {
		display: flex;
		align-items: center;
		gap: 16px;
	}

	.modal-icon {
		width: 40px;
		height: 40px;
		background: #eff6ff;
		border-radius: 12px;
		display: flex;
		align-items: center;
		justify-content: center;
		color: #3b82f6;
	}

	.modal-icon svg {
		width: 24px;
		height: 24px;
	}

	.modal-title {
		font-size: 20px;
		font-weight: 700;
		color: #1e293b;
		margin: 0;
	}

	.close-btn {
		background: transparent;
		border: none;
		color: #94a3b8;
		cursor: pointer;
		padding: 8px;
		border-radius: 8px;
		transition: all 0.2s;
	}

	.close-btn:hover {
		background: #e2e8f0;
		color: #64748b;
	}

	.close-btn svg {
		width: 24px;
		height: 24px;
	}

	form {
		padding: 32px;
	}

	.form-group {
		margin-bottom: 24px;
	}

	.form-label {
		display: block;
		font-size: 14px;
		font-weight: 600;
		color: #475569;
		margin-bottom: 8px;
	}

	.form-input,
	.form-select {
		width: 100%;
		padding: 12px 16px;
		border-radius: 12px;
		border: 2px solid #e2e8f0;
		font-size: 15px;
		color: #1e293b;
		transition: all 0.2s;
	}

	.form-input:focus,
	.form-select:focus {
		outline: none;
		border-color: #3b82f6;
		box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.1);
	}

	.form-input::placeholder {
		color: #94a3b8;
	}

	.form-row {
		display: grid;
		grid-template-columns: 1fr 1fr;
		gap: 20px;
	}

	.modal-actions {
		display: flex;
		justify-content: flex-end;
		gap: 12px;
		margin-top: 32px;
		padding-top: 24px;
		border-top: 1px solid #e2e8f0;
	}

	.spinner {
		width: 20px;
		height: 20px;
		border: 2px solid rgba(255, 255, 255, 0.3);
		border-radius: 50%;
		border-top-color: white;
		animation: spin 0.8s linear infinite;
	}

	@keyframes spin {
		to {
			transform: rotate(360deg);
		}
	}

	@keyframes fadeIn {
		from {
			opacity: 0;
		}
		to {
			opacity: 1;
		}
	}

	@keyframes slideUp {
		from {
			opacity: 0;
			transform: translateY(20px) scale(0.95);
		}
		to {
			opacity: 1;
			transform: translateY(0) scale(1);
		}
	}

	.error-message {
		background: #fee2e2;
		border: 1px solid #fecaca;
		color: #991b1b;
		padding: 16px;
		border-radius: 12px;
		margin-bottom: 24px;
		display: flex;
		align-items: center;
		gap: 12px;
		animation: slideDown 0.3s ease-out;
	}

	.error-icon {
		width: 24px;
		height: 24px;
		flex-shrink: 0;
	}

	.empty-state {
		padding: 48px 0;
		text-align: center;
		color: #64748b;
	}

	.empty-state h3 {
		font-size: 18px;
		font-weight: 600;
		color: #1e293b;
		margin: 0 0 8px 0;
	}

	.empty-state p {
		margin: 0;
		font-size: 14px;
	}

	@keyframes slideDown {
		from {
			opacity: 0;
			transform: translateY(-10px);
		}
		to {
			opacity: 1;
			transform: translateY(0);
		}
	}

	/* Responsive adjustments */
	@media (max-width: 768px) {
		.page-header {
			flex-direction: column;
			gap: 20px;
			text-align: center;
			padding: 24px;
		}

		.header-icon-wrapper {
			margin-right: 0;
			margin-bottom: 16px;
		}

		.form-row {
			grid-template-columns: 1fr;
			gap: 0;
		}
	}
</style>
