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