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
# MIIItQYJKoZIhvcNAQcCoIIIpjCCCKICAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAtPsgF1/LElHUm
# iU32DUktMuwzqOC9899NpyWMHZiUuaCCBfcwggXzMIIE26ADAgECAhMgAAAAFmQu
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
# CQQxIgQgmGazKq22UY0lSxQlhAklS6XNi02GnD/gsCJ8ytddhpwwDQYJKoZIhvcN
# AQEBBQAEggEAOL6RBV9PlcrYwZgQK+sEDjRWlMwVvywjE7GXPI8kyGLYdVYGq9ON
# huKG5NVAOBJmtA1bDO4IaG+WFNuDDKGEU/tarC+cT2SXkab/5X3BtecfmWSeiWGK
# S/RVxf/pFtUDBawiUkgsD5F7H2ImPRBMME9CgneyfjvWXuFJ/f2JRJ0y/46RHvMb
# lAr+FceCmU88I+gCH52H6gPKnz+cuK1ajC1VxbDwz12sU3BYFrethqO5u0aIviIv
# dMSt6B3Mh/9DhqY2LO31Pt51W+sUP5wO6rKeudk0/TljL5aePu4R1W3sbKOgi8x0
# t8lGugcoKfVpZ/J1+KWoR2iL24N2Gm+I0w==
# SIG # End signature block
