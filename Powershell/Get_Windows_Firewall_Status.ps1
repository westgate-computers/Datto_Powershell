######################## Script_Template ############################
# Description: Query windows firwall status with 
# `Get-NetFirewallProfile` and `netsh`. Outputs firewall profile 
# name, it's status (enabled or not), and Inbound and Outbound 
# actions. Also outputs firewall in use by the system (3rd party 
# firewall check, for built-in will output 
# "Windows Defender Firewall"

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 06/21/2024 - Created Script                                       #

#####################################################################

# Env Variable changes: 
$ErrorView = 'NormalView'
$ErrorActionPreference = 'Stop'

function Get-FirewallStatus {
    [cmdletBinding()]
    param (
        [string]$ComputerName = (Get-WmiObject Win32_ComputerSystem).Name 
    )

    # Resolve the computer name to ensure it is reachable
    try {
        $resolvedName = [System.Net.Dns]::GetHostEntry($ComputerName).HostName
        Write-Host "Resolved computer name: $resolvedName"
    } catch {
        Write-Host "Failed to resolve computer name: $ComputerName"
        return
    }

    # Check Windows Defender Firewall status
    Write-Host "Checking Windows Defender Firewall status on $resolvedName..."
    try {
        $firewallProfiles = Get-NetFirewallProfile -PolicyStore activestore

        foreach ($profile in $firewallProfiles) {
            $profileName = $profile.Name
            $enabled = $profile.Enabled
            $defaultInboundAction = $profile.DefaultInboundAction
            $defaultOutboundAction = $profile.DefaultOutboundAction

            Write-Host "Profile: $profileName"
            Write-Host "  Enabled: $enabled"
            Write-Host "  Default Inbound Action: $defaultInboundAction"
            Write-Host "  Default Outbound Action: $defaultOutboundAction"
        }
    } catch {
        Write-Host "Failed to retrieve Windows Defender Firewall status on $resolvedName"
    }

    # Check third-party firewall status
    Write-Host "Checking third-party firewall status on $resolvedName..."
    try {
        $fireWallName = ((netsh advfirewall show global | where {$_ -match "BootTimeRuleCategory"}) -split "  ")[-1];
        Write-Host "Firewall Name: $fireWallName";
    } catch {
        Write-Host "Failed to retrieve third-party firewall status on $ComputerName"
    }
}

# Run the function
Get-FirewallStatus