param (
    [switch]$InstallPrerequisites = $true
)

if ($InstallPrerequisites -and -not (Get-Module -ListAvailable -Name ps2exe)) {
    Write-Host "Installing ps2exe module..." -ForegroundColor Cyan
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser -ErrorAction Stop
    Install-Module -Name ps2exe -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
}

$sourceFile = "src\FolderOrganizer.ps1"
$outputFile = "bin\FolderOrganizer.exe"
$iconFile   = "assets\logo.ico"

if (-not (Test-Path "bin")) { New-Item -ItemType Directory -Path "bin" | Out-Null }

Write-Host "Compiling $sourceFile to $outputFile..." -ForegroundColor Cyan

# Use ps2exe module
if (Get-Command Invoke-PS2EXE -ErrorAction SilentlyContinue) {
    # Changed parameters: Removed -WindowStyle Hidden as -NoConsole achieves the UI only effect
    Invoke-PS2EXE -InputFile $sourceFile -OutputFile $outputFile -IconFile $iconFile -NoConsole -NoOutput -x86 -x64 -RequireAdmin
} else {
    Write-Host "ps2exe module not available. Failed to compile." -ForegroundColor Red
}

if (Test-Path $outputFile) {
    Write-Host "Build Complete: $outputFile" -ForegroundColor Green
} else {
    Write-Host "Build Failed." -ForegroundColor Red
}
