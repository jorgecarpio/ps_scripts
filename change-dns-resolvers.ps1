$baddns = "0.0.0.0"
$servers = get-adcomputer -Filter {(OperatingSystem -Like "Windows *Server*")}
$badrpc = @()
$fixme = @()

# Locate servers with an incorrectly configured DNS resolver

foreach ($server in $servers) {
$rtn = $null
$rtn = Test-Connection $server.Name -Count 1 -BufferSize 16 -Quiet
if ($rtn -match 'True') {
    try {
        write-host "working on $server.name"
        $dnssettings = .\get-dnsresolverinfo.ps1 -computername $server.name | select -ExpandProperty dns

        if ($dnssettings | Select-String -pattern $baddns -SimpleMatch) {
            write-host -ForegroundColor green "$server.name has incorrect dns $baddns!"
            $fixme += $server.Name
        }
    }
    catch {
        write-host -ForegroundColor Cyan "rpc trouble with $server"
        $badrpc += $server.Name
    }
    
   }
  }



# Correct the servers with improperly configured DNS resolvers


$logfile = "c:\123\dnschg.log"
$newDNSservers = "192.168.1.2","192.168.1.3"
$fixme| % {
    $nics = Get-WmiObject win32_networkadapterconfiguration -ComputerName $_ | where { $_.IPEnabled -eq "TRUE" }
    foreach ($nic in $nics) {
        foreach ($ip in $nic.IPAddress) {
            # Only work on adapters configured for the 192.x.x.x LAN
            if ($ip.StartsWith("192.")) {
                write-output "NIC with IP $ip on $_ about to be modified"
                write-output "Current DNS Servers"
                write-output $nic.dnsserversearchorder
                write-output "===================================================="

                # Create "undo" files that contain commands to easily rollback
                $dns = @()
                foreach ($d in $nic.DNSServerSearchOrder) { $dns += """$d""" }
                $dns = $dns -join ","
                $iindex = $nic.InterfaceIndex
                write-output "`$dns` = $dns" | out-file "$_.undo"
                write-output "(get-wmiobject win32_networkadapterConfiguration -ComputerName $_ | where { `$_`.interfaceindex -eq $iindex}).setdnsserversearchorder(`$dns`)" | out-file -Append "$_.undo"
                
                # Perform Change and log it

                $nic.SetDNSServerSearchOrder($newdnsservers)
                Write-Output "Change complete"

                # Verify Change
                $changedDNS = $nic.DNSServerSearchOrder
                foreach ($entry in $changedDNS) {
                    if ($newdnsservers -notcontains $entry) {
                        Write-Output "****************************************************"
                        Write-Output "Server $_ missing $entry.  Requires manual change"
                        Write-Output "****************************************************"
                        Write-Host -ForegroundColor Red "Server $_ missing $entry.  Make change manually"
                        Write-Output "****************************************************"
                    }
                }

            }
        }
        } 
} | out-file -Append $logfile

