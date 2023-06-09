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