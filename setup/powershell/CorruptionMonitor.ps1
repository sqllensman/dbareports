<#
 Collection script for SQLServer Database level information on Suspect Pages and CheckDB Execution                   
 Needs to be tested with clusters. 
 Needs to be tested using SQL Credential
                     
 Depends on dbatools and PSFramework

 Database dependencies

 Tables:    Staging.DbaLastGoodCheckDb
            Staging.DbaSuspectPage 

            info.DatabaseCheckDBInfo
            Monitoring.DatabaseCheckDBInfo
            Monitoring.DatabaseSuspectPageInfo

 Views:     Staging.DatabaseCheckDBInfo
            Staging.DatabaseSuspectPageInfo 

 SP:        Staging.DatabaseCheckDBInfoMerge
            Staging.DatabaseSuspectPageInfoAdd

 Agent Job: "dbareports - CorruptionMonitor Data Collector"

#>
<#
    .SYNOPSIS 
        Adds data regarding Suspect Pages and DBCC CheckDB to the dbareports repository database for Instances defined in view against info.SqlInstanceList

    .DESCRIPTION
        This Script will check all of the SQL Server Instances from a Repository view defined against the info.SQLInstanceList
        It collects data from the following dbatools.io functions:
            Get-DbaSuspectPage
            Get-DbaLastGoodCheckDb
        
        Running this script requires both dbatools and PSFramework be installed on the Monitoring Server

    .NOTES 
        Tags: Reports
        License: MIT https://opensource.org/licenses/MIT

#>
[CmdletBinding()]
Param (
	[object]$RepositoryInstance = "W2016BASE\SQL2017",
	[object]$SqlCredential,
	# this will come much later
	[string]$RepositoryDatabase = "dbareports",
    [string]$RepositoryQuery = "Reporting.SQLInstanceList",
	[string]$LogFileFolder = "D:\ITOPS\dbareports\Logs"
)

BEGIN
{
	# Load up shared functions (use dbatools instead of repeating code)
    Import-Module -Name dbatools
    Import-Module -Name PSFramework

    Write-PSFMessage -Level Verbose  -Message "Corruption Monitor Job started" -Tag "dbareports"

	# Connect to dbareports server
	try
	{
        Write-PSFMessage -Level Verbose  -Message "Connecting to $RepositoryInstance" -Tag "dbareports"
        $SqlInstance = Connect-DbaInstance -SqlInstance $RepositoryInstance -Database $RepositoryDatabase 
	}
	catch
	{
        Write-PSFMessage -Level Warning -Message "Failed to connect to $RepositoryInstance" -ErrorRecord $_ -Tag "dbareports"
        continue
	}

}

