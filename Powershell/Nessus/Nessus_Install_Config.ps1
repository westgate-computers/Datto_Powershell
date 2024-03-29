################### Nessus_Install_Config.ps1 #######################
# Description: Install and configure Nessus 10.6 via Datto          #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 04/26/2023 - Created Script                                       #
# 08/08/2023 - added redirection for Write-Host variable            #
# 09/14/2023 - add better error handling
# 09/18/2023 - Start nessus install as job

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

# Script variables: 
#$passwd = ConvertTo-SecureString $env:password -AsPlainText -Force
$installed = Get-WmiObject Win32_Product | Select Name | findstr /I "tenable nessus"

if ($result -ne $null){
    Write-Host "Nessus is installed."
    exit 0
}
else{
    Write-Host "Nessus is not installed. Starting install..."
}

$originalLocation = Get-Location | findstr "C:\"
$backupFile = Join-Path $originalLocation "\Nessus_Backup.tar.gz"

try {
    # Install Nessu 10.6.0
    $installJob = Start-Job -ScriptBlock { msiexec /i Nessus-10.6.0-x64.msi /qn } | Write-Host
    Write-Host "Nessus install started"
    Wait-Job $installJob
    Write-Host "Nessus install is complete, stopping service for backup restoration"
    
}
catch {
    Write-Host("Error installing Nessus")
    foreach($err in $Error) {
        Write-Host($err)
    }
}

try {
    net stop "Tenable Nessus"
    Write-Host "Restoring backup config from $backupFile"
    & "C:\Program Files\Tenable\Nessus\nessuscli.exe" backup --restore $backupFile | Write-Host
    Write-Host "Backup config restored, starting Nessus Service"
    net start "Tenable Nessus"
    Write-Host "Nessus Installation complete"
}
catch {
    Write-Host("Error Restoring Nessus")
    foreach($err in $Error) {
        Write-Host($err)
    }
}


# Setup svcNessus user: 
# Import-Module ActiveDirectory 
# $domain = Get-ADdomain | Select-Object "distinguishedName" | findstr /I dc
# $OU = "CN=Users, " + $domain
# $NewADUserParameters = @{
#     Name = "Nessus"
#     GivenName = "svcNessus"
#     Surname = ""
#     sAMAccountName = "svcNessus"
#     Password = $passwd
#     Path = $OU
#     Enabled = $true
#   }
# New-ADUser @NewADUserParameters

# New-ADGroup -Name "Nessus Local Access" -SamAccountName NessusLocalAccess -GroupCategory Security -GroupScope Global -DisplayName "Nessus Local Access" -Path $OU -Description "Gives Nessus Local access to a machine for vulnerability scanning"
