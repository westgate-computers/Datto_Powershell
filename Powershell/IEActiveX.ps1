########################### IEActiveX ###############################
# Description: Disable or Enable IEActiveX controls via GUID.       #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 12/11/2023 - Adapted script from: 
# https://mickitblog.blogspot.com/2014/05/powershell-enable-or-disable-internet.html 
# https://github.com/MicksITBlogs/PowerShell/blob/baf3f80e40039706e1f1da7789600af56b5c3010/IEActiveX.ps1

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

# Begin IEActiveX
# Script is adapted from: https://mickitblog.blogspot.com/2014/05/powershell-enable-or-disable-internet.html 
# https://github.com/MicksITBlogs/PowerShell/blob/baf3f80e40039706e1f1da7789600af56b5c3010/IEActiveX.ps1
<#
.SYNOPSIS
   Enable/Disable IE Active X Components
.DESCRIPTION
   
.PARAMETER <paramName>
   <Description of script parameter>
.EXAMPLE
   EnableIEActiveXControl "Application Name" "GUID" "Value"
   EnableIEActiveXControl "Flash for IE" "{D27CDB6E-AE6D-11CF-96B8-444553540000}" "0x00000000"
#>

#Declare Global Memory
Set-Variable -Name Errors -Value $null -Scope Global -Force
Set-Variable -Name LogFile -Value "c:\Temp\IeActiveXLogs\IEActiveX.log" -Scope Global -Force
Set-Variable -Name RelativePath -Scope Global -Force

Function GetRelativePath { 
	$Global:RelativePath = (split-path $SCRIPT:MyInvocation.MyCommand.Path -parent)+"\" 
}

Function DisableIEActiveXControl ($AppName,$GUID,$Flag) {
	$Key = "HKLM:\SOFTWARE\Microsoft\Internet Explorer\ActiveX Compatibility\"+$GUID
	If ((Test-Path $Key) -eq $true) {
		Write-Host $AppName"....." -NoNewline
		Set-ItemProperty -Path $Key -Name "Compatibility Flags" -Value $Flag -Force
		$Var = Get-ItemProperty -Path $Key -Name "Compatibility Flags"
		If ($Var."Compatibility Flags" -eq 1024) {
			Write-Host "Disabled" -ForegroundColor Yellow
		} else {
			Write-Host "Enabled" -ForegroundColor Red
		}
	}
}

Function EnableIEActiveXControl ($AppName,$GUID,$Flag) {
	$Key = "HKLM:\SOFTWARE\Microsoft\Internet Explorer\ActiveX Compatibility\"+$GUID
	If ((Test-Path $Key) -eq $true) {
		Write-Host $AppName"....." -NoNewline
		Set-ItemProperty -Path $Key -Name "Compatibility Flags" -Value $Flag -Force
		$Var = Get-ItemProperty -Path $Key -Name "Compatibility Flags"
		If ($Var."Compatibility Flags" -eq 0) {
			Write-Host "Enabled" -ForegroundColor Yellow
		} else {
			Write-Host "Disabled" -ForegroundColor Red
		}
	}
}

# Example usage: 
#DisableIEActiveXControl "Flash for IE" "{D27CDB6E-AE6D-11CF-96B8-444553540000}" "0x00000400"
#EnableIEActiveXControl "Flash for IE" "{D27CDB6E-AE6D-11CF-96B8-444553540000}" "0x00000000"

# DisableIEActiveXControl "Autodesk IDrop Heap Corruption" "{21E0CB95-1198-4945-A3D2-4BF804295F78}" "0x00000400"
# Keyworks: 
# {B7ECFD41-BE62-11D2-B9A8-00104B138C8C} - C:\Program Files (x86)\Pervasive Software\PSQL\bin\keyhelp.ocx
# {45E66957-2932-432A-A156-31503DF0A681} - C:\Program Files (x86)\Pervasive Software\PSQL\bin\keyhelp.ocx
# {1E57C6C4-B069-11D3-8D43-00104B138C8C} - C:\Program Files (x86)\Pervasive Software\PSQL\bin\keyhelp.ocx

DisableIEActiveXControl "$env:ControlName" "$env:ControlUID" "0x00000400"
# SIG # Begin signature block
# MIIIuAYJKoZIhvcNAQcCoIIIqTCCCKUCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCztii9Xqw304ND
# G7DdYH1V4FFqYrZBWKMS1QT9BiXw3aCCBfowggX2MIIE3qADAgECAhMgAAAAJTk+
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
# 9w0BCQQxIgQgF1a1pvRhyYtUJ7n4kf6uydmLE108Rw3y5bvX0dKFcU4wDQYJKoZI
# hvcNAQEBBQAEggEAV1F8MCIzzMkLFhlRoy6VT5IVirdxxX13/+//881Jv2ZEKuf1
# LwTb/SVucY2V4uKXP87P9Rvj4G/c1Ho8iMFKOUp9Vp5OmpCrY84T7aHRJpLQ2W0j
# bvLSKO4zhDzZqvb76mnoJKxmFHHdYd+Rr7cVNFd+30CKli4/vOZmkM8DevgoqXao
# jEcO9bHSw5nmfnR9gA6x5WaE0Je1EYjWpTdL/lFugIuwUOnlXutALHunFW7/jT6A
# uOd6IqWYYqdZQbPWRhCAlO6w7Il+I76xOzJMxGN8WsN7p+tCJd5JhWrueVAdV4Q0
# ql1SaiUn81oHundn1bUIL4xDoPFHxIc3G3O7bw==
# SIG # End signature block
