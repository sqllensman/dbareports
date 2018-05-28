<#
    .SYNOPSIS  
        This Script will check all of the instances in the InstanceList and gather the Windows Info and save to the Info.ServerInfo table

    .DESCRIPTION 
        This Script will check all of the instances in the InstanceList and gather the Windows Info and save to the Info.ServerInfo table

    .NOTES
        Tags: Reports
        License: MIT https://opensource.org/licenses/MIT

#>

[CmdletBinding()]
Param (
	[Alias("SqlInstance")]
	[object]$RepositoryInstance = "LGHBDB17",
	[object]$SqlCredential,
	# this will come much later
	[string]$RepositoryDatabase = "dbareports",
    [string]$RepositoryQuery = "Reporting.ActiveComputers",
	[string]$LogFileFolder = "D:\ITOPS\dbareports\Logs"
)

BEGIN
{
	# Load up shared functions (use dbatools instead of repeating code)
    Import-Module -Name dbatools
    Import-Module -Name PSFramework
    Import-Module -Name PoshRSJob -Force

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
     # Reset variables
    $ComputerList = @()

	try
	{
        Write-PSFMessage -Level Verbose -Message "Clearing the required Staging Tables" -Tag "dbareports"
        $SqlInstance | Invoke-DbaSqlQuery -Query 'TRUNCATE TABLE Staging.DiskSpaceReadings' 

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


    $rsjobs = $ComputerList | Start-RSJob -Throttle 4 -ModulesToImport 'PSFramework','dbatools' -ScriptBlock {
	    Param (
            $Computer
        )

        Write-PSFMessage -Message "Processing $($Computer.ComputerName)" -Target $Database -Tag 'dbareports:Start'

		try
		{
            $DiskInfo = $null
          	Write-PSFMessage -Level Verbose -Message "Collecting Get-DbaPageFileSetting for $($Computer.ComputerName)" -Tag "dbareports"          		
            $DiskInfo = Get-DbaDiskSpace -ComputerName $Computer.ComputerName | SELECT ComputerName, @{Name='ReadingDate';Expression={get-date -Format "yyyy-MM-dd HH:mm:ss"}}, Name, Label, PercentFree, BlockSize, FileSystem, Type, IsSqlDisk, DriveType, SizeInBytes, FreeInBytes | ConvertTo-DbaDataTable

            Write-PSFMessage -Level Verbose -Message "Writing Get-DbaDiskSpace for $($Computer.ComputerName)" -Tag "dbareports"
            Write-DbaDataTable -SqlInstance $Using:SqlInstance -Database $Using:RepositoryDatabase -InputObject $DiskInfo -Table Staging.DiskSpaceReadings
		}
		catch
		{
            Write-PSFMessage -Level Warning -Message "Failed to add Get-DbaDiskSpace data for $($Computer.ComputerName)" -ErrorRecord $_ -Tag "dbareports"
			continue
		}

    $rsjobs | Wait-RSJob
    $results = $rsjobs | Receive-RSJob
    $rsjob | Remove-RSJob


    }
}

END
{
	Write-PSFMessage -Level Verbose -Message "DiskSpace Job Finished" -Tag "dbareports"
    $SqlInstance.ConnectionContext.Disconnect()
}
