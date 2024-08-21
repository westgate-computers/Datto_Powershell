################## Remediate_Sweet32_Vul ############################
# Describe script here: Script edits registry of system and         #
# disables 3DES, DES and RC4 SSL Ciphers.                           #
# Run with caution as this might break legacy applications          #
#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 08/08/2023 - Created Script                                       #
#                                                                   #
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
    $StartResult = Write-Host "<-Start Result->" #6>&1
    $EndResult = Write-Host "<-End Result->" #6>&1
    
    $StartResult
    Write-Host "$message"
    $EndResult
}

# Disable DES/3DES
$reg = Get-Item HKLM:
$key = 'SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers'
$RegistryKey = "Enabled"
$KeyValue = "0"
#KEY1
$subkey = ("Triple DES 168")
$RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168'
$key = $reg.OpenSubKey($key, $true)
$key.CreateSubKey($subkey)
if ((Test-Path -Path $RegistryPath)) {
    (New-ItemProperty -Path $RegistryPath -Name $RegistryKey -Value $KeyValue -PropertyType DWORD -Force)
    Datto_Output("Disabled 3DES 168")
}
else {
    Datto_Output("Failed to disable 3DES 168")
}

#KEY2
$reg = Get-Item HKLM:
$key = 'SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers'
$subkey = ("DES 56/56")
$RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\DES 56/56'
$key = $reg.OpenSubKey($key, $true)
$key.CreateSubKey($subkey)
if ((Test-Path -Path $RegistryPath)) {
    (New-ItemProperty -Path $RegistryPath -Name $RegistryKey -Value $KeyValue -PropertyType DWORD -Force)
    Datto_Output("Disabled DES 56/56")
}
else {
    Datto_Output("Failed to disable DES 56/56")
}

# Disable RC4
$reg = Get-Item HKLM:
$key = 'SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers'
$RegistryKey = "Enabled"
$KeyValue = "0"

#KEY1
$subkey = ("RC4 40/128")
$RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 40/128'
$key = $reg.OpenSubKey($key, $true)
$key.CreateSubKey($subkey)
if ((Test-Path -Path $RegistryPath)) {
    (New-ItemProperty -Path $RegistryPath -Name $RegistryKey -Value $KeyValue -PropertyType DWORD -Force)
    Datto_Output("Disabled RC4 40/128")
}
else {
    Datto_Output("Failed to disable RC4 40/128")
}

#KEY2
$reg = Get-Item HKLM:
$key = 'SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers'
$subkey = ("RC4 56/128")
$RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 56/128'
$key = $reg.OpenSubKey($key, $true)
$key.CreateSubKey($subkey)
if ((Test-Path -Path $RegistryPath)) {
    (New-ItemProperty -Path $RegistryPath -Name $RegistryKey -Value $KeyValue -PropertyType DWORD -Force)
    Datto_Output("Disabled RC4 56/128")
}
else {
    Datto_Output("Failed to disable RC4 56/128")
}

#KEY3
$reg = Get-Item HKLM:
$key = 'SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers'
$subkey = ("RC4 64/128")
$RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 64/128'
$key = $reg.OpenSubKey($key, $true)
$key.CreateSubKey($subkey)
if ((Test-Path -Path $RegistryPath)) {
    (New-ItemProperty -Path $RegistryPath -Name $RegistryKey -Value $KeyValue -PropertyType DWORD -Force)
    Datto_Output("Disabled RC4 64/128")
}
else {
    Datto_Output("Failed to disable RC4 64/128")
}

#KEY4
$reg = Get-Item HKLM:
$key = 'SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers'
$subkey = ("RC4 128/128")
$RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 128/128'
$key = $reg.OpenSubKey($key, $true)
$key.CreateSubKey($subkey)
if ((Test-Path -Path $RegistryPath)) {

    (New-ItemProperty -Path $RegistryPath -Name $RegistryKey -Value $KeyValue -PropertyType DWORD -Force)
    Datto_Output("Disabled RC4 128/128")
}
else {
    Datto_Output("Failed to disable RC4 128/128")
}