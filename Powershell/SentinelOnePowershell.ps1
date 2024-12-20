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
# SIG # Begin signature block
# MIIItQYJKoZIhvcNAQcCoIIIpjCCCKICAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCB0NJI+X3WeXpI+
# ulZEzBFQ/oO1PVfd5Szq4yZf58Cm+aCCBfcwggXzMIIE26ADAgECAhMgAAAAFmQu
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
# NE1hS/lI3CECKUoA5598UusxggIUMIICEAIBATBrMFQxFTATBgoJkiaJk/IsZAEZ
# FgVsb2NhbDEcMBoGCgmSJomT8ixkARkWDHdlc3RnYXRlY29tcDEdMBsGA1UEAxMU
# d2VzdGdhdGVjb21wLURDMDEtQ0ECEyAAAAAWZC7cZNqNpo4AAAAAABYwDQYJYIZI
# AWUDBAIBBQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0BCQMxDAYKKwYB
# BAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0B
# CQQxIgQgf+72ZZc9sk7TeG14Qg/yRv57Ny0O8ncfsXnUSxKqwTkwDQYJKoZIhvcN
# AQEBBQAEggEAg63plqULO9FDBjMXwGRsNjNV5qBcalHYEvM+09yTE22lLB2LzWRG
# 5ZL7kowpCqiKMSSBd/zh5CgZAStUaNlgqjhkAEvUb5YBZ9MEhEYZKrBBvjkoqYpr
# LEVfHD5jlQ84nKUwuTuZsSoVnJzjBbr0L7L93BnbE+agczMR5RodFKltFNLSFkD4
# AX3OGKQyG7VBqeooTA/v0QN2Zd92/oqpHj8Wu2C6BgBv7GikYk70XSBteh9cWQhc
# yDSB30Uf0Yh+4Xx1FTVL4/Tmr3dp7KcY4M1JPvMoRZcSanqLcEQoRh7WVIIlSktZ
# QxHfcVENMY4eV1Dli153JWrR13m1AnokHg==
# SIG # End signature block
