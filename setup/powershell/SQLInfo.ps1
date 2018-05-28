﻿<#
    .SYNOPSIS  
         This Script will check all of the instances in the InstanceList and gather SQL Configuration Info and save to the Info.SQLInfo table

    .DESCRIPTION 
         This Script will check all of the instances in the InstanceList and gather SQL Configuration Info and save to the Info.SQLInfo table

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
            # Pre-process
            $VersionMajor = $SqlServerInstance.VersionMajor
            $VersionMinor = $SqlServerInstance.VersionMinor
            if ($VersionMajor -eq 8)
            { $Version = 'SQL 2000' }
            if ($VersionMajor -eq 9)
            { $Version = 'SQL 2005' }
            if ($VersionMajor -eq 10 -and $VersionMinor -eq 0)
            { $Version = 'SQL 2008' }
            if ($VersionMajor -eq 10 -and $VersionMinor -eq 50)
            { $Version = 'SQL 2008 R2' }
            if ($VersionMajor -eq 11)
            { $Version = 'SQL 2012' }
            if ($VersionMajor -eq 12)
            { $Version = 'SQL 2014' }
            if ($VersionMajor -eq 13)
            { $Version = 'SQL 2016' }
            if ($VersionMajor -eq 14)
            { $Version = 'SQL 2017' }		

            if ($SqlServerInstance.IsHadrEnabled -eq $True)
            {
	            $IsHADREnabled = $True
	            $AGs = $SqlServerInstance.AvailabilityGroups | Select-Object Name -ExpandProperty Name | Out-String
	            $Expression = @{ Name = 'ListenerPort'; Expression = { $_.Name + ',' + $_.PortNumber } }
	            $AGListener = $SqlServerInstance.AvailabilityGroups.AvailabilityGroupListeners | Select-Object $Expression | Select-Object ListenerPort -ExpandProperty ListenerPort
            }
            else
            {
	            $IsHADREnabled = $false
	            $AGs = 'None'
	            $AGListener = 'None'
            }
		
            if ($SqlServerInstance.version.Major -eq 8) # Check for SQL 2000 boxes
            {
	            $HADREndpointPort = '0'
            }
            else
            {
	            $HADREndpointPort = ($SqlServerInstance.Endpoints | Where-Object{ $_.EndpointType -eq 'DatabaseMirroring' }).Protocol.Tcp.ListenerPort
            }
            if (!$HADREndpointPort)
            {
	            $HADREndpointPort = '0'
            }

            $InstanceDataObject = [PSCustomObject]@{
                'InstanceId' = $InstanceId
                'InstanceName' = $InstanceName
                'ReadingDate' = $DateChecked
                'ComputerName'=$SqlServerInstance.ComputerNamePhysicalNetBIOS             
                'VersionString' = $SqlServerInstance.VersionString
                'VersionName' = $Version
                'Edition' = $SqlServerInstance.Edition
                'ServicePack' = $SqlServerInstance.ProductLevel
                'ServerType' = $SqlServerInstance.ServerType
                'Collation' = $SqlServerInstance.Collation
                'IsCaseSensitive' = $SqlServerInstance.IsCaseSensitive
                'IsHADREnabled' = $IsHADREnabled
                'HADREndpointPort' = $HADREndpointPort        
                'IsSQLClustered' =  $SqlServerInstance.IsClustered
                'ClusterName' = $SqlServerInstance.ClusterName
                'ClusterQuorumstate' = $SqlServerInstance.ClusterQuorumState
                'ClusterQuorumType' = $SqlServerInstance.ClusterQuorumType
                'AGs' = $AGs
                'AGListener' = $AGListener
                'SQLService' = $SqlServerInstance.ServiceName
                'SQLServiceAccount' = $SqlServerInstance.ServiceAccount
                'SQLServiceStartMode' = $SqlServerInstance.ServiceStartMode
                'SQLAgentServiceAccount' = $SqlServerInstance.JobServer.ServiceAccount
                'SQLAgentServiceStartMode' = $SqlServerInstance.JobServer.ServiceStartMode
                'BrowserAccount'=$SqlServerInstance.BrowserServiceAccount
                'BrowserStartMode' = $SqlServerInstance.BrowserStartMode
                'DefaultFile' = $SqlServerInstance.DefaultFile
                'DefaultLog' = $SqlServerInstance.DefaultLog
                'BackupDirectory'=$SqlServerInstance.BackupDirectory;
                'InstallDataDirectory' = $SqlServerInstance.InstallDataDirectory
                'InstallSharedDirectory' = $SqlServerInstance.InstallSharedDirectory
                'MasterDBPath' = $SqlServerInstance.MasterDBPath
                'MasterDBLogPath' = $SqlServerInstance.MasterDBLogPath
                'ErrorLogPath' = $SqlServerInstance.ErrorLogPath        
                'IsFullTextInstalled' = $SqlServerInstance.IsFullTextInstalled
                'LinkedServer' = $SqlServerInstance.LinkedServers.Count
                'LoginMode' = $SqlServerInstance.LoginMode
                'TcpEnabled' = $SqlServerInstance.TcpEnabled
                'NamedPipesEnabled' = $SqlServerInstance.NamedPipesEnabled
                'C2AuditMode' = $SqlServerInstance.Configuration.C2AuditMode.RunValue
                'CommonCriteriaComplianceEnabled' = $SqlServerInstance.Configuration.CommonCriteriaComplianceEnabled.RunValue
                'CostThresholdForParallelism' = $SqlServerInstance.Configuration.CostThresholdForParallelism.RunValue
                'DBMailEnabled' = $SqlServerInstance.Configuration.DatabaseMailEnabled.RunValue
                'DefaultBackupCompression' = $SqlServerInstance.Configuration.DefaultBackupCompression.RunValue
                'FillFactor' = $SqlServerInstance.Configuration.FillFactor.RunValue
                'MaxDegreeOfParallelism' = $SqlServerInstance.Configuration.MaxDegreeOfParallelism.RunValue
                'MaxMem' = $SqlServerInstance.Configuration.MaxServerMemory.RunValue
                'MinMem' = $SqlServerInstance.Configuration.MinServerMemory.RunValue
                'OptimizeAdhocWorkloads' = $SqlServerInstance.Configuration.OptimizeAdhocWorkloads.RunValue
                'RemoteDacEnabled' = $SqlServerInstance.Configuration.RemoteDacConnectionsEnabled.RunValue
                'XPCmdShellEnabled' = $SqlServerInstance.Configuration.XPCmdShellEnabled.RunValue  
            }
            
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
            
            Write-DbaDataTable -SqlInstance $SqlInstance -Database $RepositoryDatabase -InputObject $databaseFileInfo -Table Staging.DbaDbaDatabaseFile -KeepNulls
        }
        catch {           
            Write-PSFMessage -Level Warning -Message "Failed to add Database Scoped data for for $InstanceName" -ErrorRecord $_ -Tag "dbareports"
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

