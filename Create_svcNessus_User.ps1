##################### Create_svcNessus_User #########################
# Describe script here: List how to use the script, list input      #
# arguements, return values and exit codes                          #

#####################################################################
# Author: Walker Chesley                                                 #
# Change List: List your changes here:                              #
# 08/22/2023 - Created Script                                       #

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

$op = Get-LocalUser | where-Object Name -eq "svcNessus" | Measure

if ($op.Count -eq 0) {
    $passwd = ConvertTo-SecureString $env:password -AsPlainText -Force
    New-LocalUser -Name "svcNessus" -Description "Nessus service account" -Password $passwd
    Datto_Output("Created svcNessus user")
}
else {
    Datto_Output("svcNessus user already exists")
}