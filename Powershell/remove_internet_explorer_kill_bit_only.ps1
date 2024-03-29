###################### Set_IE_11_Kill_Bit ###########################
# Description: Set registry kill bit so nessus will stop            #
# complaining about Internet Explorer 11. This is in hopes of       #
# keeping Quickbooks working while satisfying Nessus.               #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 01/11/2024 - Created Script                                       #

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

reg add "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Main" /v "NotifyDisableIEOptions" /t REG_DWORD /d 1 /f

Datto_Output("Registry key NotifyDisableIEOptions created at HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main with DWORD value of 1")