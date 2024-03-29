###################### Enable_Cert_Padding ##########################
# Describe script here: List how to use the script, list input      #
# arguements, return values and exit codes                          #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 03/28/2023 - Created Script                                       #
# 05/18/2023 - Uploaded to Datto                                    #

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