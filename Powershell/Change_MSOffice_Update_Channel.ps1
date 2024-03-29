################ Change_MSOffice_Update_Channel #####################
# Describe script here: List how to use the script, list input      #
# arguements, return values and exit codes                          #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 08/18/2023 - add Script to Datto                                  #

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

<#
##########################################################
#Script Description: it is used to change office 365 update channel
#Author: Selcuk ERGUL
#Date Created: 30/09/2021
#Version: V1.0 - First relase.
List of Office 365 Update Channels: 
Monthly   Enterprise Channel
CDNBaseUrl =   http://officecdn.microsoft.com/pr/55336b82-a18d-4dd6-b5f6-9e5095c314a6

Current   Channel 
CDNBaseUrl =   http://officecdn.microsoft.com/pr/492350f6-3a01-4f97-b9c0-c7c6ddf67d60

Current   Channel (Preview)
CDNBaseUrl =   http://officecdn.microsoft.com/pr/64256afe-f5d9-4f86-8936-8840a6a4f5be

Semi-Annual   Enterprise Channel
CDNBaseUrl =   http://officecdn.microsoft.com/pr/7ffbc6bf-bc32-4f92-8982-f9dd17fd3114

Semi-Annual   Enterprise Channel (Preview)
CDNBaseUrl =   http://officecdn.microsoft.com/pr/b8f9b850-328d-4355-9145-c59439a0c4cf

Beta Channel
CDNBaseUrl =   http://officecdn.microsoft.com/pr/5440fd1f-7ecb-4221-8110-145efaa6372f
#>	

$UpdateChannel = "http://officecdn.microsoft.com/pr/492350f6-3a01-4f97-b9c0-c7c6ddf67d60"
$CTRPath = "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration"
$CDNBaseUrl = Get-ItemProperty -Path $CTRPath -Name "CDNBaseUrl" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty "CDNBaseUrl"
if ($CDNBaseUrl -ne $null) {
    if ($CDNBaseUrl -notmatch $UpdateChannel) {
        # Set new update channel
        Set-ItemProperty -Path $CTRPath -Name "CDNBaseUrl" -Value $UpdateChannel -Force
		if($?){Datto_Output("CDNBaseUrl has been changed as Current Channel")}
		else {Datto_Output("CDNBaseUrl has not been changed as Current Channel")}
        # Trigger hardware inventory
        Invoke-WmiMethod -Namespace "root\ccm" -Class "SMS_Client" -Name "TriggerSchedule" -ArgumentList "{00000000-0000-0000-0000-000000000001}"
    }
	else
	{Datto_Output("update channel is already as Current Channel and CDNBaseUrl is $CDNBaseUrl")}
}
else
{Datto_Output("CND Base Url registery key does not exsist.")}