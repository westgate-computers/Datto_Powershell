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

# SIG # Begin signature block
# MIIIvgYJKoZIhvcNAQcCoIIIrzCCCKsCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDWv5PhXtgbOYAF
# Kt4sRMGIgxjwBg+E/B3x2aJRvDd6x6CCBfcwggXzMIIE26ADAgECAhMgAAAAFmQu
# 3GTajaaOAAAAAAAWMA0GCSqGSIb3DQEBCwUAMFQxFTATBgoJkiaJk/IsZAEZFgVs
# b2NhbDEcMBoGCgmSJomT8ixkARkWDHdlc3RnYXRlY29tcDEdMBsGA1UEAxMUd2Vz
# dGdhdGVjb21wLURDMDEtQ0EwHhcNMjQwOTE4MjAzMzMxWhcNMjUwMTEzMTk1NDQ2
# WjAZMRcwFQYDVQQDEw5XYWxrZXIgQ2hlc2xleTCCASIwDQYJKoZIhvcNAQEBBQAD
# ggEPADCCAQoCggEBALdQvSsBcZJrgzxqe048NIx6FztzFNcu8CbziEvfMjNSnzVY
# FpQ4SqZV955ub+/6QnkNrhHY+pQlPeajpcOvgCysdGBSe26+8MpC8xGjzLU5MeOT
# cPTZAs/oSo1J9vAo94zUHguV/t0f7KlBhFmnFrkCrOA3nwsh2VFWD+OZYKKyv7tP
# uAzwVFNROKCJt+wpC+OK3akgr8bMM/S/gEl4hGkV2exHv3hdZZPUbchRhwvtH2Ax
# 3YC1EAqxPGns5uM98qqYpU9fe/BLoYFESu1Sno9/p0c9cwLqXQcs9aVrUm8AZgsR
# ed+zdAcMlbLWWBshK47L/bnPx50OILB7NvlPjpUCAwEAAaOCAvcwggLzMDwGCSsG
# AQQBgjcVBwQvMC0GJSsGAQQBgjcVCIWPl3mFh8xJg/mNCd2UeoepixJIhp2sbIS1
# w3sCAWQCAQIwEwYDVR0lBAwwCgYIKwYBBQUHAwMwDgYDVR0PAQH/BAQDAgeAMBsG
# CSsGAQQBgjcVCgQOMAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFHP608OuQEkxYq3u
# zEw2N/A53E3VMB8GA1UdIwQYMBaAFGDzwfRAj9EqefCsmrUwHE3f1WieMIHaBgNV
# HR8EgdIwgc8wgcyggcmggcaGgcNsZGFwOi8vL0NOPXdlc3RnYXRlY29tcC1EQzAx
# LUNBLENOPVdHQy1EQzAxLENOPUNEUCxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2aWNl
# cyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPXdlc3RnYXRlY29tcCxE
# Qz1sb2NhbD9jZXJ0aWZpY2F0ZVJldm9jYXRpb25MaXN0P2Jhc2U/b2JqZWN0Q2xh
# c3M9Y1JMRGlzdHJpYnV0aW9uUG9pbnQwgc0GCCsGAQUFBwEBBIHAMIG9MIG6Bggr
# BgEFBQcwAoaBrWxkYXA6Ly8vQ049d2VzdGdhdGVjb21wLURDMDEtQ0EsQ049QUlB
# LENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2VzLENOPVNlcnZpY2VzLENOPUNvbmZp
# Z3VyYXRpb24sREM9d2VzdGdhdGVjb21wLERDPWxvY2FsP2NBQ2VydGlmaWNhdGU/
# YmFzZT9vYmplY3RDbGFzcz1jZXJ0aWZpY2F0aW9uQXV0aG9yaXR5MDYGA1UdEQQv
# MC2gKwYKKwYBBAGCNxQCA6AdDBt3Y2hlc2xleUB3ZXN0Z2F0ZWNvbXAubG9jYWww
# TAYJKwYBBAGCNxkCBD8wPaA7BgorBgEEAYI3GQIBoC0EK1MtMS01LTIxLTg5MzYx
# OTIyNS05ODMxNjM4NDUtNzM0MzcyNDA1LTI2MzMwDQYJKoZIhvcNAQELBQADggEB
# ACTp/R8QXQAHRY7b4gV/4RNUfCWBBj5CAsqZXy8pGGpFiAX6inB64CBhqbKD7djv
# elBUCtmBICHbQ5gj/gHKdeIs2Pe6TxJMUbz3D9cNCVZ/bZFLxUZ1zWr/VwNsUXEL
# zqGLwX7Cy/OJaUmQDFSJGfXLbdfyKywa3qgl8j5YOjXItOcf86d9HiN9eDJfW077
# YsYiNeWsg4IAVRpjuDvzGPu+ropqCtJuNLk7cKHQjTU4RTCUzifJON8z7uFU+Hl0
# QutmghDCjojqvWsoAOUIaF4EQ+ZnuTaFuL5bQX4M4bHk6QI/xE4o5RkBPoeNuNE7
# NE1hS/lI3CECKUoA5598UusxggIdMIICGQIBATBrMFQxFTATBgoJkiaJk/IsZAEZ
# FgVsb2NhbDEcMBoGCgmSJomT8ixkARkWDHdlc3RnYXRlY29tcDEdMBsGA1UEAxMU
# d2VzdGdhdGVjb21wLURDMDEtQ0ECEyAAAAAWZC7cZNqNpo4AAAAAABYwDQYJYIZI
# AWUDBAIBBQCggYQwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0B
# CQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAv
# BgkqhkiG9w0BCQQxIgQg4NSL/YOFBkXuCnm1NbWJ4R38dMmeLFpo0YYOGFwj3Kww
# DQYJKoZIhvcNAQEBBQAEggEAPRpc3nPd8aIJ9b7qJM92v+Zl41uXDifetFD8Pwi9
# oNnSb5v+bvAdqL09TPq7Jk3Y2EQIi4iLYIONAIENyDXJKEHIoLtnQITHEQQuoDHg
# qVxD/zQAZQchkQY9w7qdTwX3gNRJej4dN+hXvFH7G3S96v9JJISFMPjLeQ+AmtnI
# U93MFhklYt6rToDtqWimABDF8dOVUZKlVCSPgv+2fe5zhoqNRI9SQw3Gy6M0ZgCD
# 616VH/s2ENbdo8XSPG5SRU2Qe5GGpqDScvKps8EUMihU4cgB+l/WDXeUKwGiHppF
# 684ZokKo0TaEBIEN6Gnao/y9ZXKkZE1255v0kqCEYFCYbA==
# SIG # End signature block
