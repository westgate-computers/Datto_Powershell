######################## Script_Template ############################
# Describe script here: List how to use the script, list input      #
# arguements, return values and exit codes                          #

#####################################################################
# Author: Your_Name                                                 #
# Change List: List your changes here:                              #
# 04/26/2023 - Created Script                                       #
# 08/08/2023 - added redirection for Write-Host variable            #
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

# Import the Active Directory module
Import-Module ActiveDirectory

# Get all AD groups
$groups = Get-ADGroup -Filter *

# Create an array to store the results
$results = @()

# Loop through each group
foreach ($group in $groups) {
    # Get members of the group
    $members = Get-ADGroupMember -Identity $group.DistinguishedName | Where-Object {$_.objectClass -eq "user"}
    
    # If the group has members
    if ($members) {
        foreach ($member in $members) {
            # Create a custom object with group and user information
            $result = [PSCustomObject]@{
                GroupName = $group.Name
                UserName = $member.Name
                UserSamAccountName = $member.SamAccountName
            }
            # Add the result to the array
            $results += $result
        }
    } else {
        # If the group has no members, add an entry with empty user fields
        $result = [PSCustomObject]@{
            GroupName = $group.Name
            UserName = ""
            UserSamAccountName = ""
        }
        $results += $result
    }
}

# Export the results to a CSV file
$results | Export-Csv -Path "C:\temp\ADGroupsAndUsers.csv" -NoTypeInformation

# Display the results in the console
$results | Format-Table -AutoSize

Write-Host "Results have been exported to C:\ADGroupsAndUsers.csv"