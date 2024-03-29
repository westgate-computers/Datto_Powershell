###################### Disable_UAC_Prompt ###########################
# Description: Disables UAC prompt by creating registry key at      #
# HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System   #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 04/26/2023 - Created Script                                       #

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

# Disable UAC Prompt - Nessus doesn't scan non-domain joined hosts properly without this: 
Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0

Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name LocalAccountTokenFilterPolicy -Value 1

Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name EnableLUA -Value 0