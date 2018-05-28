<#
 Collection script for SQLServer Instance level information (including databases)                   
 Needs to be tested with clusters. 
 Needs to be tested using SQL Credential
                     
 Depends on dbatools and PSFramework

 Database dependencies

 Tables:    Staging.DbaSqlInstanceProperty
            Staging.DbaSqlInstance 
            Staging.DbaDatabase
            Staging.DbaDatabaseFile

            info.SQLInstanceInfo
            info.SQLInstancePropertyInfo
            info.DatabaseInfo
            Monitoring.SQLInstanceInfo
            Monitoring.SQLInstancePropertyInfo
            Monitoring.DatabaseInfo
            Monitoring.DatabaseFileInfo


 Views:     Staging.SQLInstanceInfo 
            Staging.SQLInstancePropertyInfo
            Staging.DatabaseInfo
            Staging.DatabaseFileInfo

 SP:        Staging.SQLInstanceInfoMerge
            Staging.SqlInstancePropertyInfoAdd
            Staging.DatabaseInfoMerge
            Staging.DatabaseFileInfoAdd

 Agent Job: "dbareports - SQL Server Instance Data Collector"

#>

<#
    .SYNOPSIS 
        Adds Instance and Database level information to the dbareports repository database for Instances defined in view against info.SqlInstanceList

    .DESCRIPTION 
        This Script will check all of the SQL Server Instances from a Repository view defined against the info.SQLInstanceList
        It collects data from the following dbatools.io functions:
            Get-DbaSqlInstanceProperty
            Get-DbaSqlInstanceInfo
            Get-DbaDatabase
            Get-DbaDatabaseFile
        
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

    Write-PSFMessage -Level Verbose  -Message "SQLInfo Job started" -Tag "dbareports"

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
        $SqlInstance | Invoke-DbaSqlQuery -Query 'TRUNCATE TABLE Staging.DbaSqlInstanceProperty' 
        $SqlInstance | Invoke-DbaSqlQuery -Query 'TRUNCATE TABLE Staging.DbaSqlInstance' 
        $SqlInstance | Invoke-DbaSqlQuery -Query 'TRUNCATE TABLE Staging.DbaDatabase'
        $SqlInstance | Invoke-DbaSqlQuery -Query 'TRUNCATE TABLE Staging.DbaDatabaseFile'
         
		Write-PSFMessage -Level Verbose  -Message "Getting a list of SQL Server Instances from the dbareports repository database - $RepositoryInstance"  -Tag "dbareports"
		$sql = "SELECT InstanceID, ComputerName, InstanceName, SqlInstance FROM $RepositoryQuery"

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
                $InstanceInfo = $null
          		Write-PSFMessage -Level Verbose  -Message "Collecting Get-DbaSqlInstanceProperty data for $InstanceName"  -Tag "dbareports"          		
                $InstanceInfo = Get-DbaSqlInstanceProperty -SqlInstance $SqlServerInstance | ConvertTo-DbaDataTable
                
                Write-PSFMessage -Level Verbose  -Message "Writing Get-DbaSqlInstanceProperty data for $InstanceName"  -Tag "dbareports"
                Write-DbaDataTable -SqlInstance $SqlInstance -Database $RepositoryDatabase -InputObject $InstanceInfo -Table Staging.DbaSqlInstanceProperty -KeepNulls
		    }
		catch {			 
                Write-PSFMessage -Level Warning -Message "Failed to add Get-DbaSqlInstanceProperty data for for $InstanceName" -ErrorRecord $_ -Tag "dbareports"
			    continue
		}
        
        # Get Instance Scoped Information
		try {
            Write-PSFMessage -Level Verbose  -Message "Collecting Get-DbaSqlInstanceInfo data for $InstanceName"  -Tag "dbareports" 
            $InstanceDataObject = Get-DbaSqlInstanceInfo -SqlServer $SqlServerInstance | Select @{Name='InstanceId';Expression={$($InstanceId)}}, @{Name='InstanceName';Expression={$($InstanceName)}}, @{Name='ReadingDate';Expression={get-date -Format "yyyy-MM-dd HH:mm:ss"}},  
                ComputerName, VersionString, VersionName, Edition, ServicePack, ServerType, Collation, IsCaseSensitive, IsHADREnabled, HADREndpointPort, IsSQLClustered, ClusterName,
                ClusterQuorumstate, ClusterQuorumType, AGs, AGListener, SQLService, SQLServiceAccount, SQLServiceStartMode, SQLAgentServiceAccount, SQLAgentServiceStartMode, BrowserAccount, BrowserStartMode, DefaultFile,
                DefaultLog, BackupDirectory,InstallDataDirectory, InstallSharedDirectory, MasterDBPath, MasterDBLogPath, ErrorLogPath, IsFullTextInstalled, LinkedServer, LoginMode, TcpEnabled, NamedPipesEnabled, C2AuditMode, 
                CommonCriteriaComplianceEnabled, CostThresholdForParallelism, DBMailEnabled, DefaultBackupCompression, FillFactor, MaxDegreeOfParallelism, MaxMem, MinMem, OptimizeAdhocWorkloads, RemoteDacEnabled, XPCmdShellEnabled | ConvertTo-DbaDataTable

            Write-PSFMessage -Level Verbose  -Message "Writing Sql Server Instance data for $InstanceName"  -Tag "dbareports"
            Write-DbaDataTable -SqlInstance $SqlInstance -Database $RepositoryDatabase -InputObject $InstanceDataObject -Table Staging.DbaSqlInstance -KeepNulls
		}
		catch {		
            Write-PSFMessage -Level Warning -Message "Failed to add Instance Scoped data for for $InstanceName" -ErrorRecord $_ -Tag "dbareports"
			continue
		}  

        # Get Database Scoped Information
		try {
            Write-PSFMessage -Level Verbose  -Message "Collecting Get-DbaDatabase data for $InstanceName"  -Tag "dbareports" 
            $databaseInfo = Get-DbaDatabase -SqlServer $SqlServerInstance | Select ComputerName,InstanceName,SqlInstance,Name,CreateDate,Collation,CompatibilityLevel,Owner,AutoClose,AutoShrink,AutoCreateStatisticsEnabled,AutoUpdateStatisticsEnabled,
              AutoUpdateStatisticsAsync,CaseSensitive,Status,LogReuseWaitStatus,IsSystemObject,IsAccessible,IsDatabaseSnapshot,DatabaseSnapshotBaseName,IsDatabaseSnapshotBase,ReadOnly,UserAccess,Version,RecoveryModel,
              LastBackupDate,LastDifferentialBackupDate,LastLogBackupDate,TargetRecoveryTime,PageVerify,PrimaryFilePath,DefaultFileGroup,Size,SpaceAvailable,DataSpaceUsage,IndexSpaceUsage,EncryptionEnabled,
              IsFullTextEnabled,IsMirroringEnabled,IsParameterizationForced,IsReadCommittedSnapshotOn,SnapshotIsolationState,ReplicationOptions,AvailabilityDatabaseSynchronizationState,AvailabilityGroupName,IsUpdateable,
              DelayedDurability,Trustworthy,DatabaseOwnershipChaining,TemporalHistoryRetentionEnabled,HasMemoryOptimizedObjects,DefaultFileStreamFileGroup,FilestreamDirectoryName,FilestreamNonTransactedAccess | ConvertTo-DbaDataTable

            Write-DbaDataTable -SqlInstance $SqlInstance -Database $RepositoryDatabase -InputObject $databaseInfo -Table Staging.DbaDatabase -KeepNulls 
        }
        catch {			
            Write-PSFMessage -Level Warning -Message "Failed to add Database Scoped data for for $InstanceName" -ErrorRecord $_ -Tag "dbareports"
			continue
		}  


        try {
            $databaseFileInfo = Get-DbaDatabaseFile -SqlInstance $SqlServerInstance | Select ComputerName, InstanceName, SqlInstance, Database, FileGroupName, ID, Type, TypeDescription, LogicalName, PhysicalName, State, MaxSize, Growth, GrowthType, 
                NextGrowthEventSize, Size, UsedSpace, AvailableSpace, IsOffline, IsReadOnly, IsReadOnlyMedia, IsSparse, NumberOfDiskWrites, NumberOfDiskReads, ReadFromDisk, WrittenToDisk, VolumeFreeSpace, FileGroupDataSpaceId, 
                FileGroupType, FileGroupTypeDescription, FileGroupDefault, FileGroupReadOnly | ConvertTo-DbaDataTable
            
            Write-DbaDataTable -SqlInstance $SqlInstance -Database $RepositoryDatabase -InputObject $databaseFileInfo -Table Staging.DbaDatabaseFile -KeepNulls
        }
        catch {           
            Write-PSFMessage -Level Warning -Message "Failed to add DatabaseFile data for for $InstanceName" -ErrorRecord $_ -Tag "dbareports"
            continue
        }

        Write-PSFMessage -Level Verbose  -Message "Completed collection for $InstanceName Closing Connection"  -Tag "dbareports" 
        $SqlServerInstance.ConnectionContext.Disconnect()  
	}	
}

END
{
	Write-PSFMessage -Level Verbose  -Message "SQLInfo Job Finished" -Tag "dbareports"
	$SqlInstance.ConnectionContext.Disconnect()
}

