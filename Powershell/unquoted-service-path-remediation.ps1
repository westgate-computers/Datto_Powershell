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
# MIIIuAYJKoZIhvcNAQcCoIIIqTCCCKUCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBj4Sz0U+K5YSPZ
# 3Ii8gSMpRl5Kc7ZquMNb3i6xA5obOKCCBfowggX2MIIE3qADAgECAhMgAAAAJTk+
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
# 9w0BCQQxIgQgkNxQ/nBIxCSW7hMVTzbtQyAnqVKjKOfaOpJkggMNFuIwDQYJKoZI
# hvcNAQEBBQAEggEAqJJbEqijPOJCqj2zRnqIo0FfsbKH/xtlugwYzkd97vMWuDGC
# 7M5MddHRSvwFk2oZd64pmhzUFwVpU/mMYWK05R01+UH4+8yrhBvM79LHzEIexEM0
# NoByTvxe4cVXm+QsHiJmTDCFwYFFmvX4Y1GMeGxYXroK8+TlHgdVYnmkf6/N3qWN
# oidaPLBI7gSG/uXcMfWQ9WbTd6JsuQ9eyFgRp1oQqbmQoGFoiGmrX9rfXEjRnFy/
# qkWoupyQb9rHAJKM0l1d3z/U5bIap1pCCqYHuLOwnOXLzPkqIArJmnMPvK1inWsi
# Z4uoRJ3u1r1q0tPtHi4FqVxuLqctJJKJ9p/kBg==
# SIG # End signature block
