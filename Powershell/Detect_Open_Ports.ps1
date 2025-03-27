#Requires -Version 5.1

<#
.SYNOPSIS
    Alert on specified ports that are Listening or Established and optionally save the results to a custom field.
.DESCRIPTION
    Will alert on open ports, regardless if a firewall is blocking them or not.
    Checks for open ports that are in a 'Listen' or 'Established' state.
    UDP is a stateless protocol and will not have a state.
    Outputs the open ports, process ID, state, protocol, local address, and process name.
    When a Custom Field is provided this will save the results to that custom field.

.EXAMPLE
    (No Parameters)
    ## EXAMPLE OUTPUT WITHOUT PARAMS ##
    [Alert] Found open port: 80, PID: 99, State: Listen, Local Address: 0.0.0.0, Process: nginx
    [Alert] Found open port: 500, PID: 99, State: Listen, Local Address: 0.0.0.0, Process: nginx

PARAMETER: -Port "100,200,300-350, 400"
    A comma separated list of ports to check. Can include ranges (e.g. 100,200,300-350, 400)
.EXAMPLE
    -Port "80,200,300-350, 400"
    ## EXAMPLE OUTPUT WITH Port ##
    [Alert] Found open port: 80, PID: 99, State: Listen, Local Address: 0.0.0.0, Process: nginx

PARAMETER: -CustomField "ReplaceMeWithAnyMultilineCustomField"
    Name of the custom field to save the results to.
.EXAMPLE
    -Port "80,200,300-350, 400" -CustomField "ReplaceMeWithAnyMultilineCustomField"
    ## EXAMPLE OUTPUT WITH CustomField ##
    [Alert] Found open port: 80, PID: 99, State: Listen, Local Address: 0.0.0.0, Process: nginx
    [Info] Saving results to custom field: ReplaceMeWithAnyMultilineCustomField
    [Info] Results saved to custom field: ReplaceMeWithAnyMultilineCustomField
.OUTPUTS
    None
.NOTES
    Supported Operating Systems: Windows 10/Windows Server 2016 or later with PowerShell 5.1
    Release Notes: Initial Release
By using this script, you indicate your acceptance of the following legal terms as well as our Terms of Use at https://ninjastage2.wpengine.com/terms-of-use.
    Ownership Rights: NinjaOne owns and will continue to own all right, title, and interest in and to the script (including the copyright). NinjaOne is giving you a limited license to use the script in accordance with these legal terms. 
    Use Limitation: You may only use the script for your legitimate personal or internal business purposes, and you may not share the script with another party. 
    Republication Prohibition: Under no circumstances are you permitted to re-publish the script in any script library or website belonging to or under the control of any other software provider. 
    Warranty Disclaimer: The script is provided “as is” and “as available”, without warranty of any kind. NinjaOne makes no promise or guarantee that the script will be free from defects or that it will meet your specific needs or expectations. 
    Assumption of Risk: Your use of the script is at your own risk. You acknowledge that there are certain inherent risks in using the script, and you understand and assume each of those risks. 
    Waiver and Release: You will not hold NinjaOne responsible for any adverse or unintended consequences resulting from your use of the script, and you waive any legal or equitable rights or remedies you may have against NinjaOne relating to your use of the script. 
    EULA: If you are a NinjaOne customer, your use of the script is subject to the End User License Agreement applicable to you (EULA).
#>
#>

[CmdletBinding()]
param (
    [Parameter()]
    [String]$PortsToCheck,
    [String]$CustomFieldName
)

