# Define the list of problematic KBs
$problemKBs = @("KB5064081", "KB5064401", "KB5065426")

# Uninstall each problematic KB
foreach ($kb in $problemKBs) {
    Write-Host "Attempting to uninstall $kb..."
    try {
        # The wusa.exe command is used to uninstall Windows updates
        Start-Process wusa.exe -ArgumentList "/uninstall /kb:$($kb.Substring(2)) /quiet /norestart" -Wait -PassThru
        Write-Host "Successfully uninstalled $kb"
    }
    catch {
        Write-Host "Failed to uninstall $kb. It may not be installed."
    }
}

# Pause Windows updates for two weeks
$regPath = "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"
$pauseDate = (Get-Date).AddDays(14).ToString("yyyy-MM-ddT00:00:00Z")
Write-Host "Pausing Windows Updates until $pauseDate"

# Set the registry key to pause updates
try {
    # Check if the registry path exists, create it if not
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }

    Set-ItemProperty -Path $regPath -Name "PauseUntil" -Value $pauseDate -Type String -Force
    Set-ItemProperty -Path $regPath -Name "PauseFeatureUpdatesStartTime" -Value (Get-Date).ToString("yyyy-MM-ddT00:00:00Z") -Type String -Force
    Set-ItemProperty -Path $regPath -Name "PauseQualityUpdatesStartTime" -Value (Get-Date).ToString("yyyy-MM-ddT00:00:00Z") -Type String -Force
    Write-Host "Successfully paused Windows Updates."
}
catch {
    Write-Host "Failed to set the Windows Update registry key. $_"
}

Write-Host "Remediation complete."