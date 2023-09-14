################### Nessus_Install_Config.ps1 #######################
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

#$passwd = ConvertTo-SecureString $env:password -AsPlainText -Force
$installed = Get-WmiObject Win32_Product | Select Name | findstr /I "tenable nessus"

if ($result -ne $null){
    Write-Host "Nessus is installed."
    exit 0
}
else{
    Write-Host "Nessus is not installed. Starting install..."
}

$originalLocation = (Get-Item .).FullName
$backupFile = $originalLocation + "\Nessus_Backup.tar.gz"

# Install Nessu 10.6.0
Start-Process -Wait "msiexec" -ArgumentList "./Nessus-10.6.0-x64.msi /qn /i"
Write-Host "Nessus install is complete, stopping service for backup restoration"
net stop "Tenable Nessus"
Write-Host "Restoring backup config from $backupFile"
Start-Process -Wait -FilePath "nessuscli.exe" -WorkingDirectory "C:\Program Files\Tenable\Nessus" -ArgumentList "backup --restore $backupFile"
Write-Host "Backup config restored, starting Nessus Service"
net start "Tenable Nessus"
Write-Host "Nessus Installation complete"

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
