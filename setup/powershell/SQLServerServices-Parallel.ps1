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
        This Script will check all of the Computers in a supplied ComputerList and gather the SQL Server Services Information and save to the Staging.ComputerInfo table

    .DESCRIPTION 
        This Script will check all of the Computers from a view defined against the info.ComputerList and find all of the SQL Server related Service

    .NOTES
        Tags: Reports
        License: MIT https://opensource.org/licenses/MIT

#>

[CmdletBinding()]
Param (
	[object]$RepositoryInstance = "LGHBDB17",
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
    $ComputerList = @()
	try
	{
        Write-PSFMessage -Level Verbose -Message "Clearing the required Staging Tables" -Tag "dbareports"
        $SqlInstance | Invoke-DbaSqlQuery -Query 'TRUNCATE TABLE Staging.SQLServiceData' 

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

    $rsjobs = $ComputerList | Start-RSJob -Throttle 2 -ModulesToImport 'PSFramework','dbatools' -ScriptBlock {
	    Param (
            $Computer
        )

        Write-PSFMessage -Message "Processing $($Computer.ComputerName)" -Target $Database -Tag 'dbareports:Start'

		try
		{
            $SqlServiceInfo = $null
          	Write-PSFMessage -Level Verbose -Message "Collecting Get-DbaSqlService data for $($Computer.ComputerName)" -Tag "dbareports"          		
            $SqlServiceInfo = Get-DbaSqlService -ComputerName $Computer.ComputerName | Select @{Name='ComputerName';Expression={$($Computer.ComputerName)}}, @{Name='ReadingDate';Expression={get-date -Format "yyyy-MM-dd HH:mm:ss"}}, DisplayName, StartName, ServiceType, State, StartMode, InstanceName | ConvertTo-DbaDataTable

            #$SqlServiceInfo | Out-GridView

            Write-PSFMessage -Level Verbose -Message "Writing Get-DbaSqlService data for $($Computer.ComputerName)" -Tag "dbareports"
            Write-DbaDataTable -SqlInstance $Using:SqlInstance -Database $Using:RepositoryDatabase -InputObject $SqlServiceInfo -Table Staging.SQLServiceData
		}
		catch
		{
            Write-PSFMessage -Level Warning -Message "Failed to add Get-DbaSqlService data data for $($Computer.ComputerName)" -ErrorRecord $_ -Tag "dbareports"
			continue
		}

    $rsjobs | Wait-RSJob
    $results = $rsjobs | Receive-RSJob
    $rsjob | Remove-RSJob


    }
}

END
{
	Write-PSFMessage -Level Verbose -Message "SQL Server Services Job Finished" -Tag "dbareports"
    $SqlInstance.ConnectionContext.Disconnect()
}

