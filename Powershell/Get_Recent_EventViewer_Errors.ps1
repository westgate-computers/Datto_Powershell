################# Get_Remove_EventViewer_Errors #####################
# Get errors in EventViewer for past 7 days                         #
# Takes $env:LogName (EventViewer Log Category) and                 #
# OPTIONAL: $env:AppSource (Specic App Errors) as arguements.       #
# if $env:AppSource isn't specified, script will pull recent errors #
# from EventViewer/System                                           #
# If $env:LogName isn't specified, defaults to System               #
# Returns Source, EventID, and Message from EventViewer             #
# Exits 1 on error and 0 on success                                 #
#####################################################################
# Author: Walker Chesley                                            #
# Change List:                                                      #
# 04/26/2023 - Created Script                                       #
#                                                                   #
#####################################################################

# Set Error Action Preference to Stop, this allows try-catch to work
# even if command/function called wouldn't normally stop the script
# on error message. Errors are now thrown to 
# ActionPreferenceStopException. See MS docs for more: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_preference_variables?view=powershell-7.3#erroractionpreference
$ErrorActionPreference = 'Stop'

# General Variables for Datto: 
$StartResult = Write-Output "<-Start Result->"
$EndResult = Write-Output "<-End Result->"

# General Variables for Script: 
$EventPath = "System"
$events = ""

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

# Helper function to output specific items from EventViewer
# @param $evenItems = List of raw event items returned from Get-EventLog
# returns Source, EventID and Message
# not all events have these properties, script will just output error message 
# if property is not present on the event. 
function ListAndFormatEventItems {
    param (
        $eventItems
    )
    $FormattedEvents = "Source - EventID - Message `n"
    foreach($item in $eventItems) {
        $FormattedEvents += $item.Source + " - " + $item.EventID + " - " + $item.Message + "`n"
    }
    return $FormattedEvents
}

if ([string]::IsNullOrEmpty($env:LogName)) {
    $env:LogName = $EventPath
    Datto_Output("LogName is $env:LogName")
}
else {
    $EventPath = $env:LogName
    Datto_Output("EventPath is $EventPath")
}

if ([string]::IsNullOrEmpty($env:AppSource)) {
    try {
        $events = Get-EventLog -LogName "$EventPath" -EntryType Error -After (Get-Date).AddDays(-7) -Newest 10
    }
    catch {
        #Datto_Output("Error: `n$Error[0] `nNo errors found, getting 10 most recent events over past week: ")
        $events = Get-EventLog -LogName "$EventPath" -After (Get-Date).AddDays(-7) -Newest 10
    }
}
else {
    try {
        $events = Get-EventLog -LogName "$EventPath" -EntryType Error -Source "$env:AppSource" -After (Get-Date).AddDays(-7) -Newest 10
    }
    catch {
        #Datto_Output("Error: `n$Error[0] `nNo errors found, getting 10 most recent events over past week: ")
        $events = Get-EventLog -LogName "$EventPath" -After (Get-Date).AddDays(-7) -Newest 10
    }
}

$events = ListAndFormatEventItems($events)
Datto_Output($events)
exit 0
# SIG # Begin signature block
# MIIIuAYJKoZIhvcNAQcCoIIIqTCCCKUCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAtPsgF1/LElHUm
# iU32DUktMuwzqOC9899NpyWMHZiUuaCCBfowggX2MIIE3qADAgECAhMgAAAAJTk+
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
# 9w0BCQQxIgQgmGazKq22UY0lSxQlhAklS6XNi02GnD/gsCJ8ytddhpwwDQYJKoZI
# hvcNAQEBBQAEggEAIjr+OrCBKFg+MLmY3gE8KXJP00uGYYQEfCprBGnRoUSkrcAt
# QTflFsBX+GPokKOaC8XTiIJFtHX8oxMoCwSCZyzXV9kNVfgt6jzVHMTpkcAHSkmK
# pbxmadL7dE6C/5GY/h4MPtW4e0k2lQ5Hgvy+mFBHber47fdzKy6woDB4HWav+SnO
# vwI1Kx5xe2iXURVxiw1KCdmmORxW2jTej4HK+2J81Id1SVVrl55VESpJCpk/+k4b
# R/MneLDvtfvj5Z6Sh9e6FizQuJ/9/qNKgDyqWBBwXg+Js+4d3Qj/+pv+8QTv61P2
# BBx+u7TyaViHqRfXPHIQjaLeyyV8jI/yI+dFrA==
# SIG # End signature block
