############################ mount_drive ############################
# Mounts remote drive to local file system                          #
# Takes $env:MountDrive (Network share path) and                    #
# $env:DriveLetter (Mounted drive letter) as arguements.            #
# if $env:DriveLetter isn't specified a random one is chosen        #
# If mount isn't available on system, falls back to New-PSDrive     #
# Exits 1 on error and 0 on success                                 #
#####################################################################
# Author: Walker Chesley                                            #
# Change List:                                                      #
# 04/26/2023 - Created Script                                       #
#                                                                   #
#####################################################################

# General Variables for Datto: 
$StartResult = Write-Host "<-Start Result->"
$EndResult = Write-Host "<-End Result->"

# Verify Datto env vars to mount drive are specified
# $env:MountDrive should be in the format: \\<computername>\<sharename>
if ($env:MountDrive -eq "") {
    $StartResult
    Write-Error "No Path Specified to Mount, path is set to: $env:MountDrive"
    $EndResult
    exit 1
}

# Check if drive letter is specified, if not, use first available letter
# $env:MountLetter
if ($env:MountLetter -eq "") {
    $env:MountLetter -eq "*"
}

# Check that we can use mount command and mount drive:
try {
    mount $env:MountDrive $env:MountLetter
    $StartResult
    Write-Host "Mouned $env:MountDrive to $env:MountLetter"
    $EndResult
    exit 0
}
# If mount is not available, fall back to New-PSDrive: 
catch [CommandNotFoundException] {
    $StartResult
    Write-Host "Mount command not found, falling back to New-PSDrive"
    $EndResult
    try {
        New-PSDrive -Name "$env:MountLetter" -Root "$env:MountDrive" -Persist -PSProvider 'FileSystem'
        $StartResult
        Write-Host "Mouned $env:MountDrive to $env:MountLetter"
        $EndResult
        exit 0
    }
    catch {
        $StartResult
        Write-Host "Failed to mount Drive `n$Error[0]"
        $EndResult
        exit 1
    }
}
catch {
    $StartResult
    Write-Host "Failed to mount Drive `n$Error[0]"
    $EndResult
    exit 1
}

# SIG # Begin signature block
# MIIIuAYJKoZIhvcNAQcCoIIIqTCCCKUCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBeMxq/yo0YW3HR
# OBxu+G31pxjZLsx+IJl3kzsn20KejqCCBfowggX2MIIE3qADAgECAhMgAAAAJTk+
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
# 9w0BCQQxIgQgBmPSjyT2x6qnAS6EtsDfLf1hAjkOxvaQaJ2GBi8Xq68wDQYJKoZI
# hvcNAQEBBQAEggEAK8lmDRjgWbWzQcrHXfFwEMyuGnlG6jYd0BEGvFKJDLBGfO+b
# Bh7o3fV88c1c+/ddCus6DlfjJFBJBq07BF/LoNJiktAXZ6e8kmqUg5+5h6cTgEl0
# LaJWk+TmJGXJWYGL6LI/plRjyyv/GhiWB5yPvZB1lgbbzDXkXG2cnTofhvgWZqTb
# UsgydTcslBCqkj+/vvQIkqu3hQ6ja1w0m3brfkTk5XaOzwdfUsYe03CVAoOXz0yB
# WvUj1gldy/ckkWNaO2EYKyw1TwWfopoT1lL+BITAeZ11m0YXkWxMnZjNlis1wa6t
# p6qGo0gn/C37W8YXlwUH6ZNuXwgRKYo+dvIFxg==
# SIG # End signature block
