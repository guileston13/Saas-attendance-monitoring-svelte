# Apply Section Subjects Schedule Migration
# This script applies the section_subjects schedule migration to the database

Write-Host "=== Section Subjects Schedule Migration ===" -ForegroundColor Cyan
Write-Host ""

$dbHost = "localhost"
$dbUser = "root"
$dbPassword = "Adrian01*"
$dbName = "school_management"
$sqlFile = "section-subjects-schedule-migration.sql"

Write-Host "Applying migration to database: $dbName" -ForegroundColor Yellow
Write-Host ""

# Check if MySQL is available
try {
    $mysqlPath = Get-Command mysql -ErrorAction Stop
    Write-Host "MySQL found at: $($mysqlPath.Source)" -ForegroundColor Green
} catch {
    Write-Host "ERROR: MySQL not found in PATH" -ForegroundColor Red
    Write-Host "Please install MySQL or add it to your PATH" -ForegroundColor Yellow
    exit 1
}

# Apply the migration
Write-Host "Executing migration..." -ForegroundColor Yellow
$command = "mysql -h $dbHost -u $dbUser -p$dbPassword $dbName < $sqlFile"

try {
    Invoke-Expression $command
    Write-Host ""
    Write-Host "Migration applied successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "The following fields have been added to the section_subjects table:" -ForegroundColor Cyan
    Write-Host "  - Monday (TINYINT)" -ForegroundColor White
    Write-Host "  - Tuesday (TINYINT)" -ForegroundColor White
    Write-Host "  - Wednesday (TINYINT)" -ForegroundColor White
    Write-Host "  - Thursday (TINYINT)" -ForegroundColor White
    Write-Host "  - Friday (TINYINT)" -ForegroundColor White
    Write-Host ""
    Write-Host "StartTime, EndTime, TeacherID already exist in the table." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "You can now edit section subjects with schedule information!" -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "ERROR: Failed to apply migration" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Yellow
    exit 1
}
