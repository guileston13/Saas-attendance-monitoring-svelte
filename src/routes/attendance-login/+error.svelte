<script>
  import { page } from '$app/stores';
</script>

<svelte:head>
  <title>Access Denied - Attendance System</title>
</svelte:head>

<div class="error-container">
  <div class="error-content">
    <h1>🚫 Access Denied</h1>
    <p>This attendance system is restricted to authorized devices and locations only.</p>

    {#if $page.status === 403}
      <div class="error-details">
        <p><strong>Reason:</strong> Your IP address is not authorized to access this system.</p>
        <p>Please contact your system administrator if you believe this is an error.</p>
      </div>
    {/if}

    <button on:click={() => window.history.back()} class="back-btn">
      ← Go Back
    </button>
  </div>
</div>

<style>
  .error-container {
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    padding: 20px;
  }

  .error-content {
    background: white;
    border-radius: 12px;
    padding: 2rem;
    box-shadow: 0 10px 30px rgba(0,0,0,0.3);
    text-align: center;
    max-width: 500px;
    width: 100%;
  }

  h1 {
    color: #dc3545;
    margin-bottom: 1rem;
    font-size: 2.5rem;
  }

  p {
    color: #666;
    margin-bottom: 1rem;
    line-height: 1.6;
  }

  .error-details {
    background: #f8f9fa;
    border: 1px solid #dee2e6;
    border-radius: 8px;
    padding: 1rem;
    margin: 1.5rem 0;
    text-align: left;
  }

  .error-details p {
    margin: 0.5rem 0;
    font-size: 0.9rem;
  }

  .back-btn {
    background: #007bff;
    color: white;
    border: none;
    padding: 12px 24px;
    border-radius: 6px;
    font-size: 1rem;
    cursor: pointer;
    transition: background 0.2s;
  }

  .back-btn:hover {
    background: #0056b3;
  }
</style>