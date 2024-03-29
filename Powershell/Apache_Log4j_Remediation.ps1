################### Apache_Log4j_Remediation ########################
# Description: Uses Log4jRemediate.exe bundled via Datto to scan    #
# root disk for log4j vulnerabilities and apply the remediation.    #
# Results are printed out to the console.                           #
# Leverages executables from Qualys, they are located on github     #
# https://github.com/Qualys/log4jscanwin/
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

Start-Process ./Log4jRemediate.exe -ArgumentList "/remediate_sig /report_pretty" -Wait
$results = Get-Content "C:\ProgramData\Qualys\log4j_remediate.out"
Datto_Output($results)