############## unquoted-service-path-remediation ####################
# Describe script here: iterates through windows services and adds  #
# quotations to service paths that do not contain quotes            #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 08/10/2023 - Added to Datto                                       #

#####################################################################

#####################################################################################################
## Code Author: Jeff Liford
## Modified by: Seth Feaganes (@Net_Sec_Jedi)
## Original: http://www.ryanandjeffshow.com/blog/2013/04/11/powershell-fixing-unquoted-service-paths-complete/
##
## A powershell script which will search the registry for unquoted service paths and properly quote
## them. If run in a powershell window exclusively, this script will produce no output other than
## a line with "The operation completed successfully" when it fixes a bad key. Verbose output can
## be enabled by uncommenting the Write-Progress or Write-Output lines OR running the original scripts
## as intended with command pipes.
##
## This script was modified from the original three scripts named Get-SVCPath.ps1, Find-BADSVCPath.ps1,
## and Fix-BADSVCPath.ps1 to allow it to be run as a single script on one system or for use in mass
## deployment systems such as PDQDeploy, KACE, etc for example. If you require the functionality of those
## scripts for auditing, execution over multiple systems, or any other options those scripts provide, please
## use those scripts instead. I am posting this modification as reference to something useful in situations
## where a quick fix is necessary. 
##
## Myself nor the original author of this code cannot be held liable for any damage incurred running
## this in a production environment. Please take proper precautions before modifying the registry
## such as running this script with the REG ADD line commented out or taking a backup of the registry
## prior to running the script. Or obviously on virtual environments, etc.
#####################################################################################################

## Grab all the registry keys pertinent to services
$result = Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services'
$ServiceItems = $result | Foreach-Object {Get-ItemProperty $_.PsPath}

# Iterate through the keys and check for Unquoted ImagePath's
ForEach ($si in $ServiceItems) {
 if ($si.ImagePath -ne $nul) { 
  $obj = New-Object -Typename PSObject
  $obj | Add-Member -MemberType NoteProperty -Name Status -Value "Retrieved"
  # There is certianly a way to use the full path here but for now I trim it until I can find time to play with it
         $obj | Add-Member -MemberType NoteProperty -Name Key -Value $si.PSPath.TrimStart("Microsoft.PowerShell.Core\Registry::")
         $obj | Add-Member -MemberType NoteProperty -Name ImagePath -Value $si.ImagePath
  
  ########################################################################
      # Find and Fix Bad Keys for each key object
      ########################################################################
  
  #We're looking for keys with spaces in the path and unquoted
  $examine = $obj.ImagePath
  if (!($examine.StartsWith('"'))) { #Doesn't start with a quote
   if (!($examine.StartsWith("\??"))) { #Some MS Services start with this but don't appear vulnerable
    if ($examine.contains(" ")) { #If contains space
     #when I get here, I can either have a good path with arguments, or a bad path
     if ($examine.contains("-") -or $examine.contains("/")) { #found arguments, might still be bad
      #split out arguments
      $split = $examine -split " -", 0, "simplematch"
      $split = $split[0] -split " /", 0, "simplematch"
      $newpath = $split[0].Trim(" ") #Path minus flagged args
      if ($newpath.contains(" ")){
       #check for unflagged argument
       $eval = $newpath -Replace '".*"', '' #drop all quoted arguments
       $detunflagged = $eval -split "\", 0, "simplematch" #split on foler delim
       if ($detunflagged[-1].contains(" ")){ #last elem is executable and any unquoted args
        $fixarg = $detunflagged[-1] -split " ", 0, "simplematch" #split out args
        $quoteexe = $fixarg[0] + '"' #quote that EXE and insert it back
        $examine = $examine.Replace($fixarg[0], $quoteexe)
        $examine = $examine.Replace($examine, '"' + $examine)
        $badpath = $true
       } #end detect unflagged
       $examine = $examine.Replace($newpath, '"' + $newpath + '"')
       $badpath = $true
      } #end if newpath
      else { #if newpath doesn't have spaces, it was just the argument tripping the check
       $badpath = $false
      } #end else
     } #end if parameter
     else
     {#check for unflagged argument
      $eval = $examine -Replace '".*"', '' #drop all quoted arguments
      $detunflagged = $eval -split "\", 0, "simplematch"
      if ($detunflagged[-1].contains(" ")){
       $fixarg = $detunflagged[-1] -split " ", 0, "simplematch"
       $quoteexe = $fixarg[0] + '"'
       $examine = $examine.Replace($fixarg[0], $quoteexe)
       $examine = $examine.Replace($examine, '"' + $examine)
       $badpath = $true
      } #end detect unflagged
      else
      {#just a bad path
       #surround path in quotes
       $examine = $examine.replace($examine, '"' + $examine + '"')
       $badpath = $true
      }#end else
     }#end else
    }#end if contains space
    else { $badpath = $false }
   } #end if starts with \??
   else { $badpath = $false }
  } #end if startswith quote
  else { $badpath = $false }

  #Update Objects
  if ($badpath -eq $false){
   $obj | Add-Member -MemberType NoteProperty -Name BadKey -Value "No"
   $obj | Add-Member -MemberType NoteProperty -Name FixedKey -Value "N/A"
   $obj = $nul #clear $obj
  }
   
  # Plans to change this check. I believe it can be done more efficiently. But It works for now!
  if ($badpath -eq $true){
   $obj | Add-Member -MemberType NoteProperty -Name BadKey -Value "Yes"
   #sometimes we catch doublequotes
   if ($examine.endswith('""')){ $examine = $examine.replace('""','"') }
   $obj | Add-Member -MemberType NoteProperty -Name FixedKey -Value $examine
   if ($obj.badkey -eq "Yes"){
    #Write-Progress -Activity "Fixing $($obj.key)" -Status "Working..."
    $regpath = $obj.Fixedkey
    $obj.status = "Fixed"
           $regkey = $obj.key.replace('HKEY_LOCAL_MACHINE', 'HKLM:')
           # Comment the next line out to run without modifying the registry
    # Alternatively uncomment any line with Write-Output or Write-Object for extra verbosity.
    Set-ItemProperty -Path $regkey -name 'ImagePath' -value $regpath
   }    
  $obj = $nul #clear $obj
  }
 }
} 

# SIG # Begin signature block
# MIIItQYJKoZIhvcNAQcCoIIIpjCCCKICAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBj4Sz0U+K5YSPZ
# 3Ii8gSMpRl5Kc7ZquMNb3i6xA5obOKCCBfcwggXzMIIE26ADAgECAhMgAAAAFmQu
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
# CQQxIgQgkNxQ/nBIxCSW7hMVTzbtQyAnqVKjKOfaOpJkggMNFuIwDQYJKoZIhvcN
# AQEBBQAEggEAA3tYBKd3Z7XgeJMn1Qcgl5vFEMYCaokeZVJPcinhQHYsIsWQ5T/E
# m2dyJ1eYJhJgdRRSjWrruF7UTkx/Eyi0kcWepjdN1/ieo/3IsKmD6NSWwCl80UPo
# uVSI861DFgaFWfS9EEdhZHaUGh6WGCxrnnig26lENqhnbZVMQRlZuW2PLgAZ4d1/
# 07TUtYt/90WD/Sdva93NsGfuXQG2TuVeZe5//b9whSkfV280d9xf1LKwsTnl4m08
# XHf1iIqxJ/PDnojpjpuFPabeftrSNktXfyPTPMGpYq6WL23kurl6Lk88QPGNSlqW
# e4ozmtmezSQxWNJcQ4QAFsI6WO2NwwkwPw==
# SIG # End signature block
