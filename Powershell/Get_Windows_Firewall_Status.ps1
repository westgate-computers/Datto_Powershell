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
# MIIIuAYJKoZIhvcNAQcCoIIIqTCCCKUCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAhe92umw3gPePt
# CO7gEm/E7AxNte6z5Som0epLC8zW3qCCBfowggX2MIIE3qADAgECAhMgAAAAJTk+
# wdvAji8zAAEAAAAlMA0GCSqGSIb3DQEBCwUAMFQxFTATBgoJkiaJk/IsZAEZFgVs
# b2NhbDEcMBoGCgmSJomT8ixkARkWDHdlc3RnYXRlY29tcDEdMBsGA1UEAxMUd2Vz
# dGdhdGVjb21wLURDMDEtQ0EwHhcNMjUwMTIxMjIzNTI4WhcNMjcwMTIxMjI0NTI4
# WjAZMRcwFQYDVQQDEw5XYWxrZXIgQ2hlc2xleTCCASIwDQYJKoZIhvcNAQEBBQAD
# ggEPADCCAQoCggEBANRrq1GdQ8q02316VsSUZe5jcuCA1/rQ0CeICX2iEDV9P7uV
# 5ferUh1dTuDJjpQdVjjYARrV7U0H7c1lF+4DpE4S7IRLsiSJMUqNhdQMn58tu7Yt
# XleNWtRP+bkHX81vtJ1nlnxkdaIOKX7HN86FFclpo7osUt/bKZKBzKSDr6Y18vog
# YG4PIQLtymw/kNbkcHf1+iqW7/MQNevfmorLg06xpeKoEdw9B4CDlKUrXEEXB29y
# QFzrcdQiSX2jKToJOZnS40Ofov3Mi9adYd4fRAOVLLzytjj+vI4Ood2K06Dz8wVo
# zkcmQ2KOTUV+Kcobysc6pWF/FeGbYHvhYflkOpECAwEAAaOCAvowggL2MDwGCSsG
# AQQBgjcVBwQvMC0GJSsGAQQBgjcVCIWPl3mFh8xJg/mNCd2UeoepixJIhp2sbIS1
# w3sCAWQCAQIwEwYDVR0lBAwwCgYIKwYBBQUHAwMwDgYDVR0PAQH/BAQDAgeAMBsG
# CSsGAQQBgjcVCgQOMAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFEiRW0A/zWc2uM0h
# PXDdgXnzVMfMMB8GA1UdIwQYMBaAFLWGbuIuy8p6oshJR2XtcmsxnG+HMIHdBgNV
# HR8EgdUwgdIwgc+ggcyggcmGgcZsZGFwOi8vL0NOPXdlc3RnYXRlY29tcC1EQzAx
# LUNBKDEpLENOPVdHQy1EQzAxLENOPUNEUCxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2
# aWNlcyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPXdlc3RnYXRlY29t
# cCxEQz1sb2NhbD9jZXJ0aWZpY2F0ZVJldm9jYXRpb25MaXN0P2Jhc2U/b2JqZWN0
# Q2xhc3M9Y1JMRGlzdHJpYnV0aW9uUG9pbnQwgc0GCCsGAQUFBwEBBIHAMIG9MIG6
# BggrBgEFBQcwAoaBrWxkYXA6Ly8vQ049d2VzdGdhdGVjb21wLURDMDEtQ0EsQ049
# QUlBLENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2VzLENOPVNlcnZpY2VzLENOPUNv
# bmZpZ3VyYXRpb24sREM9d2VzdGdhdGVjb21wLERDPWxvY2FsP2NBQ2VydGlmaWNh
# dGU/YmFzZT9vYmplY3RDbGFzcz1jZXJ0aWZpY2F0aW9uQXV0aG9yaXR5MDYGA1Ud
# EQQvMC2gKwYKKwYBBAGCNxQCA6AdDBt3Y2hlc2xleUB3ZXN0Z2F0ZWNvbXAubG9j
# YWwwTAYJKwYBBAGCNxkCBD8wPaA7BgorBgEEAYI3GQIBoC0EK1MtMS01LTIxLTg5
# MzYxOTIyNS05ODMxNjM4NDUtNzM0MzcyNDA1LTI2MzMwDQYJKoZIhvcNAQELBQAD
# ggEBADDCZHaD3JqnGAM2Ayp0fjCkZjUJeHLfdLn3DBIVdr9XaxOqfP641az2+fVm
# tDnIDuacTIs70DoGzg33Lmel2liBsif+7NTXRHqk3mFguPeUvDbRuGQjRTnsu5DR
# nv9GdgYdoY+Dwh0eyAb4Rri+AzikMM6hytjy22xtqbfj38E/LjtXBxWtKFV1NO1Y
# xnCUvCCOuERjAnbnI2pe4Yqa8qmG6c5ii6h71V2rP5BXcqVg8EXxMHpYrypPR2F5
# mdk323TPlq58Aqf7df5dMqK5HdSlwphSAZUGzhKEVA5d5pQYujvHjwashLHRXcbo
# U/TmFTV5EvmCXaz8TZKWLJO7XlUxggIUMIICEAIBATBrMFQxFTATBgoJkiaJk/Is
# ZAEZFgVsb2NhbDEcMBoGCgmSJomT8ixkARkWDHdlc3RnYXRlY29tcDEdMBsGA1UE
# AxMUd2VzdGdhdGVjb21wLURDMDEtQ0ECEyAAAAAlOT7B28COLzMAAQAAACUwDQYJ
# YIZIAWUDBAIBBQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0BCQMxDAYK
# KwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG
# 9w0BCQQxIgQg/XTuoEfX21Q5oCE0b1BXvPTBWGT1p9d7I492N0Wy8ckwDQYJKoZI
# hvcNAQEBBQAEggEAGHPRVES9vG6Mfr6r4zzlIxZScWSuIq9atZy1ZnL8kCzGmbAe
# KmUOgQJ+Gi+d8DsXRxXjEKcXSKzHCLhny/+9JuVW3+amlBQob+seaK3ogJ5pSb8V
# olomFmdu+SJVozoIXMwXWR+M7YgQscr4NOnzQZ/nZAf9IMQEKDAouKI+psa8cHNp
# 01SbGzIV6GLVtGU4dFLjnuQDSAq/VI/2BKNPmM7Vte/Gvql6Fv+CijYZQzuKR4aa
# qRhG55hrUEdAmT1Bf5zM36ja3Q+q4ftjN9K7DUX5XlykwFtHkYrXggS2IaoYHMwF
# GuB+MFgtd9JJZuua7dWjlYKIsDWSAAypkuqO8Q==
# SIG # End signature block
