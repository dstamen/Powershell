Function Get-VCSAUpdatePolicy {
	<#
		.NOTES
		===========================================================================
		Created by:    David Stamen
		Organization:  VMware
		Blog:          www.davidstamen.com
		Twitter:       @davidstamen
		===========================================================================
		.SYNOPSIS
			This function checks for information about the VCSA Update Policy.
		.DESCRIPTION
			Function to return details about the update policy
		.EXAMPLE
			Connect-CisServer -Server 192.168.1.51 -User administrator@vsphere.local -Password VMware1!
			Get-VCSAUpdatePolicy
	#>
	if ($Global:DefaultCisServers -eq $null) {
		Write-Warning "You are not connected to any servers: Use Connect-CisServer to connect to your VCSA"
	}
	else {
		$servers = $Global:DefaultCisServers
		foreach ($server in $servers) {
			$systemUpdateAPI = Get-CisService -Name 'com.vmware.appliance.update.policy' -Server $server.Name
			$results = $systemUpdateAPI.get()

			$summaryResult = [pscustomobject] @{
				"Server" = $server.Name;
				"Default URL" = $results.default_url;
				"Custom URL" = $results.custom_url;
				"Auto Stage" = $results.auto_stage;
				"Auto Update" = $results.auto_update;
				"Check Schedule" = $results.check_schedule
			}
			$summaryResult

		}
	}
}
Function Set-VCSAUpdatePolicy {
	<#
		.NOTES
		===========================================================================
		 Created by:    David Stamen
		 Organization:  VMware
		 Blog:          www.davidstamen.com
		 Twitter:       @davidstamen
		===========================================================================
		.SYNOPSIS
			This function checks for information about the VCSA Update Policy.
		.DESCRIPTION
			Function to return details about the update policy
		.EXAMPLE
			Connect-CisServer -Server 192.168.1.51 -User administrator@vsphere.local -Password VMware1!
			Set-VCSAUpdatePolicy -AutoStage $True
		.EXAMPLE
			Connect-CisServer -Server 192.168.1.51 -User administrator@vsphere.local -Password VMware1!
			Set-VCSAUpdatePolicy -CustomURL https://linktocustomurl
			Set-VCSAUpdatePolicy -CustomURL Clear
		.EXAMPLE
			Connect-CisServer -Server 192.168.1.51 -User administrator@vsphere.local -Password VMware1!
			Set-VCSAUpdatePolicy -UsernameURL admin
			Set-VCSAUpdatePolicy -PasswordURL Password
		.EXAMPLE
			Connect-CisServer -Server 192.168.1.51 -User administrator@vsphere.local -Password VMware1!
			Set-VCSAUpdatePolicy -CheckSchedule Daily
			Set-VCSAUpdatePolicy -CheckSchedule WeeklySunday
			Set-VCSAUpdatePolicy -CheckSchedule WeeklyMonday
			Set-VCSAUpdatePolicy -CheckSchedule WeeklyTuesday
			Set-VCSAUpdatePolicy -CheckSchedule WeeklyWednesday
			Set-VCSAUpdatePolicy -CheckSchedule WeeklyThursday
			Set-VCSAUpdatePolicy -CheckSchedule WeeklyFriday
			Set-VCSAUpdatePolicy -CheckSchedule WeeklySaturday
	#>
	Param(
		[parameter(Mandatory=$false)]
		[string] $AutoStage,
		[parameter(Mandatory=$false)]
		[string] $CustomURL,
		[parameter(Mandatory=$false)]
		[string] $UsernameURL,
		[parameter(Mandatory=$false)]
		[string] $PasswordURL,
		[parameter(Mandatory=$false)]
		[string] $CheckSchedule
	)
	if ($Global:DefaultCisServers -eq $null) {
		Write-Warning "You are not connected to any servers: Use Connect-CisServer to connect to your VCSA"
	}
	else {
		$servers = $Global:DefaultCisServers
		foreach ($server in $servers) {
			$systemUpdateAPI = Get-CisService -Name 'com.vmware.appliance.update.policy' -Server $server.Name
			$results = $systemUpdateAPI.get()
			$policy = $systemUpdateAPI.help.set.policy.Create()
			$policy.custom_url = $results.custom_url
			$policy.username = $results.username
			$policy.password = $results.password
			$policy.check_schedule = $results.check_schedule
			$policy.auto_stage = $results.auto_stage
			if ($AutoStage) {
				$policy.auto_stage = $AutoStage
				Write-Host "Updating VCSA Update Policy Autostage to $AutoStage"
			}
			if ($CustomURL) {
				if ($CustomURL -like "Clear") {
					$policy.custom_url = $null
					Write-Host "Updating VCSA Update Policy Custom URL to Cleared"

				}
				else {
					$policy.custom_url = $CustomURL
					Write-Host "Updating VCSA Update Policy Custom URL to $CustomURL"
				}
			}
			if ($UsernameURL) {
				$policy.username = $UsernameURL
				Write-Host "Updating VCSA Update Policy Username to $UsernameURL"
			}
			if ($PasswordURL) {
				[VMware.VimAutomation.Cis.Core.Types.V1.Secret]$policy.password = $PasswordURL
				Write-Host "Updating VCSA Update Policy Password to $PasswordURL"
			}
			if ($CheckSchedule) {
				if ($CheckSchedule -like "Daily") {
					$policy.check_schedule[0] = @{hour=0;minute=0;day="EVERYDAY"}
					Write-Host "Updating VCSA Update Policy Custom URL to $CheckSchedule"
				}
				elseif ($CheckSchedule -like "WeeklyMonday") {
					$policy.check_schedule[0] = @{hour=0;minute=0;day="MONDAY"}
					Write-Host "Updating VCSA Update Policy Custom URL to $CheckSchedule"
				}
				elseif ($CheckSchedule -like "WeeklyTuesday") {
					$policy.check_schedule[0] = @{hour=0;minute=0;day="TUESDAY"}
					Write-Host "Updating VCSA Update Policy Custom URL to $CheckSchedule"
				}
				elseif ($CheckSchedule -like "WeeklyWednesday") {
					$policy.check_schedule[0] = @{hour=0;minute=0;day="WEDNESDAY"}
					Write-Host "Updating VCSA Update Policy Custom URL to $CheckSchedule"
				}
				elseif ($CheckSchedule -like "WeeklyThursday") {
					$policy.check_schedule[0] = @{hour=0;minute=0;day="THURSDAY"}
					Write-Host "Updating VCSA Update Policy Custom URL to $CheckSchedule"
				}
				elseif ($CheckSchedule -like "WeeklyFriday") {
					$policy.check_schedule[0] = @{hour=0;minute=0;day="FRIDAY"}
					Write-Host "Updating VCSA Update Policy Custom URL to $CheckSchedule"
				}
				elseif ($CheckSchedule -like "WeeklySaturday") {
					$policy.check_schedule[0] = @{hour=0;minute=0;day="SATURDAY"}
					Write-Host "Updating VCSA Update Policy Custom URL to $CheckSchedule"
				}
				elseif ($CheckSchedule -like "WeeklySunday") {
					$policy.check_schedule[0] = @{hour=0;minute=0;day="SUNDAY"}
					Write-Host "Updating VCSA Update Policy Custom URL to $CheckSchedule"
				}
			}
			$results = $systemUpdateAPI.set($policy)
			$results
			$summaryResult = [pscustomobject] @{
				"Server" = $server.Name;
				"Status" = "Policy Updated"
			}
			$summaryResult

		}
	}
}
Function Get-VCSAUpdateStatus {
	<#
		.NOTES
		===========================================================================
		 Created by:    David Stamen
		 Organization:  VMware
		 Blog:          www.davidstamen.com
		 Twitter:       @davidstamen
		===========================================================================
		.SYNOPSIS
			This function checks for information about the latest VCSA Update Status.
		.DESCRIPTION
			Function to return details about the update status
		.EXAMPLE
			Connect-CisServer -Server 192.168.1.51 -User administrator@vsphere.local -Password VMware1!
			Get-VCSAUpdateStatus
	#>
	if ($Global:DefaultCisServers -eq $null) {
		Write-Warning "You are not connected to any servers: Use Connect-CisServer to connect to your VCSA"
	}
	else {
		$servers = $Global:DefaultCisServers
		foreach ($server in $servers) {
			$systemUpdateAPI = Get-CisService -Name 'com.vmware.appliance.update' -Server $server.Name
			$results = $systemUpdateAPI.get()
			$summaryResult = [pscustomobject] @{
				"Server" = $server.Name;
				"State" = $results.state;
				"Version" = $results.version;
				"Last Check" = $results.latest_query_time;
				"Stage Task" = $results.task.subtasks.stage;
				"Install Task" = $results.task.subtasks.install;
				"Progress" = $results.task.progress;
				"Operation" = $results.task.operation
			}
			$summaryResult
		}
	}
}
Function Get-VCSAUpdate {
	<#
		.NOTES
		===========================================================================
		 Created by:    David Stamen
		 Organization:  VMware
		 Blog:          www.davidstamen.com
		 Twitter:       @davidstamen
		===========================================================================
		.SYNOPSIS
			This function checks for information about the latest VCSA Updates.
		.DESCRIPTION
			Function to return details about the available updates. If No Source is Specified, it defaults to Online
		.EXAMPLE
			Connect-CisServer -Server 192.168.1.51 -User administrator@vsphere.local -Password VMware1!
			Get-VCSAUpdate
		 .EXAMPLE
			Connect-CisServer -Server 192.168.1.51 -User administrator@vsphere.local -Password VMware1!
			Get-VCSAUpdate -Source "Online"
		 .EXAMPLE
			Connect-CisServer -Server 192.168.1.51 -User administrator@vsphere.local -Password VMware1!
			Get-VCSAUpdate -Source "Local"
	#>
	Param(
		[parameter(Mandatory=$false)]
		[String] $Source
	)
	if ($Source -eq "Local") {
		$SourceType = "LOCAL"
	}
	else {
		$SourceType = "LOCAL_AND_ONLINE"
	}
	if ($Global:DefaultCisServers -eq $null) {
		Write-Warning "You are not connected to any servers: Use Connect-CisServer to connect to your VCSA"
	}
	else {
		$servers = $Global:DefaultCisServers
		foreach ($server in $servers) {
			try {
				$systemUpdateAPI = Get-CisService -Name 'com.vmware.appliance.update.pending' -Server $server.Name
				$results = $systemUpdateAPI.list($SourceType)
				ForEach($result in $results) {
					$summaryResult = [pscustomobject] @{
						"Server" = $server.Name;
						"Release Date" = $result.release_date;
						"Version" = $result.version;
						"Update Type" = $result.update_type;
						"Severity" = $result.severity;
						"Priority" = $result.priority;
						"SizeGB" = [math]::Round(([int]$result.size / 1024),2)
						"Reboot Required" = $result.reboot_required;
						"Description" = $result.description.args
					}
					$summaryResult
				}
			}
			catch {
				$e=$_
				if ($e.Exception -like "*com.vmware.vapi.std.errors.not_found*") {
					Write-Warning "No applicable update found"
				}
				elseif ($e.Exception -like "*com.vmware.vapi.std.errors.unauthenticated *") {
					Write-Warning "Session is not authenticated"
				}
			elseif ($e.Exception -like "*com.vmware.vapi.std.errors.unauthorized*") {
					Write-Warning "Session is not authorized to perform this operation"
				}
				else {
					Write-Warning "You have encountered an error, please validate server."
				}
			}
		}
	}
}
Function Get-VCSAUpdateDetail {
	<#
		.NOTES
		===========================================================================
		 Created by:    David Stamen
		 Organization:  VMware
		 Blog:          www.davidstamen.com
		 Twitter:       @davidstamen
		===========================================================================
		.SYNOPSIS
			This function checks for information about the latest VCSA Update.
		.DESCRIPTION
			Function to return details about the update
		.EXAMPLE
			Connect-CisServer -Server 192.168.1.51 -User administrator@vsphere.local -Password VMware1!
			Get-VCSAUpdateDetail -Version "6.7.0.20000"
	#>
	Param(
		[parameter(Mandatory=$true)]
		[String] $Version
	)
	if ($Global:DefaultCisServers -eq $null) {
		Write-Warning "You are not connected to any servers: Use Connect-CisServer to connect to your VCSA"
	}
	else {
		$servers = $Global:DefaultCisServers
		foreach ($server in $servers) {
			$systemUpdateAPI = Get-CisService -Name 'com.vmware.appliance.update.pending' -Server $server.Name
			$result = $systemUpdateAPI.get($Version)
			$summaryResult = [pscustomobject] @{
				"Server" = $server.Name;
				"Release Date" = $result.release_date;
				"Contents" = $result.contents;
				"Update Type" = $result.update_type;
				"Severity" = $result.severity;
				"Priority" = $result.priority;
				"SizeGB" = [math]::Round(([int]$result.size / 1024),2)
				"Reboot Required" = $result.reboot_required;
				"Staged" = $result.staged;
				"Description" = $result.description.args;
				"Services Affected" = $result.services_will_be_stopped.service
			}
			$summaryResult
		}
	}
}
Function Get-VCSAUpdateStaged {
	<#
		.NOTES
		===========================================================================
		 Created by:    David Stamen
		 Organization:  VMware
		 Blog:          www.davidstamen.com
		 Twitter:       @davidstamen
		===========================================================================
		.SYNOPSIS
			This function checks for information about the staged VCSA Update.
		.DESCRIPTION
			Function to return details about the staged update
		.EXAMPLE
			Connect-CisServer -Server 192.168.1.51 -User administrator@vsphere.local -Password VMware1!
			Get-VCSAUpdateStaged
	#>
	if ($Global:DefaultCisServers -eq $null) {
		Write-Warning "You are not connected to any servers: Use Connect-CisServer to connect to your VCSA"
	}
	else {
		$servers = $Global:DefaultCisServers
		foreach ($server in $servers) {
			try {
				$systemUpdateAPI = Get-CisService -Name 'com.vmware.appliance.update.staged' -Server $server.Name
				$result = $systemUpdateAPI.get()
				$summaryResult = [pscustomobject] @{
					"Server" = $server.Name;
					"Version" = $result.version;
					"Staging Complete" = $result.staging_complete;
					"Update Type" = $result.update_type;
					"Severity" = $result.severity;
					"Priority" = $result.priority;
					"SizeGB" = [math]::Round(([int]$result.size / 1024 / 1024 / 1024),2)
					"Reboot Required" = $result.reboot_required;
					"Description" = $result.description.args;
				}
				$summaryResult
			}
			catch {
				$e=$_
				if ($e.Exception -like "*com.vmware.vapi.std.errors.not_allowed_in_current_state*") {
					Write-Warning "Nothing is Staged"
				}
				elseif ($e.Exception -like "*com.vmware.vapi.std.errors.unauthenticated *") {
					Write-Warning "Session is not authenticated"
				}
			elseif ($e.Exception -like "*com.vmware.vapi.std.errors.unauthorized*") {
					Write-Warning "Session is not authorized to perform this operation"
				}
				else {
					Write-Warning "You have encountered an error, please validate server."
				}
			}
		}
	}
}
Function Copy-VCSAUpdate {
	<#
		.NOTES
		===========================================================================
		 Created by:    David Stamen
		 Organization:  VMware
		 Blog:          www.davidstamen.com
		 Twitter:       @davidstamen
		===========================================================================
		.SYNOPSIS
			This function stages the specified VCSA Update.
		.DESCRIPTION
			Function to download and stage update
		.EXAMPLE
			Connect-CisServer -Server 192.168.1.51 -User administrator@vsphere.local -Password VMware1!
			Copy-VCSAUpdate -Version "6.7.0.20000"
	#>
	Param(
		[parameter(Mandatory=$true)]
		[String] $Version
	)
	if ($Global:DefaultCisServers -eq $null) {
		Write-Warning "You are not connected to any servers: Use Connect-CisServer to connect to your VCSA"
	}
	else {
		$servers = $Global:DefaultCisServers
		foreach ($server in $servers) {
			$systemUpdateAPI = Get-CisService -Name 'com.vmware.appliance.update.pending' -Server $server.Name
			$results = $systemUpdateAPI.stage($Version)
			$summaryResult = [pscustomobject] @{
				"Server" = $server.Name;
				"Status" = "Update is being Staged, Run Get-VCSAUpdateStaged or Get-VCSAUpdateStatus for current status."
			}
			$summaryResult
		}
	}
}
Function Remove-VCSAUpdate {
	<#
		.NOTES
		===========================================================================
		 Created by:    David Stamen
		 Organization:  VMware
		 Blog:          www.davidstamen.com
		 Twitter:       @davidstamen
		===========================================================================
		.SYNOPSIS
			This function removes a staged VCSA update.
		.DESCRIPTION
			Function to delete staged update on VCSA
		.EXAMPLE
			Connect-CisServer -Server 192.168.1.51 -User administrator@vsphere.local -Password VMware1!
			Remove-VCSAUpdate
	#>
	if ($Global:DefaultCisServers -eq $null) {
		Write-Warning "You are not connected to any servers: Use Connect-CisServer to connect to your VCSA"
	}
	else {
		$servers = $Global:DefaultCisServers
		foreach ($server in $servers) {
			try {
				$systemUpdateAPI = Get-CisService -Name 'com.vmware.appliance.update.staged' -Server $server.Name
				$result = $systemUpdateAPI.delete()

				$summaryResult = [pscustomobject] @{
					"Server" = $server.Name;
					"Status" = "Staged update has been deleted"
				}
				$summaryResult
			} 
			catch {
				$e=$_
				if ($e.Exception -like "*com.vmware.vapi.std.errors.not_allowed_in_current_state*") {
					Write-Warning "Nothing is Staged"
				}
				elseif ($e.Exception -like "*com.vmware.vapi.std.errors.unauthenticated *") {
					Write-Warning "Session is not authenticated"
				}
				elseif ($e.Exception -like "*com.vmware.vapi.std.errors.unauthorized*") {
					Write-Warning "Session is not authorized to perform this operation"
				}
				else {
					Write-Warning "You have encountered an error, please validate server."
				}
			}
		}
	}
}
Function Start-VCSAUpdatePrecheck {
	<#
		.NOTES
		===========================================================================
		 Created by:    David Stamen
		 Organization:  VMware
		 Blog:          www.davidstamen.com
		 Twitter:       @davidstamen
		===========================================================================
		.SYNOPSIS
			This function executues the VCSA Update prechecks.
		.DESCRIPTION
			Function to run built-in prechecks
		.EXAMPLE
			Connect-CisServer -Server 192.168.1.51 -User administrator@vsphere.local -Password VMware1!
			Start-VCSAUpdatePrecheck -Version "6.7.0.20000"
	#>
	Param(
		[parameter(Mandatory=$true)]
		[String] $Version
	)
	if ($Global:DefaultCisServers -eq $null) {
		Write-Warning "You are not connected to any servers: Use Connect-CisServer to connect to your VCSA"
	}
	else {
		$servers = $Global:DefaultCisServers
		foreach ($server in $servers) {
			$systemUpdateAPI = Get-CisService -Name 'com.vmware.appliance.update.pending' -Server $server.Name
			$result = $systemUpdateAPI.precheck($Version)
			$summaryResult = [pscustomobject] @{
				"Server" = $server.Name;
				"Check Time" = $result.check_time;
				"Reboot Required" = $result.reboot_required;
				"Estimated Time to Install" = $result.estimated_time_to_install;
				"Estimated Time to Rollback" = $result.estimated_time_to_rollback;
				"Questions" = $result.questions;
				"Precheck Errors" = $result.issues.errors;
				"Precheck Warnings" = $result.issues.warnings;
				"Precheck Info" = $result.issues.info;
			}
			$summaryResult
		}
	}
}
Function Start-VCSAUpdateValidate {
	<#
		.NOTES
		===========================================================================
		 Created by:    David Stamen
		 Organization:  VMware
		 Blog:          www.davidstamen.com
		 Twitter:       @davidstamen
		===========================================================================
		.SYNOPSIS
			This function validates the VCSA Update .
		.DESCRIPTION
			Function to run built-in validation
		.EXAMPLE
			Connect-CisServer -Server 192.168.1.51 -User administrator@vsphere.local -Password VMware1!
			Start-VCSAUpdateValidate -Version "6.7.0.20000" -SSODomainPass "VMware1!"
	#>
	Param(
		[parameter(Mandatory=$true)]
		[String] $Version,
		[parameter(Mandatory=$true)]
		[String] $SSODomainPass
	)
	if ($Global:DefaultCisServers -eq $null) {
		Write-Warning "You are not connected to any servers: Use Connect-CisServer to connect to your VCSA"
	}
	else {
		$servers = $Global:DefaultCisServers
		foreach ($server in $servers) {
			$systemUpdateAPI = Get-CisService -Name 'com.vmware.appliance.update.pending' -Server $server.Name
			$UserData = $systemUpdateAPI.help.validate.user_data.Create()
			$UserData.add("vmdir.password",$SSODomainPass)
			$result = $systemUpdateAPI.validate($Version,$UserData)
			$summaryResult = [pscustomobject] @{
				"Server" = $server.Name;
				"Info" = $result.info
				"Warnings" = $result.warnings
				"Errors" = $result.errors
			}
			$summaryResult
		}
	}
}
Function Start-VCSAUpdateInstall {
	<#
		.NOTES
		===========================================================================
		 Created by:    David Stamen
		 Organization:  VMware
		 Blog:          www.davidstamen.com
		 Twitter:       @davidstamen
		===========================================================================
		.SYNOPSIS
			This function installs the VCSA Update specified.
		.DESCRIPTION
			Function to install VCSA Update. This requires update to be manually staged.
		.EXAMPLE
			Connect-CisServer -Server 192.168.1.51 -User administrator@vsphere.local -Password VMware1!
			Start-VCSAUpdateInstall -Version "6.7.0.20000" -SSODomainPass "VMware1!"
	#>
	Param(
		[parameter(Mandatory=$true)]
		[String] $Version,
		[parameter(Mandatory=$true)]
		[String] $SSODomainPass
	)
	if ($Global:DefaultCisServers -eq $null) {
		Write-Warning "You are not connected to any servers: Use Connect-CisServer to connect to your VCSA"
	}
	else {
		$servers = $Global:DefaultCisServers
		foreach ($server in $servers) {
			$systemUpdateAPI = Get-CisService -Name 'com.vmware.appliance.update.pending' -Server $server.Name
			$UserData = $systemUpdateAPI.help.install.user_data.Create()
			$UserData.add("vmdir.password",$SSODomainPass)
			$result = $systemUpdateAPI.install($Version,$UserData)
			$summaryResult = [pscustomobject] @{
				"Server" = $server.Name;
				"Status" = "Update Install has started. Run Get-VCSAUpdateStatus for the latest status."
			}
			$summaryResult
			Write-Warning "During the update process your session will be disconnected. Please reconnect to your server after a few minutes."
		}
	}
}
Function Start-VCSAUpdateStageandInstall {
	<#
		.NOTES
		===========================================================================
		 Created by:    David Stamen
		 Organization:  VMware
		 Blog:          www.davidstamen.com
		 Twitter:       @davidstamen
		===========================================================================
		.SYNOPSIS
			This function stages and installs the VCSA Update specified.
		.DESCRIPTION
			Function to stage and install VCSA Update
		.EXAMPLE
			Connect-CisServer -Server 192.168.1.51 -User administrator@vsphere.local -Password VMware1!
			Start-VCSAUpdateStageandInstall -Version "6.7.0.20000" -SSODomainPass "VMware1!"
	#>
	Param(
		[parameter(Mandatory=$true)]
		[String] $Version,
		[parameter(Mandatory=$true)]
		[String] $SSODomainPass
	)
	if ($Global:DefaultCisServers -eq $null) {
		Write-Warning "You are not connected to any servers: Use Connect-CisServer to connect to your VCSA"
	}
	else {
		$servers = $Global:DefaultCisServers
		foreach ($server in $servers) {
			$systemUpdateAPI = Get-CisService -Name 'com.vmware.appliance.update.pending' -Server $server.Name
			$UserData = $systemUpdateAPI.help.stage_and_install.user_data.Create()
			$UserData.add("vmdir.password",$SSODomainPass)
			$result = $systemUpdateAPI.stage_and_install($Version,$UserData)
			$summaryResult = [pscustomobject] @{
				"Server" = $server.Name;
				"Status" = "Update Install has started. Run Get-VCSAUpdateStatus for the latest status."
			}
			$summaryResult
			Write-Warning "During the update process your session will be disconnected. Please reconnect to your server after a few minutes."
		}
	}
}
Function Stop-VCSAUpdate {
	<#
		.NOTES
		===========================================================================
		 Created by:    David Stamen
		 Organization:  VMware
		 Blog:          www.davidstamen.com
		 Twitter:       @davidstamen
		===========================================================================
		.SYNOPSIS
			This function cancels an update task that is cancelable.
		.DESCRIPTION
			Function to cancel update task
		.EXAMPLE
			Connect-CisServer -Server 192.168.1.51 -User administrator@vsphere.local -Password VMware1!
			Stop-VCSAUpdate
	#>
	if ($Global:DefaultCisServers -eq $null) {
		Write-Warning "You are not connected to any servers: Use Connect-CisServer to connect to your VCSA"
	}
	else {
		$servers = $Global:DefaultCisServers
		foreach ($server in $servers) {
			try {
				$systemUpdateAPI = Get-CisService -Name 'com.vmware.appliance.update' -Server $server.Name
				$results = $systemUpdateAPI.cancel()
				echo $results
				$summaryResult = [pscustomobject] @{
					"Server" = $server.Name;
					"Status" = "Task has been cancelled"
				}
				$summaryResult
			}
			catch {
				$e=$_
				if ($e.Exception -like "*com.vmware.vapi.std.errors.not_allowed_in_current_state*") {
					Write-Warning "Current task is not cancelable"
				}
				elseif ($e.Exception -like "*com.vmware.vapi.std.errors.unauthenticated *") {
					Write-Warning "Session is not authenticated"
				}
				elseif ($e.Exception -like "*com.vmware.vapi.std.errors.unauthorized*") {
					Write-Warning "Session is not authorized to perform this operation"
				}
				else {
					Write-Warning "You have encountered an error, please validate server."
				}
			}
		}
	}
}