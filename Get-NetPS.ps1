<#
.Synopsis
    Enumerating all installed .NET Framework and .NET Core versions
.DESCRIPTION
    Enumerating all installed .NET Framework and .NET Core versions
    As a bonus, it also checks if PowerShell Core is installed
.EXAMPLE
   .\Get-NetPS.ps1
.NOTES
   Author: Bastiaan Bakker (bastiaan@oranjeit.nl / info@sysups.nl)
   Version history:
     14-02-2019 - Bastiaan Bakker - Initial version
     15-02-2019 - Bastiaan Bakker - Added displaying powershell classic
#>

#INIT Transcript Logging
try { Stop-Transcript -ErrorAction SilentlyContinue | Out-Null } catch [System.InvalidOperationException] {}
Start-Transcript -path "$($PSScriptRoot)\Logs\$($MyInvocation.MyCommand.Name -replace '\.ps1$','.transcript.log')" -Force
$ErrorActionPreference = "Continue"
$VerbosePreference = "Continue"


#INIT functions
#function write-log
#writes a line to the logfile
Function Write-Log {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [string]$Message,

    [Parameter()]
    [string]$Path = $LogFile
  )

  Add-content -Path $Path -value "$(get-date -format 'yyyy-MM-dd HH:mm:ss') $($Message)"
}

#INIT Logfile
#logfile rotation
$LogRoot = "$($PSScriptRoot)\Logs\$($MyInvocation.MyCommand.name -replace '\.ps1$','')" 
foreach ($file in (get-item -path "$($LogRoot)*.log").FullName) {
  if ((get-item -Path $file).LastAccessTime -lt (Get-date).AddDays(-180)) {
    Remove-Item -Path $file -Force -ErrorAction SilentlyContinue
  }
}

$LogFile = "$($LogRoot)_$(get-date -format 'yyyy-MM').log"
New-Item -Path (Split-Path -Path $LogFile -Parent) -ItemType Directory -ErrorAction SilentlyContinue

write-log "Starting work..."

Clear-Host

# INIT variables
$Computer = $env:computername
$psversion = Get-Host | Select-Object Version | Format-Table -hide | out-string
$psversion = $psversion.Split([Environment]::NewLine, [StringSplitOptions]::RemoveEmptyEntries)
$psversion = $psversion.TrimEnd()

$netVersions = Get-Item "$Env:WinDir\Microsoft.NET\Framework\v*" | Select-Object Name | Format-Table -hide | Out-String
$netVersions = $netVersions.Split([Environment]::NewLine, [StringSplitOptions]::RemoveEmptyEntries)
$netVersions = $netVersions.TrimEnd()

write-log "Storing .NET core version in variable"
try {
  $netCore = (dotnet.exe --version)
}
catch {
  Write-Log ("ERROR: " + $_.Exception.Message)
}

write-log "Storing PowerShell Core version in variable"
try {
  $pwshCore = (pwsh.exe -version)
}
catch {
  Write-Log ("ERROR: " + $_.Exception.Message)
}

# Displaying computernamame being checked
Write-Host "Checking" $Computer`r`n

write-log "Starting the loop through all .NEt Framework versions"
# Looping through all the availlable versions
Foreach ($version in $netVersions) {
  
  $checkFile = -join ("$Env:WinDir\Microsoft.NET\Framework\" + $version + "\MSBuild.exe")
  
  # Checking if the MSBuild.exe file exists. If File not exists, it will skip for this version 
  if (!(Test-Path $checkFile)) {
    Write-Host ".NET Framework" $version "folder does exist, but MsBuild.exe does not exist. Skipping check." -ForegroundColor yellow
    Write-Host ""
  }
  # If MSBuild.exe exists for this version, checks the exact version number.
  else {
    $command = -join ("$Env:WinDir\Microsoft.NET\Framework\" + $version + "\MSBuild.exe -version")
    $commandString = Invoke-Expression $command | Out-String
    $commandSplit = $commandString.Split([Environment]::NewLine, [StringSplitOptions]::RemoveEmptyEntries) | Select-Object -Last 1
    Write-Host ".NET Framework version"$commandSplit "is installed"
    Write-Host ""
  }
}

write-log "Displaying the .NET Core and PowerShell Core verions"
# displaying installed .NET Core and PowerShell Core versions
if (!$netcore) {
  Write-Host ".NET Core is NOT installed" -ForegroundColor red
}
else {
  Write-Host ".NET Core version" $netCore "is installed" -ForegroundColor green
}

if (!$pwshCore) {
  Write-Host "PowerShell Core is NOT installed" -ForegroundColor red
}
else {
  Write-Host $pwshCore "Core is installed" -ForegroundColor green
}
Write-Host "Powershell" $psversion "Classic is installed" -ForegroundColor green
Write-Host "`r`n"

write-log "All done !"
Stop-Transcript