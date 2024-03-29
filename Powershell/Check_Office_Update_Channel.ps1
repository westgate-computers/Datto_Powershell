################## Check_Office_Update_Channel ######################
# Description: Iterate over registry and get O365 update URL then   #
# match the URL to update channel and return the result             #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 10/04/2023 - Created Script                                       #

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

$OfficeUpdateChannel = "None"
$CDNBaseUrl = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration" -Name CDNBaseUrl

$UpdateChannel = $CDNBaseUrl.Split('/') | Select -Last 1

switch ($UpdateChannel) {
    "492350f6-3a01-4f97-b9c0-c7c6ddf67d60" { $OfficeUpdateChannel = "Current Channel" }
    "64256afe-f5d9-4f86-8936-8840a6a4f5be" { $OfficeUpdateChannel = "Current Channel (Preview)" }
    "7ffbc6bf-bc32-4f92-8982-f9dd17fd3114" { $OfficeUpdateChannel = "Semi-Annual Enterprise Channel" }
    "b8f9b850-328d-4355-9145-c59439a0c4cf" { $OfficeUpdateChannel = "Semi-Annual Enterprise Channel (Preview)" }
    "55336b82-a18d-4dd6-b5f6-9e5095c314a6" { $OfficeUpdateChannel = "Monthly Enterprise" }
    "5440fd1f-7ecb-4221-8110-145efaa6372f" { $OfficeUpdateChannel = "Beta" }
    "f2e724c1-748f-4b47-8fb8-8e0d210e9208" { $OfficeUpdateChannel = "LTSC" }
    "2e148de9-61c8-4051-b103-4af54baffbb4" { $OfficeUpdateChannel = "LTSC (Preview)" }
    Default { $OfficeUpdateChannel = "Non CTR version / No Update Channel selected"}
}

Datto_Output("Office update channel set to: $OfficeUpdateChannel")