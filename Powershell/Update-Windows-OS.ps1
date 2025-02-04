####################### Update_Windows_OS ###########################
# Description:  This script updates windows OS and does not force a #
# reboot of the host.                                               #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 08/11/2023 - Created Script                                       #
# 09/14/2023 - Ensure PSGallery is trusted installation source      #
# 09/29/2023 - Changed ordering of PSGallery and Nuget              #
# 10/02/2023 - Add Get-WuInstall and explicitly request Microsoft   # 
# updates in Install-WindowsUpdate                                  #
# 02-27-2024 - Pipe output C:\windows\temp\update_log.txt           #
# and print to console.                                             #

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

try 
{ 
    # Check if NuGet is installed, if not, install it: 
    if(Get-PackageProvider | Where-Object {$_.Name -eq "Nuget"}) 
    { 
        "Nuget Module already exists" 
    } 

    else 
    { 
        "Installing nuget module" 
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force 
    }

# Add PSGallery and mark it as trusted: 
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
Set-PSRepository -Name 'PSGallery' -SourceLocation "https://www.powershellgallery.com/api/v2" -InstallationPolicy Trusted;

# Check if PSWindowsUpdate exists if not, add it
    if(Get-Module -ListAvailable | where-object {$_.Name -eq "PSWindowsUpdate"}) 
    { 
        "PSWindowsUpdate module already exists" | Tee-Object -FilePath C:\Windows\Temp\Update-Log.txt -Append  
    } 

    else 
    { 
        "Installing PSWindowsUpdate Module" | Tee-Object -FilePath C:\Windows\Temp\Update-Log.txt -Append  
        install-Module PSWindowsUpdate -Force | Tee-Object -FilePath C:\Windows\Temp\Update-Log.txt -Append  
    } 
# Update the OS
    Import-Module -Name PSWindowsUpdate 

    "Starting update -->" + (Get-Date -Format "dddd MM/dd/yyyy HH:mm") | Tee-Object -FilePath C:\Windows\Temp\Update-Log.txt -Append  

    install-WindowsUpdate -MicrosoftUpdate -AcceptAll -ForceDownload -ForceInstall -IgnoreReboot | Tee-Object -FilePath C:\Windows\Temp\Update-Log.txt -Append  

    Get-WuInstall -AcceptAll -IgnoreReboot | Tee-Object -FilePath C:\Windows\Temp\Update-Log.txt -Append  

    "Update completed -->"+ (Get-Date -Format "dddd MM/dd/yyyy HH:mm") | Tee-Object -FilePath C:\Windows\Temp\Update-Log.txt -Append  

} 

