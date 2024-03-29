######################### Update_MSTeams ############################
# Description: Update MS Teams to v1.6.0.24070                      #
# Script has to be run as a user account as the update exe lives    # 
# in the users %APPDATA% folder.                                    #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 09/20/2023 - Created Script                                       #

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

# Get current user name and only their name: 
$User = (Get-ChildItem Env:USERNAME).Value

# Change location to users local %APPDATA% folder and run Teams update.exe
Set-Location "C:\Users\$User\AppData\Local\Microsoft\Teams"
./Update.exe --update "https://statics.teams.cdn.office.net/production-windows-x64/1.6.00.24078/RELEASES" -s

# Wait a bit for installer to do something
Start-Sleep -Seconds 60

# Capture recent log output of installer and pipe it to Datto: 
$installInfo = Get-Content ./SquirrelSetup.log -Last 50
Datto_Output($installInfo)