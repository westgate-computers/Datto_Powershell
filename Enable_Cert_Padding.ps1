###################### Enable_Cert_Padding ##########################
# Describe script here: List how to use the script, list input      #
# arguements, return values and exit codes                          #

#####################################################################
# Author: Brandon Terry                                             #
# Change List: List your changes here:                              #
# 03/28/2023 - Created Script                                       #
# 05/18/2023 - WC: Uploaded to Datto                                #
#####################################################################

# General Variables for Datto: 
$StartResult = Write-Host "<-Start Result->"
$EndResult = Write-Host "<-End Result->"

# Wrapper function to output data into Datto
# @param $message = The text you want to output into Datto
function Datto_Output {
    param (
        $message
    )
    $StartResult
    Write-Host "$message"
    $EndResult
}

# Define the name of the registry value to enable
$RegValueName = 'EnableCertPaddingCheck'
$RegValueData = 1

# Check if the machine is 64-bit
if ([Environment]::Is64BitOperatingSystem) {
    # Add the registry value to the 32-bit registry hive
    New-Item -Path 'HKLM:\Software\Wow6432Node\Microsoft\Cryptography\Wintrust\Config' -Force | Out-Null
    New-ItemProperty -Path 'HKLM:\Software\Wow6432Node\Microsoft\Cryptography\Wintrust\Config' -Name $RegValueName -Value $RegValueData -PropertyType DWORD -Force | Out-Null
    Datto_Output("Enabled $RegValueName registry value in Wow6432Node registry hive.")
}

# Add the registry value to the 32-bit registry hive
New-Item -Path 'HKLM:\Software\Microsoft\Cryptography\Wintrust\Config' -Force | Out-Null
New-ItemProperty -Path 'HKLM:\Software\Microsoft\Cryptography\Wintrust\Config' -Name $RegValueName -Value $RegValueData -PropertyType DWORD -Force | Out-Null
Datto_Output("Enabled $RegValueName registry value in 32-bit registry hive.")