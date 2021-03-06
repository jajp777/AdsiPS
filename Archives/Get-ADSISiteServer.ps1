﻿function Get-ADSISiteServer
{
<#
.SYNOPSIS
	This function will query Active Directory for all Sites Servers
	
.PARAMETER Site
	Specify the name of the Site
	
.PARAMETER Credential
    Specify the Credential to use
	
.PARAMETER DomainDistinguishedName
    Specify the DistinguishedName of the Domain to query
	
.PARAMETER SizeLimit
    Specify the number of item(s) to output.
    Default is 100.
	
.EXAMPLE
	Get-ADSISiteServer -Site "Montreal"

.EXAMPLE
	Get-ADSISiteServer -Site "Montreal" -Domain "DC=Contoso,DC=com"
	
.NOTES
	Francois-Xavier Cat
	LazyWinAdmin.com
	@lazywinadm
#>
	[CmdletBinding()]
	PARAM (
		[Parameter(Mandatory = $true)]
		$Site,
		
		[Parameter()]
		[Alias("Domain", "DomainDN")]
		[String]$DomainDistinguishedName = $(([adsisearcher]"").Searchroot.path),
		
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		
		[Alias("ResultLimit", "Limit")]
		[int]$SizeLimit = '100'
	)
	BEGIN { }
	PROCESS
	{
		TRY
		{
			# Building the basic search object with some parameters
			$Search = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop'
			$Search.SizeLimit = $SizeLimit
			$Search.Filter = "(objectclass=server)"
			
			IF ($PSBoundParameters['DomainDistinguishedName'])
			{
				IF ($DomainDistinguishedName -notlike "LDAP://*") { $DomainDistinguishedName = "LDAP://$DomainDistinguishedName" }#IF
				Write-Verbose -Message "[PROCESS] Different Domain specified: $DomainDistinguishedName"
				$Search.SearchRoot = $DomainDistinguishedName
			}
			IF ($PSBoundParameters['Credential'])
			{
				Write-Verbose -Message "[PROCESS] Different Credential specified: $($credential.username)"
				$Cred = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDistinguishedName, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
				$Search.SearchRoot = $Cred
			}
			If (-not $PSBoundParameters["SizeLimit"])
			{
				Write-Warning -Message "Default SizeLimit: 100 Results"
			}
			
			$Search.SearchRoot = $DomainDistinguishedName -replace "LDAP://", "LDAP://CN=Servers,CN=$Site,CN=Sites,CN=Configuration,"
			
			foreach ($Site in $($Search.FindAll()))
			{
				# Define the properties
				#  The properties need to be lowercase!!
				$Site.properties
				
                <#

                #>
				
				
				
				# Output the info
				#New-Object -TypeName PSObject -Property $Properties
			}
		}#TRY
		CATCH
		{
			Write-Warning -Message "[PROCESS] Something wrong happened!"
			Write-Warning -Message $error[0].Exception.Message
		}
	}#PROCESS
	END
	{
		Write-Verbose -Message "[END] Function Get-ADSISite End."
	}
}