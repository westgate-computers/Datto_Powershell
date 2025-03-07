<# 
.SYNOPSIS
    Maintains the DattoRMM-ComponentList.csv by scanning the Scripts directory.
.DESCRIPTION
    This script scans the `Powershell/` directory, updates metadata, and ensures the component list is up-to-date.
    All parameters are optional and have default values.
    The script will update the CSV file with the latest metadata for each script.
.PARAMETER ScriptsPath
    Path to the Scripts directory.
.PARAMETER CsvPath
    Path to the DattoRMM-ComponentList.csv file.
.PARAMETER RemoveMissing
    If set, removes entries from the CSV that no longer exist in the Scripts directory.
.EXAMPLE
    .\Maintain-ComponentList.ps1 -ScriptsPath ".\Scripts" -CsvPath ".\DattoRMM-ComponentList.csv" -RemoveMissing $true
.NOTES
    Version: 1.0
    Author: Your Name
    Created: YYYY-MM-DD
#>

param (
    [string]$ScriptsPath = ".\Powershell",
    [string]$CsvPath = ".\DattoRMM-ComponentList.csv",
    [switch]$RemoveMissing
)

# Trap Error & Exit: 
trap {"Error found: $_"; break;}

# Ensure paths exist
if (-not (Test-Path $ScriptsPath)) {
    Write-Error "Scripts directory not found: $ScriptsPath"
    exit 1
}

# Load existing CSV if it exists
$ComponentList = @()
if (Test-Path $CsvPath) {
    $ComponentList = Import-Csv -Path $CsvPath
} else {
    Write-Host "Creating new CSV file: $CsvPath"
}

# Get all PowerShell scripts in the Scripts directory
$ScriptFiles = Get-ChildItem -Path $ScriptsPath -Recurse -Filter "*.ps1"

# Function to extract metadata from a script
function Get-ScriptMetadata {
    param ([string]$ScriptPath)

    $Content = Get-Content -Path $ScriptPath -Raw
    $Metadata = @{
        Name         = [System.IO.Path]::GetFileNameWithoutExtension($ScriptPath)
        ScriptName   = [System.IO.Path]::GetFileName($ScriptPath)
        Category     = (Split-Path -Path $ScriptPath -Parent | Split-Path -Leaf)
        LastUpdated  = (Get-Item $ScriptPath).LastWriteTime.ToString("yyyy-MM-dd")
        Version      = "1.0"  # Default version
        Notes        = ""
    }

    # Extract version if present in script header
    if ($Content -match "(?m)Version:\s*(\d+\.\d+)") {
        $Metadata.Version = $matches[1]
    }

    return $Metadata
}

# Track updated components
$UpdatedComponents = @()

foreach ($Script in $ScriptFiles) {
    $Metadata = Get-ScriptMetadata -ScriptPath $Script.FullName

    # Check if component already exists
    $Existing = $ComponentList | Where-Object { $_.ScriptName -eq $Metadata.ScriptName }

    if ($Existing) {
        # Update metadata if necessary
        $Existing.LastUpdated = $Metadata.LastUpdated
        $Existing.Version = $Metadata.Version
        $UpdatedComponents += $Existing
    } else {
        # Add new component entry
        $UpdatedComponents += [PSCustomObject]$Metadata
    }
}

# Remove missing entries if specified
if ($RemoveMissing) {
    $UpdatedComponents = $UpdatedComponents | Where-Object { $_.ScriptName -in $ScriptFiles.Name }
}

# Export updated list
$UpdatedComponents | Sort-Object -Property Category, ScriptName | Export-Csv -Path $CsvPath -NoTypeInformation

Write-Host "DattoRMM Component List Updated: $CsvPath"
