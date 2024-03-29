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
# added exit codes.
# 10/20/2023 - Add function to remove SentinelOne folders on failed
# install. Implement this function on error, before exit 1 call. 
# Change 'start-process' call to 'Invoke-Expression' as per this 
# article: https://stackoverflow.com/questions/4639894/executing-an-exe-file-using-a-powershell-script
# ~ wchesley

#####################################################################

#Stop the installer process if it is already running
Stop-Process -Name "SentinelInstaller" -Force

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

function RemoveSentinelOne {
    param(
        # Sentinel One path
        # either ProgramData or nothing where no arg removes Sentinel in Program Files
        # and ProgramData removes Sentinel in ProgramData folder. 
        $path
    )
    $SentinelPath = ""
    switch ($path) {
        "ProgramData" {$SentinelPath = "C:\ProgramData\Sentinel"}
        Default { $SentinelPath = "C:\Program Files\SentinelOne"}
    }

    try {
        Remove-Item -Recurse -Force -Path "$SentinelPath"
        Write-Host "Removed Sentinel One from $SentinelPath"
    }
    catch {
        Write-Error $Error
    }
}

# Env Variable changes: 
$ErrorView = 'NormalView'
$ErrorActionPreference = 'Stop'

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
        start-process -Wait -FilePath ".\SentinelInstaller.exe" -ArgumentList "/q /t $token" -PassThru
        If ($installed) {
            Write-output "'$software' is now installed."
            Exit 0;
        }
        else {
           Write-output "'$software' did not install correctly."
           RemoveSentinelOne("")
           RemoveSentinelOne("ProgramData")
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
        Invoke-Expression "& '.\SentinelInstaller.exe' /q /t $token"
        If ($installed) {
            Write-output "'$software' is now installed."
            Exit 0;
        }
        else {
           Write-output "'$software' did not install correctly."
           RemoveSentinelOne("")
           RemoveSentinelOne("ProgramData")
           Exit 1; 
        }
    }
}
else {
    Write-output "'$software' was already installed."
    Exit 0;
}