# Define the list of problematic KBs and the target DLL paths.
$KBs = @("KB5064081", "KB5064401", "KB5064081.1", "KB5065426")
$dllPath = "C:\Windows\assembly\GAC_32\Microsoft.Ink\6.1.0.0__31bf3856ad364e35\Microsoft.Ink.dll"
$backupPath = "$dllPath.bak"
$githubUrl = "https://raw.githubusercontent.com/cdetcc/etcc/main/Microsoft.Ink.dll"
$downloadPath = "C:\Temp\Microsoft.Ink.dll"

# Check for installed KBs.
Write-Host "Checking for problematic Windows updates..."
$updateFound = $false
foreach ($kb in $KBs) {
    if ((Get-HotFix -Id $kb -ErrorAction SilentlyContinue) -ne $null) {
        Write-Host "Found installed update: $kb"
        $updateFound = $true
        break
    }
}

# Proceed only if a problematic update is found.
if (-not $updateFound) {
    Write-Host "No problematic updates found. Exiting script."
    exit
}

# Proceed with file replacement.
if (-not (Test-Path -Path $dllPath)) {
    Write-Host "The specified DLL was not found at $dllPath. Exiting."
    exit
}

# Rename the original DLL to a .bak file.
try {
    Write-Host "Renaming original DLL..."
    Rename-Item -Path $dllPath -NewName $backupPath -Force
    Write-Host "Original DLL successfully renamed to $backupPath."
} catch {
    Write-Host "Failed to rename the original DLL. Check for permissions or if the file is in use. Exiting."
    exit
}

# Download the new DLL from GitHub.
try {
    Write-Host "Downloading new DLL from GitHub..."
    Invoke-WebRequest -Uri $githubUrl -OutFile $downloadPath
    Write-Host "New DLL successfully downloaded to $downloadPath."
} catch {
    Write-Host "Failed to download the new DLL from GitHub. Check your internet connection or the URL. Exiting."
    exit
}

# Copy the new DLL to the original location.
try {
    Write-Host "Copying new DLL to the target location..."
    Copy-Item -Path $downloadPath -Destination $dllPath -Force
    Write-Host "New DLL successfully copied to $dllPath."
} catch {
    Write-Host "Failed to copy the new DLL. Exiting."
    exit
}

# Clean up the downloaded file.
Remove-Item -Path $downloadPath -Force
Write-Host "Cleanup complete."

Write-Host "Script finished successfully! 🎉"