<script>
	export let items = [];
	export let onNavigate = () => {};
	
	function handleClick(item, index) {
		if (item.clickable !== false && item.action) {
			onNavigate(item, index);
		}
	}
</script>

<nav class="breadcrumb-nav" aria-label="breadcrumb">
	<ol class="breadcrumb-list">
		{#each items as item, index}
			<li class="breadcrumb-item" class:active={item.active}>
				{#if item.clickable !== false && !item.active}
					<button 
						class="breadcrumb-link"
						on:click={() => handleClick(item, index)}
						type="button"
					>
						{#if item.icon}
							<span class="breadcrumb-icon">{item.icon}</span>
						{/if}
						{item.label}
					</button>
				{:else}
					<span class="breadcrumb-text">
						{#if item.icon}
							<span class="breadcrumb-icon">{item.icon}</span>
						{/if}
						{item.label}
					</span>
				{/if}
				
				{#if index < items.length - 1}
					<span class="breadcrumb-separator" aria-hidden="true">›</span>
				{/if}
			</li>
		{/each}
	</ol>
</nav>

<style>
	.breadcrumb-nav {
		background: white;
		border-radius: 8px;
		box-shadow: 0 2px 4px rgba(0,0,0,0.1);
		padding: 1rem 1.5rem;
		margin-bottom: 1.5rem;
	}
	
	.breadcrumb-list {
		display: flex;
		align-items: center;
		flex-wrap: wrap;
		gap: 0.5rem;
		margin: 0;
		padding: 0;
		list-style: none;
	}
	
	.breadcrumb-item {
		display: flex;
		align-items: center;
		gap: 0.5rem;
	}
	
	.breadcrumb-link {
		background: none;
		border: none;
		color: #3498db;
		cursor: pointer;
		font-size: 1rem;
		text-decoration: underline;
		padding: 0.25rem 0.5rem;
		border-radius: 4px;
		transition: all 0.2s ease;
		display: flex;
		align-items: center;
		gap: 0.5rem;
	}
	
	.breadcrumb-link:hover {
		background: #f8f9fa;
		color: #2980b9;
		text-decoration: none;
	}
	
	.breadcrumb-text {
		color: #6c757d;
		font-weight: 500;
		font-size: 1rem;
		display: flex;
		align-items: center;
		gap: 0.5rem;
	}
	
	.breadcrumb-item.active .breadcrumb-text {
		color: #2c3e50;
		font-weight: 600;
	}
	
	.breadcrumb-icon {
		font-size: 0.9rem;
	}
	
	.breadcrumb-separator {
		color: #dee2e6;
		font-size: 1.2rem;
		font-weight: normal;
		margin: 0 0.25rem;
		user-select: none;
	}
	
	@media (max-width: 768px) {
		.breadcrumb-nav {
			padding: 0.75rem 1rem;
		}
		
		.breadcrumb-link,
		.breadcrumb-text {
			font-size: 0.9rem;
		}
		
		.breadcrumb-list {
			gap: 0.25rem;
		}
		
		.breadcrumb-separator {
			margin: 0 0.125rem;
		}
	}
</style>