ps_scripts
==========

a collection of powershell scripts
----------------------------------

+ change-dns-resolvers.ps1: Detects and changes DNS resolver config for servers using get-wmiobject.  Creates undo files to rollback changes.

+ AD_add_ace_to_acl.ps1: Modify an Active Directory user's ACL by adding an ACE

+ dhcp_import.ps1: Use when migrating from pre-Windows 2012 DHCP server to a Windows 2012 DHCP Failover server set.  Imports scope information (with leases) from two Windows DHCP servers configured for split scopes.  Will also pull scopes that exist uniquely from each server.  Then combines the split scope IP ranges and lease information before importing to your Windows 2012 DHCP server in failover mode.  Optional command to add the new scopes to your failover relationship.

+ take-snapshot1.ps1: VMware vSphere PowerCLI script to take server snapshots.  Parameters are server names.

+ profile.ps1: Useful functions for the shell.
