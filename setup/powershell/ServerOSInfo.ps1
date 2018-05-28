<#
 Collection script for Computer level related information                  
 Needs to be tested with clusters. 
 Needs to be tested using SQL Credential

 Depends on dbatools and PSFramework

 Database dependencies

 Tables:    Staging.DbaNetworkName
            Staging.DbaComputerSystem
            Staging.DbaOperatingSystem
            Staging.DbaPageFileSetting
            info.ComputerInfo
            Monitoring.ComputerInfo

 Views:     Staging.ComputerInfo 

 SP:        Staging.ComputerInfoMerge

 Agent Job: "dbareports - Windows Server Data Collector"
#>
<#
    .SYNOPSIS
        Adds Server level information to the dbareports repository database for Computers defined in view against info.ComputerList  

    .DESCRIPTION 
        This Script will check all of the Computers from a Repository view defined against the info.ComputerList. 
        Collects the Computer Info and save to the info.ComputerInfo table
        
        
        It collects data from the following dbatools.io functions:
            Resolve-DbaNetworkName
            Get-DbaComputerSystem
            Get-DbaOperatingSystem
            Get-DbaPageFileSetting
        
        Running this script requires both dbatools and PSFramework be installed on the Monitoring Server
 
    .NOTES
        Tags: Reports
        License: MIT https://opensource.org/licenses/MIT

#>

[CmdletBinding()]
Param (
	[Alias("SqlInstance")]
	[object]$RepositoryInstance = "W2016BASE\SQL2017",
	[object]$SqlCredential,
	[string]$RepositoryDatabase = "dbareports",
    [string]$RepositoryQuery = "Reporting.ActiveComputers",
	[string]$LogFileFolder = "D:\ITOPS\dbareports\Logs"
)

BEGIN
{
	# Load up shared functions (use dbatools instead of repeating code)
    Import-Module -Name dbatools
    Import-Module -Name PSFramework

	Write-PSFMessage -Level Verbose  -Message "ComputerOSInfo Job started" -Tag "dbareports"

	# Connect to dbareports server
	try
	{
		Write-PSFMessage -Level Verbose  -Message "Connecting to $RepositoryInstance" -Tag "dbareports"
        $SqlInstance = Connect-DbaInstance -SqlInstance $RepositoryInstance -Database $RepositoryDatabase 
	}
	catch
	{
        Write-PSFMessage -Level Warning -Message "Failed to connect to $RepositoryInstance - $_" -ErrorRecord $_ -Tag "dbareports"
	}

}

