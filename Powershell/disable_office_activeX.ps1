
################### Disable_Office_ActiveX###########################
# Description: Disable all office activeX controls via registrty 
# key set at HKCU\Software\policies\microsoft\office\common\security 

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 01/26/2024 - Created Script
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

reg add "HKCU\SOFTWARE\Microsoft\Office\common\security" /v "disableallactivex" /t REG_DWORD /d 1 /f
