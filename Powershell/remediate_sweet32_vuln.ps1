######################## Script_Template ############################
# Describe script here: List how to use the script, list input      #
# arguements, return values and exit codes                          #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 08/08/2023 - Created Script                                       #
#                                                                   #
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

# Disable DES/3DES
$reg = Get-Item HKLM:
$key = 'SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers'
$RegistryKey = "Enabled"
$KeyValue = "0"
#KEY1
$subkey = ("Triple DES 168")
$RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168'
$key = $reg.OpenSubKey($key,$true)
$key.CreateSubKey($subkey)
if ((Test-Path -Path $RegistryPath)) 
{
    (New-ItemProperty -Path $RegistryPath -Name $RegistryKey -Value $KeyValue -PropertyType DWORD -Force)
    Datto_Output("Disabled 3DES 168")
}
else 
{
    Datto_Output("Failed to disable 3DES 168")
}

#KEY2
$reg = Get-Item HKLM:
$key = 'SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers'
$subkey = ("DES 56/56")
$RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\DES 56/56'
$key = $reg.OpenSubKey($key,$true)
$key.CreateSubKey($subkey)
if ((Test-Path -Path $RegistryPath)) 
{
    (New-ItemProperty -Path $RegistryPath -Name $RegistryKey -Value $KeyValue -PropertyType DWORD -Force)
    Datto_Output("Disabled DES 56/56")
}
else 
{
    Datto_Output("Failed to disable DES 56/56")
}

# Disable RC4
$reg = Get-Item HKLM:
$key = 'SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers'
$RegistryKey = "Enabled"
$KeyValue = "0"

#KEY1
$subkey = ("RC4 40/128")
$RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 40/128'
$key = $reg.OpenSubKey($key,$true)
$key.CreateSubKey($subkey)
if ((Test-Path -Path $RegistryPath)) 
{
    (New-ItemProperty -Path $RegistryPath -Name $RegistryKey -Value $KeyValue -PropertyType DWORD -Force)
    Datto_Output("Disabled RC4 40/128")
}
else 
{
    Datto_Output("Failed to disable RC4 40/128")
}

#KEY2
$reg = Get-Item HKLM:
$key = 'SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers'
$subkey = ("RC4 56/128")
$RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 56/128'
$key = $reg.OpenSubKey($key,$true)
$key.CreateSubKey($subkey)
if ((Test-Path -Path $RegistryPath)) 
{
    (New-ItemProperty -Path $RegistryPath -Name $RegistryKey -Value $KeyValue -PropertyType DWORD -Force)
    Datto_Output("Disabled RC4 56/128")
}
else 
{
    Datto_Output("Failed to disable RC4 56/128")
}

#KEY3
$reg = Get-Item HKLM:
$key = 'SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers'
$subkey = ("RC4 64/128")
$RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 64/128'
$key = $reg.OpenSubKey($key,$true)
$key.CreateSubKey($subkey)
if ((Test-Path -Path $RegistryPath)) 
{
    (New-ItemProperty -Path $RegistryPath -Name $RegistryKey -Value $KeyValue -PropertyType DWORD -Force)
    Datto_Output("Disabled RC4 64/128")
}
else 
{
    Datto_Output("Failed to disable RC4 64/128")
}

#KEY4
$reg = Get-Item HKLM:
$key = 'SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers'
$subkey = ("RC4 128/128")
$RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 128/128'
$key = $reg.OpenSubKey($key,$true)
$key.CreateSubKey($subkey)
if ((Test-Path -Path $RegistryPath)) 
{

    (New-ItemProperty -Path $RegistryPath -Name $RegistryKey -Value $KeyValue -PropertyType DWORD -Force)
    Datto_Output("Disabled RC4 128/128")
}
else 
{
    Datto_Output("Failed to disable RC4 128/128")
}
# SIG # Begin signature block
# MIIItQYJKoZIhvcNAQcCoIIIpjCCCKICAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDvpsth6iAB9og/
# 7qU/PgPnIMCut31jRm30/nqX7hmxnqCCBfcwggXzMIIE26ADAgECAhMgAAAAFmQu
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
# CQQxIgQg0sCXFz3TeLHUYhtMUu7mKOyI9Gohq6HwT3QzLClD3CYwDQYJKoZIhvcN
# AQEBBQAEggEARUuUuiGONf8jzRb22PKp840lpS64V/HqwNa3ZRTSmdENBBiQaNFR
# udWuhbTlkFey+A/UeIyJCwuG7eH7VkqRMW3pp5ekr6HzJgbDEMjR9TDUw871LXP6
# +/l90/zP+L440uiVmbUkxXdQK0oXhmlP3T9PIZW7yWiOP8d1CmpLW3kmBVSDE/+9
# KTq7O382Ok1Lnw3LKG5at+3nYCqd1lX5HQfmcyKRYv7DTiP7OtQFE6Jm4HpKiZ+R
# 3GRlsvnuECnOk7v6CJOI7xdyKmId3iTmZY/8fXcqu+14PVltC6CwMe0aJuR/N7S9
# l2V6vSGesy2+wo/QAL/J4sQEg/ArwTzT3Q==
# SIG # End signature block
