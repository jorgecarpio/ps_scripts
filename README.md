ps_scripts
==========

a collection of powershell scripts
----------------------------------

+ dhcp_import.ps1: Imports scope information (with leases) from two Windows DHCP servers configured for split scopes.  Will also pull scopes that exist uniquely from each server.  Then combines the split scope IP ranges and lease information before importing to your Windows 2012 DHCP server in failover mode.  Optional command to add the new scopes to your failover relationship.

+ take-snapshot1.ps1: VMware vSphere PowerCLI script to take server snapshots.  Parameters are server names.
