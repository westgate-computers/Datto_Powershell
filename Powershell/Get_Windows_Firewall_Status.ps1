######################## Script_Template ############################
# Description: Query windows firwall status with 
# `Get-NetFirewallProfile` and `netsh`. Outputs firewall profile 
# name, it's status (enabled or not), and Inbound and Outbound 
# actions. Also outputs firewall in use by the system (3rd party 
# firewall check, for built-in will output 
# "Windows Defender Firewall"

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 06/21/2024 - Created Script                                       #

#####################################################################

# Env Variable changes: 
$ErrorView = 'NormalView'
$ErrorActionPreference = 'Stop'

function Get-FirewallStatus {
    [cmdletBinding()]
    param (
        [string]$ComputerName = (Get-WmiObject Win32_ComputerSystem).Name 
    )

    # Resolve the computer name to ensure it is reachable
    try {
        $resolvedName = [System.Net.Dns]::GetHostEntry($ComputerName).HostName
        Write-Host "Resolved computer name: $resolvedName"
    } catch {
        Write-Host "Failed to resolve computer name: $ComputerName"
        return
    }

    # Check Windows Defender Firewall status
    Write-Host "Checking Windows Defender Firewall status on $resolvedName..."
    try {
        $firewallProfiles = Get-NetFirewallProfile -PolicyStore activestore

        foreach ($profile in $firewallProfiles) {
            $profileName = $profile.Name
            $enabled = $profile.Enabled
            $defaultInboundAction = $profile.DefaultInboundAction
            $defaultOutboundAction = $profile.DefaultOutboundAction

            Write-Host "Profile: $profileName"
            Write-Host "  Enabled: $enabled"
            Write-Host "  Default Inbound Action: $defaultInboundAction"
            Write-Host "  Default Outbound Action: $defaultOutboundAction"
        }
    } catch {
        Write-Host "Failed to retrieve Windows Defender Firewall status on $resolvedName"
    }

    # Check third-party firewall status
    Write-Host "Checking third-party firewall status on $resolvedName..."
    try {
        $fireWallName = ((netsh advfirewall show global | where {$_ -match "BootTimeRuleCategory"}) -split "  ")[-1];
        Write-Host "Firewall Name: $fireWallName";
    } catch {
        Write-Host "Failed to retrieve third-party firewall status on $ComputerName"
    }
}

# Run the function
Get-FirewallStatus
# SIG # Begin signature block
# MIIIvgYJKoZIhvcNAQcCoIIIrzCCCKsCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAhe92umw3gPePt
# CO7gEm/E7AxNte6z5Som0epLC8zW3qCCBfcwggXzMIIE26ADAgECAhMgAAAAFmQu
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
# BgkqhkiG9w0BCQQxIgQg/XTuoEfX21Q5oCE0b1BXvPTBWGT1p9d7I492N0Wy8ckw
# DQYJKoZIhvcNAQEBBQAEggEAV5nQisUeeH91JMwJZussEEFUTC3g0Px6kBaiYZwp
# 3+uUHkOt9bzgseWjmIWT3q9DOKtfM7pwy0Dct+11meDyozUap/xjT4/pmz2Y7Da5
# daP/mMMytALTsC0VBClksnOnr29ahPhS7VZkD1L48+IR2/YQ4jd7o1KTkQxgJ0hA
# m8EK0u5wbP3yXZIVAjokaQO2PSWlCPN4Heif4gTyxpfAk+po4X34vHQsxZcuWqtd
# TUDdWqMVwiDgGJKNdVRw+vGhQcsqXJHnjyEBj4YS9KJDdgoz62mZftA6XGpf0h2k
# GyN2w+7dvDy0CdRsY+N3v0TaeGvyIRJ/FVwNht+3VTbXmw==
# SIG # End signature block
