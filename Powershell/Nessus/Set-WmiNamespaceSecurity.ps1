# Copyright (c) Microsoft Corporation.  All rights reserved. 
# For personal use only.  Provided AS IS and WITH ALL FAULTS.
 
# Set-WmiNamespaceSecurity.ps1
# Example: Set-WmiNamespaceSecurity root/cimv2 add steve Enable,RemoteAccess

# Taken from https://live.paloaltonetworks.com/t5/Management-Articles/PowerShell-Script-for-setting-WMI-Permissions-for-User-ID/ta-p/53646
# Modified by Stuart Clarkson (https://github.com/Tras2)
 
Param (
    [parameter(Mandatory=$true,Position=0)]
    [String] $namespace,

    [parameter(Mandatory=$true,Position=1)]
    [ValidateSet("Add","Delete")]
    [String] $operation,

    [parameter(Mandatory=$true,Position=2)]
    [string] $account,
    [parameter(Position=3)]
    [ValidateSet("Enable","MethodExecute","FullWrite","PartialWrite", `
                 "ProviderWrite","RemoteAccess","ReadSecurity","WriteSecurity")]
    [string[]] $permissions = $null,

    [Parameter()][ValidateSet("User","Group")]
    [String]$AccountType = "User",

    [Switch]$allowInherit,

    [Switch]$deny,

    [string] $computerName = ".",

    [System.Management.Automation.PSCredential] $credential = $null
)
   
Process {
    $ErrorActionPreference = "Stop"
 
    Function Get-AccessMaskFromPermission($permissions) {
        $WBEM_ENABLE            = 1
                $WBEM_METHOD_EXECUTE = 2
                $WBEM_FULL_WRITE_REP   = 4
                $WBEM_PARTIAL_WRITE_REP              = 8
                $WBEM_WRITE_PROVIDER   = 0x10
                $WBEM_REMOTE_ACCESS    = 0x20
                $WBEM_RIGHT_SUBSCRIBE = 0x40
                $WBEM_RIGHT_PUBLISH      = 0x80
        $READ_CONTROL = 0x20000
        $WRITE_DAC = 0x40000
       
        $WBEM_RIGHTS_FLAGS = $WBEM_ENABLE,$WBEM_METHOD_EXECUTE,$WBEM_FULL_WRITE_REP,`
            $WBEM_PARTIAL_WRITE_REP,$WBEM_WRITE_PROVIDER,$WBEM_REMOTE_ACCESS,`
            $READ_CONTROL,$WRITE_DAC
        $WBEM_RIGHTS_STRINGS = "Enable","MethodExecute","FullWrite","PartialWrite",`
            "ProviderWrite","RemoteAccess","ReadSecurity","WriteSecurity"
 
        $permissionTable = @{}
 
        for ($i = 0; $i -lt $WBEM_RIGHTS_FLAGS.Length; $i++) {
            $permissionTable.Add($WBEM_RIGHTS_STRINGS[$i].ToLower(), $WBEM_RIGHTS_FLAGS[$i])
        }
       
        $accessMask = 0
 
        foreach ($permission in $permissions) {
            if (-not $permissionTable.ContainsKey($permission.ToLower())) {
                throw "Unknown permission: $permission`nValid permissions: $($permissionTable.Keys)"
            }
            $accessMask += $permissionTable[$permission.ToLower()]
        }
       
        $accessMask
    }
 
    if ($PSBoundParameters.ContainsKey("Credential")) {
        $remoteparams = @{ComputerName=$computerName;Credential=$credential}
    } else {
        $remoteparams = @{ComputerName=$computerName}
    }
       
    $invokeparams = @{Namespace=$namespace;Path="__systemsecurity=@"} + $remoteParams
 
    $output = Invoke-WmiMethod @invokeparams -Name GetSecurityDescriptor
    if ($output.ReturnValue -ne 0) {
        throw "GetSecurityDescriptor failed: $($output.ReturnValue)"
    }
 
    $acl = $output.Descriptor
    $OBJECT_INHERIT_ACE_FLAG = 0x1
    $CONTAINER_INHERIT_ACE_FLAG = 0x2
 
    $computerName = (Get-WmiObject @remoteparams Win32_ComputerSystem).Name
   
    if ($account.Contains('\')) {
        $domainaccount = $account.Split('\')
        $domain = $domainaccount[0]
        if (($domain -eq ".") -or ($domain -eq "BUILTIN")) {
            $domain = $computerName
        }
        $accountname = $domainaccount[1]
    } elseif ($account.Contains('@')) {
        $domainaccount = $account.Split('@')
        $domain = $domainaccount[1].Split('.')[0]
        $accountname = $domainaccount[0]
    } else {
        $domain = $computerName
        $accountname = $account
    }
 
    if ($AccountType -eq "Group")
    {
        $getparams = @{Class="Win32_Group"}
    }
    else {
        $getparams = @{Class="Win32_Account"}
    }
    $getparams+= @{Filter="Domain='$domain' and Name='$accountname'"} + $remoteParams
 
    $win32account = Get-WmiObject @getparams
 
    if ($win32account -eq $null) {
        throw "Account was not found: $account"
    }
 
    switch ($operation) {
        "Add" {
            if ($permissions -eq $null) {
                throw "-Permissions must be specified for an add operation"
            }
            $accessMask = Get-AccessMaskFromPermission($permissions)
   
            $ace = (New-Object System.Management.ManagementClass("win32_Ace")).CreateInstance()
            $ace.AccessMask = $accessMask
            if ($allowInherit) {
                $ace.AceFlags = $CONTAINER_INHERIT_ACE_FLAG
            } else {
                $ace.AceFlags = 0
            }
                       
            $trustee = (New-Object System.Management.ManagementClass("win32_Trustee")).CreateInstance()
            $trustee.SidString = $win32account.Sid
            $ace.Trustee = $trustee
           
            $ACCESS_ALLOWED_ACE_TYPE = 0x0
            $ACCESS_DENIED_ACE_TYPE = 0x1
 
            if ($deny) {
                $ace.AceType = $ACCESS_DENIED_ACE_TYPE
            } else {
                $ace.AceType = $ACCESS_ALLOWED_ACE_TYPE
            }
 
            $acl.DACL += $ace.psobject.immediateBaseObject
        }
       
        "Delete" {
            if ($permissions -ne $null) {
                throw "Permissions cannot be specified for a delete operation"
            }
       
            [System.Management.ManagementBaseObject[]]$newDACL = @()
            foreach ($ace in $acl.DACL) {
                if ($ace.Trustee.SidString -ne $win32account.Sid) {
                    $newDACL += $ace.psobject.immediateBaseObject
                }
            }
 
            $acl.DACL = $newDACL.psobject.immediateBaseObject
        }
       
        default {
            throw "Unknown operation: $operation`nAllowed operations: add delete"
        }
    }
 
    $setparams = @{Name="SetSecurityDescriptor";ArgumentList=$acl.psobject.immediateBaseObject} + $invokeParams
 
    $output = Invoke-WmiMethod @setparams
    if ($output.ReturnValue -ne 0) {
        throw "SetSecurityDescriptor failed: $($output.ReturnValue)"
    }
}
# SIG # Begin signature block
# MIIIvgYJKoZIhvcNAQcCoIIIrzCCCKsCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDZpPp7FEZ37kXF
# gQI4P2yYvr33PyBEkOAB4WMOdq/JrqCCBfcwggXzMIIE26ADAgECAhMgAAAAFmQu
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
# NE1hS/lI3CECKUoA5598UusxggIdMIICGQIBATBrMFQxFTATBgoJkiaJk/IsZAEZ
# FgVsb2NhbDEcMBoGCgmSJomT8ixkARkWDHdlc3RnYXRlY29tcDEdMBsGA1UEAxMU
# d2VzdGdhdGVjb21wLURDMDEtQ0ECEyAAAAAWZC7cZNqNpo4AAAAAABYwDQYJYIZI
# AWUDBAIBBQCggYQwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0B
# CQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAv
# BgkqhkiG9w0BCQQxIgQg5CNS712uxSBSkENa6VaIrpkd7r5xjfa2oM+PYrhrlZEw
# DQYJKoZIhvcNAQEBBQAEggEApB68KcczC9qhFSXsQv3rjHxFc1fHxY3BpVXtvcIE
# tmLIgl0+jjDLQfrpv9Mj1E++VsmoqqgbihxWPJoOXbbdndA2RVQv40Va40FuDAws
# bVSpBicFo6WwYM8JwYCxpqtssNoAyzcntTmoCPoIrEoQzsmD4Bzl0a6K6saCjmmW
# 4GGGm9FhyNfZgaE7mfpaPpS+Rqq3IApZqIt/RymfNxuZZcXQ7ebsIdncasGOF/WH
# sQKKX2vD/Ccl82zHepxOZ+RCtHmoDtgJbojZSKs98igGAsOVwGyRuR9D585PsLmo
# xLvxJmdF36VT6zKkgPORZCAUs7WQ+bp9uCILX8PVxjM36w==
# SIG # End signature block
