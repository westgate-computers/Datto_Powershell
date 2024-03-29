##################### Create_svcNessus_User #########################
# Describe script here: Setup Workstations for credentialed nessus  #
# scans. This script assumes you're working with a site that has    #
# a domain, domain controller and that you've setup the 'Nessus     #
# Local Access' security group and GPO. To set up these groups see  #
# tenable's docs:                                                   #
# https://docs.tenable.com/nessus/Content/CredentialedChecksOnWindows.htm#Link-the-GPO

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 08/30/2023 - Copied from Create_svcNessus_User.ps1                #
# removed setup bits that are set by GPO leaving only admin shares,
# file and print, and remote registry. 

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

# Enable admin shares and allow access to them: 
Set-ItemProperty -Name AutoShareWks -Path HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters -Value 1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "LocalAccountTokenFilterPolicy" /t REG_DWORD /d 1 /f

# Allow File and Print Sharing: 
Enable-NetFirewallRule -Name FPS-SMB-In-TCP

# Set Remote Registry to manual if not already set. Nessus will start the service IF the option to do so is selected: 
$RemoteRegistryService = Get-Service | Where {$_.name –eq 'RemoteRegistry'} | select -Property StartType
if($RemoteRegistryService."StartType" -ne "Manual")
{
    Set-Service -Name RemoteRegistry -StartupType Manual
}
