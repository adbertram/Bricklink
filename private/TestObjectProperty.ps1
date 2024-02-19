function TestObjectProperty {
	[OutputType([bool])]
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[object]$InputObject,

		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$PropertyName
	)
	try {
		if ($PropertyName -in ($InputObject | Get-Member -MemberType Properties | Select-Object Name).name) {
			$true
		} else {
			$false
		}
	} catch {
		$PSCmdlet.ThrowTerminatingError($_)
	}
}