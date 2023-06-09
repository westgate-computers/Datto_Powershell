######################## SentinelOnePowershell ######################
# Installer script for SentinelOne, to be used with Datto RMM.      #
# Script expects that SentinelOne installer is packaged with Datto  #
# Component. Requires SentinelOne token as S1SiteToken in Component #

#####################################################################
# Author: Billy Robbins, Brandon Terry, Walker Chesley              #
# Change List: List your changes here:                              #
# 04/01/2022 - Created Script                                       #
# 05/17/2023 - WC: Added script to template, changed install        #
# command to 'start-process' rather than & .\SentinelInstaller.exe  #
# added exit codes.                                                 #
#####################################################################

#Stop the installer process if it is already running
Stop-Process -Name "SentinelInstaller" -Force

# General Variables for Datto: 
$StartResult = Write-Host "<-Start Result->"
$EndResult = Write-Host "<-End Result->"

# Wrapper function to output data into Datto
# @param $message = The text you want to output into Datto
function Datto_Output {
    param (
        $message
    )
    $StartResult
    Write-Host "$message"
    $EndResult
}

$software = "Sentinel Agent"
$directory = "C:\temp\Westgate"
$installed = (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where { $_.DisplayName -contains $software }) -ne $null
$token = $env:S1SiteToken

If ((Get-WmiObject win32_operatingsystem | Select-Object osarchitecture).osarchitecture -eq "64-bit")
{
    #Check whether SentinelOne is already installed, then install it if necessary
    If (-Not $installed) {
        New-Item -ItemType Directory -Force -Path $directory
        Datto_Output("'$software' was not found, attempting to install.")
        Start-Process SentinelInstaller.exe "/q /t $token"
        If ($installed) {
            Write-output "'$software' is now installed."
            Exit 0;
        }
        else {
           Write-output "'$software' did not install correctly."
           Exit 1; 
        }
    }
}
elseif ((Get-WmiObject win32_operatingsystem | Select-Object osarchitecture).osarchitecture -eq "32-bit") {
    <# Action when this condition is true #>
    $installed = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where { $_.DisplayName -contains $software }) -ne $null
    #Check whether SentinelOne is already installed, then install it if necessary
    If (-Not $installed) {
        New-Item -ItemType Directory -Force -Path $directory
        Datto_Output("'$software' was not found, attempting to install.")
        Start-Process SentinelInstaller32.exe "/q /t $token"
        If ($installed) {
            Write-output "'$software' is now installed."
            Exit 0;
        }
        else {
           Write-output "'$software' did not install correctly."
           Exit 1; 
        }
    }
}
else {
    Write-output "'$software' was already installed."
    Exit 0;
}