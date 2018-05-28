USE [dbareports_V2]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetErrorInfo]    Script Date: 16/03/2018 12:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- Create a procedure to retrieve error information.
CREATE PROCEDURE [dbo].[usp_GetErrorInfo]
AS
    SELECT 
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() AS ErrorState,
        ERROR_PROCEDURE() AS ErrorProcedure,
        ERROR_LINE() AS ErrorLine,
        ERROR_MESSAGE() AS ErrorMessage;
GO
/****** Object:  StoredProcedure [Reporting].[Get_FastestGrowingDisks]    Script Date: 16/03/2018 12:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author: Rob Sewell
-- Create date: 31/12/2015
-- Modified date: 7/03/2018 
-- Description:     Get the 5 fastest growing disks
-- =============================================
CREATE PROCEDURE [Reporting].[Get_FastestGrowingDisks]
AS
BEGIN
    SET NOCOUNT ON;

	WITH Percentage_cte
	AS 
	(
		SELECT
			ROW_NUMBER() OVER(PARTITION BY ComputerID, Name ORDER BY ComputerID, [Name],ReadingDate) rn
			,ReadingDate
			,ComputerID
			,[Name]
			,[PercentFree]
			,[Label]
			,Round([SizeInBytes]/1024/1024/1024.0,2) as Size
			,Round([FreeInBytes]/1024/1024/1024.0,2) as Free
		FROM  [Monitoring].[DiskSpaceInfo]
		wHERE ReadingDate > DATEADD(Day, -2, GETDATE()) 
	) 
	select top 5
		c1.ReadingDate as [date]
		,(SELECT ComputerName FROM info.ComputerList WHERE ComputerID = c1.ComputerID) as Server
		,c1.Name as DiskName
		,c1.[Label]
		,c1.[Size] as Capacity
		,c1.[Free] as FreeSpace
		,c1.[PercentFree] as Percentage
		,c2.Free - c1.Free as Growth
	from Percentage_cte c1
	join Percentage_cte c2
	ON
	c1.rn = c2.rn + 1 
	AND c1.ComputerID= c2.ComputerID
	AND c1.name = c2.name
	ORDER BY Growth desc,c1.PercentFree asc
END



GO
/****** Object:  StoredProcedure [Staging].[AgentJobInfoMerge]    Script Date: 16/03/2018 12:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Patrick Flynn
-- Create date: 2018-02-09
-- Description:	Merge Data for Servers
-- =============================================
CREATE PROCEDURE [Staging].[AgentJobInfoMerge] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRAN;
	BEGIN TRY;

		WITH NewReadings AS
		(
			SELECT aj.[InstanceId]
				  ,aj.[JobID]
				  ,aj.[ReadingDate] as DateChecked
				  ,aj.[JobName]
				  ,aj.[ComputerID]
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
			FROM [Staging].[AgentJobInfo] aj
		)
		MERGE [info].[AgentJobInfo] di
		USING NewReadings nr
			ON di.InstanceId = nr.InstanceId
			AND di.JobID = nr.JobID
		WHEN MATCHED THEN UPDATE
			SET
			    DateChecked	= nr.DateChecked
				,JobName = nr.[JobName]
				,ComputerID = nr.[ComputerID]
				,Enabled = nr.[Enabled]
				,Description = nr.[Description]
				,CategoryID =nr.[CategoryID]
				,Category = nr.[Category]
				,IsEnabled = nr.[IsEnabled]
				,HasSchedule = nr.[HasSchedule]
				,HasStep = nr.[HasStep]
				,StartStepID = nr.[StartStepID]
				,DateCreated = nr.[DateCreated]
				,DateLastModified = nr.[DateLastModified]
				,VersionNumber = nr.[VersionNumber]
				,OwnerLoginName =nr.[OwnerLoginName]
				,DeleteLevel = nr.[DeleteLevel]
				,EmailLevel = nr.[EmailLevel]
				,OperatorToEmail = nr.[OperatorToEmail]
				,EventLogLevel = nr.[EventLogLevel]
				,LastRunDate = nr.[LastRunDate]
				,LastRunOutcome = nr.[LastRunOutcome]
				,NextRunDate = nr.[NextRunDate]
				,CurrentRunRetryAttempt = nr.[CurrentRunRetryAttempt]
				,CurrentRunStatus = nr.[CurrentRunStatus]
				,CurrentRunStep = nr.[CurrentRunStep]
				,CategoryType = nr.[CategoryType]
				,JobType = nr.[JobType]
				,OriginatingServer = nr.[OriginatingServer]
				,HasServer = nr.[HasServer]
				WHEN NOT MATCHED BY TARGET THEN
		  INSERT ([InstanceId], [JobID], [DateChecked], [JobName], [ComputerID], [Enabled], [Description], [CategoryID], [Category], [IsEnabled], [HasSchedule], [HasStep], [StartStepID], [DateCreated], [DateLastModified], [VersionNumber], [OwnerLoginName], [DeleteLevel], [EmailLevel], [OperatorToEmail], [EventLogLevel], [LastRunDate], [LastRunOutcome], [NextRunDate], [CurrentRunRetryAttempt], [CurrentRunStatus], [CurrentRunStep], [CategoryType], [JobType], [OriginatingServer], [HasServer])
		  VALUES (nr.[InstanceId], nr.[JobID], nr.[DateChecked], nr.[JobName], nr.[ComputerID], nr.[Enabled], nr.[Description], nr.[CategoryID], nr.[Category], nr.[IsEnabled], nr.[HasSchedule], nr.[HasStep], nr.[StartStepID], nr.[DateCreated], nr.[DateLastModified], nr.[VersionNumber], nr.[OwnerLoginName], nr.[DeleteLevel], nr.[EmailLevel], nr.[OperatorToEmail], nr.[EventLogLevel], nr.[LastRunDate], nr.[LastRunOutcome], nr.[NextRunDate], nr.[CurrentRunRetryAttempt], nr.[CurrentRunStatus], nr.[CurrentRunStep], nr.[CategoryType], nr.[JobType], nr.[OriginatingServer], nr.[HasServer]);

		-- Insert Daily Reading
		INSERT INTO [Monitoring].[AgentJobInfo]([InstanceId], [JobID], [ReadingDate], [JobName], [ComputerID], [Enabled], [Description], [CategoryID], [Category], [IsEnabled], [HasSchedule], [HasStep], [StartStepID], [DateCreated], [DateLastModified], [VersionNumber], [OwnerLoginName], [DeleteLevel], [EmailLevel], [OperatorToEmail], [EventLogLevel], [LastRunDate], [LastRunOutcome], [NextRunDate], [CurrentRunRetryAttempt], [CurrentRunStatus], [CurrentRunStep], [CategoryType], [JobType], [OriginatingServer], [HasServer])
		SELECT [InstanceId], [JobID], [ReadingDate], [JobName], [ComputerID], [Enabled], [Description], [CategoryID], [Category], [IsEnabled], [HasSchedule], [HasStep], [StartStepID], [DateCreated], [DateLastModified], [VersionNumber], [OwnerLoginName], [DeleteLevel], [EmailLevel], [OperatorToEmail], [EventLogLevel], [LastRunDate], [LastRunOutcome], [NextRunDate], [CurrentRunRetryAttempt], [CurrentRunStatus], [CurrentRunStep], [CategoryType], [JobType], [OriginatingServer], [HasServer]
		FROM [Staging].[AgentJobInfo] ci 

		COMMIT

	END TRY
	BEGIN CATCH
		EXECUTE dbo.usp_GetErrorInfo;
		ROLLBACK
	END CATCH

END
GO
/****** Object:  StoredProcedure [Staging].[AlertInfoMerge]    Script Date: 16/03/2018 12:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Patrick Flynn
-- Create date: 2018-02-09
-- Description:	Merge Data for Servers
-- =============================================
CREATE PROCEDURE [Staging].[AlertInfoMerge] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRAN;
	BEGIN TRY;

		WITH NewReadings AS
		(
		SELECT   ai.[InstanceId]
				,ai.[Name]
				,ai.[ReadingDate] as DateChecked
				,ai.[CategoryName]
				,ai.[DatabaseID]
				,ai.[DelayBetweenResponses]
				,ai.[EventDescriptionKeyword]
				,ai.[EventSource]
				,ai.[HasNotification]
				,ai.[IncludeEventDescription]
				,ai.[IsEnabled]
				,ai.[AgentJobDetailID]
				,ai.[LastOccurrenceDate]
				,ai.[LastResponseDate]
				,ai.[MessageID]
				,ai.[NotificationMessage]
				,ai.[OccurrenceCount]
				,ai.[PerformanceCondition]
				,ai.[Severity]
				,ai.[WmiEventNamespace]
				,ai.[WmiEventQuery]
			FROM [Staging].[AlertInfo] ai
		)
		MERGE [info].[AlertInfo] ai
		USING NewReadings nr
			ON ai.InstanceId = nr.InstanceId
			AND ai.[Name] = nr.[Name]
		WHEN MATCHED THEN UPDATE
			SET
			    DateChecked	= nr.DateChecked
				,CategoryName = nr.[CategoryName]
				,DatabaseID = nr.[DatabaseID]
				,DelayBetweenResponses = nr.[DelayBetweenResponses]
				,EventDescriptionKeyword =nr.[EventDescriptionKeyword]
				,EventSource = nr.[EventSource]
				,HasNotification = nr.[HasNotification]
				,IncludeEventDescription = nr.[IncludeEventDescription]
				,IsEnabled = nr.[IsEnabled]
				,AgentJobDetailID = nr.[AgentJobDetailID]
				,LastOccurrenceDate = nr.[LastOccurrenceDate]
				,LastResponseDate = nr.[LastResponseDate]
				,MessageID = nr.[MessageID]
				,NotificationMessage = nr.[NotificationMessage]
				,OccurrenceCount = nr.[OccurrenceCount]
				,PerformanceCondition = nr.[PerformanceCondition]
				,Severity = nr.[Severity]
				,WmiEventNamespace = nr.[WmiEventNamespace]
				,WmiEventQuery = nr.[WmiEventQuery]
				WHEN NOT MATCHED BY TARGET THEN
		  INSERT ([InstanceId], [Name], [DateChecked], [CategoryName], [DatabaseID], [DelayBetweenResponses], [EventDescriptionKeyword], [EventSource], [HasNotification], [IncludeEventDescription], [IsEnabled], [AgentJobDetailID], [LastOccurrenceDate], [LastResponseDate], [MessageID], [NotificationMessage], [OccurrenceCount], [PerformanceCondition], [Severity], [WmiEventNamespace], [WmiEventQuery])
		  VALUES (nr.[InstanceId], nr.[Name], nr.[DateChecked], nr.[CategoryName], nr.[DatabaseID], nr.[DelayBetweenResponses], nr.[EventDescriptionKeyword], nr.[EventSource], nr.[HasNotification], nr.[IncludeEventDescription], nr.[IsEnabled], nr.[AgentJobDetailID], nr.[LastOccurrenceDate], nr.[LastResponseDate], nr.[MessageID], nr.[NotificationMessage], nr.[OccurrenceCount], nr.[PerformanceCondition], nr.[Severity], nr.[WmiEventNamespace], nr.[WmiEventQuery]);

		-- Insert Daily Reading
		INSERT INTO [Monitoring].[AlertInfo]([InstanceId], [Name], [ReadingDate], [CategoryName], [DatabaseID], [DelayBetweenResponses], [EventDescriptionKeyword], [EventSource], [HasNotification], [IncludeEventDescription], [IsEnabled], [AgentJobDetailID], [LastOccurrenceDate], [LastResponseDate], [MessageID], [NotificationMessage], [OccurrenceCount], [PerformanceCondition], [Severity], [WmiEventNamespace], [WmiEventQuery])
		SELECT [InstanceId], [Name], [ReadingDate], [CategoryName], [DatabaseID], [DelayBetweenResponses], [EventDescriptionKeyword], [EventSource], [HasNotification], [IncludeEventDescription], [IsEnabled], [AgentJobDetailID], [LastOccurrenceDate], [LastResponseDate], [MessageID], [NotificationMessage], [OccurrenceCount], [PerformanceCondition], [Severity], [WmiEventNamespace], [WmiEventQuery] 
		FROM [Staging].[AlertInfo] ci 

		COMMIT

	END TRY
	BEGIN CATCH
		EXECUTE dbo.usp_GetErrorInfo;
		ROLLBACK
	END CATCH

END
GO
/****** Object:  StoredProcedure [Staging].[ComputerInfoMerge]    Script Date: 16/03/2018 12:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Patrick Flynn
-- Create date: 2018-02-09
-- Description:	Merge Data for Servers
-- =============================================
CREATE PROCEDURE [Staging].[ComputerInfoMerge] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRAN;
	BEGIN TRY;

		WITH NewReadings AS
		(
			SELECT 
				ci.ComputerID,
				ci.ComputerName,
				ci.ReadingDate,
				ci.DnsHostName,
				ci.IPAddress,
				ci.FQDN,
				ci.Manufacturer,
				ci.Model,
				ci.SystemType,
				ci.TotalPhysicalMemory,
				ci.NumberofLogicalProcessors,
				ci.NumberOfProcessors,
				ci.IsHyperThreading,
				ci.Domain,
				ci.DomainRole,
				ci.BootDevice,
				ci.SystemDevice,
				ci.SystemDrive,
				ci.WindowsDirectory,
				ci.OSVersion,
				ci.SPVersion,
				ci.OSManufacturer,
				ci.PowerShellVersion,
				ci.Architecture,
				ci.BuildNumber,
				ci.[Version],
				ci.InstallDate,
				ci.LastBootTime,
				ci.LocalDateTime,
				ci.DaylightInEffect,
				ci.IsDaylightSavingsTime,
				ci.TimeZone,
				ci.TimeZoneStandard,
				ci.TimeZoneDaylight,
				ci.ActivePowerPlan,
				ci.[Status],
				ci.[Language],
				ci.LanguageAlias,
				ci.CountryCode,
				ci.PagingFileSize,
				ci.TotalVisibleMemory,
				ci.FreePhysicalMemory,
				ci.TotalVirtualMemory,
				ci.FreeVirtualMemory
			FROM [Staging].[ComputerInfo] ci
		)
		MERGE [info].[ComputerInfo] di
		USING NewReadings nr
			ON di.ComputerID = nr.ComputerID
		WHEN MATCHED THEN UPDATE
			SET
				[DateChecked] = nr.[ReadingDate],
				[DNSHostName] = nr.[DNSHostName],
				[IPAddress] = nr.[IPAddress],
				[FQDN] = nr.[FQDN],
				[Manufacturer] = nr.[Manufacturer],
				[Model] = nr.[Model],
				[SystemType] = nr.[SystemType],
				[TotalPhysicalMemory] = nr.[TotalPhysicalMemory],			
				[NumberOfLogicalProcessors] = nr.[NumberOfLogicalProcessors],
				[NumberOfProcessors] = nr.[NumberOfProcessors],
				[IsHyperThreading] = nr.[IsHyperThreading],
				[Domain] = nr.[Domain],
				[DomainRole] = nr.[DomainRole],
				[BootDevice] = nr.[BootDevice],
				[SystemDevice] = nr.[SystemDevice],
				[SystemDrive] = nr.[SystemDrive],
				[WindowsDirectory] = nr.[WindowsDirectory],
				[OSVersion] = nr.[OSVersion],
				[SPVersion] = nr.[SPVersion],
				[OSManufacturer] = nr.[OSManufacturer],
				[PowerShellVersion] = nr.[PowerShellVersion],
				[Architecture] = nr.[Architecture],
				[BuildNumber] = nr.[BuildNumber],
				[InstallDate] = nr.[InstallDate],
				[LastBootTime] = nr.[LastBootTime],
				[LocalDateTime] = nr.[LocalDateTime],
				[DaylightInEffect] = nr.[DaylightInEffect],
				IsDaylightSavingsTime = nr.IsDaylightSavingsTime,
				[TimeZone] = nr.[TimeZone],
				[TimeZoneStandard] = nr.[TimeZoneStandard],
				[TimeZoneDaylight] = nr.[TimeZoneDaylight],
				[ActivePowerPlan] = nr.[ActivePowerPlan],
				[Status] = nr.[Status],
				[LanguageAlias] = nr.[LanguageAlias],
				[CountryCode] = nr.[CountryCode],
				[PagingFileSize] = nr.[PagingFileSize],
				[TotalVisibleMemory] = nr.[TotalVisibleMemory],
				[FreePhysicalMemory] = nr.[FreePhysicalMemory],
				[TotalVirtualMemory] = nr.[TotalVirtualMemory],
				[FreeVirtualMemory] = nr.[FreeVirtualMemory]
				WHEN NOT MATCHED BY TARGET THEN
		  INSERT ([ComputerID], [ComputerName], [DateChecked], [DNSHostName], [IPAddress], [FQDN], [Manufacturer], [Model], [SystemType], [TotalPhysicalMemory], [NumberOfLogicalProcessors], [NumberOfProcessors], [IsHyperThreading], [Domain], [DomainRole], [BootDevice], [SystemDevice], [SystemDrive], [WindowsDirectory], [OSVersion], [SPVersion], [OSManufacturer], [PowerShellVersion], [Architecture], [BuildNumber], [Version], [InstallDate], [LastBootTime], [LocalDateTime], [DaylightInEffect], [IsDaylightSavingsTime], [TimeZone], [TimeZoneStandard], [TimeZoneDaylight], [ActivePowerPlan], [Status], [Language], [LanguageAlias], [CountryCode], [PagingFileSize], [TotalVisibleMemory], [FreePhysicalMemory], [TotalVirtualMemory], [FreeVirtualMemory])
		  VALUES (nr.[ComputerID], nr.[ComputerName], nr.[ReadingDate], nr.[DNSHostName], nr.[IPAddress], nr.[FQDN], nr.[Manufacturer], nr.[Model], nr.[SystemType], nr.[TotalPhysicalMemory], nr.[NumberOfLogicalProcessors], nr.[NumberOfProcessors], nr.[IsHyperThreading], nr.[Domain], nr.[DomainRole], nr.[BootDevice], nr.[SystemDevice], nr.[SystemDrive], nr.[WindowsDirectory], nr.[OSVersion], nr.[SPVersion], nr.[OSManufacturer], nr.[PowerShellVersion], nr.[Architecture], nr.[BuildNumber], nr.[Version], nr.[InstallDate], nr.[LastBootTime], nr.[LocalDateTime], nr.[DaylightInEffect], nr.[IsDaylightSavingsTime], nr.[TimeZone], nr.[TimeZoneStandard], nr.[TimeZoneDaylight], nr.[ActivePowerPlan], nr.[Status], nr.[Language], nr.[LanguageAlias], nr.[CountryCode], nr.[PagingFileSize], nr.[TotalVisibleMemory], nr.[FreePhysicalMemory], nr.[TotalVirtualMemory], nr.[FreeVirtualMemory]);


		-- Insert Daily Reading
		INSERT INTO [Monitoring].[ComputerInfo]([ComputerId], [ReadingDate], [DNSHostName], [IPAddress], [FQDN], [Manufacturer], [Model], [SystemType], [TotalPhysicalMemory], [NumberOfLogicalProcessors], [NumberOfProcessors], [IsHyperThreading], [Domain], [DomainRole], [BootDevice], [SystemDevice], [SystemDrive], [WindowsDirectory], [OSVersion], [SPVersion], [OSManufacturer], [PowerShellVersion], [Architecture], [BuildNumber], [Version], [InstallDate], [LastBootTime], [LocalDateTime], [DaylightInEffect], [IsDaylightSavingsTime], [TimeZone], [TimeZoneStandard], [TimeZoneDaylight], [ActivePowerPlan], [Status], [Language], [LanguageAlias], [CountryCode], [PagingFileSize], [TotalVisibleMemory], [FreePhysicalMemory], [TotalVirtualMemory], [FreeVirtualMemory])
		SELECT ComputerID, ReadingDate, DnsHostName, IPAddress, FQDN, Manufacturer, Model, SystemType, TotalPhysicalMemory, NumberOfLogicalProcessors, NumberOfProcessors, IsHyperThreading, 
            Domain, DomainRole, BootDevice, SystemDevice, SystemDrive, WindowsDirectory, OSVersion, SPVersion, OSManufacturer, PowerShellVersion, Architecture, BuildNumber, Version, InstallDate, LastBootTime, 
            LocalDateTime, DaylightInEffect, IsDaylightSavingsTime, TimeZone, TimeZoneStandard, TimeZoneDaylight, ActivePowerPlan, Status, Language, LanguageAlias, CountryCode, PagingFileSize, 
            TotalVisibleMemory, FreePhysicalMemory, TotalVirtualMemory, FreeVirtualMemory
		FROM [Staging].[ComputerInfo] ci 

		COMMIT

	END TRY
	BEGIN CATCH
		EXECUTE dbo.usp_GetErrorInfo;
		ROLLBACK
	END CATCH

END
GO
/****** Object:  StoredProcedure [Staging].[DatabaseCheckDBInfoMerge]    Script Date: 16/03/2018 12:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Patrick Flynn
-- Create date: 2018-01-01
-- Description:	Merge Staging Data for SQL Server Instances
-- =============================================
CREATE PROCEDURE [Staging].[DatabaseCheckDBInfoMerge] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	BEGIN TRAN;
	BEGIN TRY;
		With NewReadings as
		(
		SELECT        
			 dcdb.[InstanceId]
			,dcdb.[DatabaseID]
			,dcdb.[ReadingDate] as DateChecked
			,dcdb.[DatabaseCreated]
			,dcdb.[LastGoodCheckDb]
			,dcdb.[DaysSinceLastGoodCheckDb]
			,dcdb.[DaysSinceDbCreated]
			,dcdb.[Status]
			,dcdb.[DataPurityEnabled]
			,dcdb.[CreateVersion]
		FROM Staging.DatabaseCheckDBInfo AS dcdb 
		)
		MERGE info.DatabaseCheckDBInfo dcdb
		USING NewReadings nr
			ON dcdb.InstanceID = nr.InstanceID
		WHEN MATCHED THEN UPDATE
			SET 
				DateChecked = nr.[DateChecked],
				[DatabaseCreated] = nr.[DatabaseCreated],
				[LastGoodCheckDb] = nr.[LastGoodCheckDb],
				[DaysSinceLastGoodCheckDb] = nr.[DaysSinceLastGoodCheckDb],
				[DaysSinceDbCreated] = nr.[DaysSinceDbCreated],
				[Status] = nr.[Status],
				[DataPurityEnabled] = nr.[DataPurityEnabled],
				[CreateVersion] = nr.[CreateVersion]
		  WHEN NOT MATCHED BY TARGET THEN
		  INSERT ([InstanceId], [DatabaseId], [DateChecked], [DatabaseCreated], [LastGoodCheckDb], [DaysSinceLastGoodCheckDb], [DaysSinceDbCreated], [Status], [DataPurityEnabled], [CreateVersion])
		  VALUES (nr.[InstanceId], nr.[DatabaseId], nr.[DateChecked], nr.[DatabaseCreated], nr.[LastGoodCheckDb], nr.[DaysSinceLastGoodCheckDb], nr.[DaysSinceDbCreated], nr.[Status], nr.[DataPurityEnabled], nr.[CreateVersion]);

		-- Current Readings
		INSERT INTO [Monitoring].[DatabaseCheckDBInfo]([InstanceId], [DatabaseId], [ReadingDate], [DatabaseCreated], [LastGoodCheckDb], [DaysSinceLastGoodCheckDb], [DaysSinceDbCreated], [Status], [DataPurityEnabled], [CreateVersion])
		SELECT        
			 dcdb.[InstanceId]
			,dcdb.[DatabaseID]
			,dcdb.[ReadingDate]
			,dcdb.[DatabaseCreated]
			,dcdb.[LastGoodCheckDb]
			,dcdb.[DaysSinceLastGoodCheckDb]
			,dcdb.[DaysSinceDbCreated]
			,dcdb.[Status]
			,dcdb.[DataPurityEnabled]
			,dcdb.[CreateVersion]
		FROM Staging.DatabaseCheckDBInfo AS dcdb;

		COMMIT

	END TRY
	BEGIN CATCH
		EXECUTE dbo.usp_GetErrorInfo;
		ROLLBACK
	END CATCH
END
GO
/****** Object:  StoredProcedure [Staging].[DatabaseFileInfoAdd]    Script Date: 16/03/2018 12:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






-- =============================================
-- Author:		Patrick Flynn
-- Create date: 2018-02-01
-- Description:	Merge Data for Servers
-- =============================================
CREATE PROCEDURE [Staging].[DatabaseFileInfoAdd] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRAN;
	BEGIN TRY;

	INSERT INTO [Monitoring].[DatabaseFileInfo]([InstanceID], [DatabaseID], [ReadingDate], [Database], [FileGroupName], [ID], [Type], [TypeDescription], [LogicalName], [PhysicalName], [State], [MaxSize], [Growth], [GrowthType], [NextGrowthEventSize], [Size], [UsedSpace], [AvailableSpace], [IsOffline], [IsReadOnly], [IsReadOnlyMedia], [IsSparse], [NumberOfDiskWrites], [NumberOfDiskReads], [ReadFromDisk], [WrittenToDisk], [VolumeFreeSpace], [FileGroupDataSpaceId], [FileGroupType], [FileGroupTypeDescription], [FileGroupDefault], [FileGroupReadOnly])
	SELECT [InstanceID]
		  ,[DatabaseID]
		  ,GetDate() as ReadingDate
		  ,[Database]
		  ,[FileGroupName]
		  ,[ID]
		  ,[Type]
		  ,[TypeDescription]
		  ,[LogicalName]
		  ,[PhysicalName]
		  ,[State]
		  ,[MaxSize]
		  ,[Growth]
		  ,[GrowthType]
		  ,[NextGrowthEventSize]
		  ,[Size]
		  ,[UsedSpace]
		  ,[AvailableSpace]
		  ,[IsOffline]
		  ,[IsReadOnly]
		  ,[IsReadOnlyMedia]
		  ,[IsSparse]
		  ,[NumberOfDiskWrites]
		  ,[NumberOfDiskReads]
		  ,[ReadFromDisk]
		  ,[WrittenToDisk]
		  ,[VolumeFreeSpace]
		  ,[FileGroupDataSpaceId]
		  ,[FileGroupType]
		  ,[FileGroupTypeDescription]
		  ,[FileGroupDefault]
		  ,[FileGroupReadOnly]
	FROM [Staging].[DatabaseFileInfo]

		COMMIT

	END TRY
	BEGIN CATCH
		EXECUTE dbo.usp_GetErrorInfo;
		ROLLBACK
	END CATCH

END
GO
/****** Object:  StoredProcedure [Staging].[DatabaseInfoMerge]    Script Date: 16/03/2018 12:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Patrick Flynn
-- Create date: 2018-02-01
-- Description:	Merge Data for DatabaseInfo
-- =============================================
CREATE PROCEDURE [Staging].[DatabaseInfoMerge]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRAN;
	BEGIN TRY;
		-- Update [info].[Databases] 
		With NewReadings as
		(
			SELECT 
				dbi.instanceId,
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
			FROM Staging.DatabaseInfo AS dbi 
		)
		MERGE [info].[DatabaseInfo] di
		USING NewReadings nr
			ON di.InstanceId = nr.InstanceId
			AND di.Name = nr.Name
		WHEN MATCHED THEN UPDATE
			SET 
				DateChecked = GetDate(),
                AutoClose = nr.AutoClose,
                AutoCreateStatisticsEnabled = nr.AutoCreateStatisticsEnabled,
                AutoShrink = nr.AutoShrink,
                AutoUpdateStatisticsAsync = nr.AutoUpdateStatisticsAsync,
                AutoUpdateStatisticsEnabled = nr.AutoUpdateStatisticsEnabled,
                AvailabilityDatabaseSynchronizationState = nr.AvailabilityDatabaseSynchronizationState,
                AvailabilityGroupName = nr.AvailabilityGroupName,
                CaseSensitive = nr.CaseSensitive,
                Collation = nr.Collation,
                CompatibilityLevel = nr.CompatibilityLevel,
                CreateDate = nr.CreateDate,
                DatabaseOwnershipChaining = nr.DatabaseOwnershipChaining,
                DatabaseSnapshotBaseName = nr.DatabaseSnapshotBaseName,
                DataSpaceUsage = nr.DataSpaceUsage,
                DefaultFileGroup = nr.DefaultFileGroup,
                DefaultFileStreamFileGroup = nr.DefaultFileStreamFileGroup,
                DelayedDurability = nr.DelayedDurability,
                EncryptionEnabled = nr.EncryptionEnabled,
                FilestreamDirectoryName = nr.FilestreamDirectoryName,
                FilestreamNonTransactedAccess = nr.FilestreamNonTransactedAccess,
                HasMemoryOptimizedObjects = nr.HasMemoryOptimizedObjects,
                IndexSpaceUsage = nr.IndexSpaceUsage,
                IsAccessible = nr.IsAccessible,
                IsDatabaseSnapshot = nr.IsDatabaseSnapshot,
                IsDatabaseSnapshotBase = nr.IsDatabaseSnapshotBase,
                IsFullTextEnabled = nr.IsFullTextEnabled,
                IsMirroringEnabled = nr.IsMirroringEnabled,
                IsParameterizationForced = nr.IsParameterizationForced,
                IsReadCommittedSnapshotOn = nr.IsReadCommittedSnapshotOn,
                IsSystemObject = nr.IsSystemObject,
                IsUpdateable = nr.IsUpdateable,
                LastBackupDate = nr.LastBackupDate,
                LastDifferentialBackupDate = nr.LastDifferentialBackupDate,
                LastLogBackupDate = nr.LastLogBackupDate,
                LogReuseWaitStatus = nr.LogReuseWaitStatus,
                Owner = nr.Owner,
                PageVerify = nr.PageVerify,
                PrimaryFilePath = nr.PrimaryFilePath,
                ReadOnly = nr.ReadOnly,
                RecoveryModel = nr.RecoveryModel,
                ReplicationOptions = nr.ReplicationOptions,
                Size = nr.Size,
                SnapshotIsolationState = nr.SnapshotIsolationState,
                SpaceAvailable = nr.SpaceAvailable,
                Status = nr.Status,
                TargetRecoveryTime = nr.TargetRecoveryTime,
                TemporalHistoryRetentionEnabled = nr.TemporalHistoryRetentionEnabled,
                Trustworthy = nr.Trustworthy,
                UserAccess = nr.UserAccess,
                Version = nr.Version

        WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			[InstanceID], 
			[Name], 
			[AutoClose], 
			[AutoCreateStatisticsEnabled], 
			[AutoShrink], 
			[AutoUpdateStatisticsAsync], 
			[AutoUpdateStatisticsEnabled], 
			[AvailabilityDatabaseSynchronizationState], 
			[AvailabilityGroupName], 
			[CaseSensitive], 
			[Collation], 
			[CompatibilityLevel], 
			[CreateDate], 
			[DatabaseOwnershipChaining], 
			[DatabaseSnapshotBaseName], 
			[DataSpaceUsage], 
			[DefaultFileGroup], 
			[DefaultFileStreamFileGroup], 
			[DelayedDurability], 
			[EncryptionEnabled], 
			[FilestreamDirectoryName], 
			[FilestreamNonTransactedAccess], 
			[HasMemoryOptimizedObjects], 
			[IndexSpaceUsage], 
			[IsAccessible], 
			[IsDatabaseSnapshot], 
			[IsDatabaseSnapshotBase], 
			[IsFullTextEnabled], 
			[IsMirroringEnabled], 
			[IsParameterizationForced], 
			[IsReadCommittedSnapshotOn], 
			[IsSystemObject], 
			[IsUpdateable], 
			[LastBackupDate], 
			[LastDifferentialBackupDate], 
			[LastLogBackupDate], 
			[LogReuseWaitStatus],
			[Owner], 
			[PageVerify], 
			[PrimaryFilePath], 
			[ReadOnly], 
			[RecoveryModel], 
			[ReplicationOptions], 
			[Size], 
			[SnapshotIsolationState], 
			[SpaceAvailable], 
			[Status], 
			[TargetRecoveryTime], 
			[TemporalHistoryRetentionEnabled], 
			[Trustworthy], 
			[UserAccess], 
			[Version], 
			[DateAdded], 
			[DateChecked], 
			[InActive]
		)
        VALUES (
			nr.InstanceId, 
			nr.[Name], 
			nr.[AutoClose], 
			nr.[AutoCreateStatisticsEnabled], 
			nr.[AutoShrink], 
			nr.[AutoUpdateStatisticsAsync], 
			nr.[AutoUpdateStatisticsEnabled], 
			nr.[AvailabilityDatabaseSynchronizationState], 
			nr.[AvailabilityGroupName], 
			nr.[CaseSensitive], 
			nr.[Collation], 
			nr.[CompatibilityLevel], 
			nr.[CreateDate], 
			nr.[DatabaseOwnershipChaining], 
			nr.[DatabaseSnapshotBaseName], 
			nr.[DataSpaceUsage], 
			nr.[DefaultFileGroup], 
			nr.[DefaultFileStreamFileGroup], 
			nr.[DelayedDurability], 
			nr.[EncryptionEnabled], 
			nr.[FilestreamDirectoryName], 
			nr.[FilestreamNonTransactedAccess], 
			nr.[HasMemoryOptimizedObjects], 
			nr.[IndexSpaceUsage], 
			nr.[IsAccessible], 
			nr.[IsDatabaseSnapshot], 
			nr.[IsDatabaseSnapshotBase], 
			nr.[IsFullTextEnabled], 
			nr.[IsMirroringEnabled], 
			nr.[IsParameterizationForced], 
			nr.[IsReadCommittedSnapshotOn], 
			nr.[IsSystemObject], 
			nr.[IsUpdateable], 
			nr.[LastBackupDate], 
			nr.[LastDifferentialBackupDate],
			nr.[LastLogBackupDate],
			nr.[LogReuseWaitStatus], 
			nr.[Owner], 
			nr.[PageVerify], 
			nr.[PrimaryFilePath], 
			nr.[ReadOnly], 
			nr.[RecoveryModel], 
			nr.[ReplicationOptions], 
			nr.[Size], 
			nr.[SnapshotIsolationState], 
			nr.[SpaceAvailable], 
			nr.[Status], 
			nr.[TargetRecoveryTime], 
			nr.[TemporalHistoryRetentionEnabled], 
			nr.[Trustworthy], 
			nr.[UserAccess], 
			nr.[Version], 
			GetDate(), 
			GetDate(), 
			0
		);
		-- Insert Readings in [Monitoring].[DatabaseInfo] 
		INSERT INTO [Monitoring].[DatabaseInfo]
           ([InstanceID]
           ,[Name]
           ,[ReadingDate]
           ,[AutoClose]
           ,[AutoCreateStatisticsEnabled]
           ,[AutoShrink]
           ,[AutoUpdateStatisticsAsync]
           ,[AutoUpdateStatisticsEnabled]
           ,[AvailabilityDatabaseSynchronizationState]
           ,[AvailabilityGroupName]
           ,[CaseSensitive]
           ,[Collation]
           ,[CompatibilityLevel]
           ,[CreateDate]
           ,[DatabaseOwnershipChaining]
           ,[DatabaseSnapshotBaseName]
           ,[DataSpaceUsage]
           ,[DefaultFileGroup]
           ,[DefaultFileStreamFileGroup]
           ,[DelayedDurability]
           ,[EncryptionEnabled]
           ,[FilestreamDirectoryName]
           ,[FilestreamNonTransactedAccess]
           ,[HasMemoryOptimizedObjects]
           ,[IndexSpaceUsage]
           ,[IsAccessible]
           ,[IsDatabaseSnapshot]
           ,[IsDatabaseSnapshotBase]
           ,[IsFullTextEnabled]
           ,[IsMirroringEnabled]
           ,[IsParameterizationForced]
           ,[IsReadCommittedSnapshotOn]
           ,[IsSystemObject]
           ,[IsUpdateable]
           ,[LastBackupDate]
           ,[LastDifferentialBackupDate]
           ,[LastLogBackupDate]
           ,[LogReuseWaitStatus]
           ,[Owner]
           ,[PageVerify]
           ,[PrimaryFilePath]
           ,[ReadOnly]
           ,[RecoveryModel]
           ,[ReplicationOptions]
           ,[Size]
           ,[SnapshotIsolationState]
           ,[SpaceAvailable]
           ,[Status]
           ,[TargetRecoveryTime]
           ,[TemporalHistoryRetentionEnabled]
           ,[Trustworthy]
           ,[UserAccess]
           ,[Version])
		Select 
            [InstanceID]
           ,[Name]
           ,GetDate() as [ReadingDate]
           ,[AutoClose]
           ,[AutoCreateStatisticsEnabled]
           ,[AutoShrink]
           ,[AutoUpdateStatisticsAsync]
           ,[AutoUpdateStatisticsEnabled]
           ,[AvailabilityDatabaseSynchronizationState]
           ,[AvailabilityGroupName]
           ,[CaseSensitive]
           ,[Collation]
           ,[CompatibilityLevel]
           ,[CreateDate]
           ,[DatabaseOwnershipChaining]
           ,[DatabaseSnapshotBaseName]
           ,[DataSpaceUsage]
           ,[DefaultFileGroup]
           ,[DefaultFileStreamFileGroup]
           ,[DelayedDurability]
           ,[EncryptionEnabled]
           ,[FilestreamDirectoryName]
           ,[FilestreamNonTransactedAccess]
           ,[HasMemoryOptimizedObjects]
           ,[IndexSpaceUsage]
           ,[IsAccessible]
           ,[IsDatabaseSnapshot]
           ,[IsDatabaseSnapshotBase]
           ,[IsFullTextEnabled]
           ,[IsMirroringEnabled]
           ,[IsParameterizationForced]
           ,[IsReadCommittedSnapshotOn]
           ,[IsSystemObject]
           ,[IsUpdateable]
           ,[LastBackupDate]
           ,[LastDifferentialBackupDate]
           ,[LastLogBackupDate]
           ,[LogReuseWaitStatus]
           ,[Owner]
           ,[PageVerify]
           ,[PrimaryFilePath]
           ,[ReadOnly]
           ,[RecoveryModel]
           ,[ReplicationOptions]
           ,[Size]
           ,[SnapshotIsolationState]
           ,[SpaceAvailable]
           ,[Status]
           ,[TargetRecoveryTime]
           ,[TemporalHistoryRetentionEnabled]
           ,[Trustworthy]
           ,[UserAccess]
           ,[Version]
		From Staging.DatabaseInfo

		-- Insert New Databases into [info].[ApplicationDatabaseLookup]
		INSERT INTO [info].[ApplicationDatabaseLookup](ApplicationId, InstanceID, DatabaseID, Notes, CreateDate, LastUpdate)
		SELECT 
			0 as [ApplicationId],
			d.[InstanceID],
			d.[DatabaseID],
			'' as Notes,
			GetDate() as CreateDate, 
			GetDate() as LastUpdate
		FROM [info].[DatabaseInfo] d
		LEFT JOIN [info].[ApplicationDatabaseLookup] a
			On a.InstanceID = d.InstanceID
			AND a.DatabaseID = d.DatabaseID
		WHERE a.ApplicationId is Null

		COMMIT

	END TRY
	BEGIN CATCH
		EXECUTE dbo.usp_GetErrorInfo;
		ROLLBACK
	END CATCH

END
GO
/****** Object:  StoredProcedure [Staging].[DiskSpaceInfoMerge]    Script Date: 16/03/2018 12:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Patrick Flynn
-- Create date: 2018-02-09
-- Description:	Merge Data for Servers
-- =============================================
CREATE PROCEDURE [Staging].[DiskSpaceInfoMerge] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRAN;
	BEGIN TRY;

		WITH NewReadings AS
		(
			SELECT 
				 dsi.[ComputerID]
				,dsi.[ComputerName]
				,dsi.[ReadingDate] as DateChecked
				,dsi.[Name]
				,dsi.[Label]
				,dsi.[PercentFree]
				,dsi.[BlockSize]
				,dsi.[FileSystem]
				,dsi.[IsSqlDisk]
				,dsi.[DriveType]
				,dsi.[SizeInBytes]
				,dsi.[FreeInBytes]
			FROM [Staging].[DiskSpaceInfo] dsi
		)
		MERGE [info].[DiskSpaceInfo] di
		USING NewReadings nr
			ON di.ComputerID = nr.ComputerID
			AND di.Name = nr.Name
		WHEN MATCHED THEN UPDATE
			SET
				[Label] = nr.[Label],
				[PercentFree] = nr.[PercentFree],
				[BlockSize] = nr.[BlockSize],
				[FileSystem] = nr.[FileSystem],
				[IsSqlDisk] = nr.[IsSqlDisk],
				[DriveType] = nr.[DriveType],
				[SizeInBytes] = nr.[SizeInBytes],
				[FreeInBytes] = nr.[FreeInBytes],
				[DateChecked] = nr.[DateChecked]
		WHEN NOT MATCHED BY TARGET THEN
		  INSERT ([ComputerID], [Name], [Label], [PercentFree], [BlockSize], [FileSystem], [IsSqlDisk], [DriveType], [SizeInBytes], [FreeInBytes], [DateChecked])
		  VALUES (nr.[ComputerID], nr.[Name], nr.[Label], nr.[PercentFree], nr.[BlockSize], nr.[FileSystem], nr.[IsSqlDisk], nr.[DriveType], nr.[SizeInBytes], nr.[FreeInBytes], nr.[DateChecked]);


		-- Insert Daily Reading
		INSERT INTO [Monitoring].[DiskSpaceInfo]([ComputerID], [ComputerName], [ReadingDate], [Name], [Label], [PercentFree], [BlockSize], [FileSystem], [IsSqlDisk], [DriveType], [SizeInBytes], [FreeInBytes])
		SELECT [ComputerID], [ComputerName], [ReadingDate], [Name], [Label], [PercentFree], [BlockSize], [FileSystem], [IsSqlDisk], [DriveType], [SizeInBytes], [FreeInBytes]
		FROM Staging.DiskSpaceInfo

		COMMIT

	END TRY
	BEGIN CATCH
		EXECUTE dbo.usp_GetErrorInfo;
		ROLLBACK
	END CATCH

END
GO
/****** Object:  StoredProcedure [Staging].[PageFileSettingInfoMerge]    Script Date: 16/03/2018 12:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Patrick Flynn
-- Create date: 2018-02-01
-- Description:	Merge Data for Servers
-- =============================================
CREATE PROCEDURE [Staging].[PageFileSettingInfoMerge] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRAN;
	BEGIN TRY;

		WITH NewReadings AS
		(
			SELECT 
				 pfs.[ComputerID]
				,pfs.[ComputerName]
				,pfs.FileName
				,GetDate() as DateChecked
				,pfs.AutoPageFile
				,pfs.Status
				,pfs.LastModified
				,pfs.LastAccessed
				,pfs.AllocatedBaseSize
				,pfs.InitialSize
				,pfs.MaximumSize
				,pfs.PeakUsage
				,pfs.CurrentUsage
			FROM [Staging].[PageFileSettingInfo] pfs
		)
		MERGE [info].[PageFileSettingInfo] pfs
		USING NewReadings nr
			ON pfs.ComputerID = nr.ComputerID
			AND pfs.FileName = nr.FileName
		WHEN MATCHED THEN UPDATE
			SET
				[AutoPageFile] = nr.[AutoPageFile],
				[Status] = nr.[Status],
				[LastModified] = nr.[LastModified],
				[LastAccessed] = nr.[LastAccessed],
				[AllocatedBaseSize] = nr.[AllocatedBaseSize],
				[InitialSize] = nr.[InitialSize],
				[MaximumSize] = nr.[MaximumSize],
				[PeakUsage] = nr.[PeakUsage],
				[CurrentUsage] = nr.[CurrentUsage],
				[DateChecked] = nr.[DateChecked]
		WHEN NOT MATCHED BY TARGET THEN
		  INSERT ([ComputerId], [FileName], [DateChecked], [AutoPageFile], [Status], [LastModified], [LastAccessed], [AllocatedBaseSize], [InitialSize], [MaximumSize], [PeakUsage], [CurrentUsage])
		  VALUES (nr.[ComputerId], nr.[FileName], nr.[DateChecked], nr.[AutoPageFile], nr.[Status], nr.[LastModified], nr.[LastAccessed], nr.[AllocatedBaseSize], nr.[InitialSize], nr.[MaximumSize], nr.[PeakUsage], nr.[CurrentUsage]);


		-- Insert Daily Reading
		INSERT INTO [Monitoring].[PageFileSettingInfo]([ComputerId], [FileName], [ReadingDate], [AutoPageFile], [Status], [LastModified], [LastAccessed], [AllocatedBaseSize], [InitialSize], [MaximumSize], [PeakUsage], [CurrentUsage])
		SELECT [ComputerId], [FileName], GetDate() as [ReadingDate], [AutoPageFile], [Status], [LastModified], [LastAccessed], [AllocatedBaseSize], [InitialSize], [MaximumSize], [PeakUsage], [CurrentUsage]
		FROM Staging.PageFileSettingInfo

		COMMIT

	END TRY
	BEGIN CATCH
		EXECUTE dbo.usp_GetErrorInfo;
		ROLLBACK
	END CATCH

END
GO
/****** Object:  StoredProcedure [Staging].[SQLInstanceAddFromService]    Script Date: 16/03/2018 12:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		Patrick Flynn
-- Create date: 2018-02-01
-- Description:	Merge Data for Servers
-- =============================================
CREATE PROCEDURE [Staging].[SQLInstanceAddFromService] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRAN;
	BEGIN TRY;

		With InstanceData(ComputerID, SQLInstance) 
		as
		(
			Select 
				cl.ComputerID,
				CASE 
					WHEN ssi.InstanceName = 'MSSQLSERVER' THEN cl.ComputerName
					ELSE cl.ComputerName + '\' + ssi.InstanceName
				END as InstanceName
			from info.SqlServiceInfo ssi
			INNER JOIN  info.ComputerList cl
				on cl.ComputerID = ssi.ComputerId
			WHERE ServiceType = 'Engine'
		)
		INSERT INTO [info].[SQLInstanceList]([ComputerID], [SqlInstance], [IsActive], [NotContactable], [createDate], [updateDate])
		Select id.ComputerID, id.SQLInstance, 1, 0, GetDate() as createDate, GetDate() as updateDate
		FROM InstanceData id
		LEFT JOIN [info].[SQLInstanceList] sl
			on id.ComputerID = sl.ComputerID
			AND id.SQLInstance = sl.SqlInstance
		WHERE sl.InstanceID is Null;

		COMMIT

	END TRY
	BEGIN CATCH
		EXECUTE dbo.usp_GetErrorInfo;
		ROLLBACK
	END CATCH

END
GO
/****** Object:  StoredProcedure [Staging].[SQLInstanceInfoMerge]    Script Date: 16/03/2018 12:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Patrick Flynn
-- Create date: 2018-01-01
-- Description:	Merge Staging Data for SQL Server Instances
-- =============================================
CREATE PROCEDURE [Staging].[SQLInstanceInfoMerge] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	BEGIN TRAN;
	BEGIN TRY;
		With NewReadings as
		(
		SELECT        
			sqlii.instanceId,
			sqlii.ReadingDate AS DateChecked,
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
		FROM Staging.SQLInstanceInfo AS sqlii 
		)
		MERGE info.SQLInstanceInfo si
		USING NewReadings nr
			ON si.InstanceID = nr.InstanceID
		WHEN MATCHED THEN UPDATE
			SET 
				DateChecked = nr.[DateChecked],
				[VersionString] = nr.[VersionString],
				[VersionName] = nr.[VersionName],
				[Edition] = nr.[Edition],
				[ServicePack] = nr.[ServicePack],
				[ServerType] = nr.[ServerType],
				[Collation] = nr.[Collation],
				[IsCaseSensitive] = nr.[IsCaseSensitive],
				[IsHADREnabled] = nr.[IsHADREnabled],
				[HADREndpointPort] = nr.[HADREndpointPort],
				[IsSQLClustered] = nr.[IsSQLClustered],
				[ClusterName] = nr.[ClusterName],
				[ClusterQuorumstate] = nr.[ClusterQuorumstate],
				[ClusterQuorumType] = nr.[ClusterQuorumType],
				[AGs] = nr.[AGs],
				[AGListener] = nr.[AGListener],
				[SQLService] = nr.[SQLService],
				[SQLServiceAccount] = nr.[SQLServiceAccount],
				[SQLServiceStartMode] = nr.[SQLServiceStartMode],
				[SQLAgentServiceAccount] = nr.[SQLAgentServiceAccount],
				[SQLAgentServiceStartMode] = nr.[SQLAgentServiceStartMode],
				[BrowserAccount] = nr.[BrowserAccount],
				[BrowserStartMode] = nr.[BrowserStartMode],
				[DefaultFile] = nr.[DefaultFile],
				[DefaultLog] = nr.[DefaultLog],
				[BackupDirectory] = nr.[BackupDirectory],
				[InstallDataDirectory] = nr.[InstallDataDirectory],
				[InstallSharedDirectory] = nr.[InstallSharedDirectory],
				[MasterDBPath] = nr.[MasterDBPath],
				[MasterDBLogPath] = nr.[MasterDBLogPath],
				[ErrorLogPath] = nr.[ErrorLogPath],
				[IsFullTextInstalled] = nr.[IsFullTextInstalled],
				[LinkedServer] = nr.[LinkedServer],
				[LoginMode] = nr.[LoginMode],
				[TcpEnabled] = nr.[TcpEnabled],
				[NamedPipesEnabled] = nr.[NamedPipesEnabled],
				[C2AuditMode] = nr.[C2AuditMode],
				[CommonCriteriaComplianceEnabled] = nr.[CommonCriteriaComplianceEnabled],
				[CostThresholdForParallelism] = nr.[CostThresholdForParallelism],
				[DBMailEnabled] = nr.[DBMailEnabled],
				[DefaultBackupCompression] = nr.[DefaultBackupCompression],
				[FillFactor] = nr.[FillFactor],
				[MaxDegreeOfParallelism] = nr.[MaxDegreeOfParallelism],
				[MaxMem] = nr.[MaxMem],
				[MinMem] = nr.[MinMem],
				[OptimizeAdhocWorkloads] = nr.[OptimizeAdhocWorkloads],
				[RemoteDacEnabled] = nr.[RemoteDacEnabled],
				[XPCmdShellEnabled] = nr.[XPCmdShellEnabled]
		  WHEN NOT MATCHED BY TARGET THEN
		  INSERT (InstanceID, DateChecked, VersionString, VersionName, Edition, ServicePack, ServerType, Collation, IsCaseSensitive, IsHADREnabled, HADREndpointPort, IsSQLClustered, ClusterName, ClusterQuorumstate, ClusterQuorumType, AGs, AGListener, SQLService, SQLServiceAccount, SQLServiceStartMode, SQLAgentServiceAccount, SQLAgentServiceStartMode, BrowserAccount, BrowserStartMode, DefaultFile, DefaultLog, BackupDirectory, InstallDataDirectory, InstallSharedDirectory, MasterDBPath, MasterDBLogPath, ErrorLogPath, IsFullTextInstalled, LinkedServer, LoginMode, TcpEnabled, NamedPipesEnabled, C2AuditMode, CommonCriteriaComplianceEnabled, CostThresholdForParallelism, DBMailEnabled, DefaultBackupCompression, [FillFactor], MaxDegreeOfParallelism, MaxMem, MinMem, OptimizeAdhocWorkloads, RemoteDacEnabled, XPCmdShellEnabled)
		  VALUES (nr.InstanceID, nr.DateChecked, nr.VersionString, nr.VersionName, nr.Edition, nr.ServicePack, nr.ServerType, nr.Collation, nr.IsCaseSensitive, nr.IsHADREnabled, nr.HADREndpointPort, nr.IsSQLClustered, nr.ClusterName, nr.ClusterQuorumstate, nr.ClusterQuorumType, nr.AGs, nr.AGListener, nr.SQLService, nr.SQLServiceAccount, nr.SQLServiceStartMode, nr.SQLAgentServiceAccount, nr.SQLAgentServiceStartMode, nr.BrowserAccount, nr.BrowserStartMode, nr.DefaultFile, nr.DefaultLog, nr.BackupDirectory, nr.InstallDataDirectory, nr.InstallSharedDirectory, nr.MasterDBPath, nr.MasterDBLogPath, nr.ErrorLogPath, nr.IsFullTextInstalled, nr.LinkedServer, nr.LoginMode, nr.TcpEnabled, nr.NamedPipesEnabled, nr.C2AuditMode, nr.CommonCriteriaComplianceEnabled, nr.CostThresholdForParallelism, nr.DBMailEnabled, nr.DefaultBackupCompression, nr.[FillFactor], nr.MaxDegreeOfParallelism, nr.MaxMem, nr.MinMem, nr.OptimizeAdhocWorkloads, nr.RemoteDacEnabled, nr.XPCmdShellEnabled);



		-- Current Readings
		INSERT INTO [Monitoring].[SQLInstanceInfo]([InstanceID], [ReadingDate], [VersionString], [VersionName], [Edition], [ServicePack], [ServerType], [Collation], [IsCaseSensitive], [IsHADREnabled], [HADREndpointPort], [IsSQLClustered], [ClusterName], [ClusterQuorumstate], [ClusterQuorumType], [AGs], [AGListener], [SQLService], [SQLServiceAccount], [SQLServiceStartMode], [SQLAgentServiceAccount], [SQLAgentServiceStartMode], [BrowserAccount], [BrowserStartMode], [DefaultFile], [DefaultLog], [BackupDirectory], [InstallDataDirectory], [InstallSharedDirectory], [MasterDBPath], [MasterDBLogPath], [ErrorLogPath], [IsFullTextInstalled], [LinkedServer], [LoginMode], [TcpEnabled], [NamedPipesEnabled], [C2AuditMode], [CommonCriteriaComplianceEnabled], [CostThresholdForParallelism], [DBMailEnabled], [DefaultBackupCompression], [FillFactor], [MaxDegreeOfParallelism], [MaxMem], [MinMem], [OptimizeAdhocWorkloads], [RemoteDacEnabled], [XPCmdShellEnabled])
		SELECT        
			sqlii.InstanceID, 
			sqlii.ReadingDate,
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
		FROM Staging.SQLInstanceInfo AS sqlii;

		COMMIT

	END TRY
	BEGIN CATCH
		EXECUTE dbo.usp_GetErrorInfo;
		ROLLBACK
	END CATCH
END
GO
/****** Object:  StoredProcedure [Staging].[SqlInstancePropertyInfoAdd]    Script Date: 16/03/2018 12:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		Patrick Flynn
-- Create date: 2018-02-01
-- Description:	Merge Data for Servers
-- =============================================
CREATE PROCEDURE [Staging].[SqlInstancePropertyInfoAdd] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRAN;
	BEGIN TRY;

		INSERT INTO Monitoring.SqlInstancePropertyInfo
		SELECT [InstanceID]
			  ,GetDate() as ReadingDate
			  ,[PropertyType]
			  ,[Name]
			  ,[Value]
			  ,[Writable]
			  ,[Readable]
			  ,[Expensive]
			  ,[Dirty]
			  ,[Retrieved]
			  ,[IsNull]
			  ,[Enabled]
			  ,[Required]
			  ,[Attributes]
		FROM [dbareports].[Staging].[SqlInstancePropertyInfo]

		COMMIT

	END TRY
	BEGIN CATCH
		EXECUTE dbo.usp_GetErrorInfo;
		ROLLBACK
	END CATCH

END
GO
/****** Object:  StoredProcedure [Staging].[SQLServiceInfoMerge]    Script Date: 16/03/2018 12:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		Patrick Flynn
-- Create date: 2018-02-01
-- Description:	Merge Data for Servers
-- =============================================
CREATE PROCEDURE [Staging].[SQLServiceInfoMerge] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRAN;
	BEGIN TRY;

		WITH NewReadings AS
		(
			SELECT 
                 ss.ComputerID
                ,ss.[ReadingDate] as DateChecked
                ,ss.[DisplayName]
                ,ss.[StartName]
                ,ss.[ServiceType]
                ,ss.[State]
                ,ss.[StartMode]
                ,ss.[InstanceName]
			FROM [Staging].[SQLServiceInfo] ss
		)
		MERGE [info].[SQLServiceInfo] ss
		USING NewReadings nr
			ON ss.ComputerID = nr.ComputerID
			AND ss.DisplayName = nr.DisplayName
		WHEN MATCHED THEN UPDATE
			SET
				[StartName] = nr.[StartName],
				[ServiceType] = nr.[ServiceType],
				[State] = nr.[State],
				[StartMode] = nr.[StartMode],
				[InstanceName] = nr.[InstanceName],
				[DateChecked] = nr.[DateChecked]
		WHEN NOT MATCHED BY TARGET THEN
		  INSERT ([ComputerId], [DisplayName], [StartName], [ServiceType], [State], [StartMode], [InstanceName], [DateChecked])
		  VALUES (nr.[ComputerId], nr.[DisplayName], nr.[StartName], nr.[ServiceType], nr.[State], nr.[StartMode], nr.[InstanceName], nr.[DateChecked]);

		-- Insert Daily Reading
		INSERT INTO [Monitoring].[SQLServiceInfo]([ComputerId], [DisplayName], [ReadingDate], [StartName], [ServiceType], [State], [StartMode], [InstanceName])
		SELECT [ComputerId], [DisplayName], [ReadingDate], [StartName], [ServiceType], [State], [StartMode], [InstanceName]
		FROM [Staging].[SQLServiceInfo]

		COMMIT

	END TRY
	BEGIN CATCH
		EXECUTE dbo.usp_GetErrorInfo;
		ROLLBACK
	END CATCH

END
GO
