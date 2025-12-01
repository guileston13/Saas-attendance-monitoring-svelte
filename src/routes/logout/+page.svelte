<script>
	import { onMount } from 'svelte';
	import { goto, invalidateAll } from '$app/navigation';
	
	onMount(async () => {
		// Invalidate all data to force refresh of layout
		await invalidateAll();
		// Redirect to login after a brief moment to ensure session is cleared
		setTimeout(() => {
			goto('/login', { replaceState: true });
		}, 100);
	});
</script>

<div class="logout-container">
	<div class="logout-message">
		<h2>Logging out...</h2>
		<p>Please wait while we sign you out.</p>
	</div>
</div>

<style>
	.logout-container {
		display: flex;
		justify-content: center;
		align-items: center;
		min-height: 50vh;
	}
	
	.logout-message {
		text-align: center;
		padding: 2rem;
		background: white;
		border-radius: 8px;
		box-shadow: 0 2px 10px rgba(0,0,0,0.1);
	}
	
	.logout-message h2 {
		margin: 0 0 1rem 0;
		color: #2c3e50;
	}
	
	.logout-message p {
		margin: 0;
		color: #7f8c8d;
	}
</style>