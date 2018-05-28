<#
 Collection script for Computer level Disk information inculding Diskspace                  
 Needs to be tested with clusters. 
 Needs to be tested using SQL Credential

 Depends on dbatools and PSFramework

 Database dependencies

 Tables:    Staging.DbaDiskSpace
            info.DiskSpaceInfo
            Monitoring.DiskSpaceInfo

 Views:     Staging.DiskSpaceInfo 

 SP:        Staging.DiskSpaceInfoMerge

 Agent Job: "dbareports - Disk Space Data Collector"

#>
<#
    .SYNOPSIS
        Adds disk information to the dbareports repository database for Computers defined in view against info.ComputerList
  
    .DESCRIPTION 
        This Script will check all of the Computers from a Repository view defined against the info.ComputerList. 
        Collects the Disk level Infomation and save to the info.DiskSpaceInfo (summary) and Monitoring.DiskSpaceInfo
        
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

    Write-PSFMessage -Level Verbose  -Message "DiskSpace Job started" -Tag "dbareports"
	
	# Connect to dbareports server
	try
	{
		Write-PSFMessage -Level Verbose -Message "Connecting to $RepositoryInstance" -Tag "dbareports"       
        $SqlInstance = Connect-DbaInstance -SqlInstance $RepositoryInstance -Database $RepositoryDatabase
	}
	catch
	{
        Write-PSFMessage -Level Warning -Message "Failed to connect to $RepositoryInstance" -ErrorRecord $_ -Tag "dbareports"
	}	
}

PROCESS
{
	try
	{

        Write-PSFMessage -Level Verbose -Message "Clearing the required Staging Tables" -Tag "dbareports"
        $SqlInstance | Invoke-DbaSqlQuery -Query 'TRUNCATE TABLE Staging.DbaDiskSpace' 

        Write-PSFMessage -Level Verbose -Message "Getting a list of ComputerNames from the dbareports repository database - $RepositoryInstance" -Tag "dbareports"
		$sql = "SELECT ComputerName FROM $RepositoryQuery"

		$ComputerList = $SqlInstance | Invoke-DbaSqlQuery -Query $sql 
		Write-PSFMessage -Level Verbose -Message "Got the list of ComputerNames from the dbareports repository database - $RepositoryInstance" -Tag "dbareports"
	
	}
	catch
	{
        Write-PSFMessage -Level Warning -Message "Failed to get list of ComputerNames from the dbareports repository database - $RepositoryInstance" -ErrorRecord $_ -Tag "dbareports"
		break
	}
	
	foreach ($Computer in $ComputerList)
	{
		$ComputerName = $Computer.ComputerName		
		Write-PSFMessage -Level Verbose -Message "Processing $ComputerName" -Tag "dbareports"

		try
		{
            $DiskInfo = $null
          	Write-PSFMessage -Level Verbose -Message "Collecting Get-DbaDiskSpace for $ComputerName" -Tag "dbareports"          		
            $DiskInfo = Get-DbaDiskSpace -ComputerName $ComputerName | SELECT ComputerName, @{Name='ReadingDate';Expression={get-date -Format "yyyy-MM-dd HH:mm:ss"}}, Name, Label, PercentFree, BlockSize, FileSystem, IsSqlDisk, DriveType, SizeInBytes, FreeInBytes | ConvertTo-DbaDataTable

            Write-PSFMessage -Level Verbose -Message "Writing Get-DbaDiskSpace for $ComputerName" -Tag "dbareports"
            Write-DbaDataTable -SqlInstance $SqlInstance -Database $RepositoryDatabase -InputObject $DiskInfo -Table Staging.DbaDiskSpace
		}
		catch
		{
            Write-PSFMessage -Level Warning -Message "Failed to add Get-DbaDiskSpace data for $ComputerName" -ErrorRecord $_ -Tag "dbareports"
			continue
		}

	}
	
}

END
{
	Write-PSFMessage -Level Verbose -Message "DiskSpace Job Finished" -Tag "dbareports"
    $SqlInstance.ConnectionContext.Disconnect()
}
