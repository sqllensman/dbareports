<#
 
 Collection script for SQLServer related Services                   
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
        Adds SQL Server Services Information to the dbareports repository database for Computers defined in view against info.ComputerList  

    .DESCRIPTION 
        This Script will check all of the Computers from a Repository view defined against the info.ComputerList and find all of the SQL Server related Service
        It collects data from the following dbatools.io functions:
            Get-DbaSqlService
        
        Running this script requires both dbatools and PSFramework be installed on the Monitoring Server

    .NOTES
        Tags: Reports
        License: MIT https://opensource.org/licenses/MIT

#>

[CmdletBinding()]
Param (
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

    Write-PSFMessage -Level Verbose  -Message "SQL Server Services Job started" -Tag "dbareports"
	
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
	$DateChecked = Get-Date
	try
	{
        Write-PSFMessage -Level Verbose -Message "Clearing the required Staging Tables" -Tag "dbareports"
        $SqlInstance | Invoke-DbaSqlQuery -Query 'TRUNCATE TABLE Staging.DbaSqlService' 

        Write-PSFMessage -Level Verbose -Message "Getting a list of ComputerNames from the dbareports repository database - $RepositoryInstance" -Tag "dbareports"
		$sql = "SELECT ComputerName FROM $RepositoryQuery"

		$ComputerList = $SqlInstance | Invoke-DbaSqlQuery -Query $sql 
		Write-PSFMessage -Level Verbose -Message "Got the list of ComputerNames from the dbareports repository database - $RepositoryInstance" -Tag "dbareports"
	
	}
	catch
	{
		Write-Log -path $LogFilePath -message " Failed to get list of ComputerNames from the dbareports repository database - $RepositoryInstance" -level Error
		break
	}
	
	foreach ($Computer in $ComputerList)
	{
		$ComputerName = $Computer.ComputerName		
		Write-PSFMessage -Level Verbose -Message "Processing $ComputerName" -Tag "dbareports"

		try
		{
            $SqlServiceInfo = $null
          	Write-PSFMessage -Level Verbose -Message "Collecting Get-DbaSqlService data for $ComputerName" -Tag "dbareports"          		
            $SqlServiceInfo = Get-DbaSqlService -ComputerName $ComputerName | Select @{Name='ComputerName';Expression={$($ComputerName)}}, @{Name='ReadingDate';Expression={get-date -Format "yyyy-MM-dd HH:mm:ss"}}, DisplayName, StartName, ServiceType, State, StartMode, InstanceName | ConvertTo-DbaDataTable

            Write-PSFMessage -Level Verbose -Message "Writing Get-DbaSqlService data for $ComputerName" -Tag "dbareports"
            Write-DbaDataTable -SqlInstance $SqlInstance -Database $RepositoryDatabase -InputObject $SqlServiceInfo -Table Staging.DbaSqlService 
		}
		catch
		{
			Write-Log -path $LogFilePath -message "Failed to add Get-DbaSqlService data for $ComputerName" -level Error
			continue
		}

	}
	
}

END
{
	Write-PSFMessage -Level Verbose -Message "SQL Server Services Job Finished" -Tag "dbareports"
    $SqlInstance.ConnectionContext.Disconnect()
}

