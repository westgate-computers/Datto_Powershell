####################### Veeam_svcAct_Setup ###########################
# Describe script here: Creates svcNessus user if it doesn't 
# already exist, does nothing if user exists. 
# takes password as variable from Datto or env. 

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 08/22/2023 - Created Script                                       #
# 08/25/2023 - Change Network to Private                            #
# 08/26/2023 - Allow WMI through firewall, give svcNessus           #
# permissions on WMI, set RemoteRegistry service startup type to    #
# manual.                                                           #
# Explicitly allow TCP ports 139, 445 from Nessus Server            #
# 08/28/2023 - Test if RemoteRegistry StartType set to manual       #
# Adjust paramters for Set-WMINameSpaceSecurity.ps1                 #
# Adjust firewall rules to crate new rule and allow Nessus Server   #
# through required ports.                                           #
# 11/15/2023 - Modified script for usage with Veeam
# re-enabled account creation, username and password are env vars 
# set by Datto. 
# enabled file-and-print sharing in firewall, mirroring how Nessus
# is set up. 
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

# single message object for Datto_Output: 
$message = ""; 
$op = Get-LocalUser | where-Object Name -eq $env:svcVeeam | Measure

if ($op.Count -eq 0) {
    $passwd = ConvertTo-SecureString $env:password -AsPlainText -Force
    New-LocalUser -Name "$env:svcVeeam" -Description "Nessus service account" -Password $passwd
    $message += "Created $env:svcVeeam user`n"
}
else {
    $messsage += "$env:svcVeeam user already exists`n"
}

# $grp = Get-LocalGroupMember -Group Administrators | Where-Object Name -like "*$env:svcVeeam" | Measure

# if ($grp.Count -eq 0){
    # add svcNessus to local admin group: 
    Add-LocalGroupMember -Group Administrators -Member $env:svcVeeam -Verbose
    $message += "Added $env:svcVeeam to local admin group"
# }
# else {
    # $message += "$env:svcVeeam user is already a local admin"
# }

# File-n-Print SMB is only allowed on Domain & Private Networks
# Script assumes this is running on a PC that is NOT joined to a Domain.
Set-NetConnectionProfile -NetworkCategory "Private"

# Enable admin shares and allow access to them: 
Set-ItemProperty -Name AutoShareWks -Path HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters -Value 1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "LocalAccountTokenFilterPolicy" /t REG_DWORD /d 1 /f

# Allow File and Print Sharing: 
# Enable-NetFirewallRule -Name FPS-SMB-In-TCP
New-NetFirewallRule -DisplayName "VeeamPort139" –RemoteAddress $env:VeeamServerIP -Direction Inbound -Protocol TCP –LocalPort 139 -Action Allow
New-NetFirewallRule -DisplayName "VeeamPort445" –RemoteAddress $env:VeeamServerIP -Direction Inbound -Protocol TCP –LocalPort 435 -Action Allow
New-NetFirewallRule -DisplayName "VeeamPort6160" –RemoteAddress $env:VeeamServerIP -Direction Inbound -Protocol TCP –LocalPort 6160 -Action Allow

# Enable File and Print Sharing through firewall: 
Set-NetFirewallRule FPS-SMB-In-TCP -Enabled True
Set-NetFirewallRule FPS-ICMP4-ERQ-In -Enabled True

# Enable WMI through firewall: 
netsh advfirewall firewall set rule group="windows management instrumentation (wmi)" new enable=yes

# Give svcNessus WMI access: (Uses attached script Set-WmiNamespaceSecurity.ps1)
# see https://gist.github.com/Tras2/06670c93199b5621ce2076a36e86f41e for original script 
.\Set-WMINameSpaceSecurity.ps1 -namespace root -operation add -account $env:svcVeeam -permissions "Enable", "RemoteAccess", "MethodExecute", "ReadSecurity"

Datto_Output($message)