##################### Update_Nessus_Offline #########################
# Description: Uses datto-bundled Nessus Update file to update      #
# Nessus to a later version. 

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 10/02/2023 - Created Script                                       #

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

Write-Host "Starting Nessus update, current version is:"
& "C:\Program Files\Tenable\Nessus\nessuscli.exe" -v
Write-Host "Stopping nessus for update"
net stop "tenable nessus"
& "C:\Program Files\Tenable\Nessus\nessuscli.exe" update "./nessus-updates-10.6.1.tar.gz"
Write-Host "update complete, restarting nessus"
net start "tenable nessus"
Write-Host "Nessus update complete, version is now:"
& "C:\Program Files\Tenable\Nessus\nessuscli.exe" -v