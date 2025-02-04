############################ syschk #################################
# Describe script here: List how to use the script, list input      #
# arguements, return values and exit codes                          #
#                                                                   #
#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 04/27/2023 - Created Script                                       #
# 04/28/2023 - Script is working, minus disk information            #
# # 
#####################################################################

# General Script Vars
$output = ""

# TODO: rework other 'ValuesFromList' functions and roll into this one
# function GetCimValuesFromList {
#     param (
#         $CimList,
#         $ValuesList
#     )
#     foreach ($value in $ValuesList) {
#         foreach ($cim in $CimList) {
#             $output += "{$value}: "
#             $output += "$cim.$value"
#         }
#     }
# }

# Pulled from: https://stackoverflow.com/questions/63965384/how-to-convert-the-output-value-stored-in-variable-which-is-in-bytes-into-kb-mb
Function Get-FriendlySize {
    Param([bigint]$bytes)
    switch($bytes){
        {$_ -gt 1PB}{"{0:N2} PB" -f ($_ / 1PB);break}
        {$_ -gt 1TB}{"{0:N2} TB" -f ($_ / 1TB);break}
        {$_ -gt 1GB}{"{0:N2} GB" -f ($_ / 1GB);break}
        {$_ -gt 1MB}{"{0:N2} MB" -f ($_ / 1MB);break}
        {$_ -gt 1KB}{"{0:N2} KB" -f ($_ / 1KB);break}
        default {"{0:N2} Bytes" -f $_}
    }
}

function GetMemoryValuesFromList {
    param (
        $values
    )
    $FormattedEvents += "Memory `nManufacturer - Speed - Location - Capacity`n"
    foreach ($item in $values) {
        $MemCap = Get-FriendlySize($item.Capacity)
        $FormattedEvents += $item.Manufacturer + " - " + $item.Speed + " - " + $item.DeviceLocator + " - " + $MemCap +"`n"
    }
    return $FormattedEvents
}

function GetProcValuesFromList {
    param (
        $values
    )
    $FormattedEvents += "CPU `nName - Caption - DeviceID `n"
    foreach ($item in $values) {
        $FormattedEvents += $item.nName + " - " + $item.Caption + " - " + $item.DeviceID + "`n"
    }
    return $FormattedEvents
}

function GetDiskValuesFromList {
    param (
        $values
    )
    $FormatedEvents += "Disk(s) `nDrive Letter - Capacity - Serial Number - Automount`n"
    foreach ($item in $values) {
        $DiskCap = Get-FriendlySize($item.Capacity)
        $FormatedEvents += $item.Caption + " - " + $DiskCap + " - " + $item.SerialNumber + " - " + $item.Automount + "`n"
    }
    return $FormattedEvents
}

function GetOSValuesFromList {
    param (
        $values
    )
    $FormattedEvents += "OS `nBuild Number - Version - Serial Number`n"
    foreach ($item in $values) {
        $FormattedEvents += $item.BuildNumber + " - " + $item.Version + " - " + $item.SerialNumber + "`n"
    }
    return $FormattedEvents
}

$memory = Get-CimInstance -Class Win32_physicalMemory
$proc = Get-CimInstance -Class Win32_Processor
#$disks = Get-CimInstance -ClassName Win32_Volume
$disks = Get-WmiObject Win32_LogicalDisk -ErrorAction STOP | Select-Object DeviceID,FileSystem,VolumeName,AutoMount, @{Expression={$_.Size /1Gb -as [int]};Label="Total Size (GB)"}, @{Expression={$_.Freespace / 1Gb -as [int]};Label="Free Space (GB)"}
$OS = Get-CimInstance -Class Win32_OperatingSystem
$output += GetMemoryValuesFromList($memory)
$output += GetProcValuesFromList($proc)
$output += GetOSValuesFromList($OS)
#$output += GetDiskValuesFromList($disks)
Write-Host "<-------- Disks -------->"
Write-Host $disks
Write-Host "$output"
# SIG # Begin signature block
# MIIIuAYJKoZIhvcNAQcCoIIIqTCCCKUCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAvCfdCw66MCSbB
# yUyEQ8YIJlmx1Dzzo8KA9dt1ugMvl6CCBfowggX2MIIE3qADAgECAhMgAAAAJTk+
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
# 9w0BCQQxIgQg9bNaf4JddmZzRDDtDV0bx3NXLPIUuue1eaF0P7GwGZswDQYJKoZI
# hvcNAQEBBQAEggEAZoYQvBHk+40kGkoqj9wekHqh82kZLj2twoMhZFzC8leRegPC
# qMNJ/xIqnE27D5gFpd3lCMNqU9hnXQNwf6Gxc/d/F6zk74/csyC3YxholtX9KZOW
# ytdSC8PEwFZwAYHbdqmQBcLlNoEs22K+amNgpFyagDVCwTteELiJTEG1XZk1PmMw
# ibXazDmLAQP4uv/VEoah+7CFwpCl0NH3Mdfid7WI2qWKs6jrhQ19v21IJs9xmwNh
# RclLOMJnADujHiq7isCZFQgA1KICVp9N9n9RAIKht0zt5EUnncINr2q3borg4/3S
# zSr68Q7lE9iHjGi9xVKMiGK8DkFGfu5OKQDN2w==
# SIG # End signature block
