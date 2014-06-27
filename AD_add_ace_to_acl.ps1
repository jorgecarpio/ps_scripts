# Script will add an ACE for an Active Directory user's ACL

# user samAccountNames are pulled from mod_users.txt

$mod_users = gc .\mod_users.txt

# sid of account operators
$sid = New-Object System.Security.Principal.SecurityIdentifier `
(Get-ADGroup "Account Operators").SID

$right = "GenericAll"
$type = "Allow"

foreach ($user in $mod_users) {
	# get user dn from samaccountname
	$dn = Get-ADUser $user | select -expandproperty distinguishedName

	# get user's acl
	# $acl.Access lists the actual ACL

	$acl = (get-acl ("ad:\" + $dn))

	# create/add a new ACE for ACL

	$acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule `
	$sid,$right,$type))

	#Re-apply the modified ACL to the OU

	Set-ACL -ACLObject $acl -Path ("AD:\" + $dn)

	}
