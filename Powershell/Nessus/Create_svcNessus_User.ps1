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
# SIG # Begin signature block
# MIIIvgYJKoZIhvcNAQcCoIIIrzCCCKsCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBY5g3VfTeC1JlP
# 7kj6OfGu+sQ6yR+ij2qQqp4L6EA1RqCCBfcwggXzMIIE26ADAgECAhMgAAAAFmQu
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
# NE1hS/lI3CECKUoA5598UusxggIdMIICGQIBATBrMFQxFTATBgoJkiaJk/IsZAEZ
# FgVsb2NhbDEcMBoGCgmSJomT8ixkARkWDHdlc3RnYXRlY29tcDEdMBsGA1UEAxMU
# d2VzdGdhdGVjb21wLURDMDEtQ0ECEyAAAAAWZC7cZNqNpo4AAAAAABYwDQYJYIZI
# AWUDBAIBBQCggYQwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0B
# CQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAv
# BgkqhkiG9w0BCQQxIgQgmH6cl3Z2BrdM0YeYcHZF2SPqAgcqrFDNVxV1NoLABC0w
# DQYJKoZIhvcNAQEBBQAEggEAiBjk5dIgH3JNWokFA8OHf4dBIloQCzQr3ERL+oy1
# ByGtIhhB3tIXHBZZoAsw25gOhnmpl1D8u34unhYq2VzV8hM8/Mg1Tqqzk9TgiZ4G
# IiAuWcLslTKlu8MdjZXhLi9ycwJdzGyyvdhH+0QwHdQikfhHd/2mtNfTIROSazUv
# Z7LVdJxD8cPt0Qw8NO5DKekFnQZ2SG9pk3v6y37e2orVEIr28sjr016avAmogx4V
# k8vRlaCAnBA/c22fpTWzUSjy+8T8BRjWiCgkxSih2vbsKcjkM2RH4EM0AdiejOYI
# PfMfXhL/S7/3NPL6rQjUAzNTebeqZSsD1csr9AHpLApRxw==
# SIG # End signature block
