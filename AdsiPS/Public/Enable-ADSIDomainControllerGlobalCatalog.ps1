﻿function Enable-ADSIDomainControllerGlobalCatalog
{
<#
	.SYNOPSIS
		Function to enable the Global Catalog role on a Domain Controller
	
	.DESCRIPTION
		Function to enable the Global Catalog role on a Domain Controller
	
	.PARAMETER ComputerName
		Specifies the Domain Controller
	
	.PARAMETER Credential
		Specifies alternate credentials to use. Use Get-Credential to create proper credentials.
	
	.EXAMPLE
		Enable-ADSIDomainControllerGlobalCatalog -ComputerName dc1.ad.local
		
		Connects to remote domain controller dc1.ad.local using current credentials and enable the GC role.

	.EXAMPLE
		Enable-ADSIDomainControllerGlobalCatalog -ComputerName dc2.ad.local -Credential (Get-Credential SuperAdmin)
		
		Connects to remote domain controller dc2.ad.local using SuperAdmin credentials and enable the GC role.
	
	.NOTES
		Version History
			1.0 Initial Version (Micky Balladelli)
			1.1 Update (Francois-Xavier Cat)
					Rename from Enable-ADSIReplicaGC to Enable-ADSIDomainControllerGlobalCatalog
					Add New-ADSIDirectoryContext to take care of the Context
					Other minor modifications
	
		Authors
			Micky Balladelli
			 balladelli.com
			 micky@balladelli.com
			 @mickyballadelli
			
			Francois-Xavier Cat
			 lazywinadmin.com
			 @lazywinadm
			 github.com/lazywinadmin
#>
	
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$ComputerName,
		
		[System.Management.Automation.Credential()]
		[Alias('RunAs')]
		$Credential = [System.Management.Automation.PSCredential]::Empty
	)
	
	PROCESS
	{
		TRY
		{
			$Context = New-ADSIDirectoryContext -ContextType 'DirectoryServer' @PSBoundParameters
			$DomainController = [System.DirectoryServices.ActiveDirectory.DomainController]::GetDomainController($context)
			
			IF ($DomainController.IsGlobalCatalog())
			{ Write-Verbose -Message "[Enable-ADSIDomainControllerGlobalCatalog][PROCESS] $($DomainController.name) is already a Global Catalog" }
			ELSE
			{
				Write-Verbose -Message "[Enable-ADSIDomainControllerGlobalCatalog][PROCESS] $($DomainController.name) Enabling Global Catalog ..."
				$DomainController.EnableGlobalCatalog()
			}
			
			Write-Verbose -Message "[Enable-ADSIDomainControllerGlobalCatalog][PROCESS] $($DomainController.name) Done."
		}
		CATCH
		{
			Write-Error -Message "[Enable-ADSIDomainControllerGlobalCatalog][PROCESS] Something wrong happened"
			$Error[0].Exception.Message
		}
	}
}