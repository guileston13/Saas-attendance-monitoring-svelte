<script>
	import { onMount } from 'svelte';
	import { enhance } from '$app/forms';
	import { goto } from '$app/navigation';

	export let form;
	
	let loading = false;
	let formVisible = false;
	let scrollY = 0;
	let gradientOffset = 0;
	let emailFocused = false;
	let passwordFocused = false;
	let isLoading = true;
	let loadingProgress = 0;
	let loadingText = 'Initializing...';
	let loadingFadeOut = false;

	// Loading animation sequence
	onMount(() => {
		// Simulate loading progress
		const loadingSteps = [
			{ progress: 20, text: 'Loading assets...', delay: 300 },
			{ progress: 45, text: 'Connecting to server...', delay: 600 },
			{ progress: 70, text: 'Preparing interface...', delay: 900 },
			{ progress: 100, text: 'Ready!', delay: 1200 }
		];

		let currentStep = 0;
		
		const runLoadingStep = () => {
			if (currentStep < loadingSteps.length) {
				const step = loadingSteps[currentStep];
				setTimeout(() => {
					loadingProgress = step.progress;
					loadingText = step.text;
					currentStep++;
					runLoadingStep();
				}, step.delay);
			} else {
				// Loading complete - fade out loading screen and show form
				setTimeout(() => {
					loadingFadeOut = true;
					setTimeout(() => {
						isLoading = false;
						setTimeout(() => formVisible = true, 200);
					}, 800);
				}, 500);
			}
		};

		runLoadingStep();

		// Scroll listener for parallax (only after loading)
		const handleScroll = () => {
			scrollY = window.scrollY;
			gradientOffset = scrollY * 0.5;
		};

		// Add scroll listener after loading is complete
		setTimeout(() => {
			window.addEventListener('scroll', handleScroll, { passive: true });
		}, 2000);

		return () => {
			window.removeEventListener('scroll', handleScroll);
		};
	});

	function handleSubmit() {
		// kept for backwards compatibility with any other on:submit references; prefer use:enhance
		loading = true;
	}
</script>

