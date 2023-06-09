############################ Wake_On_Lan ############################
# Send Wake On LAN Packet to specified computer                     #
# Takes $env:Mac (Destination MAC address) and                      #
# $env:IP (Destination IP address) as arguements.                   #
# Crafts magic WoL packet and sends it to remote machine.           #
# Exits 1 on error and 0 on success                                 #
#####################################################################
# Author: Walker Chesley                                            #
# Change List:                                                      #
# 04/26/2023 - Created Script                                       #
# ref:                                                              #
# https://www.pdq.com/blog/wake-on-lan-wol-magic-packet-powershell/ # 
#####################################################################

# General Variables for Datto: 
$StartResult = Write-Host "<-Start Result->"
$EndResult = Write-Host "<-End Result->"

# Define device MAC address, should be in standard format AA:BB:CC:11:22:33

if ($env:Mac -eq "") {
    $StartResult
    Write-Host "No MAC address specified"
    $EndResult
    exit 1
}
if ($env:IP -eq "") {
    $StartResult
    Write-Host "No IP address specified"
    $EndResult
    exit 1
}
# Splic MAC address by octet
$MacByteArray = $Mac -split "[:-]" | ForEach-Object { [Byte] "0x$_"}

# Convert MAC to Byte Array for magic packet:
[Byte[]] $MagicPacket = (,0xFF * 6) + ($MacByteArray  * 16)

# Send the magic
try {
    $UdpClient = New-Object System.Net.Sockets.UdpClient
    $UdpClient.Connect(($env:IP::Broadcast),7)
    $UdpClient.Send($MagicPacket,$MagicPacket.Length)
    $UdpClient.Close()
    $StartResult
    Write-Host "Magic has been sent!"
    $EndResult
    exit 0
}
catch {
    $StartResult
    Write-Host "Error sending the magic `n$Error[0]"
    $EndResult
    exit 1
}