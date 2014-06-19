Function like ($type, $name) {
<#
	.SYNOPSIS
	Shortcut for searching object names in Get-AD* cmdlets!
	.EXAMPLE
	like user bob
	This command runs get-aduser -filter 'name -like "*bob*"'
	.EXAMPLE
	like computer zeus
	This command runs get-adcomputer -filter 'name -like "*zeus*"'
	.EXAMPLE
	like group accounting
	This command runs get-adgroup -filter 'name -like "*accounting*"'
#>
	$callargs = @("name -like `'*$name*`'")
	$command = "get-ad" + $type
	& $command -filter @callargs
}

function map ($fn, $a)
{
	for ($i = 0; $i -lt $a.length; $i++)
	{
	&$fn $a[$i]
	}
}

function reduce ($fn, $a, $init)
{
	$s = $init
	for ($i = 0; $i -lt $a.length; $i++)
	{
	$s = &$fn $s $a[$i]
	}
	return $s
}
