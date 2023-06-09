############################ mount_drive ############################
# Mounts remote drive to local file system                          #
# Takes $env:MountDrive (Network share path) and                    #
# $env:DriveLetter (Mounted drive letter) as arguements.            #
# if $env:DriveLetter isn't specified a random one is chosen        #
# If mount isn't available on system, falls back to New-PSDrive     #
# Exits 1 on error and 0 on success                                 #
#####################################################################
# Author: Walker Chesley                                            #
# Change List:                                                      #
# 04/26/2023 - Created Script                                       #
#                                                                   #
#####################################################################

# General Variables for Datto: 
$StartResult = Write-Host "<-Start Result->"
$EndResult = Write-Host "<-End Result->"

# Verify Datto env vars to mount drive are specified
# $env:MountDrive should be in the format: \\<computername>\<sharename>
if ($env:MountDrive -eq "") {
    $StartResult
    Write-Error "No Path Specified to Mount, path is set to: $env:MountDrive"
    $EndResult
    exit 1
}

# Check if drive letter is specified, if not, use first available letter
# $env:MountLetter
if ($env:MountLetter -eq "") {
    $env:MountLetter -eq "*"
}

# Check that we can use mount command and mount drive:
try {
    mount $env:MountDrive $env:MountLetter
    $StartResult
    Write-Host "Mouned $env:MountDrive to $env:MountLetter"
    $EndResult
    exit 0
}
# If mount is not available, fall back to New-PSDrive: 
catch [CommandNotFoundException] {
    $StartResult
    Write-Host "Mount command not found, falling back to New-PSDrive"
    $EndResult
    try {
        New-PSDrive -Name "$env:MountLetter" -Root "$env:MountDrive" -Persist -PSProvider 'FileSystem'
        $StartResult
        Write-Host "Mouned $env:MountDrive to $env:MountLetter"
        $EndResult
        exit 0
    }
    catch {
        $StartResult
        Write-Host "Failed to mount Drive `n$Error[0]"
        $EndResult
        exit 1
    }
}
catch {
    $StartResult
    Write-Host "Failed to mount Drive `n$Error[0]"
    $EndResult
    exit 1
}
