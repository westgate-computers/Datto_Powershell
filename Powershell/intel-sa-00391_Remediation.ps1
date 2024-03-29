################### Intel-SA-00391_Remediation ######################
# Description - Download updated version from intel, extract 
# archive and perform silent installation

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 12/11/2023 - Created Script

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

try {
    Write-Host "Downloading update file from intel: "
    curl.exe "https://downloadmirror.intel.com/733739/ME_SW_2216.16.0.2805.zip" --output Intel_SA_00391.zip
}
catch {
    Write-Host "curl failed, trying wget"
    wget "https://downloadmirror.intel.com/733739/ME_SW_2216.16.0.2805.zip" -outfile Intel_SA_00391.zip
}
if(Test-Path -Path "./Intel_SA_00391.zip:")
{
    Expand-Archive -path ./Intel_SA_00391.zip -DestinationPath ./Intel_SA_00391
}
else {
    Write-Error "Cannot find Intel_SA_00391.zip"
    exit 1
}
& ".\Intel_SA_00391\ME_SW_DCH\SetupME.exe /i /s"
Write-Host "Installation of Intel_SA_00391 remediation has started. Wait at least 12 hours then reboot host and run another nesses scan to confirm remediation."