begin {
    function Test-IsElevated {
        $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        $p = New-Object System.Security.Principal.WindowsPrincipal($id)
        $p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
    }
}
process {
    if (-not (Test-IsElevated)) {
        Write-Error -Message "Access Denied. Please run with Administrator privileges."
        exit 1
    }
    if ($env:portsToCheck -and $env:portsToCheck -ne 'null') {
        $PortsToCheck = $env:portsToCheck
    }
    if ($env:customFieldName -and $env:customFieldName -ne 'null') {
        $CustomFieldName = $env:customFieldName
    }

    # Remove any whitespace
    $PortsToCheck = $PortsToCheck -replace '\s', ''

    # Parse the ports to check
    $Ports = if ($PortsToCheck) {
        # Split the ports by comma and handle ranges
        $PortsToCheck -split ',' | ForEach-Object {
            # Trim the whitespace
            $Ports = "$_".Trim()
            # If the port is a range, expand it
            if ($Ports -match '-') {
                # Split the range and expand it
                $Range = $Ports -split '-' | ForEach-Object { "$_".Trim() } | Where-Object { $_ }
                if ($Range.Count -ne 2) {
                    Write-Host "[Error] Invalid range formatting, must be two number with a dash in between them (eg 1-10): $PortsToCheck"
                    exit 1
                }
                try {
                    $Range[0]..$Range[1]
                }
                catch {
                    Write-Host "[Error] Failed to parse range, must be two number with a dash in between them (eg 1-10): $PortsToCheck"
                    exit 1
                }
            }
            else {
                $Ports
            }
        }
    }
    else { $null }

    if ($($Ports | Where-Object { [int]$_ -gt 65535 })) {
        Write-Host "[Error] Can not search for ports above 65535. Must be with in the range of 1 to 65535."
        exit 1
    }

    # Get the open ports
    $FoundPorts = $(
        Get-NetTCPConnection | Select-Object @(
            'LocalAddress'
            'LocalPort'
            'State'
            @{Name = "Protocol"; Expression = { "TCP" } }
            'OwningProcess'
            @{Name = "Process"; Expression = { (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName } }
        )
        Get-NetUDPEndpoint | Select-Object @(
            'LocalAddress'
            'LocalPort'
            @{Name = "State"; Expression = { "None" } }
            @{Name = "Protocol"; Expression = { "UDP" } }
            'OwningProcess'
            @{Name = "Process"; Expression = { (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName } }
        )
    ) | Where-Object {
        $(
            <# When Ports are specified select just those ports. #>
            if ($Ports) { $_.LocalPort -in $Ports }else { $true }
        ) -and
        (
            <# Filter out anything that isn't listening or established. #>
            $(
                $_.Protocol -eq "TCP" -and
                $(
                    $_.State -eq "Listen" -or
                    $_.State -eq "Established"
                )
            ) -or
            <# UDP is stateless, return all UDP connections. #>
            $_.Protocol -eq "UDP"
        )
    } | Sort-Object LocalPort | Select-Object * -Unique

    if (-not $FoundPorts -or $FoundPorts.Count -eq 0) {
        Write-Host "[Info] No ports were found listening or established with the specified: $PortsToCheck"
    }

    # Output the found ports
    $FoundPorts | ForEach-Object {
        Write-Host "[Alert] Found open port: $($_.LocalPort), PID: $($_.OwningProcess), Protocol: $($_.Protocol), State: $($_.State), Local IP: $($_.LocalAddress), Process: $($_.Process)"
    }
    
}
end {
    
    
    
}

# SIG # Begin signature block
# MIIf9QYJKoZIhvcNAQcCoIIf5jCCH+ICAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAaBWh7ogBdnEDm
# MH2EOMPJSXLUAJwjSqH3UcA/cIUHNqCCBfowggX2MIIE3qADAgECAhMgAAAAJTk+
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
# 9w0BCQQxIgQgHqyUSdUD3xmDMDfBm5NqDBzvFlGTRZt0glWC7hAA3+wwDQYJKoZI
# hvcNAQEBBQAEggEAt6iBHN4IUXTLIVO2RSyYI7+Pcml0XgHoPOKCT/hVk4dSoJZN
# SOkcnTnuyfW1VxQvCJtrGiEO/0OUWWFZjtpac4fYDVJR99oNNeFlequWkBS3BXz6
# Hd/Xu9Evgjw/sNQmum+DycUyPTvvR0gE/OUmwOwfGHbilgVnv6dKpBO4da15FGLy
# y/7wXhDR9uX5++tCAbiSK/knTfjxM24IzhGMD6uePMWBqnPQ8B61qRIFl+II4cTV
# pqxRUUwbyVMJrFHqz9ZNG1cbzGafVZ0wg1Ifx7fBS3qJk2cH9GmvZJj0CawqVb2z
# Jn8FLCA+fMRZ3hmoq+R/ieOYyfrE7COjDAMMQaGCFzkwghc1BgorBgEEAYI3AwMB
# MYIXJTCCFyEGCSqGSIb3DQEHAqCCFxIwghcOAgEDMQ8wDQYJYIZIAWUDBAIBBQAw
# dwYLKoZIhvcNAQkQAQSgaARmMGQCAQEGCWCGSAGG/WwHATAxMA0GCWCGSAFlAwQC
# AQUABCAI6CCE8BXr/q2YCyn00mWCg/0eFThrW6EWzJf6RZR2GgIQTgdT1YBXN4MX
# MFkFO5ITmRgPMjAyNTAzMDcxNzEzNDVaoIITAzCCBrwwggSkoAMCAQICEAuuZrxa
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
# Fw0yNTAzMDcxNzEzNDVaMCsGCyqGSIb3DQEJEAIMMRwwGjAYMBYEFNvThe5i29I+
# e+T2cUhQhyTVhltFMC8GCSqGSIb3DQEJBDEiBCB7Q0DLM1DpLfNwiE3KmDSpGnzp
# u+mEQfXnrAoprK/mYjA3BgsqhkiG9w0BCRACLzEoMCYwJDAiBCB2dp+o8mMvH0ML
# OiMwrtZWdf7Xc9sF1mW5BZOYQ4+a2zANBgkqhkiG9w0BAQEFAASCAgBtEo9e8dFC
# OYEXRjucpnoBHM9guULJb7O7v/rxExjEVxhm8sJz/ZuKARqWZGlNrZFXRZquoOPk
# tjHIYBh5jADlD3+6nxi8x+vP7igZcCe3Ar8/w8LXRWzYorkqLwObqY+stqkm5I4m
# r3NSCCEiESZim0go+R58rtaNKtiFUdiT4JM+KGI63xNJ8ecwy6iMl0n/K/FGJ+UK
# 03VRiS3IkvOIjC+4Q289r/fw5w4PXHrtciAJvNC1iYrEtO6yCIPhd4gOp45/fhMp
# 3Mu94iNgXBppnSSBYriHnX2IMPeWFIVyS4dFKYtBIZIpsVmsDH+pKbIa/ZnI1gJK
# dWqf4LL9/jd6LzMuVc9FAuNesiRoNhNIFTRIVTpiO+YDaP97e7ONq0o4SJ5JcOIL
# P9UfR+9K2KZBWZWBrcIMhJ4UjP+c7785wmEt1t4lGm3NWjMrSoJthwNazV4CJrbu
# a9nRjr08r79486yvz/AgUb6JVOU0/+fbvXc8Qv0vBR0bTXaTneVFeCNjEWDzKNXQ
# 33sZPQaHCBnpfCJYPD/y8gvEBbJERi8eBAu3ChAwLfgGrhNpk5bfvOHl0Awuv1M5
# oUjZrUnLb39O1cIbYPxyNvIpLxpNXTfAN2bX1K9s/XcXhZXCvacSpUjKXvxRFuUn
# D6VFVmhmqVu1itLdGifdYQgwOBtKAP1K8w==
# SIG # End signature block
