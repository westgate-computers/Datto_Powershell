################## intel_update_chipset_driver ######################
# Description: use SetupChipset.exe bundled from Datto RMM to 
# perform silent installation of Intel Chipset drivers. 
# As of 12/14/2023, this script installs v10.1.19444.8378

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 12/14/2023 - Created Script                                       #
# 12/15/2023 - adjusted -ArguementList                              #

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

if(Test-Path -Path "./SetupChipset.exe")
{
    Start-Process -FilePath "./SetupChipset.exe" -ArgumentList "-s", "-noreboot"
}
else {
    Write-Error("Cannot find SetupChipset.exe in directory")
    exit 1;
}
Datto_Output("Chipset drivers have been updated. Please confirm update manually on the host.")