<!-- Loading Screen -->
{#if isLoading}
	<div class="loading-screen" class:fade-out={loadingFadeOut}>
		<!-- Animated Background Particles -->
		<div class="particles-container">
			{#each Array(20) as _, i}
				<div class="particle particle-{i % 4 + 1}" style="animation-delay: {i * 0.1}s"></div>
			{/each}
		</div>

		<!-- Main Loading Content -->
		<div class="loading-content">
			<!-- Animated Logo -->
			<div class="loading-logo">
				<svg class="logo-svg" fill="none" stroke="url(#logoGradient)" viewBox="0 0 24 24">
					<defs>
						<linearGradient id="logoGradient" x1="0%" y1="0%" x2="100%" y2="100%">
							<stop offset="0%" stop-color="#3B82F6">
								<animate attributeName="stop-color" values="#3B82F6;#A855F7;#22C55E;#F97316;#3B82F6" dur="3s" repeatCount="indefinite" />
							</stop>
							<stop offset="100%" stop-color="#A855F7">
								<animate attributeName="stop-color" values="#A855F7;#22C55E;#F97316;#3B82F6;#A855F7" dur="3s" repeatCount="indefinite" />
							</stop>
						</linearGradient>
					</defs>
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
				</svg>
				<div class="logo-pulse"></div>
			</div>

			<!-- Brand Text -->
			<div class="loading-brand">
				<h1 class="brand-main">School Management</h1>
				<p class="brand-tagline">System</p>
			</div>

			<!-- Loading Progress -->
			<div class="loading-progress">
				<div class="progress-bar">
					<div class="progress-fill" style="width: {loadingProgress}%"></div>
					<div class="progress-glow" style="width: {loadingProgress}%"></div>
				</div>
				<div class="progress-text">{loadingText}</div>
				<div class="progress-percentage">{loadingProgress}%</div>
			</div>

			<!-- Loading Dots Animation -->
			<div class="loading-dots">
				<div class="dot dot-1"></div>
				<div class="dot dot-2"></div>
				<div class="dot dot-3"></div>
			</div>
		</div>

		<!-- Background Gradient Orbs -->
		<div class="loading-orbs">
			<div class="orb orb-1"></div>
			<div class="orb orb-2"></div>
			<div class="orb orb-3"></div>
			<div class="orb orb-4"></div>
		</div>
	</div>
{/if}

<!-- Animated Background Layer -->
<div
	class="animated-background"
>
	<!-- Dot pattern overlay -->
	<div class="dot-pattern"></div>
</div>

<div class="auth-container">
	<!-- Main Form Container with Glass Morphism -->
	<div 
		class="form-wrapper"
		class:visible={formVisible}
	>
		<!-- Logo/Brand Section with Gradient -->
		<div class="brand-section">
			<div class="logo-container">
				<svg class="logo-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
				</svg>
			</div>
			<h2 class="brand-title">School Management</h2>
			<p class="brand-subtitle">Welcome back! Please login to continue</p>
		</div>

		<!-- Error Message with Animation -->
		{#if form?.error}
			<div class="error-container">
				<svg class="error-icon" fill="currentColor" viewBox="0 0 20 20">
					<path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
				</svg>
				<span>{form.error}</span>
			</div>
		{/if}

		<!-- Login Form -->
		<form method="POST" use:enhance={() => {
			loading = true;
			return async ({ result }) => {
				loading = false;
				// On server redirect, navigate client-side
				if (result.type === 'redirect') {
					goto(result.location);
				}
			};
		}} class="form-content">
			<!-- Email Input -->
			<div class="input-group">
				<label for="email" class="input-label">
					<svg class="input-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207" />
					</svg>
					Email Address
				</label>
				<div class="input-wrapper" class:focused={emailFocused}>
					<input
						type="email"
						id="email"
						name="email"
						required
						disabled={loading}
						value={form?.email || ''}
						class="form-input"
						placeholder="your.email@example.com"
						on:focus={() => emailFocused = true}
						on:blur={() => emailFocused = false}
					/>
				</div>
			</div>

			<!-- Password Input -->
			<div class="input-group">
				<label for="password" class="input-label">
					<svg class="input-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
					</svg>
					Password
				</label>
				<div class="input-wrapper" class:focused={passwordFocused}>
					<input
						type="password"
						id="password"
						name="password"
						required
						disabled={loading}
						class="form-input"
						placeholder="Enter your password"
						on:focus={() => passwordFocused = true}
						on:blur={() => passwordFocused = false}
					/>
				</div>
			</div>

			<!-- Submit Button with Loading State -->
			<button
				type="submit"
				class="submit-button"
				disabled={loading}
			>
				<span class="button-content">
					{#if loading}
						<div class="spinner-container">
							<div class="spinner-outer"></div>
							<div class="spinner-inner"></div>
						</div>
						<span>Signing In...</span>
					{:else}
						<svg class="button-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1" />
						</svg>
						<span>Sign In</span>
					{/if}
				</span>
			</button>

			<!-- Links Section -->
			<div class="links-container">
				<p class="link-text">
					Don't have an account? 
					<a href="/register" class="link">Create Account</a>
				</p>
			</div>
		</form>

		<!-- Divider -->
		<div class="divider">
			<span class="divider-text">or</span>
		</div>

		<!-- Alternative Login Button -->
		<button 
			class="alternative-button"
			on:click={() => window.location.href = '/attendance-login'}
			type="button"
		>
			<svg class="button-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z" />
			</svg>
			<span class="button-text">
				<span class="button-title">Face Recognition Login</span>
				<span class="button-subtitle">Use your camera for quick access</span>
			</span>
			<svg class="arrow-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
			</svg>
		</button>

		<!-- Footer -->
		<div class="form-footer">
			<p class="footer-text">
				Secured with enterprise-grade encryption
			</p>
		</div>
	</div>
</div>

<style>
	/* Container Styles */
	.auth-container {
		min-height: 100vh;
		display: flex;
		justify-content: center;
		align-items: center;
		padding: 1rem;
		position: relative;
	}

	/* Dot Background */
	.dot-background {
		position: absolute;
		inset: 0;
		overflow: hidden;
		z-index: -1;
		background: rgba(255, 255, 255, 0.02);
	}

	.dot-grid {
		position: absolute;
		inset: 0;
		display: grid;
		grid-template-columns: repeat(15, 1fr);
		grid-template-rows: repeat(7, 1fr);
		gap: 3rem;
		padding: 2rem;
	}

	.dot {
		width: 35px;
		height: 35px;
		background: rgba(59, 130, 246, 1);
		border-radius: 50%;
		animation: dotPulse 4s ease-in-out infinite;
		opacity: 1;
		position: relative;
		box-shadow: 0 0 25px rgba(59, 130, 246, 0.9), 0 0 50px rgba(59, 130, 246, 0.5);
	}

	.dot:nth-child(2n) {
		width: 12px;
		height: 12px;
		transform: translate(0.5px, -0.5px);
	}

	.dot:nth-child(3n) {
		width: 25px;
		height: 25px;
		background: rgba(168, 85, 247, 1);
		animation-duration: 5s;
		transform: translate(-0.3px, 0.7px);
		box-shadow: 0 0 20px rgba(168, 85, 247, 0.9), 0 0 40px rgba(168, 85, 247, 0.5);
	}

	.dot:nth-child(4n) {
		background: rgba(34, 197, 94, 1);
		animation-duration: 6s;
		transform: translate(0.8px, -0.2px);
		box-shadow: 0 0 20px rgba(34, 197, 94, 0.9), 0 0 40px rgba(34, 197, 94, 0.5);
	}

	.dot:nth-child(5n) {
		background: rgba(249, 115, 22, 1);
		animation-duration: 7s;
		transform: translate(-0.6px, 0.4px);
		box-shadow: 0 0 20px rgba(249, 115, 22, 0.9), 0 0 40px rgba(249, 115, 22, 0.5);
	}

	.dot:nth-child(6n) {
		width: 8px;
		height: 8px;
		transform: translate(0.2px, -0.8px);
	}

	.dot:nth-child(7n) {
		background: rgba(236, 72, 153, 1);
		animation-duration: 5.5s;
		transform: translate(-0.4px, 0.6px);
		box-shadow: 0 0 20px rgba(236, 72, 153, 0.9), 0 0 40px rgba(236, 72, 153, 0.5);
	}

	.dot:nth-child(8n) {
		width: 30px;
		height: 30px;
		opacity: 0.9;
		transform: translate(0.7px, -0.3px);
		box-shadow: 0 0 25px rgba(59, 130, 246, 1), 0 0 50px rgba(59, 130, 246, 0.7);
	}

	.color-overlay {
		position: absolute;
		inset: 0;
		background: radial-gradient(
			ellipse at top left,
			rgba(59, 130, 246, 0.03) 0%,
			rgba(168, 85, 247, 0.02) 25%,
			rgba(34, 197, 94, 0.02) 50%,
			rgba(249, 115, 22, 0.01) 75%,
			transparent 100%
		);
		animation: overlayShift 20s ease-in-out infinite;
	}

	/* Animated Background */
	.animated-background {
		position: fixed;
		inset: 0;
		z-index: -10;
		overflow: hidden;
		background: #ffffff;
	}

	/* Dot Pattern - Simple grid of small dots like Contentgrow */
	.dot-pattern {
		position: absolute;
		inset: 0;
		background-image: radial-gradient(circle, #d0d0d0 1px, transparent 1px);
		background-size: 30px 30px;
		background-position: 0 0;
	}

	.floating-orb {
		position: absolute;
		border-radius: 50%;
		filter: blur(48px);
	}

	.orb-1 {
		top: 5rem;
		left: 2.5rem;
		width: 18rem;
		height: 18rem;
		background: rgba(59, 130, 246, 0.2);
		animation: float 6s ease-in-out infinite;
	}

	.orb-2 {
		top: 10rem;
		right: 5rem;
		width: 24rem;
		height: 24rem;
		background: rgba(168, 85, 247, 0.2);
		animation: float-delayed 8s ease-in-out infinite;
	}

	.orb-3 {
		bottom: 5rem;
		left: 33.333%;
		width: 20rem;
		height: 20rem;
		background: rgba(34, 197, 94, 0.2);
		animation: float-slow 10s ease-in-out infinite;
	}

	/* Form Wrapper with Glass Morphism */
	.form-wrapper {
		background: rgba(255, 255, 255, 0.25);
		backdrop-filter: blur(20px);
		-webkit-backdrop-filter: blur(20px);
		border-radius: 2rem;
		box-shadow: 
			0 20px 60px rgba(0, 0, 0, 0.1),
			0 0 0 1px rgba(255, 255, 255, 0.3) inset;
		padding: 3rem 2.5rem;
		width: 100%;
		max-width: 480px;
		position: relative;
		overflow: hidden;
		opacity: 0;
		transform: translateY(30px) scale(0.95);
		transition: all 0.6s cubic-bezier(0.4, 0, 0.2, 1);
		z-index: 1;
	}

	.form-wrapper.visible {
		opacity: 1;
		transform: translateY(0) scale(1);
	}

	/* Gradient border effect on hover */
	.form-wrapper::before {
		content: '';
		position: absolute;
		inset: 0;
		border-radius: 2rem;
		padding: 2px;
		background: linear-gradient(135deg, #3B82F6, #A855F7, #22C55E);
		-webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
		-webkit-mask-composite: xor;
		mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
		mask-composite: exclude;
		opacity: 0;
		transition: opacity 0.5s ease;
	}

	.form-wrapper:hover::before {
		opacity: 0.5;
	}

	/* Brand Section */
	.brand-section {
		text-align: center;
		margin-bottom: 2rem;
	}

	.logo-container {
		display: flex;
		justify-content: center;
		margin-bottom: 1rem;
	}

	.logo-icon {
		width: 4rem;
		height: 4rem;
		color: #3B82F6;
		animation: pulse-slow 2s ease-in-out infinite;
	}

	.error-icon {
		width: 1.25rem;
		height: 1.25rem;
		flex-shrink: 0;
	}

	.input-icon {
		width: 1.25rem;
		height: 1.25rem;
		margin-right: 0.5rem;
		flex-shrink: 0;
	}

	.button-icon {
		width: 1.25rem;
		height: 1.25rem;
		flex-shrink: 0;
	}

	.arrow-icon {
		width: 1.125rem;
		height: 1.125rem;
		flex-shrink: 0;
		transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
	}

	.brand-title {
		font-size: 2rem;
		font-weight: 700;
		background: linear-gradient(135deg, #3B82F6, #A855F7);
		-webkit-background-clip: text;
		-webkit-text-fill-color: transparent;
		background-clip: text;
		margin-bottom: 0.5rem;
		animation: gradient-shift 3s ease infinite;
	}

	.brand-subtitle {
		color: #64748b;
		font-size: 0.95rem;
		font-weight: 500;
	}

	/* Error Container */
	.error-container {
		display: flex;
		align-items: center;
		gap: 0.75rem;
		padding: 1rem 1.25rem;
		background: linear-gradient(135deg, rgba(239, 68, 68, 0.1), rgba(220, 38, 38, 0.1));
		border: 1px solid rgba(239, 68, 68, 0.3);
		border-radius: 1rem;
		color: #DC2626;
		font-size: 0.9rem;
		font-weight: 500;
		margin-bottom: 1.5rem;
		animation: shake 0.4s ease;
	}

	/* Form Content */
	.form-content {
		display: flex;
		flex-direction: column;
		gap: 1.5rem;
	}

	/* Input Group */
	.input-group {
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
	}

	.input-label {
		display: flex;
		align-items: center;
		font-size: 0.9rem;
		font-weight: 600;
		color: #334155;
		transition: color 0.3s ease;
	}

	.input-wrapper {
		position: relative;
		transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
	}

	.input-wrapper::after {
		content: '';
		position: absolute;
		inset: 0;
		border-radius: 0.75rem;
		background: linear-gradient(135deg, #3B82F6, #A855F7);
		opacity: 0;
		transition: opacity 0.3s ease;
		pointer-events: none;
		padding: 2px;
		-webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
		-webkit-mask-composite: xor;
		mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
		mask-composite: exclude;
	}

	.input-wrapper.focused::after {
		opacity: 1;
	}

	.form-input {
		width: 100%;
		padding: 1rem 1.25rem;
		border: 2px solid rgba(148, 163, 184, 0.3);
		border-radius: 0.75rem;
		font-size: 1rem;
		background: rgba(255, 255, 255, 0.7);
		backdrop-filter: blur(10px);
		transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
		outline: none;
	}

	.form-input:focus {
		border-color: transparent;
		background: rgba(255, 255, 255, 0.9);
		transform: translateY(-2px);
		box-shadow: 0 8px 20px rgba(59, 130, 246, 0.15);
	}

	.form-input::placeholder {
		color: #94a3b8;
	}

	.form-input:disabled {
		opacity: 0.6;
		cursor: not-allowed;
	}

	/* Submit Button */
	.submit-button {
		position: relative;
		width: 100%;
		padding: 1.1rem 1.5rem;
		background: linear-gradient(135deg, #3B82F6, #2563EB);
		color: white;
		border: none;
		border-radius: 0.75rem;
		font-size: 1.05rem;
		font-weight: 600;
		cursor: pointer;
		overflow: hidden;
		transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
		box-shadow: 0 4px 15px rgba(59, 130, 246, 0.3);
	}

	.submit-button::before {
		content: '';
		position: absolute;
		inset: 0;
		background: linear-gradient(135deg, #2563EB, #1D4ED8);
		opacity: 0;
		transition: opacity 0.3s ease;
	}

	.submit-button:hover:not(:disabled)::before {
		opacity: 1;
	}

	.submit-button:hover:not(:disabled) {
		transform: translateY(-2px) scale(1.02);
		box-shadow: 0 10px 30px rgba(59, 130, 246, 0.4);
	}

	.submit-button:active:not(:disabled) {
		transform: translateY(0) scale(0.98);
	}

	.submit-button:disabled {
		opacity: 0.7;
		cursor: not-allowed;
	}

	.button-content {
		position: relative;
		display: flex;
		align-items: center;
		justify-content: center;
		gap: 0.5rem;
		z-index: 1;
	}

	.button-icon {
		width: 1.25rem;
		height: 1.25rem;
		flex-shrink: 0;
		margin-right: 0.5rem;
		transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
	}

	.submit-button:hover:not(:disabled) .button-icon {
		transform: translateX(4px);
	}

	/* Spinner */
	.spinner-container {
		position: relative;
		width: 20px;
		height: 20px;
	}

	.spinner-outer {
		position: absolute;
		width: 20px;
		height: 20px;
		border: 3px solid rgba(255, 255, 255, 0.3);
		border-top-color: white;
		border-radius: 50%;
		animation: spin 0.8s linear infinite;
	}

	.spinner-inner {
		position: absolute;
		inset: 3px;
		border: 2px solid rgba(255, 255, 255, 0.2);
		border-top-color: white;
		border-radius: 50%;
		animation: spin 0.6s linear infinite reverse;
	}

	/* Links Container */
	.links-container {
		text-align: center;
		padding-top: 0.5rem;
	}

	.link-text {
		color: #64748b;
		font-size: 0.9rem;
	}

	.link {
		color: #3B82F6;
		font-weight: 600;
		text-decoration: none;
		transition: all 0.3s ease;
		position: relative;
	}

	.link::after {
		content: '';
		position: absolute;
		bottom: -2px;
		left: 0;
		width: 0;
		height: 2px;
		background: linear-gradient(90deg, #3B82F6, #A855F7);
		transition: width 0.3s ease;
	}

	.link:hover {
		color: #2563EB;
	}

	.link:hover::after {
		width: 100%;
	}

	/* Divider */
	.divider {
		position: relative;
		margin: 2rem 0 1.5rem;
		text-align: center;
	}

	.divider::before {
		content: '';
		position: absolute;
		top: 50%;
		left: 0;
		right: 0;
		height: 1px;
		background: linear-gradient(90deg, transparent, rgba(148, 163, 184, 0.3), transparent);
	}

	.divider-text {
		position: relative;
		display: inline-block;
		padding: 0 1rem;
		background: rgba(255, 255, 255, 0.4);
		backdrop-filter: blur(10px);
		color: #94a3b8;
		font-size: 0.85rem;
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.05em;
	}

	/* Alternative Button */
	.alternative-button {
		display: flex;
		align-items: center;
		width: 100%;
		padding: 1.25rem 1.5rem;
		background: linear-gradient(135deg, rgba(168, 85, 247, 0.1), rgba(147, 51, 234, 0.1));
		border: 2px solid rgba(168, 85, 247, 0.3);
		border-radius: 1rem;
		color: #7E22CE;
		font-size: 1rem;
		font-weight: 600;
		cursor: pointer;
		transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
		overflow: hidden;
		position: relative;
	}

	.alternative-button::before {
		content: '';
		position: absolute;
		inset: 0;
		background: linear-gradient(135deg, rgba(168, 85, 247, 0.2), rgba(147, 51, 234, 0.2));
		opacity: 0;
		transition: opacity 0.3s ease;
	}

	.alternative-button:hover::before {
		opacity: 1;
	}

	.alternative-button:hover {
		transform: translateY(-2px) scale(1.01);
		box-shadow: 0 10px 30px rgba(168, 85, 247, 0.2);
		border-color: rgba(168, 85, 247, 0.5);
	}

	.alternative-button:hover .arrow-icon {
		transform: translateX(8px);
	}

	.button-text {
		flex: 1;
		text-align: left;
	}

	.button-title {
		display: block;
		font-weight: 600;
	}

	.button-subtitle {
		display: block;
		font-size: 0.875rem;
		opacity: 0.75;
	}

	/* Footer */
	.form-footer {
		margin-top: 2rem;
		text-align: center;
	}

	.footer-text {
		display: flex;
		align-items: center;
		justify-content: center;
		gap: 0.5rem;
		color: #94a3b8;
		font-size: 0.8rem;
	}

	.footer-text::before {
		content: '🔒';
		font-size: 1rem;
	}

	/* Loading Screen Styles */
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

	/* Animated Particles */
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
		background: #3B82F6;
	}

	.particle-2 {
		width: 6px;
		height: 6px;
		background: #A855F7;
	}

	.particle-3 {
		width: 3px;
		height: 3px;
		background: #22C55E;
	}

	.particle:nth-child(1) { top: 10%; left: 10%; }
	.particle:nth-child(2) { top: 20%; left: 80%; }
	.particle:nth-child(3) { top: 30%; left: 20%; }
	.particle:nth-child(4) { top: 40%; left: 70%; }
	.particle:nth-child(5) { top: 50%; left: 30%; }
	.particle:nth-child(6) { top: 60%; left: 90%; }
	.particle:nth-child(7) { top: 70%; left: 40%; }
	.particle:nth-child(8) { top: 80%; left: 60%; }
	.particle:nth-child(9) { top: 15%; left: 50%; }
	.particle:nth-child(10) { top: 85%; left: 15%; }
	.particle:nth-child(11) { top: 25%; left: 85%; }
	.particle:nth-child(12) { top: 75%; left: 25%; }
	.particle:nth-child(13) { top: 35%; left: 45%; }
	.particle:nth-child(14) { top: 65%; left: 75%; }
	.particle:nth-child(15) { top: 45%; left: 5%; }
	.particle:nth-child(16) { top: 55%; left: 95%; }
	.particle:nth-child(17) { top: 5%; left: 35%; }
	.particle:nth-child(18) { top: 95%; left: 65%; }
	.particle:nth-child(19) { top: 55%; left: 55%; }
	.particle:nth-child(20) { top: 75%; left: 85%; }

	/* Loading Content */
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
		background: radial-gradient(circle, rgba(59, 130, 246, 0.3) 0%, transparent 70%);
		animation: logoPulse 2s ease-in-out infinite;
	}

	.loading-brand {
		margin-bottom: 3rem;
	}

	.brand-main {
		font-size: 3rem;
		font-weight: 800;
		background: linear-gradient(135deg, #3B82F6, #A855F7, #22C55E, #F97316);
		-webkit-background-clip: text;
		-webkit-text-fill-color: transparent;
		background-clip: text;
		margin-bottom: 0.5rem;
		animation: textGlow 3s ease-in-out infinite alternate;
		text-shadow: 0 0 30px rgba(59, 130, 246, 0.5);
	}

	.brand-tagline {
		font-size: 1.5rem;
		font-weight: 600;
		color: #94a3b8;
		letter-spacing: 0.1em;
	}

	/* Progress Bar */
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
		background: linear-gradient(90deg, #3B82F6, #A855F7, #22C55E);
		border-radius: 3px;
		transition: width 0.8s cubic-bezier(0.4, 0, 0.2, 1);
		position: relative;
	}

	.progress-fill::after {
		content: '';
		position: absolute;
		top: 0;
		left: 0;
		bottom: 0;
		right: 0;
		background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.4), transparent);
		animation: progressShine 2s ease-in-out infinite;
	}

	.progress-glow {
		position: absolute;
		top: 0;
		left: 0;
		height: 100%;
		background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.6), transparent);
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
		color: #3B82F6;
		font-size: 1.2rem;
		font-weight: 700;
		font-variant-numeric: tabular-nums;
	}

	/* Loading Dots */
	.loading-dots {
		display: flex;
		justify-content: center;
		gap: 0.5rem;
		margin-top: 1rem;
	}

	.dot {
		width: 8px;
		height: 8px;
		border-radius: 50%;
		background: #3B82F6;
		animation: dotBounce 1.4s ease-in-out infinite both;
	}

	.dot-1 { animation-delay: -0.32s; }
	.dot-2 { animation-delay: -0.16s; }
	.dot-3 { animation-delay: 0s; }

	/* Background Orbs */
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
		background: #3B82F6;
		top: 10%;
		left: 10%;
		animation-delay: 0s;
	}

	.orb-2 {
		width: 300px;
		height: 300px;
		background: #A855F7;
		top: 60%;
		right: 10%;
		animation-delay: 2s;
	}

	.orb-3 {
		width: 150px;
		height: 150px;
		background: #22C55E;
		bottom: 20%;
		left: 20%;
		animation-delay: 4s;
	}

	.orb-4 {
		width: 250px;
		height: 250px;
		background: #F97316;
		top: 30%;
		right: 30%;
		animation-delay: 1s;
	}

	/* Animations */
	@keyframes loadingFadeIn {
		0% { opacity: 0; }
		100% { opacity: 1; }
	}

	@keyframes loadingFadeOut {
		0% { opacity: 1; transform: scale(1); }
		100% { opacity: 0; transform: scale(1.1); }
	}

	@keyframes logoRotate {
		0%, 100% { transform: rotate(0deg) scale(1); }
		25% { transform: rotate(5deg) scale(1.05); }
		50% { transform: rotate(-5deg) scale(0.95); }
		75% { transform: rotate(3deg) scale(1.02); }
	}

	@keyframes logoPulse {
		0%, 100% {
			transform: scale(1);
			opacity: 0.5;
		}
		50% {
			transform: scale(1.2);
			opacity: 0.8;
		}
	}

	@keyframes textGlow {
		0% { filter: drop-shadow(0 0 10px rgba(59, 130, 246, 0.5)); }
		100% { filter: drop-shadow(0 0 20px rgba(59, 130, 246, 0.8)); }
	}

	@keyframes progressShine {
		0% { transform: translateX(-100%); }
		100% { transform: translateX(100%); }
	}

	@keyframes progressGlow {
		0%, 100% { opacity: 0; transform: translateX(-50%); }
		50% { opacity: 1; transform: translateX(50%); }
	}

	@keyframes textFade {
		0% { opacity: 0; transform: translateY(10px); }
		100% { opacity: 1; transform: translateY(0); }
	}

	@keyframes dotBounce {
		0%, 80%, 100% {
			transform: scale(0.8);
			opacity: 0.6;
		}
		40% {
			transform: scale(1.2);
			opacity: 1;
		}
	}

	@keyframes dotPulse {
		0%, 100% {
			opacity: 0.2;
			transform: scale(1);
		}
		50% {
			opacity: 0.6;
			transform: scale(1.2);
		}
	}

	@keyframes overlayShift {
		0%, 100% {
			background-position: 0% 0%;
		}
		25% {
			background-position: 100% 0%;
		}
		50% {
			background-position: 100% 100%;
		}
		75% {
			background-position: 0% 100%;
		}
	}

	/* Animations */
	@keyframes float {
		0%, 100% { transform: translateY(0) rotate(0deg); }
		50% { transform: translateY(-20px) rotate(5deg); }
	}

	@keyframes float-delayed {
		0%, 100% { transform: translateY(0) rotate(0deg); }
		50% { transform: translateY(-30px) rotate(-5deg); }
	}

	@keyframes float-slow {
		0%, 100% { transform: translateY(0) rotate(0deg); }
		50% { transform: translateY(-15px) rotate(3deg); }
	}

	@keyframes spin {
		to { transform: rotate(360deg); }
	}

	@keyframes shake {
		0%, 100% { transform: translateX(0); }
		25% { transform: translateX(-5px); }
		75% { transform: translateX(5px); }
	}

	@keyframes gradient-shift {
		0%, 100% { background-position: 0% 50%; }
		50% { background-position: 100% 50%; }
	}

	@keyframes pulse-slow {
		0%, 100% { opacity: 1; }
		50% { opacity: 0.5; }
	}

	/* Responsive Design */
	@media (max-width: 640px) {
		.form-wrapper {
			padding: 2rem 1.5rem;
			border-radius: 1.5rem;
		}

		.brand-title {
			font-size: 1.75rem;
		}

		.form-input {
			padding: 0.9rem 1rem;
		}

		.submit-button {
			padding: 1rem 1.25rem;
		}
	}

	/* Reduced Motion Support */
	@media (prefers-reduced-motion: reduce) {
		*, *::before, *::after {
			animation-duration: 0.01ms !important;
			animation-iteration-count: 1 !important;
			transition-duration: 0.01ms !important;
		}
	}
</style>