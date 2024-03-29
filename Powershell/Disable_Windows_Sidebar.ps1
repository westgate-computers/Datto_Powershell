######################## Script_Template ############################
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

$Key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Windows\Sidebar"

if(Test-Path -Path $Key)
{
    Write-Host "Sidbar Key Exists"
}
else 
{
    Write-Host "Sidebar Key does not exist, creating it now"
    New-ItemProperty -Path $Key -Name "TurnOffSidebar" -Value "1" -PropertyType DWord
    Write-Host -f Green "Sidebar has been disabled via regsitry key"
}