##################### Apache_Log4j_Scanner ##########################
# Description: Uses Log4jScanner.exe bundled via Datto to scan root #
# Disk for log4j vulnerabilities. Results are printed to console.   #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 09/26/2023 - Created Script                                       #

#####################################################################

function Datto_Output {
    <#
        .SYNOPSIS
            Wrapper function to output data into Datto
        .EXAMPLE
            Datto_Output("The software was installed")
    #>
    
    param (
        # The text you want to output into Datto
        $message
    )
    # General Variables for Datto: 
    $StartResult = Write-Host "<-Start Result->" 6>&1
    $EndResult = Write-Host "<-End Result->" 6>&1
    
    $StartResult
    Write-Host "$message"
    $EndResult
}

# Env Variable changes: 
$ErrorView = 'NormalView'
$ErrorActionPreference = 'Stop'

Start-Process ./Log4jScanner.exe -ArgumentList "/scan /report_sig" -Wait
$stats = Get-Content "C:\ProgramData\Qualys\status.txt"
$summary = Get-Content "C:\ProgramData\Qualys\log4j_summary.out"
$findings = Get-Content "C:\ProgramData\Qualys\log4j_findings.out"
$Log4jScan = "Scan Stats:`n$Stats`n`nScan Summary:`n$summary`n`nScan Findings:`n$findings"
Datto_Output($Log4jScan)