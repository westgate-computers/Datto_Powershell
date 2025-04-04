function Set-WOLSettings {
    <#
    .SYNOPSIS
        Function to update the Wake-on-Lan (WOL) settings of a Windows device from the UEFI configuration.

    .DESCRIPTION
        Function checks the manufacturer of the device and attempts to set the WOL state. Supports Dell, HP, and Lenovo devices.
        It attempts to install the required module for the manufacturer if it's not already installed.
        If the manufacturer is Dell, it uses DellBIOSProvider to set the WOL state.
        If the manufacturer is HP, it uses HPCMSL to set the WOL state.
        If the manufacturer is Lenovo, it uses WMI to set the WOL state.

        Disclaimer: This function was also developed with the assistance of OpenAI's ChatGPT.

    .EXAMPLE
        Set-WOLSettings
        # This will update the Wake-on-Lan settings for the local computer based on its manufacturer.

    #>
    [CmdletBinding()]
    param ()

    $result = 0
    $detectSummary = ""

    # Check and install necessary dependencies
    $PPNuGet = Get-PackageProvider -ListAvailable | Where-Object { $_.Name -eq "Nuget" }
    if (!$PPNuget) {
        Write-Host "Installing Nuget provider" -foregroundcolor Green
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
        $detectSummary += "Installed Nuget. "
    }

    $PSGallery = Get-PSRepository -Name PsGallery
    if (!$PSGallery) {
        Write-Host "Installing PSGallery" -foregroundcolor Green
        Set-PSRepository -InstallationPolicy Trusted -Name PSGallery
        $detectSummary += "Installed PsGallery. "
    }

    # Check the manufacturer and get the WOL status
    if ($result -eq 0) {
        Write-Host "Checking Manufacturer" -foregroundcolor Green
        $Manufacturer = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer
        if ($Manufacturer -like "*Dell*") {
            $detectSummary += "Dell system. "
            Write-Host "Manufacturer is Dell. Installing Module and trying to enable WOL state" -foregroundcolor Green
            Write-Host "Installing Dell Bios Provider if needed" -foregroundcolor Green
            $Mod = Get-Module DellBIOSProvider
            if (!$mod) {
                Install-Module -Name DellBIOSProvider -Force
                $detectSummary += "Installed Dell BIOS Provider. "
            }
            Import-Module -Global DellBIOSProvider
            try {
                # Setting the WOL state
                Set-Item -Path "DellSmBios:\PowerManagement\WakeOnLan" -value "LANOnly" -ErrorAction Stop
                $detectSummary += "Dell WoL updated. "
            }
            catch {
                Write-Host "Error occured. Could not update Dell WOL setting."
                $detectSummary += "Error updating Dell WoL setting. "
                $result = -1
            }
        }
        elseif ($Manufacturer -like "*HP*" -or $Manufacturer -like "*Hewlett*") {
            $detectSummary += "HP system. "
            Write-Host "Manufacturer is HP. Installing module and trying to enable WOL State." -foregroundcolor Green
            Write-Host "Installing HP Provider if needed." -foregroundcolor Green
            $Mod = Get-Module HPCMSL
            if (!$mod) {
                Install-Module -Name HPCMSL -Force -AcceptLicense
                $detectSummary += "Installed HP BIOS provider. "
            }
            Import-Module -Global HPCMSL
            try {
                $WolTypes = get-hpbiossettingslist | Where-Object { $_.Name -like "*Wake On Lan*" }
                ForEach ($WolType in $WolTypes) {
                    Write-Host "Setting WOL Type: $($WOLType.Name)"
                    Set-HPBIOSSettingValue -name $($WolType.name) -Value "Boot to Hard Drive" -ErrorAction Stop
                }
                $detectSummary += "HP WoL updated. "
            }
            catch {
                write-host "Error occured. Could not update HP WOL state"
                $detectSummary += "Error updating HP WoL setting. "
                $result = -1
            }
        }
        elseif ($Manufacturer -like "*Lenovo*") {
            $detectSummary += "Lenovo system. "
            Write-Host "Manufacturer is Lenovo. Trying to set WOL via WMI" -foregroundcolor Green
            try {
                Write-Host "Setting BIOS." -foregroundcolor Green
                (Get-WmiObject -ErrorAction Stop -class "Lenovo_SetBiosSetting" -namespace "root\wmi").SetBiosSetting('WakeOnLAN,Primary') | Out-Null
                Write-Host "Saving BIOS." -foregroundcolor Green
                (Get-WmiObject -ErrorAction Stop -class "Lenovo_SaveBiosSettings" -namespace "root\wmi").SaveBiosSettings() | Out-Null
                $detectSummary += "Lenovo WoL updated. "
            }
            catch {
                write-host "Error occured. Could not update Lenovo WOL state"
                $detectSummary += "Error updating Lenovo WoL setting. "
                $result = -1
            }
        }
        else {
            $detectSummary += "$($Manufacturer) not supported by script. "
            $result = -2
        }

        Write-Host "Setting NIC to enable WOL" -ForegroundColor Green
        # Get all network adapters with Wake-on-Lan capability
        $NicsWithWake = Get-CimInstance -ClassName "MSPower_DeviceWakeEnable" -Namespace "root/wmi"

        # Check if any NICs are found
        if ($NicsWithWake) {
            # Loop through each NIC
            foreach ($Nic in $NicsWithWake) {
                Write-Host "Attempting to enable WOL for NIC in OS" -ForegroundColor green
                # Try block for error handling
                try {
                    # Set the Enable property to true to enable Wake-on-Lan
                    Set-CimInstance -InputObject $NIC -Property @{Enable = $true } -ErrorAction Stop
                    Write-Host "Successfully enabled WOL for NIC $($Nic.InstanceName)" -ForegroundColor Green
                    $detectSummary += "$($Nic.InstanceName) WOL Enabled. "
                }
                catch {
                    # Catch and display any errors that occur during the execution
                    Write-Host "Failed to enable WOL for NIC $($Nic.InstanceName). Error: $_" -ForegroundColor Red
                    $detectSummary += "$($Nic.InstanceName) WOL set error. "
                }
            }
        } else {
            Write-Host "No NICs with Wake-on-Lan capability found." -ForegroundColor Yellow
            $detectSummary += "No WOL NICs found. "
        }

    }

    # Return the result
    return @{
        Result = $result
        Summary = $detectSummary
    }
}


$WoLSettings = Set-WOLSettings
$WoLResult = $WoLSettings.Result
$WoLSummary = $WoLSettings.Summary

#Return result
if ($WoLResult -eq 0) {
    Write-Host "OK $([datetime]::Now) : $($WoLSummary)"
    Exit 0
}
elseif ($WoLResult -eq 1) {
    Write-Host "WARNING $([datetime]::Now) : $($WoLSummary)"
    Exit 1
}
else {
    Write-Host "NOTE $([datetime]::Now) : $($WoLSummary)"
    Exit 0
}