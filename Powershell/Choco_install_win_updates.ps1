################# Choco-install-Windows-Updates #####################
# Describe script here: List how to use the script, list input      #
# arguements, return values and exit codes                          #

#####################################################################
# Author: Your_Name                                                 #
# Change List: List your changes here:                              #
# 04/26/2023 - Created Script                                       #
# 08/08/2023 - added redirection for Write-Host variable            #
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

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
Set-Location "C:\ProgramData\chocolatey\"
.\choco.exe feature enable -n=allowGlobalConfirmation
.\choco.exe feature enable -n useFipsCompliantChecksums
.\choco.exe upgrade all
.\choco.exe install pswindowsupdate
Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d -Confirm:$false
Install-WindowsUpdate -MicrosoftUpdate -AcceptAll 
Get-WuInstall -AcceptAll -IgnoreReboot