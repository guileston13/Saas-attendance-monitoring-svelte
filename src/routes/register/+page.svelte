<script>
	// Register page component
	import { enhance } from '$app/forms';
	import { goto } from '$app/navigation';
	
	/** @type {import('./$types').ActionData} */
	export let form;
	
	let loading = false;
	
	const yearLevels = [
		'Grade 7', 'Grade 8', 'Grade 9', 'Grade 10', 'Grade 11', 'Grade 12'
	];
</script>

<div class="auth-container">
	<div class="form-container">
		<h2 class="text-center mb-2">School Management System</h2>
		<h3 class="text-center mb-2">Student Registration</h3>
		
		{#if form?.error}
			<div class="error-message mb-1">{form.error}</div>
		{/if}
		
		{#if form?.success}
			<div class="success-message mb-1">Registration successful! Please login.</div>
		{/if}
		
		<form method="POST" use:enhance={() => {
			loading = true;
			return async ({ result }) => {
				loading = false;
				if (result.type === 'redirect') {
					goto(result.location);
				}
			};
		}}>
			<div class="form-group">
				<label for="studentId">Student ID:</label>
				<input
					type="text"
					id="studentId"
					name="studentId"
					required
					disabled={loading}
					value={form?.studentId || ''}
					placeholder="e.g., 2024001"
				/>
			</div>
			
			<div class="form-group">
				<label for="firstName">First Name:</label>
				<input
					type="text"
					id="firstName"
					name="firstName"
					required
					disabled={loading}
					value={form?.firstName || ''}
				/>
			</div>
			
			<div class="form-group">
				<label for="lastName">Last Name:</label>
				<input
					type="text"
					id="lastName"
					name="lastName"
					required
					disabled={loading}
					value={form?.lastName || ''}
				/>
			</div>
			
			<div class="form-group">
				<label for="middleName">Middle Name:</label>
				<input
					type="text"
					id="middleName"
					name="middleName"
					disabled={loading}
					value={form?.middleName || ''}
				/>
			</div>
			
			<div class="form-group">
				<label for="yearLevel">Year Level:</label>
				<select
					id="yearLevel"
					name="yearLevel"
					required
					disabled={loading}
				>
					<option value="">Select Year Level</option>
					{#each yearLevels as level}
						<option value={level} selected={form?.yearLevel === level}>
							{level}
						</option>
					{/each}
				</select>
			</div>
			
			<div class="form-group">
				<label for="email">Email:</label>
				<input
					type="email"
					id="email"
					name="email"
					required
					disabled={loading}
					value={form?.email || ''}
				/>
			</div>
			
			<div class="form-group">
				<label for="password">Password:</label>
				<input
					type="password"
					id="password"
					name="password"
					required
					disabled={loading}
					minlength="6"
				/>
			</div>
			
			<div class="form-group">
				<label for="confirmPassword">Confirm Password:</label>
				<input
					type="password"
					id="confirmPassword"
					name="confirmPassword"
					required
					disabled={loading}
					minlength="6"
				/>
			</div>
			
			<div class="form-group">
				<button type="submit" class="btn btn-primary" disabled={loading} style="width: 100%;">
					{#if loading}
						<span class="spinner"></span>
					{/if}
					Register
				</button>
			</div>
			
			<div class="text-center mt-1">
				<p>Already have an account? <a href="/login">Login here</a></p>
			</div>
		</form>
	</div>
</div>

<style>
	.auth-container {
		min-height: 100vh;
		display: flex;
		justify-content: center;
		align-items: center;
		padding: 1rem;
	}
	
	.success-message {
		background: #d4edda;
		color: #155724;
		padding: 0.75rem;
		border-radius: 4px;
		border: 1px solid #c3e6cb;
		font-size: 0.9rem;
	}
	
	a {
		color: #3498db;
		text-decoration: none;
	}
	
	a:hover {
		text-decoration: underline;
	}
</style>