PROCESS
{
	$DateChecked = Get-Date
	try
	{
        Write-PSFMessage -Level Verbose  -Message "Clearing the required Staging Tables" -Tag "dbareports"
        $SqlInstance | Invoke-DbaSqlQuery -Query 'TRUNCATE TABLE Staging.DbaLastGoodCheckDb' 
         
		Write-PSFMessage -Level Verbose  -Message "Getting a list of SQL Server Instances from the dbareports repository database - $RepositoryInstance"  -Tag "dbareports"
		$sql = "SELECT InstanceID, ComputerName, instanceName, ConnectName FROM $RepositoryQuery"

		$SqlServerInstances = $SqlInstance | Invoke-DbaSqlQuery -Query $sql 
		Write-PSFMessage -Level Verbose  -Message "Got the list of SQL Server Instances from the dbareports repository database - $RepositoryInstance"  -Tag "dbareports"
	
	}
	catch
	{
        Write-PSFMessage -Level Warning -Message "Failed to get list of SQL Server Instances from the dbareports repository database - $RepositoryInstance" -ErrorRecord $_ -Tag "dbareports"
		break
	}
	
	foreach ($sqlserver in $SqlServerInstances)
	{
		$sqlservername = $sqlserver.ServerName
		$InstanceName = $sqlserver.SqlInstance
		$InstanceId = $sqlserver.InstanceId
        $Connection = $sqlserver.InstanceName
		
		# Connect to Instance
		try
		{
            $SqlServerInstance = Connect-DbaInstance -SqlInstance $Connection
			Write-PSFMessage -Level Verbose  -Message "Connecting to $Connection"  -Tag "dbareports"
		}
		catch{
            Write-PSFMessage -Level Warning -Message "Failed to connect to $Connection - $_ -ErrorRecord $_" -Tag "dbareports"
			continue
		}
        
		try {
                $SuspectPages = $null
          		Write-PSFMessage -Level Verbose  -Message "Collecting Get-DbaSuspectPage data for $InstanceName"  -Tag "dbareports"          		
                $SuspectPages = Get-DbaSuspectPage -SqlInstance $SqlServerInstance | Select @{Name='InstanceId';Expression={$($InstanceId)}}, SqlInstance, @{Name='ReadingDate';Expression={get-date -Format "yyyy-MM-dd HH:mm:ss"}}, ComputerName, 
                    InstanceName, Database, FileId, PageId, EventType, ErrorCount, LastUpdateDate | ConvertTo-DbaDataTable

                If ($SuspectPages) {
                    Write-PSFMessage -Level Verbose  -Message "Writing Get-DbaSuspectPage data for $InstanceName"  -Tag "dbareports"
                    Write-DbaDataTable -SqlInstance $SqlInstance -Database $RepositoryDatabase -InputObject $SuspectPages -Table Staging.DbaSuspectPage -KeepNulls    
                }
                else {
                    Write-PSFMessage -Level Verbose  -Message "Skipping Writing Get-DbaSuspectPage data for $InstanceName. No Problems found"  -Tag "dbareports"
                }
		    }
		catch {			 
                Write-PSFMessage -Level Warning -Message "Failed to add Get-DbaLastGoodCheckDb data for for $InstanceName" -ErrorRecord $_ -Tag "dbareports"
			    continue
		}

		try {
                $LastGoodCheckDb = $null
          		Write-PSFMessage -Level Verbose  -Message "Get-DbaLastGoodCheckDb data for $InstanceName"  -Tag "dbareports"          		
                $LastGoodCheckDb = Get-DbaLastGoodCheckDb -SqlInstance $SqlServerInstance | Select @{Name='InstanceId';Expression={$($InstanceId)}}, SqlInstance, @{Name='ReadingDate';Expression={get-date -Format "yyyy-MM-dd HH:mm:ss"}}, ComputerName, InstanceName,
                    Database, DatabaseCreated, LastGoodCheckDb, DaysSinceLastGoodCheckDb, DaysSinceDbCreated, Status, DataPurityEnabled, CreateVersion | ConvertTo-DbaDataTable
                
                Write-PSFMessage -Level Verbose  -Message "Writing Get-DbaLastGoodCheckDb data for $InstanceName"  -Tag "dbareports"
                Write-DbaDataTable -SqlInstance $SqlInstance -Database $RepositoryDatabase -InputObject $LastGoodCheckDb -Table Staging.DbaLastGoodCheckDb -KeepNulls    
		    }
		catch {			 
                Write-PSFMessage -Level Warning -Message "Failed to add Get-DbaLastGoodCheckDb data for for $InstanceName" -ErrorRecord $_ -Tag "dbareports"
			    continue
		}
    
        Write-PSFMessage -Level Verbose  -Message "Completed collection for $InstanceName Closing Connection"  -Tag "dbareports" 
        $SqlServerInstance.ConnectionContext.Disconnect()  
	}	
}

END
{
    Write-PSFMessage -Level Verbose  -Message "Corruption Monitor Job Finished" -Tag "dbareports"
	$SqlServerInstance.ConnectionContext.Disconnect()
}
