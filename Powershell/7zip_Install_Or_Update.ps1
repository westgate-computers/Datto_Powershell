#################### 7zip_Install_or_Update #########################
# Description: Use nuget and psGallery to install 7zip as module    #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 09/26/2023 - Created Script                                       #

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

# Begin Script: 
# [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
# Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force;
# Set-PSRepository -Name 'PSGallery' -SourceLocation "https://www.powershellgallery.com/api/v2" -InstallationPolicy Trusted;
# # Setup is complete, install 7zip
# Install-Module -Name 7Zip4PowerShell -Force;
# Datto_Output("7zip was installed/updated.")



$Installer7Zip = $env:TEMP + "\7z1900-x64.msi"; 
Invoke-WebRequest "https://www.7-zip.org/a/7z2301-x64.msi" -OutFile $Installer7Zip; 
msiexec /i $Installer7Zip /qb; 
Remove-Item $Installer7Zip;