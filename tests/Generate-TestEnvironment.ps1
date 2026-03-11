<#
.SYNOPSIS
    Generates a test environment on the Desktop with dummy files for testing the FolderOrganizer application.
.DESCRIPTION
    This script dynamically creates a directory on the current user's Desktop named "FolderOrganizer_TestEnv".
    Inside this directory, it creates 0-byte or small text files corresponding to all supported file extensions
    defined in the Folder Organizer project. This allows for quick, robust testing of the application's categorization logic.
#>

$desktopPath = [Environment]::GetFolderPath("Desktop")
$testEnvPath = Join-Path $desktopPath "FolderOrganizer_TestEnv"

if (-not (Test-Path $testEnvPath)) {
    Write-Host "Creating test environment directory: $testEnvPath"
    New-Item -ItemType Directory -Path $testEnvPath | Out-Null
} else {
    Write-Host "Test environment directory already exists: $testEnvPath"
}

# Master list of all extensions supported in FolderOrganizerV2.bat
$extensions = @(
    ".pdf", ".doc", ".docx", ".xls", ".xlsx", ".csv", ".ppt", ".pptx", ".txt", ".rtf", ".md",
    ".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp", ".svg", ".heic", ".raw",
    ".mp4", ".mov", ".avi", ".mkv", ".wmv", ".flv", ".m4v", ".webm",
    ".mp3", ".wav", ".flac", ".aac", ".ogg", ".wma", ".m4a",
    ".exe", ".msi", ".msix", ".appx", ".dmg", ".pkg", ".deb", ".rpm",
    ".zip", ".rar", ".7z", ".tar", ".gz", ".bz2", ".xz",
    ".py", ".js", ".ts", ".html", ".css", ".json", ".xml", ".sql", ".sh", ".bat", ".ps1",
    ".ttf", ".otf", ".woff", ".woff2",
    ".torrent"
)

$createdCount = 0

foreach ($ext in $extensions) {
    # Generate a dummy file name like "dummy_file_pdf.pdf"
    $cleanExt = $ext.Substring(1)
    $fileName = "dummy_file_$cleanExt$ext"
    $filePath = Join-Path $testEnvPath $fileName
    
    if (-not (Test-Path $filePath)) {
        Set-Content -Path $filePath -Value "This is a dummy test file for the $ext extension."
        $createdCount++
    }
}

Write-Host "`nTest Environment Generation Complete!"
Write-Host "Generated $createdCount new dummy files in: $testEnvPath"
Write-Host "You can now test FolderOrganizer by selecting this directory."
