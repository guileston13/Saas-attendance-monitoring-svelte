<script>
  // Attendance login layout - no sidebar, full screen
</script>

<svelte:head>
  <title>Attendance Login - School Management System</title>
</svelte:head>

<div class="attendance-layout">
  <slot />
</div>

<style>
  .attendance-layout {
    min-height: 100vh;
    background: #f9f9f9;
    display: flex;
    justify-content: center;
    align-items: center;
  }
</style>