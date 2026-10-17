$ErrorActionPreference = 'Stop'

# ==============================================================================
# Configuration - UPDATE THESE VARIABLES
# ==============================================================================
$GitHubOwner = "movva-tech"
$GitHubRepo = "movva-cli"
$BinaryName = "movva"
# Installs to C:\Users\<User>\AppData\Local\movva
$InstallDir = Join-Path $env:LOCALAPPDATA $BinaryName
# ==============================================================================

Write-Host "Installing $BinaryName for Windows..." -ForegroundColor Cyan

# 1. Detect Architecture
$Arch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "x86_64" }
Write-Host "Detected Architecture: Windows ($Arch)"

# 2. Fetch the latest release version via HTTP redirect (Bypasses API rate limits)
Write-Host "Fetching latest release version..."
$LatestUrl = "https://github.com/$GitHubOwner/$GitHubRepo/releases/latest"

try {
    # We intentionally stop the redirect to capture the target URL from the headers
    $Response = Invoke-WebRequest -Uri $LatestUrl -MaximumRedirection 0 -ErrorAction Ignore
    $Location = $Response.Headers.Location
    
    if (-not $Location) {
        throw "No redirect location found."
    }
    
    # Extract the tag name from the end of the URL
    $Version = Split-Path $Location -Leaf
} catch {
    Write-Error "Failed to fetch latest version from GitHub."
    exit 1
}

if (-not $Version) {
    Write-Error "Could not determine the latest version."
    exit 1
}

Write-Host "Latest version found: $Version" -ForegroundColor Green

# 3. Construct the download URL
# Expected format based on the GoReleaser config: movva_Windows_x86_64.zip
$FileName = "${BinaryName}_Windows_${Arch}.zip"
$DownloadUrl = "https://github.com/$GitHubOwner/$GitHubRepo/releases/download/$Version/$FileName"

# 4. Download and Extract
$TempZip = Join-Path $env:TEMP $FileName
Write-Host "Downloading $FileName..."
Invoke-WebRequest -Uri $DownloadUrl -OutFile $TempZip

Write-Host "Extracting archive..."
if (!(Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
}

# Expand the zip file into the installation directory
Expand-Archive -Path $TempZip -DestinationPath $InstallDir -Force
Remove-Item $TempZip -Force

# 5. Add to User PATH if it's not already there
$UserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($UserPath -notlike "*$InstallDir*") {
    Write-Host "Adding $InstallDir to your User PATH..."
    $NewPath = "$InstallDir;$UserPath"
    [Environment]::SetEnvironmentVariable("PATH", $NewPath, "User")
    Write-Host "PATH updated. (You may need to restart your terminal for changes to take effect)" -ForegroundColor Yellow
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "$BinaryName $Version was successfully installed!" -ForegroundColor Green
Write-Host "Run '$BinaryName --help' to get started."
Write-Host "========================================" -ForegroundColor Cyan
