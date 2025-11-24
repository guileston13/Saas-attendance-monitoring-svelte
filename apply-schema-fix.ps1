#!/usr/bin/env pwsh
# Apply schema fix for section_subjects table

Write-Host "Applying schema fix for section_subjects table..." -ForegroundColor Cyan

# Get MySQL credentials
$mysqlUser = Read-Host "Enter MySQL username (default: root)"
if ([string]::IsNullOrWhiteSpace($mysqlUser)) {
    $mysqlUser = "root"
}

$mysqlPassword = Read-Host "Enter MySQL password" -AsSecureString
$mysqlPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($mysqlPassword)
)

$database = "school_management"

Write-Host "`nApplying migration..." -ForegroundColor Yellow

# Try to find mysql executable
$mysqlPath = Get-Command mysql -ErrorAction SilentlyContinue
if (-not $mysqlPath) {
    # Try common installation paths
    $commonPaths = @(
        "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe",
        "C:\Program Files\MySQL\MySQL Server 5.7\bin\mysql.exe",
        "C:\xampp\mysql\bin\mysql.exe",
        "C:\wamp64\bin\mysql\mysql8.0.27\bin\mysql.exe"
    )
    
    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            $mysqlPath = $path
            break
        }
    }
    
    if (-not $mysqlPath) {
        Write-Host "Error: MySQL executable not found. Please install MySQL or add it to PATH." -ForegroundColor Red
        exit 1
    }
}

# Apply the migration
$migrationFile = "fix-section-subjects-schema.sql"
if (-not (Test-Path $migrationFile)) {
    Write-Host "Error: Migration file '$migrationFile' not found." -ForegroundColor Red
    exit 1
}

try {
    # Execute the migration
    $process = Start-Process -FilePath $mysqlPath -ArgumentList "-u", $mysqlUser, "-p$mysqlPasswordPlain", "<", $migrationFile -Wait -NoNewWindow -PassThru
    
    if ($process.ExitCode -eq 0) {
        Write-Host "`nMigration applied successfully!" -ForegroundColor Green
        Write-Host "`nThe section_subjects table now includes:" -ForegroundColor Cyan
        Write-Host "  - Per-day start times (MondayStart, TuesdayStart, etc.)" -ForegroundColor White
        Write-Host "  - Per-day end times (MondayEnd, TuesdayEnd, etc.)" -ForegroundColor White
        Write-Host "  - Per-day teacher assignments (MondayTeacher, TuesdayTeacher, etc.)" -ForegroundColor White
    } else {
        Write-Host "`nMigration failed with exit code $($process.ExitCode)" -ForegroundColor Red
        Write-Host "Please check your MySQL credentials and database connection." -ForegroundColor Yellow
    }
} catch {
    Write-Host "`nError applying migration: $_" -ForegroundColor Red
    Write-Host "You can apply it manually using:" -ForegroundColor Yellow
    Write-Host "mysql -u $mysqlUser -p $database < $migrationFile" -ForegroundColor White
}
