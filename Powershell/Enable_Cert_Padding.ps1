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
# SIG # Begin signature block
# MIIItQYJKoZIhvcNAQcCoIIIpjCCCKICAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAAq+/VTPzvownk
# n0W+2vd74RMFlXeJFzdrlc4EdCNfgaCCBfcwggXzMIIE26ADAgECAhMgAAAAFmQu
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
# NE1hS/lI3CECKUoA5598UusxggIUMIICEAIBATBrMFQxFTATBgoJkiaJk/IsZAEZ
# FgVsb2NhbDEcMBoGCgmSJomT8ixkARkWDHdlc3RnYXRlY29tcDEdMBsGA1UEAxMU
# d2VzdGdhdGVjb21wLURDMDEtQ0ECEyAAAAAWZC7cZNqNpo4AAAAAABYwDQYJYIZI
# AWUDBAIBBQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0BCQMxDAYKKwYB
# BAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0B
# CQQxIgQgz+KHLp6EQAGxxyd05/Xf+OsjSiNkm/cRgk9PKAwJDEwwDQYJKoZIhvcN
# AQEBBQAEggEAq9AQ/HIZX8fwmunOx39+0VyxeLtzHrCvEsJFVM7jyU41/Wov61ug
# yC9U1yQWf42hjwihPhW5H3b+U6m39dm4ty8KGWfhO0xiQSJKPqOLJIuOyXhUazmi
# dgZg2APUv92weAmv7NV04vAjrdS3DqohcXPMhFLDucSf2LkOm7qGLJcQbBWszJwT
# Mo1xBMTjN9Go7NRNaCgBK+nEnXVxchM02wMZWXeoF1LdTWNcZR0bVdtD4+MMu0Fv
# MSNssEC673owaPLFH77zV2VTyVuim+YH0K0eWHP8lmvOUv6oKLzHb5QkjdKnAQv4
# QgBPa6rtwmDdZjaKvBSHz5ielB3/Z7gFHw==
# SIG # End signature block
