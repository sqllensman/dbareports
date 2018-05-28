<#
    .SYNOPSIS  
        This Script will check all of the instances in the Repository Query and gather the Alerts Information to the Staging.DbaAgentAlert table

    .DESCRIPTION 
        This Script will check all of the instances in the Repository Query and gather the Alerts Information to the Staging.DbaAgentAlert table
        It uses the Get-DbaAgentAlert function from dbatools to Collect data.

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

    Set-PSFConfig -FullName 'psframework.logging.filesystem.logpath' -Value $LogFileFolder
    Write-PSFMessage -Level Verbose  -Message "SQL Server Alerts Job started" -Tag "dbareports"

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
        $SqlInstance | Invoke-DbaSqlQuery -Query 'TRUNCATE TABLE Staging.DbaAgentAlert' 
         
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
		try {
            $SqlServerInstance = Connect-DbaInstance -SqlInstance $Connection
			Write-PSFMessage -Level Verbose  -Message "Connecting to $Connection"  -Tag "dbareports"
		}
		catch{
            Write-PSFMessage -Level Warning -Message "Failed to connect to $Connection - $_ -ErrorRecord $_" -Tag "dbareports"
			continue
		}
        
		try {
            $DbaAgentAlert = $null
          	Write-PSFMessage -Level Verbose  -Message "Collecting Get-DbaAgentAlert data for $InstanceName"  -Tag "dbareports"
            $DbaAgentAlert = Get-DbaAgentAlert -SqlInstance $SqlServerInstance | Select @{Name='InstanceId';Expression={$($InstanceId)}}, SqlInstance, @{Name='ReadingDate';Expression={get-date -Format "yyyy-MM-dd HH:mm:ss"}}, ComputerName, 
                InstanceName, Name, CategoryName, DatabaseName, DelayBetweenResponses, EventDescriptionKeyword, EventSource, HasNotification, IncludeEventDescription, IsEnabled, JobID, JobName, LastOccurrenceDate, LastResponseDate, MessageID, 
                NotificationMessage, OccurrenceCount, PerformanceCondition, Severity, WmiEventNamespace, WmiEventQuery | ConvertTo-DbaDataTable

            If ($DbaAgentAlert) {
                Write-PSFMessage -Level Verbose  -Message "Writing Get-DbaAgentAlert data for $InstanceName"  -Tag "dbareports"
                Write-DbaDataTable -SqlInstance $SqlInstance -Database $RepositoryDatabase -InputObject $DbaAgentAlert -Table Staging.DbaAgentAlert -KeepNulls -AutoCreateTable
            }
            else {
                Write-PSFMessage -Level Verbose  -Message "Skipping Writing Get-DbaAgentAlert data for $InstanceName. No Alerts found"  -Tag "dbareports"
            }
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
    Write-PSFMessage -Level Verbose  -Message "SQL Server Alerts Job Finished" -Tag "dbareports"
	$SqlServerInstance.ConnectionContext.Disconnect()
}