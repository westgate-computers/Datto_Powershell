####################### view_msi_database ###########################
# Describe script here: Lists all installed msi's on PC, including  #
# Product code, upgrade code and the Name.                          #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 04/26/2023 - Created Script                                       #
# 08/08/2023 - added redirection for Write-Host variable
# 08/08/2023 - Pulled from https://stackoverflow.com/questions/46637094/how-can-i-find-the-upgrade-code-for-an-installed-msi-file/46637095#46637095

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

$wmipackages = Get-WmiObject -Class win32_product
$wmiproperties = gwmi -Query "SELECT ProductCode,Value FROM Win32_Property WHERE Property='UpgradeCode'"
$packageinfo = New-Object System.Data.Datatable
[void]$packageinfo.Columns.Add("Name")
[void]$packageinfo.Columns.Add("ProductCode")
[void]$packageinfo.Columns.Add("UpgradeCode")

foreach ($package in $wmipackages) 
{
    $foundupgradecode = $false # Assume no upgrade code is found

    foreach ($property in $wmiproperties) {

        if ($package.IdentifyingNumber -eq $property.ProductCode) {
           [void]$packageinfo.Rows.Add($package.Name,$package.IdentifyingNumber, $property.Value)
           $foundupgradecode = $true
           break
        }
    }
    
    if(-Not ($foundupgradecode)) { 
         # No upgrade code found, add product code to list
         [void]$packageinfo.Rows.Add($package.Name,$package.IdentifyingNumber, "") 
    }
}

$packageinfo | Sort-Object -Property Name | Format-table ProductCode, UpgradeCode, Name

# Enable the following line to export to CSV (good for annotation). Set full path in quotes
# $packageinfo | Export-Csv "[YourFullWriteablePath]\MsiInfo.csv"

