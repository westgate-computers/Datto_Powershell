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
# MIIItQYJKoZIhvcNAQcCoIIIpjCCCKICAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAvCfdCw66MCSbB
# yUyEQ8YIJlmx1Dzzo8KA9dt1ugMvl6CCBfcwggXzMIIE26ADAgECAhMgAAAAFmQu
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
# CQQxIgQg9bNaf4JddmZzRDDtDV0bx3NXLPIUuue1eaF0P7GwGZswDQYJKoZIhvcN
# AQEBBQAEggEAORuUvrIhKBny7M4W+LDkXHYasMutUQl5ckvhCze9kgKBhhf76S28
# +mNTZAgW1q1c4r1fRRTqi+efc49H5gPA1yzbBqMlFfalxLVqtYlp4yWF3FqnUNXk
# U3DixB/ELOFLJBvCAo+hyrVSaypUSEqlkssyuVxhDANm/lKZW9bv32jWcf3j8OOO
# 9l7f5EHxu2fqWPgUIaC7JK/pNnECMMbdQQ7EBQwp7RMXlFfS1rooL/bwTn7oSGdH
# cg+AQ5/UwJ4fUPpZ55fAJQa2B/n0sejRrYKBY13Czdo2gZiOkpQt05UDAJmQ9/1B
# 1W5n8jYZJDMBn2mpvDBn2NSz39xKHJlfbQ==
# SIG # End signature block
