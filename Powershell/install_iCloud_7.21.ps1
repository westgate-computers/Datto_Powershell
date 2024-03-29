######################## install_iCloud_7.21 ############################
# Description: This script installs iCloud version 7.21 using bundled 
# icloud.exe installer. This installer can be found at the here: 
# https://updates.cdn-apple.com/2020/windows/001-39935-20200911-1A70AA56-F448-11EA-8CC0-99D41950005E/iCloudSetup.exe

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

# Extract bundled installer:
./iCloudSetup.exe /Extract

# explicit wait for previous command to finish: 
Thread.Sleep(3000)

# Begin silent install of iCloud:
MsiExec.exe /i ./AppleApplicationSupport.msi /qn
Start-Process -FilePath ./iCloudSetup.exe -ArgumentList "REBOOT=ReallySupress /qn" -Wait
Datto_Output("iCloud 7.21 installed")