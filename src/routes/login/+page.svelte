<script>
	/** @type {import('./$types').ActionData} */
	export let form;
	
	let loading = false;
</script>


<div class="auth-container">
   <div class="form-container">
	   <h2 class="text-center mb-2">School Management System</h2>
	   <h3 class="text-center mb-2">Login</h3>
       
	   {#if form?.error}
		   <div class="error-message mb-1">{form.error}</div>
	   {/if}
       
	   <!-- Simple form without enhance - let browser handle redirect naturally -->
	   <form method="POST">
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
			   />
		   </div>
           
		   <div class="form-group">
			   <button type="submit" class="btn btn-primary" disabled={loading} style="width: 100%;">
				   {#if loading}
					   <span class="spinner"></span>
				   {/if}
				   Login
			   </button>
		   </div>
           
		   <div class="text-center mt-1">
			   <p>Don't have an account? <a href="/register">Register here</a></p>
			   <p><a href="/dashboard">Test Dashboard Access</a></p>
		   </div>
	   </form>

	   <div class="text-center mt-3">
		   <button class="btn btn-secondary" style="width: 100%; margin-top: 2rem;" on:click={() => window.location.href = '/attendance-login'}>
			   Screen Login
		   </button>
	   </div>
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
	
	a {
		color: #3498db;
		text-decoration: none;
	}
	
	a:hover {
		text-decoration: underline;
	}
</style>