PROCESS
{
	$DateChecked = Get-Date
	try
	{
        Write-PSFMessage -Level Verbose  -Message "Clearing the required Staging Tables" -Tag "dbareports"
        $SqlInstance | Invoke-DbaSqlQuery -Query 'TRUNCATE TABLE Staging.DbaNetworkName' 
        $SqlInstance | Invoke-DbaSqlQuery -Query 'TRUNCATE TABLE Staging.DbaComputerSystem' 
        $SqlInstance | Invoke-DbaSqlQuery -Query 'TRUNCATE TABLE Staging.DbaOperatingSystem'
        $SqlInstance | Invoke-DbaSqlQuery -Query 'TRUNCATE TABLE Staging.DbaPageFileSetting'

		Write-PSFMessage -Level Verbose  -Message "Getting a list of ComputerNames from the dbareports repository database - $RepositoryInstance" -Tag "dbareports"
		$sql = "SELECT ComputerName FROM $RepositoryQuery"

		$ComputerList = $SqlInstance | Invoke-DbaSqlQuery -Query $sql 
		Write-PSFMessage -Level Verbose  -Message "Got the list of ComputerNames from the dbareports repository database - $RepositoryInstance" -Tag "dbareports"
	
	}
	catch
	{
        Write-PSFMessage -Level Warning -Message "Failed to get list of ComputerNames from the dbareports repository database - $RepositoryInstance" -ErrorRecord $_ -Tag "dbareports"
		break
	}
	
	
	foreach ($Computer in $ComputerList)
	{
		$ComputerName = $Computer.ComputerName
		
		# Connect to Instance
        try
        {
            Write-PSFMessage -Level Verbose  -Message "Connecting to $ComputerName" -Tag "dbareports"
            $NwNameInfo = Resolve-DbaNetworkName -ComputerName $ComputerName | Select InputName, @{Name='ReadingDate';Expression={get-date -Format "yyyy-MM-dd"}}, 
                    ComputerName, IPAddress, FQDN, FullComputerName | ConvertTo-DbaDataTable

            Write-DbaDataTable -SqlInstance $SqlInstance -Database $RepositoryDatabase -InputObject $NwNameInfo -Table Staging.DbaNetworkName

        }
        Catch
        {
            Write-PSFMessage -Level Warning -Message "Failed to connect to $Connection - $_" -ErrorRecord $_ -Tag "dbareports"
            $NwNameInfo = $null
            continue
        }   
        
        If ($NwNameInfo -ne $Null) {
		    try
		    {
                $CSInfo = $null
          		Write-PSFMessage -Level Verbose  -Message "Collecting Get-DbaComputerSystem for $ComputerName" -Tag "dbareports"
                $CSInfo = Get-DbaComputerSystem  -ComputerName $ComputerName | Select @{Name='InputName';Expression={$($ComputerName)}}, ComputerName, Domain, DomainRole, Manufacturer, Model, SystemType, NumberLogicalProcessors, NumberProcessors, IsHyperThreading, TotalPhysicalMemory, IsDaylightSavingsTime, DaylightInEffect, DnsHostName | ConvertTo-DbaDataTable                
                
                Write-PSFMessage -Level Verbose  -Message "Writing Get-DbaComputerSystem for $ComputerName" -Tag "dbareports"
                Write-DbaDataTable -SqlInstance $SqlInstance -Database $RepositoryDatabase -InputObject $CSInfo -Table Staging.DbaComputerSystem
			                    
		    }
		    catch
		    {
                Write-PSFMessage -Level Warning -Message "Failed to add Get-DbaComputerSystem data for $ComputerName" -ErrorRecord $_ -Tag "dbareports"
			    continue
		    }

		    try
		    {
                $OSInfo = $null
                Write-PSFMessage -Level Verbose  -Message "Collecting Get-DbaOperatingSystem for $ComputerName" -Tag "dbareports"          		
                $OSInfo = Get-DbaOperatingSystem -ComputerName $ComputerName | Select @{Name='InputName';Expression={$($ComputerName)}}, ComputerName, Manufacturer, Architecture, Version, 
                Build, OSVersion, SPVersion, InstallDate, LastBootTime, LocalDateTime, PowerShellVersion, TimeZone, TimeZoneStandard, TimeZoneDaylight, BootDevice, SystemDevice, SystemDrive, 
                WindowsDirectory, PagingFileSize, TotalVisibleMemory, FreePhysicalMemory, TotalVirtualMemory, FreeVirtualMemory, ActivePowerPlan, Status, Language, LanguageAlias, CountryCode  | ConvertTo-DbaDataTable
                
                Write-PSFMessage -Level Verbose  -Message "Writing Get-DbaOperatingSystem for $ComputerName" -Tag "dbareports"
                Write-DbaDataTable -SqlInstance $SqlInstance -Database $RepositoryDatabase -InputObject $OSInfo -Table Staging.DbaOperatingSystem                
		    }
		    catch
		    {			  
                Write-PSFMessage -Level Warning -Message "Failed to add Get-DbaOperatingSystem data for $ComputerName" -ErrorRecord $_ -Tag "dbareports"
			    continue
		    }

		    try
		    {
                $PFInfo = $null
          		Write-PSFMessage -Level Verbose  -Message "Collecting Get-DbaPageFileSetting for $ComputerName" -Tag "dbareports"          		
                $PFInfo = Get-DbaPageFileSetting -ComputerName $ComputerName | Select @{Name='InputName';Expression={$($ComputerName)}}, ComputerName, AutoPageFile, FileName, Status, LastModified, LastAccessed, AllocatedBaseSize, InitialSize, MaximumSize, PeakUsage, CurrentUsage | ConvertTo-DbaDataTable
                
                Write-PSFMessage -Level Verbose  -Message "Writing Get-DbaPageFileSetting for $ComputerName" -Tag "dbareports"
                Write-DbaDataTable -SqlInstance $SqlInstance -Database $RepositoryDatabase -InputObject $PFInfo -Table Staging.DbaPageFileSetting
		    }
		    catch
		    {
                Write-PSFMessage -Level Warning -Message "Failed to add Get-DbaPageFileSetting data for $ComputerName" -ErrorRecord $_ -Tag "dbareports"
			    continue
		    }
            
        }
        
	}
	
}

END
{
	Write-PSFMessage -Level Verbose  -Message "ComputerOSInfo Job Finished" -Tag "dbareports"
	$SqlInstance.ConnectionContext.Disconnect()
}