# copy this line as well
# SIG # Begin signature block
# MIIf9QYJKoZIhvcNAQcCoIIf5jCCH+ICAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDgOfPUu455fIC0
# T4+naYa/NLK2i1wyhyYyhGQhFKB1HaCCBfowggX2MIIE3qADAgECAhMgAAAAJTk+
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
# U/TmFTV5EvmCXaz8TZKWLJO7XlUxghlRMIIZTQIBATBrMFQxFTATBgoJkiaJk/Is
# ZAEZFgVsb2NhbDEcMBoGCgmSJomT8ixkARkWDHdlc3RnYXRlY29tcDEdMBsGA1UE
# AxMUd2VzdGdhdGVjb21wLURDMDEtQ0ECEyAAAAAlOT7B28COLzMAAQAAACUwDQYJ
# YIZIAWUDBAIBBQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0BCQMxDAYK
# KwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG
# 9w0BCQQxIgQguY3dMSQhz3Xh+qo/yxLczYNxYT+SvAPATAOUU0daOsYwDQYJKoZI
# hvcNAQEBBQAEggEAxW2l3z46cYH0zhgVSLy6WEZgdnzgP55L1oLGr1LpxWeaN86R
# +90xn4vCCsJsOW/+1y3XIZrlgCoEAr/q8lY/+Qoa6n5XZ1xokbuAMaFVCTILXoG7
# Z05zeEtsYAcX13roWP9W/Gn0rB+DL3lSpoXNOYd37MFFMIAE34/ZopxL2ajJMjpC
# QYGsCTdGYjKrmjrZ3s/FGw8MQ923WPPerz4F+/aDxskQvFOt300ct6Dlu/XtYkgY
# QUSsswcxsQsfdFpCORRZbDeItttfwmFbf62tH9oqKPju0fnSKAY9cip7cOJ/cpCl
# nCa3frOfCILY7YKY8PhHIuH5/arcOCjNK7PuQ6GCFzkwghc1BgorBgEEAYI3AwMB
# MYIXJTCCFyEGCSqGSIb3DQEHAqCCFxIwghcOAgEDMQ8wDQYJYIZIAWUDBAIBBQAw
# dwYLKoZIhvcNAQkQAQSgaARmMGQCAQEGCWCGSAGG/WwHATAxMA0GCWCGSAFlAwQC
# AQUABCBQMkgZdL2+Gi/rz7bGNfg7p9tTIPVDXo0Sfv1sUHtRdQIQbMe58T7ChAWy
# 5+rE2sLP+RgPMjAyNTAzMDMyMTM4MTdaoIITAzCCBrwwggSkoAMCAQICEAuuZrxa
# un+Vh8b56QTjMwQwDQYJKoZIhvcNAQELBQAwYzELMAkGA1UEBhMCVVMxFzAVBgNV
# BAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0
# IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTAeFw0yNDA5MjYwMDAwMDBa
# Fw0zNTExMjUyMzU5NTlaMEIxCzAJBgNVBAYTAlVTMREwDwYDVQQKEwhEaWdpQ2Vy
# dDEgMB4GA1UEAxMXRGlnaUNlcnQgVGltZXN0YW1wIDIwMjQwggIiMA0GCSqGSIb3
# DQEBAQUAA4ICDwAwggIKAoICAQC+anOf9pUhq5Ywultt5lmjtej9kR8YxIg7apnj
# pcH9CjAgQxK+CMR0Rne/i+utMeV5bUlYYSuuM4vQngvQepVHVzNLO9RDnEXvPghC
# aft0djvKKO+hDu6ObS7rJcXa/UKvNminKQPTv/1+kBPgHGlP28mgmoCw/xi6FG9+
# Un1h4eN6zh926SxMe6We2r1Z6VFZj75MU/HNmtsgtFjKfITLutLWUdAoWle+jYZ4
# 9+wxGE1/UXjWfISDmHuI5e/6+NfQrxGFSKx+rDdNMsePW6FLrphfYtk/FLihp/fe
# un0eV+pIF496OVh4R1TvjQYpAztJpVIfdNsEvxHofBf1BWkadc+Up0Th8EifkEEW
# dX4rA/FE1Q0rqViTbLVZIqi6viEk3RIySho1XyHLIAOJfXG5PEppc3XYeBH7xa6V
# TZ3rOHNeiYnY+V4j1XbJ+Z9dI8ZhqcaDHOoj5KGg4YuiYx3eYm33aebsyF6eD9MF
# 5IDbPgjvwmnAalNEeJPvIeoGJXaeBQjIK13SlnzODdLtuThALhGtyconcVuPI8Aa
# iCaiJnfdzUcb3dWnqUnjXkRFwLtsVAxFvGqsxUA2Jq/WTjbnNjIUzIs3ITVC6VBK
# AOlb2u29Vwgfta8b2ypi6n2PzP0nVepsFk8nlcuWfyZLzBaZ0MucEdeBiXL+nUOG
# hCjl+QIDAQABo4IBizCCAYcwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB/wQCMAAw
# FgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJ
# YIZIAYb9bAcBMB8GA1UdIwQYMBaAFLoW2W1NhS9zKXaaL3WMaiCPnshvMB0GA1Ud
# DgQWBBSfVywDdw4oFZBmpWNe7k+SH3agWzBaBgNVHR8EUzBRME+gTaBLhklodHRw
# Oi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRSU0E0MDk2U0hB
# MjU2VGltZVN0YW1waW5nQ0EuY3JsMIGQBggrBgEFBQcBAQSBgzCBgDAkBggrBgEF
# BQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMFgGCCsGAQUFBzAChkxodHRw
# Oi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRSU0E0MDk2
# U0hBMjU2VGltZVN0YW1waW5nQ0EuY3J0MA0GCSqGSIb3DQEBCwUAA4ICAQA9rR4f
# dplb4ziEEkfZQ5H2EdubTggd0ShPz9Pce4FLJl6reNKLkZd5Y/vEIqFWKt4oKcKz
# 7wZmXa5VgW9B76k9NJxUl4JlKwyjUkKhk3aYx7D8vi2mpU1tKlY71AYXB8wTLrQe
# h83pXnWwwsxc1Mt+FWqz57yFq6laICtKjPICYYf/qgxACHTvypGHrC8k1TqCeHk6
# u4I/VBQC9VK7iSpU5wlWjNlHlFFv/M93748YTeoXU/fFa9hWJQkuzG2+B7+bMDvm
# gF8VlJt1qQcl7YFUMYgZU1WM6nyw23vT6QSgwX5Pq2m0xQ2V6FJHu8z4LXe/371k
# 5QrN9FQBhLLISZi2yemW0P8ZZfx4zvSWzVXpAb9k4Hpvpi6bUe8iK6WonUSV6yPl
# MwerwJZP/Gtbu3CKldMnn+LmmRTkTXpFIEB06nXZrDwhCGED+8RsWQSIXZpuG4WL
# FQOhtloDRWGoCwwc6ZpPddOFkM2LlTbMcqFSzm4cd0boGhBq7vkqI1uHRz6Fq1IX
# 7TaRQuR+0BGOzISkcqwXu7nMpFu3mgrlgbAW+BzikRVQ3K2YHcGkiKjA4gi4OA/k
# z1YCsdhIBHXqBzR0/Zd2QwQ/l4Gxftt/8wY3grcc/nS//TVkej9nmUYu83BDtccH
# HXKibMs/yXHhDXNkoPIdynhVAku7aRZOwqw6pDCCBq4wggSWoAMCAQICEAc2N7ck
# VHzYR6z9KGYqXlswDQYJKoZIhvcNAQELBQAwYjELMAkGA1UEBhMCVVMxFTATBgNV
# BAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8G
# A1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MB4XDTIyMDMyMzAwMDAwMFoX
# DTM3MDMyMjIzNTk1OVowYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0
# LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hB
# MjU2IFRpbWVTdGFtcGluZyBDQTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoC
# ggIBAMaGNQZJs8E9cklRVcclA8TykTepl1Gh1tKD0Z5Mom2gsMyD+Vr2EaFEFUJf
# pIjzaPp985yJC3+dH54PMx9QEwsmc5Zt+FeoAn39Q7SE2hHxc7Gz7iuAhIoiGN/r
# 2j3EF3+rGSs+QtxnjupRPfDWVtTnKC3r07G1decfBmWNlCnT2exp39mQh0YAe9tE
# QYncfGpXevA3eZ9drMvohGS0UvJ2R/dhgxndX7RUCyFobjchu0CsX7LeSn3O9TkS
# Z+8OpWNs5KbFHc02DVzV5huowWR0QKfAcsW6Th+xtVhNef7Xj3OTrCw54qVI1vCw
# MROpVymWJy71h6aPTnYVVSZwmCZ/oBpHIEPjQ2OAe3VuJyWQmDo4EbP29p7mO1vs
# gd4iFNmCKseSv6De4z6ic/rnH1pslPJSlRErWHRAKKtzQ87fSqEcazjFKfPKqpZz
# QmiftkaznTqj1QPgv/CiPMpC3BhIfxQ0z9JMq++bPf4OuGQq+nUoJEHtQr8FnGZJ
# UlD0UfM2SU2LINIsVzV5K6jzRWC8I41Y99xh3pP+OcD5sjClTNfpmEpYPtMDiP6z
# j9NeS3YSUZPJjAw7W4oiqMEmCPkUEBIDfV8ju2TjY+Cm4T72wnSyPx4JduyrXUZ1
# 4mCjWAkBKAAOhFTuzuldyF4wEr1GnrXTdrnSDmuZDNIztM2xAgMBAAGjggFdMIIB
# WTASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQWBBS6FtltTYUvcyl2mi91jGog
# j57IbzAfBgNVHSMEGDAWgBTs1+OC0nFdZEzfLmc/57qYrhwPTzAOBgNVHQ8BAf8E
# BAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUHAwgwdwYIKwYBBQUHAQEEazBpMCQGCCsG
# AQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQQYIKwYBBQUHMAKGNWh0
# dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290RzQu
# Y3J0MEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9E
# aWdpQ2VydFRydXN0ZWRSb290RzQuY3JsMCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsG
# CWCGSAGG/WwHATANBgkqhkiG9w0BAQsFAAOCAgEAfVmOwJO2b5ipRCIBfmbW2CFC
# 4bAYLhBNE88wU86/GPvHUF3iSyn7cIoNqilp/GnBzx0H6T5gyNgL5Vxb122H+oQg
# JTQxZ822EpZvxFBMYh0MCIKoFr2pVs8Vc40BIiXOlWk/R3f7cnQU1/+rT4osequF
# zUNf7WC2qk+RZp4snuCKrOX9jLxkJodskr2dfNBwCnzvqLx1T7pa96kQsl3p/yhU
# ifDVinF2ZdrM8HKjI/rAJ4JErpknG6skHibBt94q6/aesXmZgaNWhqsKRcnfxI2g
# 55j7+6adcq/Ex8HBanHZxhOACcS2n82HhyS7T6NJuXdmkfFynOlLAlKnN36TU6w7
# HQhJD5TNOXrd/yVjmScsPT9rp/Fmw0HNT7ZAmyEhQNC3EyTN3B14OuSereU0cZLX
# JmvkOHOrpgFPvT87eK1MrfvElXvtCl8zOYdBeHo46Zzh3SP9HSjTx/no8Zhf+yvY
# fvJGnXUsHicsJttvFXseGYs2uJPU5vIXmVnKcPA3v5gA3yAWTyf7YGcWoWa63VXA
# OimGsJigK+2VQbc61RWYMbRiCQ8KvYHZE/6/pNHzV9m8BPqC3jLfBInwAM1dwvnQ
# I38AC+R2AibZ8GV2QqYphwlHK+Z/GqSFD/yYlvZVVCsfgPrA8g4r5db7qS9EFUrn
# Ew4d2zc4GqEr9u3WfPwwggWNMIIEdaADAgECAhAOmxiO+dAt5+/bUOIIQBhaMA0G
# CSqGSIb3DQEBDAUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJ
# bmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0
# IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0yMjA4MDEwMDAwMDBaFw0zMTExMDkyMzU5
# NTlaMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNV
# BAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IFRydXN0ZWQg
# Um9vdCBHNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAL/mkHNo3rvk
# XUo8MCIwaTPswqclLskhPfKK2FnC4SmnPVirdprNrnsbhA3EMB/zG6Q4FutWxpdt
# HauyefLKEdLkX9YFPFIPUh/GnhWlfr6fqVcWWVVyr2iTcMKyunWZanMylNEQRBAu
# 34LzB4TmdDttceItDBvuINXJIB1jKS3O7F5OyJP4IWGbNOsFxl7sWxq868nPzaw0
# QF+xembud8hIqGZXV59UWI4MK7dPpzDZVu7Ke13jrclPXuU15zHL2pNe3I6PgNq2
# kZhAkHnDeMe2scS1ahg4AxCN2NQ3pC4FfYj1gj4QkXCrVYJBMtfbBHMqbpEBfCFM
# 1LyuGwN1XXhm2ToxRJozQL8I11pJpMLmqaBn3aQnvKFPObURWBf3JFxGj2T3wWmI
# dph2PVldQnaHiZdpekjw4KISG2aadMreSx7nDmOu5tTvkpI6nj3cAORFJYm2mkQZ
# K37AlLTSYW3rM9nF30sEAMx9HJXDj/chsrIRt7t/8tWMcCxBYKqxYxhElRp2Yn72
# gLD76GSmM9GJB+G9t+ZDpBi4pncB4Q+UDCEdslQpJYls5Q5SUUd0viastkF13nqs
# X40/ybzTQRESW+UQUOsxxcpyFiIJ33xMdT9j7CFfxCBRa2+xq4aLT8LWRV+dIPyh
# HsXAj6KxfgommfXkaS+YHS312amyHeUbAgMBAAGjggE6MIIBNjAPBgNVHRMBAf8E
# BTADAQH/MB0GA1UdDgQWBBTs1+OC0nFdZEzfLmc/57qYrhwPTzAfBgNVHSMEGDAW
# gBRF66Kv9JLLgjEtUYunpyGd823IDzAOBgNVHQ8BAf8EBAMCAYYweQYIKwYBBQUH
# AQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQwYI
# KwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFz
# c3VyZWRJRFJvb3RDQS5jcnQwRQYDVR0fBD4wPDA6oDigNoY0aHR0cDovL2NybDMu
# ZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDARBgNVHSAE
# CjAIMAYGBFUdIAAwDQYJKoZIhvcNAQEMBQADggEBAHCgv0NcVec4X6CjdBs9thbX
# 979XB72arKGHLOyFXqkauyL4hxppVCLtpIh3bb0aFPQTSnovLbc47/T/gLn4offy
# ct4kvFIDyE7QKt76LVbP+fT3rDB6mouyXtTP0UNEm0Mh65ZyoUi0mcudT6cGAxN3
# J0TU53/oWajwvy8LpunyNDzs9wPHh6jSTEAZNUZqaVSwuKFWjuyk1T3osdz9HNj0
# d1pcVIxv76FQPfx2CWiEn2/K2yCNNWAcAgPLILCsWKAOQGPFmCLBsln1VWvPJ6ts
# ds5vIy30fnFqI2si/xK4VC0nftg62fC2h5b9W9FcrBjDTZ9ztwGpn1eqXijiuZQx
# ggN2MIIDcgIBATB3MGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1
# NiBUaW1lU3RhbXBpbmcgQ0ECEAuuZrxaun+Vh8b56QTjMwQwDQYJYIZIAWUDBAIB
# BQCggdEwGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMBwGCSqGSIb3DQEJBTEP
# Fw0yNTAzMDMyMTM4MTdaMCsGCyqGSIb3DQEJEAIMMRwwGjAYMBYEFNvThe5i29I+
# e+T2cUhQhyTVhltFMC8GCSqGSIb3DQEJBDEiBCAug86hL9Cpm5fECFPIuYO2/zmt
# u04Qqqw11KcIr9b3XjA3BgsqhkiG9w0BCRACLzEoMCYwJDAiBCB2dp+o8mMvH0ML
# OiMwrtZWdf7Xc9sF1mW5BZOYQ4+a2zANBgkqhkiG9w0BAQEFAASCAgAoRQrVhLew
# h5yOMq2UF3IsgjY+R/o/AZCUcqia2Hth4pd89qAT+jDqrodVqXBBtHTu0CZHgA1j
# 2mFv7kRBE/uL+FHNG6RMrewmKz6Z8CdYPuXU7YNWnYAiGFd4nb4ajhaZk/twznE6
# 1Y+qLY2DAWjdiPlxKFgmGvUBLKZlU0V1nAgUfqfCtCHiRCDaRYW7sgjD1j9cEss4
# GZo81NeNaubCar0IJfSNlLbD5uXaqFXK5HqP4p1E5bGx7J9iQJBJcUmhf3YvXVJ7
# UqbsZ7BO4bW50JqN99hRTgRS54pyhzMloIawB22XjQSyMv8qoM070Lf/oC6SEGYF
# oWXSjr8P2reE3x1wOQI24N+qfNqN0Lk6soFtKo/pg0uLXh+CPGS+wXPvm30rNe3K
# X3ykxIL/5unZwpxZk9v8yCpPgF/1F5dgq7zeWHyapvTgKyIDzH9fBrcAht9qMNNd
# m0U9Pu78hX80MHHvjOAd958uRfV8lj5h4Ce4ZUMZag/LnZt+1PT0IEu3eK7GCObI
# 8+WKJT47dSu0GjaTZuNaYUixxAVFnv5utkRA/rNWKBW+ZW0ZmJvmT1+YOWOeXLh+
# ijne47v/qGzsDnhTNMs7Movb3jzxlubE8ALdV42pAXLC2knKyq/IR5ANIj62B2Be
# 0vGI2Pzj3QzDpEbg8g/D2O+8yKjpa4hFqQ==
# SIG # End signature block
