# Script to export out scopes from two DHCP servers acting in a split-scope configuration.
# Assumes that you have a master_scope_list.txt listing all the scopes that are split between 
# server1 and server2.  Also, you can use server1_scopes and server2_scopes for any scopes that
# aren't in split scope and are unique to each server.  These files are merely a list of IP scopes.

$server1 = "server1"
$server2 = "server2"
$master_scope_list = gc .\master_scope_list.txt
$server1_scopes = gc .\server1_scopes.txt
$server2_scopes = gc .\server2_scopes.txt

# split scope processing
foreach ($scope in $master_scope_list) {
    # get the scope files
    export-dhcpserver $($server1 + "_" + $scope) -computername $server1 -scopeid $scope -leases
    export-dhcpserver $($server2 + "_" + $scope) -computername $server2 -scopeid $scope -leases

    # edit endrange and save files
    [xml]$server2_xml = gc $($server2 + "_" + $scope)
    $endrange = $server2_xml.DHCPServer.IPv4.Scopes.Scope.EndRange
    [xml]$server1_xml = gc $($server1 + "_" + $scope)
    $server1_xml.DHCPServer.IPv4.Scopes.Scope.EndRange = $endrange


    # merge the leases
    $parent_node = $server1_xml.DHCPServer.IPv4.Scopes.Scope.Leases
    $child_node = $server2_xml.DHCPServer.IPv4.Scopes.Scope.Leases
    while ($child_node.HasChildNodes) {
        $cn = $child_node.firstchild
        $cn = $child_node.Removechild($cn)
        $cn = $parent_node.OwnerDocument.ImportNode($cn, $true)
        $parent_node.AppendChild($cn)
    }

    # save the files
    $server1_xml.Save("c:\export\prod\ready_" + $scope)

    # import to dhcp server
    $filename = "ready_" + $scope
    $bkuppath = "bkup_" + $scope
    import-dhcpserver $filename -scopeid $scope -BackupPath $bkuppath -force -ScopeOverwrite -Leases
}


# unique scope processing
# no merging of lease data or modification of endrange necessary
foreach ($scope in $server1_scopes) {
    export-dhcpserver $("ready_" + $scope) -computername $server1 -scopeid $scope -leases
    $filename = "ready_" + $scope
    $bkuppath = "bkup_" + $scope
    import-dhcpserver $filename -scopeid $scope -BackupPath $bkuppath -force -ScopeOverwrite -Leases
}

foreach ($scope in $server2_scopes) {
    export-dhcpserver $("ready_" + $scope) -computername $server2 -scopeid $scope -leases
    $filename = "ready_" + $scope
    $bkuppath = "bkup_" + $scope
    import-dhcpserver $filename -scopeid $scope -BackupPath $bkuppath -force -ScopeOverwrite -Leases
}

# add all newly added scopes to existing failover relationship
# $failover_name = "your_failover_relationship_name"
# $uberscopelist = $master_scope_list + $server1_scopes + $server2_scopes
# foreach ($scope in $uberscopelist) {
# Add-DhcpServerv4FailoverScope -Name $failover_name -ScopeId $scope
# }
