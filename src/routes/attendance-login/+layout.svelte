<script>
  // Attendance login layout - no sidebar, full screen
  // No props needed - this is just a layout wrapper
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
    background: transparent;
    display: flex;
    justify-content: center;
    align-items: center;
  }
</style>