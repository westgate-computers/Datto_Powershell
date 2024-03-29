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
function Invoke-WakeOnLan
{
  param
  (
    # one or more MACAddresses
    [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
    # mac address must be a following this regex pattern:
    [ValidatePattern('^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$')]
    [string[]]
    $MacAddress 
  )
 
  begin
  {
    # instantiate a UDP client:
    $UDPclient = [System.Net.Sockets.UdpClient]::new()
  }
  process
  {
    foreach($_ in $MacAddress)
    {
      try {
        $currentMacAddress = $_
        
        # get byte array from mac address:
        $mac = $currentMacAddress -split '[:-]' |
          # convert the hex number into byte:
          ForEach-Object {
            [System.Convert]::ToByte($_, 16)
          }
 
        #region compose the "magic packet"
        
        # create a byte array with 102 bytes initialized to 255 each:
        $packet = [byte[]](,0xFF * 102)
        
        # leave the first 6 bytes untouched, and
        # repeat the target mac address bytes in bytes 7 through 102:
        6..101 | Foreach-Object { 
          # $_ is indexing in the byte array,
          # $_ % 6 produces repeating indices between 0 and 5
          # (modulo operator)
          $packet[$_] = $mac[($_ % 6)]
        }
        
        #endregion
        
        # connect to port 400 on broadcast address:
        $UDPclient.Connect(([System.Net.IPAddress]::Broadcast),4000)
        
        # send the magic packet to the broadcast address:
        $null = $UDPclient.Send($packet, $packet.Length)
        Write-Host "sent magic packet to $currentMacAddress..."
      }
      catch 
      {
        Write-Error "Unable to send ${mac}: $_"
      }
    }
  }
  end
  {
    # release the UDF client and free its memory:
    $UDPclient.Close()
    $UDPclient.Dispose()
  }
}

Invoke-WakeOnLan -MacAddress $env:Mac