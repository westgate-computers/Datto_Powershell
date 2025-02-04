################## Remove_Old_Dotnet_Versions #######################
# Describe script here: List how to use the script, list input      #
# arguements, return values and exit codes                          #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 11/06/2023 - Created Script                                       #
# 12/19/2023 - add .NET 3.1.32 removal, create UninstallByName func #

#####################################################################

trap {
    Write-Host "An error occurred: $_"
    exit 1
}

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

# Function to retrieve installed .NET versions
function Get-InstalledDotNetVersions {
    return Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
        Where-Object { $_.DisplayName -match "Microsoft .NET" } |
        Select-Object DisplayName, DisplayVersion, UninstallString, PSChildName
}

# Function to uninstall .NET versions
function UninstallByName {
    param (
        [string]$AppName,
        [string]$UninstallString,
        [string]$PSChildName
    )

    Write-Host "Uninstalling: $AppName (Version: $PSChildName)" -ForegroundColor Yellow

    if ($UninstallString) {
        if ($UninstallString -match "msiexec") {
            Start-Process -FilePath "msiexec.exe" -ArgumentList "/x $PSChildName /quiet /norestart" -NoNewWindow -Wait
        } else {
            Start-Process -FilePath "cmd.exe" -ArgumentList "/c $UninstallString /quiet /norestart" -NoNewWindow -Wait
        }
        Write-Host "Uninstalled $AppName" -ForegroundColor Green
    } else {
        Write-Host "No uninstall string found for $AppName!" -ForegroundColor Gray
    }
}

# Function to download and install .NET
function InstallDotNet {
    param (
        [string]$DownloadUrl,
        [string]$InstallerFile
    )

    Write-Host "Downloading .NET installer from $DownloadUrl..."
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $InstallerFile

    if (Test-Path $InstallerFile) {
        Write-Host "Installing .NET from $InstallerFile..."
        Start-Process -FilePath $InstallerFile -ArgumentList "/quiet /norestart" -NoNewWindow -Wait
        Write-Host "Installation completed." -ForegroundColor Green
        Remove-Item -Path $InstallerFile -Force
    } else {
        Write-Host "Download failed! Unable to install .NET." -ForegroundColor Red
    }
}

# Get installed .NET versions
$installedDotNet = Get-InstalledDotNetVersions

# Define supported .NET versions (Major.Minor.Patch)
$supportedVersions = @("8.0.12")  # Adjust this list as needed

# Filter unsupported versions dynamically
$unsupportedDotNet = $installedDotNet | Where-Object {
    if ($_.DisplayVersion -match "(\d+\.\d+\.\d+)") {
        $fullVersion = $matches[1]
        return $fullVersion -and $fullVersion -notin $supportedVersions
    }
    return $false
}

# Display detected versions
Write-Host "`nInstalled .NET Versions:"
$installedDotNet | ForEach-Object { Write-Host "$($_.DisplayName) - $($_.DisplayVersion)" }

# Uninstall unsupported versions
if ($unsupportedDotNet) {
    Write-Host "`nRemoving unsupported .NET versions..."
    foreach ($app in $unsupportedDotNet) {
        UninstallByName -AppName $app.DisplayName -UninstallString $app.UninstallString -PSChildName $app.PSChildName
    }
} else {
    Write-Host "`nNo unsupported .NET versions found."
}

# Define latest .NET installer URLs (Update these dynamically)
$dotNetInstallers = @(
    @{ Version = "8.0.12"; URL = "https://download.visualstudio.microsoft.com/download/pr/976226c0-41dc-49ba-ad3c-14ed3f55294d/adfedbe9509adcca236e9035d0ba7d0a/dotnet-hosting-8.0.12-win.exe" }
)

# Install the latest versions
Write-Host "`nInstalling latest .NET versions..."
foreach ($dotNet in $dotNetInstallers) {
    $InstallerPath = "$env:TEMP\dotnet-runtime-$($dotNet.Version).exe"
    InstallDotNet -DownloadUrl $dotNet.URL -InstallerFile $InstallerPath
}

Write-Host "`nProcess complete."


exit $LASTEXITCODE
# SIG # Begin signature block
# MIIIuAYJKoZIhvcNAQcCoIIIqTCCCKUCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAdH3aqYbiDfWjD
# 1DusObpe9UO8D2VTdlS2m9wMYUe6HqCCBfowggX2MIIE3qADAgECAhMgAAAAJTk+
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
# 9w0BCQQxIgQgnFYevz94tdHkST3VGPBbCkMXDNTVaqbNA+NqsY4LZsUwDQYJKoZI
# hvcNAQEBBQAEggEAl65heULx3MtsMhnbhtlZ+Qx10zSO3832/OXhbq+jkyX1urY6
# bip67EGvlfXEveVQIM7jyeV0pdYPf5A3/G2mwyoxS+9V67dNIvBMnrpVtpIvoktU
# f89MydHf9Dby4bgdto510i7rs08gi9IcazjPvSZcRMLLhsvZRAsbwbcZoMKcrQcC
# CLz0II10HQEAgnwIyxyfjM1BnJJuSk/2stDdt6mCjTAFoHmXhOWcO8ZFCeFpIsVe
# YYtk0lDDAb8fkXDkei6XGK81nlfi2r835LJQjr/LTBu9/Xh16MqH1vMxG2x6uLlI
# fsDDDFrLjL7kpKqjdmw9YYtGM63F2Dx4Qt0BtA==
# SIG # End signature block
