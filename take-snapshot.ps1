if (!$args)
{Write-Host 'Specifiy hostnames after script. e.g. take-snapshot.ps1 host1 host2'
break}

Set-PowerCLIConfiguration -InvalidCertificateAction "Ignore" -DefaultVIServerMode single -Confirm:$false

Connect-VIServer -Server server_name -Protocol https -User domain\username -Password password

$name = get-date -format f

foreach ($i in $args)
{New-Snapshot -VM $i -Name $name -Quiesce:$false}
