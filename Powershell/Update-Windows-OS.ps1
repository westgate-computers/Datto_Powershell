####################### Update_Windows_OS ###########################
# Description:  This script updates windows OS and does not force a #
# reboot of the host.                                               #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 08/11/2023 - Created Script                                       #
# 09/14/2023 - Ensure PSGallery is trusted installation source      #
# 09/29/2023 - Changed ordering of PSGallery and Nuget              #
# 10/02/2023 - Add Get-WuInstall and explicitly request Microsoft   # 
# updates in Install-WindowsUpdate                                  #
# 02-27-2024 - Pipe output C:\windows\temp\update_log.txt           #
# and print to console.                                             #

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

try 
{ 
    # Check if NuGet is installed, if not, install it: 
    if(Get-PackageProvider | Where-Object {$_.Name -eq "Nuget"}) 
    { 
        "Nuget Module already exists" 
    } 

    else 
    { 
        "Installing nuget module" 
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force 
    }

# Add PSGallery and mark it as trusted: 
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
Set-PSRepository -Name 'PSGallery' -SourceLocation "https://www.powershellgallery.com/api/v2" -InstallationPolicy Trusted;

# Check if PSWindowsUpdate exists if not, add it
    if(Get-Module -ListAvailable | where-object {$_.Name -eq "PSWindowsUpdate"}) 
    { 
        "PSWindowsUpdate module already exists" | Tee-Object -FilePath C:\Windows\Temp\Update-Log.txt -Append  
    } 

    else 
    { 
        "Installing PSWindowsUpdate Module" | Tee-Object -FilePath C:\Windows\Temp\Update-Log.txt -Append  
        install-Module PSWindowsUpdate -Force | Tee-Object -FilePath C:\Windows\Temp\Update-Log.txt -Append  
    } 
# Update the OS
    Import-Module -Name PSWindowsUpdate 

    "Starting update -->" + (Get-Date -Format "dddd MM/dd/yyyy HH:mm") | Tee-Object -FilePath C:\Windows\Temp\Update-Log.txt -Append  

    install-WindowsUpdate -MicrosoftUpdate -AcceptAll -ForceDownload -ForceInstall -IgnoreReboot | Tee-Object -FilePath C:\Windows\Temp\Update-Log.txt -Append  

    Get-WuInstall -AcceptAll -IgnoreReboot | Tee-Object -FilePath C:\Windows\Temp\Update-Log.txt -Append  

    "Update completed -->"+ (Get-Date -Format "dddd MM/dd/yyyy HH:mm") | Tee-Object -FilePath C:\Windows\Temp\Update-Log.txt -Append  

} 

catch { 

    Datto_Output($_.Exception.Message) | Tee-Object -FilePath C:\Windows\Temp\Update-Log.txt -Append  

} 