catch { 

    Datto_Output($_.Exception.Message) | Tee-Object -FilePath C:\Windows\Temp\Update-Log.txt -Append  

} 
# SIG # Begin signature block
# MIIIuAYJKoZIhvcNAQcCoIIIqTCCCKUCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCC+wibJKy+fzse/
# /Yflpp6lyvjzDPUAG4ZcmddF6WXb5aCCBfowggX2MIIE3qADAgECAhMgAAAAJTk+
# wdvAji8zAAEAAAAlMA0GCSqGSIb3DQEBCwUAMFQxFTATBgoJkiaJk/IsZAEZFgVs
# b2NhbDEcMBoGCgmSJomT8ixkARkWDHdlc3RnYXRlY29tcDEdMBsGA1UEAxMUd2Vz
# dGdhdGVjb21wLURDMDEtQ0EwHhcNMjUwMTIxMjIzNTI4WhcNMjcwMTIxMjI0NTI4
# WjAZMRcwFQYDVQQDEw5XYWxrZXIgQ2hlc2xleTCCASIwDQYJKoZIhvcNAQEBBQAD
# ggEPADCCAQoCggEBANRrq1GdQ8q02316VsSUZe5jcuCA1/rQ0CeICX2iEDV9P7uV
# 5ferUh1dTuDJjpQdVjjYARrV7U0H7c1lF+4DpE4S7IRLsiSJMUqNhdQMn58tu7Yt
# XleNWtRP+bkHX81vtJ1nlnxkdaIOKX7HN86FFclpo7osUt/bKZKBzKSDr6Y18vog
# YG4PIQLtymw/kNbkcHf1+iqW7/MQNevfmorLg06xpeKoEdw9B4CDlKUrXEEXB29y
# QFzrcdQiSX2jKToJOZnS40Ofov3Mi9adYd4fRAOVLLzytjj+vI4Ood2K06Dz8wVo
# zkcmQ2KOTUV+Kcobysc6pWF/FeGbYHvhYflkOpECAwEAAaOCAvowggL2MDwGCSsG
# AQQBgjcVBwQvMC0GJSsGAQQBgjcVCIWPl3mFh8xJg/mNCd2UeoepixJIhp2sbIS1
# w3sCAWQCAQIwEwYDVR0lBAwwCgYIKwYBBQUHAwMwDgYDVR0PAQH/BAQDAgeAMBsG
# CSsGAQQBgjcVCgQOMAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFEiRW0A/zWc2uM0h
# PXDdgXnzVMfMMB8GA1UdIwQYMBaAFLWGbuIuy8p6oshJR2XtcmsxnG+HMIHdBgNV
# HR8EgdUwgdIwgc+ggcyggcmGgcZsZGFwOi8vL0NOPXdlc3RnYXRlY29tcC1EQzAx
# LUNBKDEpLENOPVdHQy1EQzAxLENOPUNEUCxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2
# aWNlcyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPXdlc3RnYXRlY29t
# cCxEQz1sb2NhbD9jZXJ0aWZpY2F0ZVJldm9jYXRpb25MaXN0P2Jhc2U/b2JqZWN0
# Q2xhc3M9Y1JMRGlzdHJpYnV0aW9uUG9pbnQwgc0GCCsGAQUFBwEBBIHAMIG9MIG6
# BggrBgEFBQcwAoaBrWxkYXA6Ly8vQ049d2VzdGdhdGVjb21wLURDMDEtQ0EsQ049
# QUlBLENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2VzLENOPVNlcnZpY2VzLENOPUNv
# bmZpZ3VyYXRpb24sREM9d2VzdGdhdGVjb21wLERDPWxvY2FsP2NBQ2VydGlmaWNh
# dGU/YmFzZT9vYmplY3RDbGFzcz1jZXJ0aWZpY2F0aW9uQXV0aG9yaXR5MDYGA1Ud
# EQQvMC2gKwYKKwYBBAGCNxQCA6AdDBt3Y2hlc2xleUB3ZXN0Z2F0ZWNvbXAubG9j
# YWwwTAYJKwYBBAGCNxkCBD8wPaA7BgorBgEEAYI3GQIBoC0EK1MtMS01LTIxLTg5
# MzYxOTIyNS05ODMxNjM4NDUtNzM0MzcyNDA1LTI2MzMwDQYJKoZIhvcNAQELBQAD
# ggEBADDCZHaD3JqnGAM2Ayp0fjCkZjUJeHLfdLn3DBIVdr9XaxOqfP641az2+fVm
# tDnIDuacTIs70DoGzg33Lmel2liBsif+7NTXRHqk3mFguPeUvDbRuGQjRTnsu5DR
# nv9GdgYdoY+Dwh0eyAb4Rri+AzikMM6hytjy22xtqbfj38E/LjtXBxWtKFV1NO1Y
# xnCUvCCOuERjAnbnI2pe4Yqa8qmG6c5ii6h71V2rP5BXcqVg8EXxMHpYrypPR2F5
# mdk323TPlq58Aqf7df5dMqK5HdSlwphSAZUGzhKEVA5d5pQYujvHjwashLHRXcbo
# U/TmFTV5EvmCXaz8TZKWLJO7XlUxggIUMIICEAIBATBrMFQxFTATBgoJkiaJk/Is
# ZAEZFgVsb2NhbDEcMBoGCgmSJomT8ixkARkWDHdlc3RnYXRlY29tcDEdMBsGA1UE
# AxMUd2VzdGdhdGVjb21wLURDMDEtQ0ECEyAAAAAlOT7B28COLzMAAQAAACUwDQYJ
# YIZIAWUDBAIBBQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0BCQMxDAYK
# KwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG
# 9w0BCQQxIgQg9mcW3hUhMj7nyRLCcGaprgY13PXn6o11HbxdMZfbRrswDQYJKoZI
# hvcNAQEBBQAEggEAQCWeTVfk/NCVSIN2nodVe4VmjrZMTKczdSdvrvhNJ3RG/pyo
# R7IIm1Wpg2d0U+zc9Kp98C8tgOF4MjTzdnITjOKOCtSvn5JXQkDrGIzDBSIGVk30
# 3pdAbWiLK5hThs9k+5yTZirs5lU2v4RRgGDSS8886Em3YRQ0eR5KdNzmgKksUaAT
# Giyv1n+C6VyHUogcEi+VyPmAuKe3kDxraWQFt5lrCWDq+2ySXp7y/lGMCSxiouO7
# 5uChE6oVe1P05m6ned+6ARu6E5zJb0rh5Qv83yWHGuihNLba2qq03Ov/PRYHb3m4
# Rkcp2kumd24662CTJGypzn/NkBZkKlMrNpJ4Sw==
# SIG # End signature block
