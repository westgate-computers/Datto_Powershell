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
# MIIIuAYJKoZIhvcNAQcCoIIIqTCCCKUCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDvpsth6iAB9og/
# 7qU/PgPnIMCut31jRm30/nqX7hmxnqCCBfowggX2MIIE3qADAgECAhMgAAAAJTk+
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
# 9w0BCQQxIgQg0sCXFz3TeLHUYhtMUu7mKOyI9Gohq6HwT3QzLClD3CYwDQYJKoZI
# hvcNAQEBBQAEggEAkNHANOrICxLoiLGW738olrFhaBXTg2d+7VTf5BPoS30g0jHi
# +OSo1d4PfyJEKdZV0q+ZG9HPrNiJa9ir3laWpy1ja3H8MzHsVdMw+2k3CyJkrYym
# YVFMz6GMKAL+CKigCvbeJx+lxr5gXo9XgdhIXv1/5niZF3ZwN8jsSoRH8pN9LnUh
# Y9sqwuQz+cqvsq0b7yzJkW4LV26RHzcHCoFL7JeX6juRvXGPI62FTaivrajLNfcI
# 94UW6faIH0+OcdiA5B3LiNqUyeNTzYR6HrPJp/k+nzgRQp4pyWUuTBANyqdJP0ib
# 9Ghd5abmMVuV0/xyn9JRBeB39kQZYQ6TUxfHww==
# SIG # End signature block
