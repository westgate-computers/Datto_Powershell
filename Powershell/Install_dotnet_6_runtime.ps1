################### Install_Dotnet_6_Runtime ########################
# Description: Uses installers bundled in Datto to install .NET 6   #
# runtime, desktop runtime and ASP.NET runtime                      #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 11/06/2023 - Created Script                                       #

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

Write-Host "Installing .NET 6 Desktop Runtime"
& ./windowsdesktop-runtime-6.0.24-win-x64.exe /q /norestart

Write-Host "Installing .NET 6 Runtime"
& ./dotnet-runtime-6.0.24-win-x64.exe /q /norestart

Write-Host "Installing ASP.NET Core Runtime"
& ./aspnetcore-runtime-6.0.24-win-x64.exe /q /norestart

Write-Host "Script complete, currently installed .NET versions are: "
Get-WmiObject Win32_product | findstr /I ".net"