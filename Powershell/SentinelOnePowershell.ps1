######################## SentinelOnePowershell ######################
# Installer script for SentinelOne, to be used with Datto RMM.      #
# Script expects that SentinelOne installer is packaged with Datto  #
# Component. Requires SentinelOne token as S1SiteToken in Component #

#####################################################################
# Author: Billy Robbins, Brandon Terry, Walker Chesley              #
# Change List: List your changes here:                              #
# 04/01/2022 - Created Script                                       #
# 05/17/2023 - WC: Added script to template, changed install        #
# command to 'start-process' rather than & .\SentinelInstaller.exe  #
# added exit codes.
# 10/20/2023 - Add function to remove SentinelOne folders on failed
# install. Implement this function on error, before exit 1 call. 
# Change 'start-process' call to 'Invoke-Expression' as per this 
# article: https://stackoverflow.com/questions/4639894/executing-an-exe-file-using-a-powershell-script
# ~ wchesley

#####################################################################

#Stop the installer process if it is already running
Stop-Process -Name "SentinelInstaller" -Force

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

function RemoveSentinelOne {
    param(
        # Sentinel One path
        # either ProgramData or nothing where no arg removes Sentinel in Program Files
        # and ProgramData removes Sentinel in ProgramData folder. 
        $path
    )
    $SentinelPath = ""
    switch ($path) {
        "ProgramData" {$SentinelPath = "C:\ProgramData\Sentinel"}
        Default { $SentinelPath = "C:\Program Files\SentinelOne"}
    }

    try {
        Remove-Item -Recurse -Force -Path "$SentinelPath"
        Write-Host "Removed Sentinel One from $SentinelPath"
    }
    catch {
        Write-Error $Error
    }
}

# Env Variable changes: 
$ErrorView = 'NormalView'
$ErrorActionPreference = 'Stop'

$software = "Sentinel Agent"
$directory = "C:\temp\Westgate"
$installed = (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where { $_.DisplayName -contains $software }) -ne $null
$token = $env:S1SiteToken

If ((Get-WmiObject win32_operatingsystem | Select-Object osarchitecture).osarchitecture -eq "64-bit")
{
    #Check whether SentinelOne is already installed, then install it if necessary
    If (-Not $installed) {
        New-Item -ItemType Directory -Force -Path $directory
        Datto_Output("'$software' was not found, attempting to install.")
        start-process -Wait -FilePath ".\SentinelInstaller.exe" -ArgumentList "/q /t $token" -PassThru
        If ($installed) {
            Write-output "'$software' is now installed."
            Exit 0;
        }
        else {
           Write-output "'$software' did not install correctly."
           RemoveSentinelOne("")
           RemoveSentinelOne("ProgramData")
           Exit 1; 
        }
    }
}

elseif ((Get-WmiObject win32_operatingsystem | Select-Object osarchitecture).osarchitecture -eq "32-bit") {
    <# Action when this condition is true #>
    $installed = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where { $_.DisplayName -contains $software }) -ne $null
    #Check whether SentinelOne is already installed, then install it if necessary
    If (-Not $installed) {
        New-Item -ItemType Directory -Force -Path $directory
        Datto_Output("'$software' was not found, attempting to install.")
        Invoke-Expression "& '.\SentinelInstaller.exe' /q /t $token"
        If ($installed) {
            Write-output "'$software' is now installed."
            Exit 0;
        }
        else {
           Write-output "'$software' did not install correctly."
           RemoveSentinelOne("")
           RemoveSentinelOne("ProgramData")
           Exit 1; 
        }
    }
}
else {
    Write-output "'$software' was already installed."
    Exit 0;
}
# SIG # Begin signature block
# MIIIuAYJKoZIhvcNAQcCoIIIqTCCCKUCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCB0NJI+X3WeXpI+
# ulZEzBFQ/oO1PVfd5Szq4yZf58Cm+aCCBfowggX2MIIE3qADAgECAhMgAAAAJTk+
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
# 9w0BCQQxIgQgf+72ZZc9sk7TeG14Qg/yRv57Ny0O8ncfsXnUSxKqwTkwDQYJKoZI
# hvcNAQEBBQAEggEAz08Q0NcBkb2/CyHIup33pT+h67D8BUF3lC9OuXg7LFFqOL+N
# 6NygQucFBQAxSfkjH8lifnAHi6vTwXNhyPFX5x+0MgJqV/yuyO48qdjJtvikCjn2
# V2gI7VyV9Kifpt/SQFy7rEVCf1vhErmapQmmmYyN5h9hrRg8PUHegyx0G97uJXsU
# pFiFOHO6quDJdai5A2ENATNM8Iy3zy6MLl4uidoJGvB+Jyn3SQsce+MuIzT4sICc
# HNTN/Q3mSR++TMwwXTN4dUCyGeUaZKmBPcssVqRQfMt7ZNRwqzJbKEX+ZBcR1GO/
# ad0hNhO36hYFpJN6w58qjqIKVI1qDhEa0UMv1A==
# SIG # End signature block
