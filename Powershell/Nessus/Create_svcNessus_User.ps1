##################### Create_svcNessus_User #########################
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
# 12/11/2023 - set password to not expire even if user exists       #

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

$op = Get-LocalUser | where-Object Name -eq "svcNessus" | Measure

if ($op.Count -eq 0) {
    $passwd = ConvertTo-SecureString $env:password -AsPlainText -Force
    New-LocalUser -Name "svcNessus" -Description "Nessus service account" -Password $passwd
    Datto_Output("Created svcNessus user")
}
else {
    Datto_Output("svcNessus user already exists")
}

# add svcNessus to local admin group: 
Add-LocalGroupMember -Group Administrators -Member svcNessus -Verbose

# set svcNessus password to never expire: 
Set-LocalUser -Name "svcNessus" -PasswordNeverExpires 1

# File-n-Print SMB is only allowed on Domain & Private Networks
# Script assumes this is running on a PC that is NOT joined to a Domain.
Set-NetConnectionProfile -NetworkCategory "Private"

# Enable admin shares and allow access to them: 
Set-ItemProperty -Name AutoShareWks -Path HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters -Value 1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "LocalAccountTokenFilterPolicy" /t REG_DWORD /d 1 /f

# Allow File and Print Sharing: 
# Enable-NetFirewallRule -Name FPS-SMB-In-TCP
New-NetFirewallRule -DisplayName "NessusPort139" –RemoteAddress $env:NessusServerIP -Direction Inbound -Protocol TCP –LocalPort 139 -Action Allow
New-NetFirewallRule -DisplayName "NessusPort445" –RemoteAddress $env:NessusServerIP -Direction Inbound -Protocol TCP –LocalPort 435 -Action Allow

Set-NetFirewallRule FPS-SMB-In-TCP -Enabled True
Set-NetFirewallRule FPS-ICMP4-ERQ-In -Enabled True

# Enable WMI through firewall: 
netsh advfirewall firewall set rule group="windows management instrumentation (wmi)" new enable=yes

# Give svcNessus WMI access: (Uses attached script Set-WmiNamespaceSecurity.ps1)
# see https://gist.github.com/Tras2/06670c93199b5621ce2076a36e86f41e for original script 
.\Set-WMINameSpaceSecurity.ps1 -namespace root -operation add -account "svcNessus" -permissions "Enable", "RemoteAccess", "MethodExecute", "ReadSecurity"

# Set Remote Registry to manual if not already set. Nessus will start the service IF the option to do so is selected: 
$RemoteRegistryService = Get-Service | Where {$_.name –eq 'RemoteRegistry'} | select -Property StartType
if($RemoteRegistryService."StartType" -ne "Manual")
{
    Set-Service -Name RemoteRegistry -StartupType Manual
}

# Disable UAC Prompt - Nessus doesn't scan non-domain joined hosts properly without these set: 
Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name EnableLUA -Value 0
Write-Host "EnableLUA set to 0"

Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name LocalAccountTokenFilterPolicy -Value 1
Write-Host "LocalAccountTokenFilterPolicy set to 1"

Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0
Write-Host "ConsentPromptBehaviorAdmin set to 0"
Datto_Output("Create svcNessus User complete.")