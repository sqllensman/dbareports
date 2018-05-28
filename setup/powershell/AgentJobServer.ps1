<#
 
 Collection script for SQLAgent Job Information                   
 Needs to be tested with clusters. 
 Needs to be tested using SQL Credential
                     
 Depends on dbatools and PSFramework

 Database dependencies

 Tables:    Staging.DbaSqlService
            info.SqlServiceInfo
            Monitoring.SqlServiceInfo

 Views:     Staging.SqlServiceInfo 

 SP:        Staging.SQLServiceInfoMerge
 
 Agent Job: "dbareports - SQL Server Services Data Collector"

#>
<#

    .SYNOPSIS 
        Adds data to the DBA database for agent job results in a server list 

    .DESCRIPTION 
        Connects to a server list and iterates though reading the agent job results and adds data to the DBA Database - This is run as an agent job on LD5v-SQL11n-I06

    .PARAMETER SqlCredential
        Credentials to connect to the SQL Server instance if the calling user doesn't have permission.

    .PARAMETER RepositoryDatabase
        The database containg the dbareports objects

    .PARAMETER $RepositoryQuery
        The query used to determine the database(s) to process.

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

    Write-PSFMessage -Level Verbose  -Message "Agent Job Server Job started" -Tag "dbareports"

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
        $SqlInstance | Invoke-DbaSqlQuery -Query 'TRUNCATE TABLE Staging.DbaAgentJob' 
         
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
		$InstanceName = $sqlserver.InstanceName
		$InstanceId = $sqlserver.InstanceId
        $Connection = $sqlserver.ConnectName
		
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
                $AgentJobInfo = $null
          		Write-PSFMessage -Level Verbose  -Message "Collecting Get-DbaAgentJob data for $InstanceName"  -Tag "dbareports"          		
                $AgentJobInfo = Get-DbaAgentJob -SqlInstance $SqlServerInstance | Select @{Name='InstanceId';Expression={$($InstanceId)}},InstanceName, @{Name='ReadingDate';Expression={get-date -Format "yyyy-MM-dd HH:mm:ss"}}, ComputerName, SqlInstance, 
                    Enabled, Name, JobID, Description, CategoryID, Category, IsEnabled, HasSchedule, HasStep, StartStepID, DateCreated, DateLastModified, VersionNumber, OwnerLoginName, DeleteLevel, EmailLevel, OperatorToEmail, EventLogLevel, 
                    LastRunDate, LastRunOutcome, NextRunDate, CurrentRunRetryAttempt, CurrentRunStatus, CurrentRunStep, CategoryType, JobType, OriginatingServer, HasServer | ConvertTo-DbaDataTable
                
                Write-PSFMessage -Level Verbose  -Message "Writing Get-DbaAgentJob data for $InstanceName"  -Tag "dbareports"
                Write-DbaDataTable -SqlInstance $SqlInstance -Database $RepositoryDatabase -InputObject $AgentJobInfo -Table Staging.DbaAgentJob -KeepNulls
		    }
		catch {			 
                Write-PSFMessage -Level Warning -Message "Failed to add Get-DbaAgentJob data for for $InstanceName" -ErrorRecord $_ -Tag "dbareports"
			    continue
		}

        Write-PSFMessage -Level Verbose  -Message "Completed collection for $InstanceName Closing Connection"  -Tag "dbareports" 
        $SqlServerInstance.ConnectionContext.Disconnect()  
	}	
}

END
{
    Write-PSFMessage -Level Verbose  -Message "Agent Job Server Job Finished" -Tag "dbareports"
	$SqlServerInstance.ConnectionContext.Disconnect()
}

