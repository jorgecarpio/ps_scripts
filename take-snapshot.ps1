  <#
    .SYNOPSIS 
      Takes a host or hosts, or optionally a VMware Folder name and snapshots them.
    .EXAMPLE
     .\take-snapshot.ps1 host1
     Takes a snapshot of host1

     .\take-snapshot.ps1 host1, host2
     Takes a snapshot of host1 and host2

     .\take-snapshot.ps1 -folderName Accounting
     Takes snapshots of all the VM's in Accounting
  #>

Param(
  [string[]] $hosts,
  [string]$folderName
  )

Set-PowerCLIConfiguration -InvalidCertificateAction "Ignore" -DefaultVIServerMode single -Confirm:$false

Connect-VIServer -Server server_name -Protocol https -User domain\username -Password password

$name = get-date -format f
if ($hosts) {
  foreach ($host in $hosts)
    {New-Snapshot -VM $host -Name $name -Quiesce:$false}
}

if ($foldername) {
  foreach ($host in Get-Folder $foldername | Get-VM)
    {New-Snapshot -VM $host -Name $name -Quiesce:$false}
}
