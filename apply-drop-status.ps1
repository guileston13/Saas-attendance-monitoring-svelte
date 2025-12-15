# Apply Drop Status Migration
# Adds 'Drop' status to attendance_records table

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Apply Drop Status Migration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Database configuration
$dbHost = "localhost"
$dbName = "school_management"
$dbUser = "root"
$dbPass = ""  # Change if you have a password

# Path to SQL file
$sqlFile = Join-Path $PSScriptRoot "add-drop-status.sql"

if (-not (Test-Path $sqlFile)) {
    Write-Host "Error: SQL file not found at $sqlFile" -ForegroundColor Red
    exit 1
}

Write-Host "Applying migration..." -ForegroundColor Yellow
Write-Host "SQL File: $sqlFile" -ForegroundColor Gray
Write-Host ""

try {
    # Execute the SQL file using mysql command
    if ($dbPass) {
        Get-Content $sqlFile | mysql -h $dbHost -u $dbUser -p$dbPass $dbName
    } else {
        Get-Content $sqlFile | mysql -h $dbHost -u $dbUser $dbName
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Migration applied successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "The 'Drop' status has been added to attendance_records table." -ForegroundColor Green
        Write-Host "Students with 3 consecutive absences can now be marked as 'Dropped' (💣)." -ForegroundColor Green
    } else {
        Write-Host "✗ Migration failed with exit code: $LASTEXITCODE" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Error applying migration: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Migration Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
