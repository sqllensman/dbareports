
/****** Object:  View [Reporting].[CurrentBackupStatus]    Script Date: 16/03/2018 12:14:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Reporting].[CurrentBackupStatus]
AS
SELECT        di.Name AS DatabaseName, sl.SqlInstance, di.Name, di.RecoveryModel, di.DateChecked, di.LastBackupDate, di.LastDifferentialBackupDate, di.LastLogBackupDate, 
                         CASE
						 WHEN di.LastBackupDate IS NULL OR di.LastBackupDate < DATEADD(DAY, -365, SYSDATETIME()) THEN 366  
						 WHEN di.LastBackupDate < DATEADD(DAY, -8, SYSDATETIME()) THEN DATEDIFF(dd, di.LastBackupDate, SYSDATETIME())
						 WHEN di.LastBackupDate > DATEADD(YEAR, - 1, SYSDATETIME()) AND di.LastDifferentialBackupDate >= di.LastBackupDate THEN DATEDIFF(dd, di.LastDifferentialBackupDate, SYSDATETIME()) 
                         WHEN di.LastBackupDate > DATEADD(YEAR, - 1, SYSDATETIME()) AND di.LastDifferentialBackupDate < di.LastBackupDate THEN DATEDIFF(dd, di.LastBackupDate, SYSDATETIME()) 
                         ELSE 366 END AS ActualFullDiffBackupAge, CASE WHEN di.RecoveryModel <> 'Simple' AND di.LastLogBackupDate > DATEADD(YEAR, - 1, SYSDATETIME()) THEN DATEDIFF(dd, di.LastLogBackupDate, 
                         SYSDATETIME()) ELSE 366 END AS ActualLogBackupAge, sl.status, CASE WHEN di.AvailabilityGroupName IS NOT NULL AND di.IsUpdateable = 1 THEN 1 WHEN di.AvailabilityGroupName IS NULL AND 
                         di.IsAccessible = 1 THEN 1 ELSE 0 END AS IsActiveDatabase, 7 as TargetFullBackupAge, 12 as TargetLogBackupAge
FROM            info.DatabaseInfo AS di INNER JOIN
                         info.SQLInstanceList AS sl ON sl.InstanceID = di.InstanceID
WHERE        (COALESCE (di.InActive, 0) = 0) AND (di.Name <> N'tempdb') AND (sl.IsActive = 1) AND (di.Status = 'Normal')
GO
/****** Object:  View [Reporting].[MissingOrFailedFullBackups]    Script Date: 16/03/2018 12:14:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Reporting].[MissingOrFailedFullBackups]
AS
SELECT        SqlInstance, DatabaseName, CASE WHEN LastBackupDate < '2001-01-01' THEN NULL ELSE LastBackupDate END AS BackupDate, CASE WHEN LastDifferentialBackupDate < '2001-01-01' THEN NULL 
                         ELSE LastDifferentialBackupDate END AS DifferentialBackupDate, ActualFullDiffBackupAge
FROM            Reporting.CurrentBackupStatus AS cbs
WHERE        (ActualFullDiffBackupAge > COALESCE (TargetFullBackupAge, 1)) AND (status = 'P') AND (IsActiveDatabase = 1)
GO
/****** Object:  View [Reporting].[MissingOrFailedLogBackups]    Script Date: 16/03/2018 12:14:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Reporting].[MissingOrFailedLogBackups]
AS
SELECT        SqlInstance, Name, RecoveryModel, DateChecked, CASE WHEN LastBackupDate < '2001-01-01' THEN NULL ELSE LastBackupDate END AS BackupDate, 
                         CASE WHEN LastLogBackupDate < '2001-01-01' THEN NULL ELSE LastLogBackupDate END AS LogBackupDate, ActualLogBackupAge
FROM            Reporting.CurrentBackupStatus AS cbs
WHERE        (ActualLogBackupAge > COALESCE (TargetLogBackupAge, 1)) AND (status = 'P') AND (RecoveryModel <> 'Simple')
GO
/****** Object:  View [Reporting].[ComputerInfo]    Script Date: 16/03/2018 12:14:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Reporting].[ComputerInfo]
AS
SELECT        info.ComputerList.ComputerID, info.ComputerList.ComputerName, info.ComputerList.ConnectName, Config.Location.Description AS Location, Config.Location.Domain, Config.Location.PrimaryBU, 
                         Config.Priority.PriorityDescription, Config.Priority.Production, Config.ServerActiveStatus.Description AS ActiveStatus, Config.ServerActiveStatus.RequiresLicence, 
                         Config.MonitorOption.Description AS MonitorOption, info.ComputerList.NotContactable, info.ComputerList.description, info.ComputerList.decommissionDate, ComputerInfo_1.DateChecked, 
                         ComputerInfo_1.DNSHostName, ComputerInfo_1.IPAddress, ComputerInfo_1.FQDN, ComputerInfo_1.Manufacturer, ComputerInfo_1.Model, ComputerInfo_1.SystemType, ComputerInfo_1.TotalPhysicalMemory, 
                         ComputerInfo_1.NumberOfLogicalProcessors, ComputerInfo_1.NumberOfProcessors, ComputerInfo_1.IsHyperThreading, ComputerInfo_1.DomainRole, ComputerInfo_1.BootDevice, ComputerInfo_1.SystemDevice, 
                         ComputerInfo_1.SystemDrive, ComputerInfo_1.WindowsDirectory, ComputerInfo_1.OSVersion, ComputerInfo_1.SPVersion, ComputerInfo_1.OSManufacturer, ComputerInfo_1.PowerShellVersion, 
                         ComputerInfo_1.Architecture, ComputerInfo_1.BuildNumber, ComputerInfo_1.Version, ComputerInfo_1.InstallDate, ComputerInfo_1.LastBootTime, ComputerInfo_1.LocalDateTime, ComputerInfo_1.DaylightInEffect, 
                         ComputerInfo_1.IsDaylightSavingsTime, ComputerInfo_1.TimeZone, ComputerInfo_1.TimeZoneStandard, ComputerInfo_1.TimeZoneDaylight, ComputerInfo_1.ActivePowerPlan, ComputerInfo_1.Status, 
                         ComputerInfo_1.Language, ComputerInfo_1.LanguageAlias, ComputerInfo_1.CountryCode, ComputerInfo_1.PagingFileSize, ComputerInfo_1.TotalVisibleMemory, ComputerInfo_1.FreePhysicalMemory, 
                         ComputerInfo_1.TotalVirtualMemory, ComputerInfo_1.FreeVirtualMemory
FROM            info.ComputerList INNER JOIN
                         info.ComputerInfo AS ComputerInfo_1 ON info.ComputerList.ComputerID = ComputerInfo_1.ComputerID INNER JOIN
                         Config.Location ON info.ComputerList.Location = Config.Location.Location INNER JOIN
                         Config.Priority ON info.ComputerList.Priority = Config.Priority.PriorityId INNER JOIN
                         Config.ServerActiveStatus ON info.ComputerList.ActiveStatus = Config.ServerActiveStatus.ActiveStatus INNER JOIN
                         Config.MonitorOption ON info.ComputerList.MonitorOptions = Config.MonitorOption.MonitorOption
GO
/****** Object:  View [Reporting].[DiskSpaceInfo]    Script Date: 16/03/2018 12:14:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Reporting].[DiskSpaceInfo]
AS
SELECT        Reporting.ComputerInfo.ComputerID, Reporting.ComputerInfo.ComputerName, Reporting.ComputerInfo.Location, Reporting.ComputerInfo.PriorityDescription, Reporting.ComputerInfo.Production, 
                         Reporting.ComputerInfo.ActiveStatus, info.DiskSpaceInfo.Name, info.DiskSpaceInfo.Label, info.DiskSpaceInfo.PercentFree, info.DiskSpaceInfo.FileSystem, info.DiskSpaceInfo.IsSqlDisk, 
                         info.DiskSpaceInfo.SizeInBytes, info.DiskSpaceInfo.FreeInBytes, info.DiskSpaceInfo.DateChecked, info.DiskSpaceInfo.DriveType, info.DiskSpaceInfo.BlockSize
FROM            info.DiskSpaceInfo INNER JOIN
                         Reporting.ComputerInfo ON info.DiskSpaceInfo.ComputerID = Reporting.ComputerInfo.ComputerID
GO
/****** Object:  View [Reporting].[SQLInstanceInfo]    Script Date: 16/03/2018 12:14:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Reporting].[SQLInstanceInfo]
AS
SELECT        sil.InstanceID, sil.ComputerID, ci.ComputerName, sil.SqlInstance, st.Description AS InstanceStatus, ci.ActiveStatus AS ComputerStatus, ci.PriorityDescription, sil.LicenceStatus, sil.IsActive, sil.createDate, 
                         sil.updateDate, sil.decommissionDate, sii.DateChecked, sii.VersionString, sii.VersionName, sii.Edition, sii.ServicePack, sii.Collation, sii.IsCaseSensitive, sii.IsHADREnabled, sii.IsSQLClustered, sii.ClusterName, 
                         sii.AGListener, sii.IsFullTextInstalled, sii.LinkedServer, sii.LoginMode, sii.TcpEnabled, sii.NamedPipesEnabled, sii.CostThresholdForParallelism, sii.MaxDegreeOfParallelism, sii.DBMailEnabled, 
                         sii.DefaultBackupCompression, sii.[FillFactor], sii.MaxMem, sii.MinMem, sii.OptimizeAdhocWorkloads, sii.RemoteDacEnabled, sii.XPCmdShellEnabled, sii.SQLService, sii.SQLServiceAccount, 
                         sii.SQLServiceStartMode, sii.SQLAgentServiceAccount, sii.SQLAgentServiceStartMode, sii.BrowserAccount, sii.BrowserStartMode, ci.Location, ci.Domain, ci.PrimaryBU, ci.OSVersion, ci.SPVersion
FROM            info.SQLInstanceList AS sil INNER JOIN
                         info.SQLInstanceInfo AS sii ON sil.InstanceID = sii.InstanceID INNER JOIN
                         Reporting.ComputerInfo AS ci ON sil.ComputerID = ci.ComputerID INNER JOIN
                         Config.InstanceStatus AS st ON st.Status = sil.Status
GO
/****** Object:  View [Reporting].[ActiveComputers]    Script Date: 16/03/2018 12:14:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Reporting].[ActiveComputers]
AS
SELECT        ComputerName, ConnectName, MonitorOptions
FROM            info.ComputerList
WHERE        (ActiveStatus = 1) AND (NotContactable = 0) AND (MonitorOptions < 2)
GO
/****** Object:  View [Reporting].[SQLInstanceList]    Script Date: 16/03/2018 12:14:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Reporting].[SQLInstanceList]
AS
SELECT        
	sil.InstanceID, 
	sil.ComputerID, 
	cl.ComputerName, 
	sil.SqlInstance, 
	sil.ConnectName,
	Coalesce(sil.ConnectName, sil.SqlInstance) as InstanceName 
FROM info.ComputerList cl 
INNER JOIN info.SQLInstanceList AS sil 
	ON cl.ComputerID = sil.ComputerID
WHERE (sil.IsActive = 1) AND (sil.NotContactable = 0)
GO
/****** Object:  View [Staging].[AgentJobInfo]    Script Date: 16/03/2018 12:14:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Staging].[AgentJobInfo]
AS
SELECT aj.[InstanceId]
      ,aj.[JobID]
      ,aj.[ReadingDate]
      ,aj.[Name] as JobName
      ,cl.ComputerID
      ,aj.[Enabled]
      ,aj.[Description]
      ,aj.[CategoryID]
      ,aj.[Category]
      ,aj.[IsEnabled]
      ,aj.[HasSchedule]
      ,aj.[HasStep]
      ,aj.[StartStepID]
      ,aj.[DateCreated]
      ,aj.[DateLastModified]
      ,aj.[VersionNumber]
      ,aj.[OwnerLoginName]
      ,aj.[DeleteLevel]
      ,aj.[EmailLevel]
      ,aj.[OperatorToEmail]
      ,aj.[EventLogLevel]
      ,aj.[LastRunDate]
      ,aj.[LastRunOutcome]
      ,aj.[NextRunDate]
      ,aj.[CurrentRunRetryAttempt]
      ,aj.[CurrentRunStatus]
      ,aj.[CurrentRunStep]
      ,aj.[CategoryType]
      ,aj.[JobType]
      ,aj.[OriginatingServer]
      ,aj.[HasServer]
  FROM [Staging].[DbaAgentJob] aj
  INNER JOIN info.ComputerList cl
	ON cl.ComputerName = aj.ComputerName
GO
/****** Object:  View [Staging].[AlertInfo]    Script Date: 16/03/2018 12:14:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [Staging].[AlertInfo]
AS
SELECT aa.[InstanceId]
      ,aa.[Name]
      ,aa.[ReadingDate]
      ,aa.[CategoryName]
	  , di.DatabaseID
      ,aa.[DelayBetweenResponses]
      ,aa.[EventDescriptionKeyword]
      ,aa.[EventSource]
      ,aa.[HasNotification]
      ,aa.[IncludeEventDescription]
      ,aa.[IsEnabled]
	  ,ji.AgentJobDetailID
      ,Case 
		  WHEN aa.[LastOccurrenceDate] = '0001-01-01 00:00:00.0000000' THEN NULL
		  ELSE aa.[LastOccurrenceDate]
	   END LastOccurrenceDate
      ,Case 
		  WHEN aa.[LastResponseDate] = '0001-01-01 00:00:00.0000000' THEN NULL
		  ELSE aa.[LastResponseDate]
	   END LastResponseDate
      ,aa.[MessageID]
      ,aa.[NotificationMessage]
      ,aa.[OccurrenceCount]
      ,aa.[PerformanceCondition]
      ,aa.[Severity]
      ,aa.[WmiEventNamespace]
      ,aa.[WmiEventQuery]
FROM [Staging].[DbaAgentAlert] aa
LEFT JOIN info.DatabaseInfo di
	ON di.InstanceID = aa.InstanceId 
	AND di.Name = aa.DatabaseName
LEFT JOIN info.AgentJobInfo ji
	ON ji.JobID = aa.[JobID]
GO
/****** Object:  View [Staging].[ComputerInfo]    Script Date: 16/03/2018 12:14:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [Staging].[ComputerInfo]
AS
SELECT 
	cl.ComputerID,
	cl.ComputerName,
	nm.ReadingDate,
	cs.DnsHostName,
	nm.IPAddress,
	nm.FQDN,
	cs.Manufacturer,
	cs.Model,
	cs.SystemType,
	cs.TotalPhysicalMemory,
	cs.NumberLogicalProcessors as NumberOfLogicalProcessors,
	cs.NumberProcessors as NumberOfProcessors,
	cs.IsHyperThreading,
	cs.Domain,
	cs.DomainRole,
	os.BootDevice,
	os.SystemDevice,
	os.SystemDrive,
	os.WindowsDirectory,
	os.OSVersion,
	os.SPVersion,
	os.Manufacturer AS OSManufacturer,
	os.PowerShellVersion,
	os.Architecture,
	os.Build as BuildNumber,
	os.[Version],
	os.InstallDate,
	os.LastBootTime,
	os.LocalDateTime,
	cs.DaylightInEffect,
	cs.IsDaylightSavingsTime,
	os.TimeZone,
	os.TimeZoneStandard,
	os.TimeZoneDaylight,
	os.ActivePowerPlan,
	os.[Status],
	os.[Language],
	os.LanguageAlias,
	os.CountryCode,
	os.PagingFileSize,
	os.TotalVisibleMemory,
	os.FreePhysicalMemory,
	os.TotalVirtualMemory,
	os.FreeVirtualMemory
FROM [info].[ComputerList] cl
INNER JOIN [Staging].[DbaNetworkName] nm
	ON cl.ComputerName = nm.InputName
LEFT JOIN [Staging].[DbaComputerSystem] cs
	ON cl.ComputerName = cs.InputName 
LEFT JOIN [Staging].[DbaOperatingSystem] os
	ON cl.ComputerName = os.InputName;
GO
/****** Object:  View [Staging].[DatabaseCheckDBInfo]    Script Date: 16/03/2018 12:14:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [Staging].[DatabaseCheckDBInfo]
AS
SELECT cdb.[InstanceId]
	  ,di.DatabaseID
      ,cdb.[ReadingDate]
      ,cdb.[Database]
      ,cdb.[DatabaseCreated]
      ,cdb.[LastGoodCheckDb]
      ,cdb.[DaysSinceLastGoodCheckDb]
      ,cdb.[DaysSinceDbCreated]
      ,cdb.[Status]
      ,cdb.[DataPurityEnabled]
      ,cdb.[CreateVersion]
FROM [Staging].[DbaLastGoodCheckDb] cdb
INNER JOIN info.DatabaseInfo di
	ON di.InstanceID = cdb.InstanceId 
	AND di.[Name] = cdb.[Database];

GO
/****** Object:  View [Staging].[DatabaseFileInfo]    Script Date: 16/03/2018 12:14:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Staging].[DatabaseFileInfo]
AS
SELECT 
	   sil.InstanceID
	  ,di.DatabaseID
      ,dbf.[Database]
      ,dbf.[FileGroupName]
      ,dbf.[ID]
      ,dbf.[Type]
      ,dbf.[TypeDescription]
      ,dbf.[LogicalName]
      ,dbf.[PhysicalName]
      ,dbf.[State]
      ,dbf.[MaxSize]
      ,dbf.[Growth]
      ,dbf.[GrowthType]
      ,dbf.[NextGrowthEventSize]
      ,dbf.[Size]
      ,dbf.[UsedSpace]
      ,dbf.[AvailableSpace]
      ,dbf.[IsOffline]
      ,dbf.[IsReadOnly]
      ,dbf.[IsReadOnlyMedia]
      ,dbf.[IsSparse]
      ,dbf.[NumberOfDiskWrites]
      ,dbf.[NumberOfDiskReads]
      ,dbf.[ReadFromDisk]
      ,dbf.[WrittenToDisk]
      ,dbf.[VolumeFreeSpace]
      ,dbf.[FileGroupDataSpaceId]
      ,dbf.[FileGroupType]
      ,dbf.[FileGroupTypeDescription]
      ,dbf.[FileGroupDefault]
      ,dbf.[FileGroupReadOnly]
FROM [Staging].[DbaDatabaseFile] dbf
INNER JOIN info.SQLInstanceList sil
	ON sil.SqlInstance = dbf.SqlInstance
INNER JOIN info.DatabaseInfo di
	ON sil.InstanceID = di.InstanceID
	AND dbf.[Database] = di.Name
GO
/****** Object:  View [Staging].[DatabaseInfo]    Script Date: 16/03/2018 12:14:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [Staging].[DatabaseInfo]
AS
SELECT 
	s.InstanceId, 
	s.SqlInstance as InstanceName, 
	dbi.[Name], 
    dbi.AutoClose, 
    dbi.AutoCreateStatisticsEnabled, 
    dbi.AutoShrink, 
    dbi.AutoUpdateStatisticsAsync, 
    dbi.AutoUpdateStatisticsEnabled, 
    dbi.AvailabilityDatabaseSynchronizationState, 
    dbi.AvailabilityGroupName, 
    dbi.CaseSensitive, 
    dbi.Collation, 
    dbi.CompatibilityLevel, 
    dbi.CreateDate, 
    dbi.DatabaseOwnershipChaining,
    dbi.DatabaseSnapshotBaseName,
    dbi.DataSpaceUsage, 
    dbi.DefaultFileGroup,  
    dbi.DefaultFileStreamFileGroup,
    dbi.DelayedDurability,
    dbi.EncryptionEnabled, 
    dbi.FilestreamDirectoryName,
    dbi.FilestreamNonTransactedAccess,
    dbi.HasMemoryOptimizedObjects,
    dbi.IndexSpaceUsage, 
    dbi.IsAccessible, 
    dbi.IsDatabaseSnapshot, 
    dbi.IsDatabaseSnapshotBase,
    dbi.IsFullTextEnabled, 
    dbi.IsMirroringEnabled, 
    dbi.IsParameterizationForced, 
    dbi.IsReadCommittedSnapshotOn, 
	dbi.IsSystemObject,
    dbi.IsUpdateable,
    dbi.LastBackupDate, 
    dbi.LastDifferentialBackupDate, 
    dbi.LastLogBackupDate, 
	dbi.LogReuseWaitStatus,
    dbi.Owner, 
    dbi.PageVerify, 
    dbi.PrimaryFilePath, 
    dbi.ReadOnly, 
    dbi.RecoveryModel, 
    dbi.ReplicationOptions, 
    dbi.Size,
    dbi.SnapshotIsolationState, 
    dbi.SpaceAvailable, 
    dbi.Status, 
    dbi.TargetRecoveryTime, 
    dbi.TemporalHistoryRetentionEnabled,
    dbi.Trustworthy,
    dbi.UserAccess,
    dbi.Version 
FROM Staging.DbaDatabase AS dbi 
INNER JOIN info.SQLInstanceList AS s 
	ON dbi.SqlInstance = Coalesce(s.ConnectName, s.SqlInstance)

GO
/****** Object:  View [Staging].[DiskSpaceInfo]    Script Date: 16/03/2018 12:14:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [Staging].[DiskSpaceInfo]
AS
SELECT 
	cl.ComputerID
    ,cl.[ComputerName]
    ,ds.[ReadingDate]
    ,ds.[Name]
    ,ds.[Label]
    ,ds.[PercentFree]
    ,ds.[BlockSize]
    ,ds.[FileSystem]
    ,ds.[IsSqlDisk]
    ,ds.[DriveType]
    ,ds.[SizeInBytes]
    ,ds.[FreeInBytes]
FROM [Staging].[DbaDiskSpace] ds
INNER JOIN [info].[ComputerList] cl
	ON cl.ComputerName = ds.ComputerName

GO
/****** Object:  View [Staging].[PageFileSettingInfo]    Script Date: 16/03/2018 12:14:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Staging].[PageFileSettingInfo]
AS
SELECT 
	cl.ComputerID
	,cl.ComputerName
	,pfs.[AutoPageFile]
    ,Coalesce(pfs.[FileName], 'Auto') as FileName
    ,pfs.[Status]
    ,pfs.[LastModified]
    ,pfs.[LastAccessed]
    ,pfs.[AllocatedBaseSize]
    ,pfs.[InitialSize]
    ,pfs.[MaximumSize]
    ,pfs.[PeakUsage]
    ,pfs.[CurrentUsage]
FROM [info].[ComputerList] cl
INNER JOIN [Staging].[DbaPageFileSetting] pfs
	ON cl.ComputerName = pfs.InputName

GO
/****** Object:  View [Staging].[SqlInstanceInfo]    Script Date: 16/03/2018 12:14:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [Staging].[SqlInstanceInfo]
AS
		SELECT        
			s.instanceId, 
			s.SqlInstance,
			sqlii.ReadingDate,
			sqlii.ComputerName,
			sqlii.VersionString, 
			sqlii.VersionName, 
			sqlii.Edition, 
			sqlii.ServicePack, 
			sqlii.ServerType, 
			sqlii.Collation, 
			sqlii.IsCaseSensitive, 
			sqlii.IsHADREnabled, 
			sqlii.HADREndpointPort, 
			sqlii.IsSQLClustered, 
			sqlii.ClusterName, 
			sqlii.ClusterQuorumstate, 
			sqlii.ClusterQuorumType, 
			sqlii.AGs, 
			sqlii.AGListener,
			sqlii.SQLService, 
			sqlii.SQLServiceAccount, 
			sqlii.SQLServiceStartMode, 
			sqlii.SQLAgentServiceAccount, 
			sqlii.SQLAgentServiceStartMode, 
			sqlii.BrowserAccount, 
			sqlii.BrowserStartMode, 
			sqlii.DefaultFile, 
			sqlii.DefaultLog, 
			sqlii.BackupDirectory, 
			sqlii.InstallDataDirectory, 
			sqlii.InstallSharedDirectory, 
			sqlii.MasterDBPath, 
			sqlii.MasterDBLogPath, 
			sqlii.ErrorLogPath, 
			sqlii.IsFullTextInstalled, 
			sqlii.LinkedServer, 
			sqlii.LoginMode, 
			sqlii.TcpEnabled,
			sqlii.NamedPipesEnabled, 
			sqlii.C2AuditMode, 
			sqlii.CommonCriteriaComplianceEnabled, 
			sqlii.CostThresholdForParallelism, 
			sqlii.DBMailEnabled, 
			sqlii.DefaultBackupCompression, 
			sqlii.[FillFactor], 
			sqlii.MaxDegreeOfParallelism, 
			sqlii.MaxMem, 
			sqlii.MinMem, 
			sqlii.OptimizeAdhocWorkloads, 
			sqlii.RemoteDacEnabled, 
			sqlii.XPCmdShellEnabled
		FROM [info].[SQLInstanceList] AS s 
		INNER JOIN Staging.DbaSQLInstance AS sqlii 
			ON sqlii.InstanceName = Coalesce(s.ConnectName, s.SqlInstance)
GO
/****** Object:  View [Staging].[SqlInstancePropertyInfo]    Script Date: 16/03/2018 12:14:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Staging].[SqlInstancePropertyInfo]
AS
SELECT sil.InstanceID
      ,sip.[SqlInstance]
      ,sip.[PropertyType]
      ,sip.[Name]
      ,sip.[Value]
      ,sip.[Writable]
      ,sip.[Readable]
      ,sip.[Expensive]
      ,sip.[Dirty]
      ,sip.[Retrieved]
      ,sip.[IsNull]
      ,sip.[Enabled]
      ,sip.[Required]
      ,sip.[Attributes]
  FROM [Staging].[DbaSqlInstanceProperty] sip
  INNER JOIN info.SQLInstanceList sil
	ON sil.SqlInstance = sip.SqlInstance

GO
/****** Object:  View [Staging].[SQLServiceInfo]    Script Date: 16/03/2018 12:14:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [Staging].[SQLServiceInfo]
AS
SELECT 
	cl.ComputerID
   ,cl.ComputerName
   ,ss.[ReadingDate]
   ,ss.[DisplayName]
   ,ss.[StartName]
   ,ss.[ServiceType]
   ,ss.[State]
   ,ss.[StartMode]
   ,ss.[InstanceName]
   ,ss.[ReadingId]
FROM [info].[ComputerList] cl
INNER JOIN [Staging].[DbaSqlService] ss
	ON cl.ComputerName = ss.ComputerName

GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "ComputerList (info)"
            Begin Extent = 
               Top = 4
               Left = 366
               Bottom = 298
               Right = 557
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ComputerInfo_1"
            Begin Extent = 
               Top = 8
               Left = 719
               Bottom = 180
               Right = 959
            End
            DisplayFlags = 280
            TopColumn = 38
         End
         Begin Table = "Location (Config)"
            Begin Extent = 
               Top = 15
               Left = 69
               Bottom = 204
               Right = 239
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Priority (Config)"
            Begin Extent = 
               Top = 218
               Left = 60
               Bottom = 348
               Right = 247
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ServerActiveStatus (Config)"
            Begin Extent = 
               Top = 199
               Left = 1002
               Bottom = 366
               Right = 1176
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "MonitorOption (Config)"
            Begin Extent = 
               Top = 219
               Left = 631
               Bottom = 358
               Right = 801
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPa' , @level0type=N'SCHEMA',@level0name=N'Reporting', @level1type=N'VIEW',@level1name=N'ComputerInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'ne = 
      Begin ColumnWidths = 11
         Column = 2100
         Alias = 1830
         Table = 1905
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'Reporting', @level1type=N'VIEW',@level1name=N'ComputerInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'Reporting', @level1type=N'VIEW',@level1name=N'ComputerInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "DiskSpaceInfo (info)"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 226
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "ComputerInfo (Reporting)"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 241
               Right = 486
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'Reporting', @level1type=N'VIEW',@level1name=N'DiskSpaceInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'Reporting', @level1type=N'VIEW',@level1name=N'DiskSpaceInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = -272
         Left = 0
      End
      Begin Tables = 
         Begin Table = "sil"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 229
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "sii"
            Begin Extent = 
               Top = 63
               Left = 482
               Bottom = 193
               Right = 766
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ci"
            Begin Extent = 
               Top = 339
               Left = 208
               Bottom = 525
               Right = 448
            End
            DisplayFlags = 280
            TopColumn = 29
         End
         Begin Table = "st"
            Begin Extent = 
               Top = 6
               Left = 267
               Bottom = 102
               Right = 437
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'Reporting', @level1type=N'VIEW',@level1name=N'SQLInstanceInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'Reporting', @level1type=N'VIEW',@level1name=N'SQLInstanceInfo'
GO
