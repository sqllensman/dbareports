
/****** Object:  Table [Config].[Applications]    Script Date: 16/03/2018 12:13:53 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Config].[Applications](
	[ApplicationId] [smallint] NOT NULL,
	[ApplicationName] [varchar](100) NULL,
	[ApplicationOwner] [varchar](100) NULL,
	[Notes] [varchar](250) NULL,
	[PrincipalContact] [varchar](100) NULL,
	[PrincipalEmail] [varchar](100) NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_Applications] PRIMARY KEY CLUSTERED 
(
	[ApplicationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Info]
) ON [Info]
GO
/****** Object:  Table [Config].[InstanceStatus]    Script Date: 16/03/2018 12:13:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Config].[InstanceStatus](
	[Status] [char](1) NOT NULL,
	[Description] [varchar](20) NULL
) ON [Info]
GO
/****** Object:  Table [Config].[LicenceStatus]    Script Date: 16/03/2018 12:13:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Config].[LicenceStatus](
	[LicenceStatusId] [tinyint] NOT NULL,
	[Description] [varchar](100) NULL,
	[Valid] [bit] NULL
) ON [Info]
GO
/****** Object:  Table [Config].[Location]    Script Date: 16/03/2018 12:13:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Config].[Location](
	[Location] [tinyint] NOT NULL,
	[Description] [varchar](128) NULL,
	[Domain] [varchar](128) NULL,
	[PrimaryBU] [varchar](128) NULL,
	[Address] [varchar](500) NULL,
 CONSTRAINT [PK_Location] PRIMARY KEY CLUSTERED 
(
	[Location] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Info]
) ON [Info]
GO
/****** Object:  Table [Config].[MonitorOption]    Script Date: 16/03/2018 12:13:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Config].[MonitorOption](
	[MonitorOption] [tinyint] NOT NULL,
	[Description] [varchar](100) NULL,
 CONSTRAINT [PK_MonitorOption] PRIMARY KEY CLUSTERED 
(
	[MonitorOption] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Info]
) ON [Info]
GO
/****** Object:  Table [Config].[NotificationStatus]    Script Date: 16/03/2018 12:13:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Config].[NotificationStatus](
	[NotificationUserId] [smallint] NOT NULL,
	[StartTime] [datetime] NOT NULL,
	[EndTime] [datetime] NOT NULL,
	[Notes] [varchar](100) NULL,
 CONSTRAINT [PK_NotificationStatus] PRIMARY KEY CLUSTERED 
(
	[NotificationUserId] ASC,
	[StartTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Info]
) ON [Info]
GO
/****** Object:  Table [Config].[NotificationUsers]    Script Date: 16/03/2018 12:13:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Config].[NotificationUsers](
	[Id] [smallint] NOT NULL,
	[Name] [varchar](100) NULL,
	[SMSEmailAddress] [varchar](100) NULL,
	[SupportLevel] [tinyint] NULL,
	[IsAvailable] [bit] NULL,
	[WorkEmail] [varchar](100) NULL,
	[AferHoursEmail] [varchar](100) NULL,
	[WorkPhone] [varchar](20) NULL,
	[MobilePhone] [varchar](20) NULL,
	[NotificationOrder] [smallint] NULL,
 CONSTRAINT [PK_NotificationUsers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Info]
) ON [Info]
GO
/****** Object:  Table [Config].[Priority]    Script Date: 16/03/2018 12:13:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Config].[Priority](
	[PriorityId] [tinyint] NOT NULL,
	[PriorityDescription] [varchar](100) NULL,
	[Notes] [varchar](500) NULL,
	[Production] [bit] NULL,
 CONSTRAINT [PK_Priority] PRIMARY KEY CLUSTERED 
(
	[PriorityId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Info]
) ON [Info]
GO
/****** Object:  Table [Config].[ServerActiveStatus]    Script Date: 16/03/2018 12:13:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Config].[ServerActiveStatus](
	[ActiveStatus] [tinyint] NOT NULL,
	[Description] [varchar](30) NOT NULL,
	[RequiresLicence] [bit] NULL,
	[CheckStatus] [tinyint] NULL
) ON [Info]
GO
/****** Object:  Table [Config].[SQLServerBuilds]    Script Date: 16/03/2018 12:13:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Config].[SQLServerBuilds](
	[SQLbuildID] [int] IDENTITY(1,1) NOT NULL,
	[Build] [nvarchar](15) NOT NULL,
	[SQLSERVERExeBuild] [nvarchar](15) NOT NULL,
	[Fileversion] [nvarchar](20) NULL,
	[Q] [nvarchar](10) NOT NULL,
	[KB] [nvarchar](10) NULL,
	[KBDescription] [nvarchar](300) NULL,
	[ReleaseDate] [date] NULL,
	[New] [bit] NOT NULL,
 CONSTRAINT [PK_SQLServerBuilds] PRIMARY KEY CLUSTERED 
(
	[SQLbuildID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Info]
) ON [Info]
GO
/****** Object:  Table [Config].[StorageType]    Script Date: 16/03/2018 12:13:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Config].[StorageType](
	[StorageType] [smallint] NOT NULL,
	[Description] [varchar](100) NULL,
 CONSTRAINT [PK_StorageType] PRIMARY KEY CLUSTERED 
(
	[StorageType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Info]
) ON [Info]
GO
/****** Object:  Table [Config].[WindowsOS]    Script Date: 16/03/2018 12:13:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Config].[WindowsOS](
	[VersionId] [tinyint] NOT NULL,
	[OSVersion] [varchar](128) NULL,
	[OperatingSystem] [varchar](128) NULL,
	[Edition] [varchar](128) NULL,
	[Supported] [bit] NULL,
	[EOL_Mainstream] [datetime] NULL,
	[EOL_ExtendedSupport] [datetime] NULL
) ON [Info]
GO
/****** Object:  Table [info].[AgentJobDetail]    Script Date: 16/03/2018 12:13:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [info].[AgentJobDetail](
	[AgentJobDetailID] [int] IDENTITY(1,1) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[InstanceID] [int] NOT NULL,
	[Category] [nvarchar](50) NOT NULL,
	[JobName] [nvarchar](250) NOT NULL,
	[Description] [nvarchar](750) NOT NULL,
	[IsEnabled] [bit] NOT NULL,
	[Status] [nvarchar](50) NULL,
	[LastRunTime] [datetime] NULL,
	[Outcome] [nvarchar](50) NOT NULL,
	[Date] [datetime] NOT NULL,
 CONSTRAINT [PK_info.AgentJobDetail] PRIMARY KEY CLUSTERED 
(
	[AgentJobDetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Info]
) ON [PRIMARY]
GO
/****** Object:  Table [info].[AgentJobInfo]    Script Date: 16/03/2018 12:13:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [info].[AgentJobInfo](
	[AgentJobDetailID] [int] IDENTITY(1,1) NOT NULL,
	[InstanceId] [smallint] NULL,
	[JobID] [uniqueidentifier] NULL,
	[DateChecked] [datetime] NULL,
	[JobName] [varchar](128) NULL,
	[ComputerID] [smallint] NOT NULL,
	[Enabled] [bit] NULL,
	[Description] [varchar](750) NULL,
	[CategoryID] [int] NULL,
	[Category] [varchar](128) NULL,
	[IsEnabled] [bit] NULL,
	[HasSchedule] [bit] NULL,
	[HasStep] [bit] NULL,
	[StartStepID] [int] NULL,
	[DateCreated] [datetime2](7) NULL,
	[DateLastModified] [datetime2](7) NULL,
	[VersionNumber] [int] NULL,
	[OwnerLoginName] [varchar](128) NULL,
	[DeleteLevel] [varchar](10) NULL,
	[EmailLevel] [varchar](10) NULL,
	[OperatorToEmail] [varchar](128) NULL,
	[EventLogLevel] [varchar](10) NULL,
	[LastRunDate] [datetime2](7) NULL,
	[LastRunOutcome] [varchar](10) NULL,
	[NextRunDate] [datetime2](7) NULL,
	[CurrentRunRetryAttempt] [int] NULL,
	[CurrentRunStatus] [varchar](10) NULL,
	[CurrentRunStep] [varchar](128) NULL,
	[CategoryType] [tinyint] NULL,
	[JobType] [varchar](11) NULL,
	[OriginatingServer] [varchar](128) NULL,
	[HasServer] [bit] NULL,
 CONSTRAINT [PK_AgentJobInfo] PRIMARY KEY CLUSTERED 
(
	[AgentJobDetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Info]
) ON [Info]
GO
/****** Object:  Table [info].[AgentJobServer]    Script Date: 16/03/2018 12:13:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [info].[AgentJobServer](
	[AgentJobServerID] [int] IDENTITY(1,1) NOT NULL,
	[Date] [datetime] NOT NULL,
	[InstanceID] [int] NOT NULL,
	[NumberOfJobs] [int] NOT NULL,
	[SuccessfulJobs] [int] NOT NULL,
	[FailedJobs] [int] NOT NULL,
	[DisabledJobs] [int] NOT NULL,
	[UnknownJobs] [int] NOT NULL,
 CONSTRAINT [PK_Info.AgentJobServer] PRIMARY KEY CLUSTERED 
(
	[AgentJobServerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Info]
) ON [Info]
GO
/****** Object:  Table [info].[AlertInfo]    Script Date: 16/03/2018 12:13:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [info].[AlertInfo](
	[InstanceId] [smallint] NOT NULL,
	[Name] [varchar](128) NOT NULL,
	[DateChecked] [datetime2](7) NULL,
	[CategoryName] [nvarchar](128) NULL,
	[DatabaseID] [int] NULL,
	[DelayBetweenResponses] [smallint] NULL,
	[EventDescriptionKeyword] [varchar](100) NULL,
	[EventSource] [varchar](100) NULL,
	[HasNotification] [int] NULL,
	[IncludeEventDescription] [varchar](128) NULL,
	[IsEnabled] [bit] NULL,
	[AgentJobDetailID] [int] NULL,
	[LastOccurrenceDate] [datetime2](7) NULL,
	[LastResponseDate] [datetime2](7) NULL,
	[MessageID] [int] NULL,
	[NotificationMessage] [varchar](512) NULL,
	[OccurrenceCount] [int] NULL,
	[PerformanceCondition] [varchar](512) NULL,
	[Severity] [int] NULL,
	[WmiEventNamespace] [varchar](512) NULL,
	[WmiEventQuery] [varchar](512) NULL,
 CONSTRAINT [PK_AlertInfo] PRIMARY KEY CLUSTERED 
(
	[InstanceId] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Info]
) ON [Info]
GO
/****** Object:  Table [info].[ApplicationDatabaseLookup]    Script Date: 16/03/2018 12:13:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [info].[ApplicationDatabaseLookup](
	[ApplicationDatabaseLookup] [int] IDENTITY(1,1) NOT NULL,
	[ApplicationId] [smallint] NULL,
	[InstanceID] [smallint] NULL,
	[DatabaseID] [int] NULL,
	[Notes] [varchar](250) NULL,
	[CreateDate] [datetime] NULL,
	[LastUpdate] [datetime] NULL,
 CONSTRAINT [PK_ApplicationDatabaseLookup] PRIMARY KEY CLUSTERED 
(
	[ApplicationDatabaseLookup] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Info]
) ON [Info]
GO
/****** Object:  Table [info].[ComputerInfo]    Script Date: 16/03/2018 12:13:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [info].[ComputerInfo](
	[ComputerID] [smallint] NOT NULL,
	[ComputerName] [varchar](128) NOT NULL,
	[DateChecked] [datetime] NOT NULL,
	[DNSHostName] [varchar](128) NULL,
	[IPAddress] [varchar](39) NULL,
	[FQDN] [varchar](128) NULL,
	[Manufacturer] [varchar](128) NULL,
	[Model] [varchar](128) NULL,
	[SystemType] [varchar](128) NULL,
	[TotalPhysicalMemory] [bigint] NULL,
	[NumberOfLogicalProcessors] [smallint] NULL,
	[NumberOfProcessors] [smallint] NULL,
	[IsHyperThreading] [bit] NULL,
	[Domain] [varchar](128) NULL,
	[DomainRole] [varchar](128) NULL,
	[BootDevice] [varchar](128) NULL,
	[SystemDevice] [varchar](128) NULL,
	[SystemDrive] [varchar](10) NULL,
	[WindowsDirectory] [varchar](128) NULL,
	[OSVersion] [varchar](128) NULL,
	[SPVersion] [tinyint] NULL,
	[OSManufacturer] [varchar](40) NULL,
	[PowerShellVersion] [varchar](10) NULL,
	[Architecture] [varchar](10) NULL,
	[BuildNumber] [varchar](20) NULL,
	[Version] [varchar](128) NULL,
	[InstallDate] [datetime2](7) NULL,
	[LastBootTime] [datetime2](7) NULL,
	[LocalDateTime] [datetime2](7) NULL,
	[DaylightInEffect] [bit] NULL,
	[IsDaylightSavingsTime] [bit] NULL,
	[TimeZone] [varchar](128) NULL,
	[TimeZoneStandard] [varchar](128) NULL,
	[TimeZoneDaylight] [varchar](128) NULL,
	[ActivePowerPlan] [varchar](128) NULL,
	[Status] [varchar](10) NULL,
	[Language] [varchar](128) NULL,
	[LanguageAlias] [varchar](128) NULL,
	[CountryCode] [varchar](10) NULL,
	[PagingFileSize] [bigint] NULL,
	[TotalVisibleMemory] [bigint] NULL,
	[FreePhysicalMemory] [bigint] NULL,
	[TotalVirtualMemory] [bigint] NULL,
	[FreeVirtualMemory] [bigint] NULL,
 CONSTRAINT [PK_ComputerInfo] PRIMARY KEY CLUSTERED 
(
	[ComputerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Info]
) ON [Info]
GO
/****** Object:  Table [info].[ComputerList]    Script Date: 16/03/2018 12:13:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [info].[ComputerList](
	[ComputerID] [smallint] IDENTITY(1105,1) NOT NULL,
	[ComputerName] [varchar](128) NOT NULL,
	[ConnectName] [varchar](128) NULL,
	[Location] [tinyint] NULL,
	[Priority] [tinyint] NULL,
	[ActiveStatus] [tinyint] NULL,
	[MonitorOptions] [tinyint] NULL,
	[NotContactable] [bit] NULL,
	[description] [varchar](500) NULL,
	[createDate] [date] NOT NULL,
	[updateDate] [datetime] NOT NULL,
	[decommissionDate] [date] NULL,
	[ClusterId] [smallint] NULL,
 CONSTRAINT [PK_Hosts] PRIMARY KEY CLUSTERED 
(
	[ComputerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Info]
) ON [Info]
GO
/****** Object:  Table [info].[DatabaseCheckDBInfo]    Script Date: 16/03/2018 12:13:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [info].[DatabaseCheckDBInfo](
	[InstanceId] [smallint] NOT NULL,
	[DatabaseId] [int] NOT NULL,
	[DateChecked] [datetime2](7) NULL,
	[DatabaseCreated] [datetime2](7) NULL,
	[LastGoodCheckDb] [datetime2](7) NULL,
	[DaysSinceLastGoodCheckDb] [int] NULL,
	[DaysSinceDbCreated] [int] NULL,
	[Status] [varchar](30) NULL,
	[DataPurityEnabled] [bit] NULL,
	[CreateVersion] [smallint] NULL,
 CONSTRAINT [PK_DatabaseCheckDBInfo] PRIMARY KEY CLUSTERED 
(
	[InstanceId] ASC,
	[DatabaseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Info]
) ON [Info]
GO
/****** Object:  Table [info].[DatabaseInfo]    Script Date: 16/03/2018 12:13:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [info].[DatabaseInfo](
	[DatabaseID] [int] IDENTITY(1,1) NOT NULL,
	[InstanceID] [int] NOT NULL,
	[Name] [varchar](128) NULL,
	[DateAdded] [datetime2](7) NULL,
	[DateChecked] [datetime2](7) NULL,
	[AutoClose] [bit] NULL,
	[AutoCreateStatisticsEnabled] [bit] NULL,
	[AutoShrink] [bit] NULL,
	[AutoUpdateStatisticsAsync] [bit] NULL,
	[AutoUpdateStatisticsEnabled] [bit] NULL,
	[AvailabilityDatabaseSynchronizationState] [varchar](20) NULL,
	[AvailabilityGroupName] [varchar](128) NULL,
	[CaseSensitive] [bit] NULL,
	[Collation] [varchar](50) NULL,
	[CompatibilityLevel] [varchar](30) NULL,
	[CreateDate] [datetime2](7) NULL,
	[DatabaseOwnershipChaining] [bit] NULL,
	[DatabaseSnapshotBaseName] [varchar](128) NULL,
	[DataSpaceUsage] [float] NULL,
	[DefaultFileGroup] [varchar](128) NULL,
	[DefaultFileStreamFileGroup] [varchar](128) NULL,
	[DelayedDurability] [varchar](10) NULL,
	[EncryptionEnabled] [bit] NULL,
	[FilestreamDirectoryName] [varchar](128) NULL,
	[FilestreamNonTransactedAccess] [varchar](10) NULL,
	[HasMemoryOptimizedObjects] [bit] NULL,
	[IndexSpaceUsage] [float] NULL,
	[IsAccessible] [bit] NULL,
	[IsDatabaseSnapshot] [bit] NULL,
	[IsDatabaseSnapshotBase] [bit] NULL,
	[IsFullTextEnabled] [bit] NULL,
	[IsMirroringEnabled] [bit] NULL,
	[IsParameterizationForced] [bit] NULL,
	[IsReadCommittedSnapshotOn] [bit] NULL,
	[IsSystemObject] [bit] NULL,
	[IsUpdateable] [bit] NULL,
	[LastBackupDate] [datetime2](7) NULL,
	[LastDifferentialBackupDate] [datetime2](7) NULL,
	[LastLogBackupDate] [datetime2](7) NULL,
	[LogReuseWaitStatus] [varchar](20) NULL,
	[Owner] [varchar](128) NULL,
	[PageVerify] [varchar](20) NULL,
	[PrimaryFilePath] [varchar](128) NULL,
	[ReadOnly] [bit] NULL,
	[RecoveryModel] [varchar](10) NULL,
	[ReplicationOptions] [varchar](50) NULL,
	[Size] [float] NULL,
	[SnapshotIsolationState] [varchar](10) NULL,
	[SpaceAvailable] [float] NULL,
	[Status] [varchar](50) NULL,
	[TargetRecoveryTime] [int] NULL,
	[TemporalHistoryRetentionEnabled] [varchar](10) NULL,
	[Trustworthy] [bit] NULL,
	[UserAccess] [varchar](30) NULL,
	[Version] [int] NULL,
	[LastRead] [datetime2](7) NULL,
	[LastWrite] [datetime2](7) NULL,
	[LastDBCCDate] [datetime] NULL,
	[InActive] [bit] NULL,
 CONSTRAINT [PK_Databases] PRIMARY KEY CLUSTERED 
(
	[DatabaseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Info]
) ON [Info]
GO
/****** Object:  Table [info].[DiskSpaceInfo]    Script Date: 16/03/2018 12:13:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [info].[DiskSpaceInfo](
	[DiskSpaceID] [int] IDENTITY(1,1) NOT NULL,
	[ComputerID] [smallint] NOT NULL,
	[Name] [varchar](128) NULL,
	[Label] [varchar](128) NULL,
	[PercentFree] [decimal](10, 2) NULL,
	[BlockSize] [int] NULL,
	[FileSystem] [varchar](15) NULL,
	[IsSqlDisk] [bit] NULL,
	[DriveType] [varchar](30) NULL,
	[SizeInBytes] [bigint] NULL,
	[FreeInBytes] [bigint] NULL,
	[DateChecked] [datetime] NOT NULL,
 CONSTRAINT [PK_DiskSpace_1] PRIMARY KEY CLUSTERED 
(
	[DiskSpaceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Info]
) ON [Info]
GO
/****** Object:  Table [info].[LogFileErrorMessages]    Script Date: 16/03/2018 12:13:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [info].[LogFileErrorMessages](
	[LogFileErrorMessagesID] [int] IDENTITY(1,1) NOT NULL,
	[Date] [date] NOT NULL,
	[FileName] [nvarchar](100) NOT NULL,
	[ErrorMsg] [nvarchar](500) NOT NULL,
	[Line] [int] NOT NULL,
	[Matches] [nvarchar](12) NULL,
 CONSTRAINT [PK_LogFileErrorMessages] PRIMARY KEY CLUSTERED 
(
	[LogFileErrorMessagesID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Info]
) ON [Info]
GO
/****** Object:  Table [info].[PageFileSettingInfo]    Script Date: 16/03/2018 12:13:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [info].[PageFileSettingInfo](
	[ComputerId] [smallint] NOT NULL,
	[FileName] [varchar](128) NOT NULL,
	[DateChecked] [datetime] NOT NULL,
	[AutoPageFile] [bit] NULL,
	[Status] [varchar](20) NULL,
	[LastModified] [datetime2](7) NULL,
	[LastAccessed] [datetime2](7) NULL,
	[AllocatedBaseSize] [bigint] NULL,
	[InitialSize] [bigint] NULL,
	[MaximumSize] [bigint] NULL,
	[PeakUsage] [bigint] NULL,
	[CurrentUsage] [bigint] NULL,
 CONSTRAINT [PK_PageFileSettingInfo] PRIMARY KEY CLUSTERED 
(
	[ComputerId] ASC,
	[FileName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Info]
) ON [Info]
GO
/****** Object:  Table [info].[SQLInstanceInfo]    Script Date: 16/03/2018 12:13:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [info].[SQLInstanceInfo](
	[InstanceID] [smallint] NOT NULL,
	[DateChecked] [datetime] NULL,
	[VersionString] [varchar](20) NULL,
	[VersionName] [varchar](40) NULL,
	[Edition] [varchar](128) NULL,
	[ServicePack] [varchar](3) NULL,
	[ServerType] [varchar](50) NULL,
	[Collation] [varchar](50) NULL,
	[IsCaseSensitive] [bit] NULL,
	[IsHADREnabled] [bit] NULL,
	[HADREndpointPort] [int] NULL,
	[IsSQLClustered] [bit] NULL,
	[ClusterName] [varchar](30) NULL,
	[ClusterQuorumstate] [varchar](20) NULL,
	[ClusterQuorumType] [varchar](50) NULL,
	[AGs] [varchar](max) NULL,
	[AGListener] [varchar](max) NULL,
	[SQLService] [varchar](50) NULL,
	[SQLServiceAccount] [varchar](128) NULL,
	[SQLServiceStartMode] [varchar](10) NULL,
	[SQLAgentServiceAccount] [varchar](128) NULL,
	[SQLAgentServiceStartMode] [varchar](10) NULL,
	[BrowserAccount] [varchar](128) NULL,
	[BrowserStartMode] [varchar](10) NULL,
	[DefaultFile] [varchar](128) NULL,
	[DefaultLog] [varchar](128) NULL,
	[BackupDirectory] [varchar](128) NULL,
	[InstallDataDirectory] [varchar](128) NULL,
	[InstallSharedDirectory] [varchar](128) NULL,
	[MasterDBPath] [varchar](128) NULL,
	[MasterDBLogPath] [varchar](128) NULL,
	[ErrorLogPath] [varchar](128) NULL,
	[IsFullTextInstalled] [bit] NULL,
	[LinkedServer] [smallint] NULL,
	[LoginMode] [varchar](10) NULL,
	[TcpEnabled] [bit] NULL,
	[NamedPipesEnabled] [bit] NULL,
	[C2AuditMode] [tinyint] NULL,
	[CommonCriteriaComplianceEnabled] [bit] NULL,
	[CostThresholdForParallelism] [smallint] NULL,
	[DBMailEnabled] [bit] NULL,
	[DefaultBackupCompression] [bit] NULL,
	[FillFactor] [tinyint] NULL,
	[MaxDegreeOfParallelism] [smallint] NULL,
	[MaxMem] [int] NULL,
	[MinMem] [int] NULL,
	[OptimizeAdhocWorkloads] [bit] NULL,
	[RemoteDacEnabled] [bit] NULL,
	[XPCmdShellEnabled] [bit] NULL,
 CONSTRAINT [PK_SQLInstanceInfo] PRIMARY KEY CLUSTERED 
(
	[InstanceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Info]
) ON [Info] TEXTIMAGE_ON [Info]
GO
/****** Object:  Table [info].[SQLInstanceList]    Script Date: 16/03/2018 12:13:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [info].[SQLInstanceList](
	[InstanceID] [smallint] IDENTITY(1108,1) NOT NULL,
	[ComputerID] [smallint] NOT NULL,
	[SqlInstance] [varchar](128) NOT NULL,
	[ConnectName] [varchar](128) NULL,
	[ClusterID] [int] NULL,
	[Status] [char](1) NULL,
	[LicenceStatus] [tinyint] NULL,
	[IsActive] [bit] NULL,
	[NotContactable] [bit] NULL,
	[createDate] [smalldatetime] NULL,
	[updateDate] [smalldatetime] NULL,
	[decommissionDate] [date] NULL,
 CONSTRAINT [PK_SQLInstanceList] PRIMARY KEY CLUSTERED 
(
	[InstanceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Info]
) ON [Info]
GO
/****** Object:  Table [info].[SqlServiceInfo]    Script Date: 16/03/2018 12:13:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [info].[SqlServiceInfo](
	[ComputerId] [smallint] NOT NULL,
	[DisplayName] [varchar](128) NOT NULL,
	[StartName] [varchar](128) NULL,
	[ServiceType] [varchar](128) NULL,
	[State] [varchar](20) NULL,
	[StartMode] [varchar](20) NULL,
	[InstanceName] [varchar](128) NULL,
	[DateChecked] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_SQLServiceInfo] PRIMARY KEY CLUSTERED 
(
	[ComputerId] ASC,
	[DisplayName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Info]
) ON [Info]
GO
/****** Object:  Table [info].[SuspectPages]    Script Date: 16/03/2018 12:13:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [info].[SuspectPages](
	[SuspectPageID] [int] IDENTITY(1,1) NOT NULL,
	[DatabaseID] [int] NOT NULL,
	[DateChecked] [datetime] NOT NULL,
	[FileName] [varchar](2000) NOT NULL,
	[Page_id] [bigint] NOT NULL,
	[EventType] [nvarchar](24) NOT NULL,
	[Error_count] [int] NOT NULL,
	[last_update_date] [datetime] NOT NULL,
	[InstanceID] [int] NOT NULL,
 CONSTRAINT [PK_SuspectPages] PRIMARY KEY CLUSTERED 
(
	[SuspectPageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Info]
) ON [Info]
GO
/****** Object:  Table [Monitoring].[AgentJobInfo]    Script Date: 16/03/2018 12:13:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Monitoring].[AgentJobInfo](
	[InstanceId] [smallint] NOT NULL,
	[JobID] [uniqueidentifier] NOT NULL,
	[ReadingDate] [datetime] NOT NULL,
	[JobName] [varchar](128) NULL,
	[ComputerID] [smallint] NOT NULL,
	[Enabled] [bit] NULL,
	[Description] [varchar](750) NULL,
	[CategoryID] [int] NULL,
	[Category] [varchar](128) NULL,
	[IsEnabled] [bit] NULL,
	[HasSchedule] [bit] NULL,
	[HasStep] [bit] NULL,
	[StartStepID] [int] NULL,
	[DateCreated] [datetime2](7) NULL,
	[DateLastModified] [datetime2](7) NULL,
	[VersionNumber] [int] NULL,
	[OwnerLoginName] [varchar](128) NULL,
	[DeleteLevel] [varchar](10) NULL,
	[EmailLevel] [varchar](10) NULL,
	[OperatorToEmail] [varchar](128) NULL,
	[EventLogLevel] [varchar](10) NULL,
	[LastRunDate] [datetime2](7) NULL,
	[LastRunOutcome] [varchar](10) NULL,
	[NextRunDate] [datetime2](7) NULL,
	[CurrentRunRetryAttempt] [int] NULL,
	[CurrentRunStatus] [varchar](10) NULL,
	[CurrentRunStep] [varchar](128) NULL,
	[CategoryType] [tinyint] NULL,
	[JobType] [varchar](11) NULL,
	[OriginatingServer] [varchar](128) NULL,
	[HasServer] [bit] NULL,
 CONSTRAINT [PK_AgentJobInfo_1] PRIMARY KEY CLUSTERED 
(
	[InstanceId] ASC,
	[JobID] ASC,
	[ReadingDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Monitoring]
) ON [Monitoring]
GO
/****** Object:  Table [Monitoring].[AlertInfo]    Script Date: 16/03/2018 12:13:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Monitoring].[AlertInfo](
	[InstanceId] [smallint] NOT NULL,
	[Name] [varchar](128) NOT NULL,
	[ReadingDate] [datetime2](7) NULL,
	[CategoryName] [nvarchar](128) NULL,
	[DatabaseID] [int] NULL,
	[DelayBetweenResponses] [smallint] NULL,
	[EventDescriptionKeyword] [varchar](100) NULL,
	[EventSource] [varchar](100) NULL,
	[HasNotification] [int] NULL,
	[IncludeEventDescription] [varchar](128) NULL,
	[IsEnabled] [bit] NULL,
	[AgentJobDetailID] [int] NULL,
	[LastOccurrenceDate] [datetime2](7) NULL,
	[LastResponseDate] [datetime2](7) NULL,
	[MessageID] [int] NULL,
	[NotificationMessage] [varchar](512) NULL,
	[OccurrenceCount] [int] NULL,
	[PerformanceCondition] [varchar](512) NULL,
	[Severity] [int] NULL,
	[WmiEventNamespace] [varchar](512) NULL,
	[WmiEventQuery] [varchar](512) NULL,
 CONSTRAINT [PK_AlertInfo] PRIMARY KEY CLUSTERED 
(
	[InstanceId] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Monitoring]
) ON [Monitoring]
GO
/****** Object:  Table [Monitoring].[ComputerInfo]    Script Date: 16/03/2018 12:13:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Monitoring].[ComputerInfo](
	[ComputerId] [smallint] NOT NULL,
	[ReadingDate] [datetime] NOT NULL,
	[DNSHostName] [varchar](128) NULL,
	[IPAddress] [varchar](39) NULL,
	[FQDN] [varchar](128) NULL,
	[Manufacturer] [varchar](128) NULL,
	[Model] [varchar](128) NULL,
	[SystemType] [varchar](128) NULL,
	[TotalPhysicalMemory] [bigint] NULL,
	[NumberOfLogicalProcessors] [smallint] NULL,
	[NumberOfProcessors] [smallint] NULL,
	[IsHyperThreading] [bit] NULL,
	[Domain] [varchar](128) NULL,
	[DomainRole] [varchar](128) NULL,
	[BootDevice] [varchar](128) NULL,
	[SystemDevice] [varchar](128) NULL,
	[SystemDrive] [varchar](10) NULL,
	[WindowsDirectory] [varchar](128) NULL,
	[OSVersion] [varchar](128) NULL,
	[SPVersion] [tinyint] NULL,
	[OSManufacturer] [varchar](40) NULL,
	[PowerShellVersion] [varchar](10) NULL,
	[Architecture] [varchar](10) NULL,
	[BuildNumber] [varchar](20) NULL,
	[Version] [varchar](128) NULL,
	[InstallDate] [datetime2](7) NULL,
	[LastBootTime] [datetime2](7) NULL,
	[LocalDateTime] [datetime2](7) NULL,
	[DaylightInEffect] [bit] NULL,
	[IsDaylightSavingsTime] [bit] NULL,
	[TimeZone] [varchar](128) NULL,
	[TimeZoneStandard] [varchar](128) NULL,
	[TimeZoneDaylight] [varchar](128) NULL,
	[ActivePowerPlan] [varchar](128) NULL,
	[Status] [varchar](10) NULL,
	[Language] [varchar](128) NULL,
	[LanguageAlias] [varchar](128) NULL,
	[CountryCode] [varchar](10) NULL,
	[PagingFileSize] [bigint] NULL,
	[TotalVisibleMemory] [bigint] NULL,
	[FreePhysicalMemory] [bigint] NULL,
	[TotalVirtualMemory] [bigint] NULL,
	[FreeVirtualMemory] [bigint] NULL,
 CONSTRAINT [PK_ComputerInfo] PRIMARY KEY CLUSTERED 
(
	[ComputerId] ASC,
	[ReadingDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Monitoring]
) ON [Monitoring]
GO
/****** Object:  Table [Monitoring].[DatabaseCheckDBInfo]    Script Date: 16/03/2018 12:13:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Monitoring].[DatabaseCheckDBInfo](
	[InstanceId] [smallint] NOT NULL,
	[DatabaseId] [int] NOT NULL,
	[ReadingDate] [datetime2](7) NULL,
	[DatabaseCreated] [datetime2](7) NULL,
	[LastGoodCheckDb] [datetime2](7) NULL,
	[DaysSinceLastGoodCheckDb] [int] NULL,
	[DaysSinceDbCreated] [int] NULL,
	[Status] [varchar](30) NULL,
	[DataPurityEnabled] [bit] NULL,
	[CreateVersion] [smallint] NULL,
 CONSTRAINT [PK_DatabaseCheckDBInfo] PRIMARY KEY CLUSTERED 
(
	[InstanceId] ASC,
	[DatabaseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Monitoring]
) ON [Monitoring]
GO
/****** Object:  Table [Monitoring].[DatabaseFileInfo]    Script Date: 16/03/2018 12:13:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Monitoring].[DatabaseFileInfo](
	[InstanceID] [smallint] NOT NULL,
	[DatabaseID] [int] NOT NULL,
	[ReadingDate] [datetime] NOT NULL,
	[Database] [varchar](128) NOT NULL,
	[FileGroupName] [varchar](128) NULL,
	[ID] [int] NOT NULL,
	[Type] [tinyint] NULL,
	[TypeDescription] [varchar](128) NULL,
	[LogicalName] [varchar](128) NULL,
	[PhysicalName] [varchar](128) NULL,
	[State] [varchar](30) NULL,
	[MaxSize] [bigint] NULL,
	[Growth] [int] NULL,
	[GrowthType] [varchar](10) NULL,
	[NextGrowthEventSize] [bigint] NULL,
	[Size] [bigint] NULL,
	[UsedSpace] [bigint] NULL,
	[AvailableSpace] [bigint] NULL,
	[IsOffline] [bit] NULL,
	[IsReadOnly] [bit] NULL,
	[IsReadOnlyMedia] [bit] NULL,
	[IsSparse] [bit] NULL,
	[NumberOfDiskWrites] [bigint] NULL,
	[NumberOfDiskReads] [bigint] NULL,
	[ReadFromDisk] [bigint] NULL,
	[WrittenToDisk] [bigint] NULL,
	[VolumeFreeSpace] [bigint] NULL,
	[FileGroupDataSpaceId] [int] NULL,
	[FileGroupType] [varchar](10) NULL,
	[FileGroupTypeDescription] [varchar](30) NULL,
	[FileGroupDefault] [bit] NULL,
	[FileGroupReadOnly] [bit] NULL,
 CONSTRAINT [PK_DatabaseFileInfo] PRIMARY KEY CLUSTERED 
(
	[InstanceID] ASC,
	[DatabaseID] ASC,
	[ReadingDate] ASC,
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Monitoring]
) ON [Monitoring]
GO
/****** Object:  Table [Monitoring].[DatabaseInfo]    Script Date: 16/03/2018 12:13:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Monitoring].[DatabaseInfo](
	[InstanceID] [int] NOT NULL,
	[Name] [varchar](128) NOT NULL,
	[ReadingDate] [datetime2](7) NOT NULL,
	[AutoClose] [bit] NULL,
	[AutoCreateStatisticsEnabled] [bit] NULL,
	[AutoShrink] [bit] NULL,
	[AutoUpdateStatisticsAsync] [bit] NULL,
	[AutoUpdateStatisticsEnabled] [bit] NULL,
	[AvailabilityDatabaseSynchronizationState] [varchar](20) NULL,
	[AvailabilityGroupName] [varchar](128) NULL,
	[CaseSensitive] [bit] NULL,
	[Collation] [varchar](50) NULL,
	[CompatibilityLevel] [varchar](30) NULL,
	[CreateDate] [datetime2](7) NULL,
	[DatabaseOwnershipChaining] [bit] NULL,
	[DatabaseSnapshotBaseName] [varchar](128) NULL,
	[DataSpaceUsage] [float] NULL,
	[DefaultFileGroup] [varchar](128) NULL,
	[DefaultFileStreamFileGroup] [varchar](128) NULL,
	[DelayedDurability] [varchar](10) NULL,
	[EncryptionEnabled] [bit] NULL,
	[FilestreamDirectoryName] [varchar](128) NULL,
	[FilestreamNonTransactedAccess] [varchar](10) NULL,
	[HasMemoryOptimizedObjects] [bit] NULL,
	[IndexSpaceUsage] [float] NULL,
	[IsAccessible] [bit] NULL,
	[IsDatabaseSnapshot] [bit] NULL,
	[IsDatabaseSnapshotBase] [bit] NULL,
	[IsFullTextEnabled] [bit] NULL,
	[IsMirroringEnabled] [bit] NULL,
	[IsParameterizationForced] [bit] NULL,
	[IsReadCommittedSnapshotOn] [bit] NULL,
	[IsSystemObject] [bit] NULL,
	[IsUpdateable] [bit] NULL,
	[LastBackupDate] [datetime2](7) NULL,
	[LastDifferentialBackupDate] [datetime2](7) NULL,
	[LastLogBackupDate] [datetime2](7) NULL,
	[LogReuseWaitStatus] [varchar](20) NULL,
	[Owner] [varchar](128) NULL,
	[PageVerify] [varchar](20) NULL,
	[PrimaryFilePath] [varchar](128) NULL,
	[ReadOnly] [bit] NULL,
	[RecoveryModel] [varchar](10) NULL,
	[ReplicationOptions] [varchar](50) NULL,
	[Size] [float] NULL,
	[SnapshotIsolationState] [varchar](10) NULL,
	[SpaceAvailable] [float] NULL,
	[Status] [varchar](50) NULL,
	[TargetRecoveryTime] [int] NULL,
	[TemporalHistoryRetentionEnabled] [varchar](10) NULL,
	[Trustworthy] [bit] NULL,
	[UserAccess] [varchar](30) NULL,
	[Version] [int] NULL,
 CONSTRAINT [PK_Databases] PRIMARY KEY CLUSTERED 
(
	[InstanceID] ASC,
	[Name] ASC,
	[ReadingDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Monitoring]
) ON [Monitoring]
GO
/****** Object:  Table [Monitoring].[DiskSpaceInfo]    Script Date: 16/03/2018 12:13:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Monitoring].[DiskSpaceInfo](
	[ComputerID] [smallint] NOT NULL,
	[ComputerName] [varchar](128) NOT NULL,
	[ReadingDate] [datetime] NOT NULL,
	[Name] [varchar](128) NOT NULL,
	[Label] [varchar](128) NULL,
	[PercentFree] [decimal](10, 2) NULL,
	[BlockSize] [int] NULL,
	[FileSystem] [varchar](15) NULL,
	[IsSqlDisk] [bit] NULL,
	[DriveType] [varchar](30) NULL,
	[SizeInBytes] [bigint] NULL,
	[FreeInBytes] [bigint] NULL,
 CONSTRAINT [PK_DiskSpace] PRIMARY KEY CLUSTERED 
(
	[ComputerID] ASC,
	[ReadingDate] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Monitoring]
) ON [Monitoring]
GO
/****** Object:  Table [Monitoring].[PageFileSettingInfo]    Script Date: 16/03/2018 12:13:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Monitoring].[PageFileSettingInfo](
	[ComputerId] [smallint] NOT NULL,
	[FileName] [varchar](128) NOT NULL,
	[ReadingDate] [datetime] NOT NULL,
	[AutoPageFile] [bit] NULL,
	[Status] [varchar](20) NULL,
	[LastModified] [datetime2](7) NULL,
	[LastAccessed] [datetime2](7) NULL,
	[AllocatedBaseSize] [bigint] NULL,
	[InitialSize] [bigint] NULL,
	[MaximumSize] [bigint] NULL,
	[PeakUsage] [bigint] NULL,
	[CurrentUsage] [bigint] NULL,
 CONSTRAINT [PK_PageFileSettingInfo_1] PRIMARY KEY CLUSTERED 
(
	[ComputerId] ASC,
	[FileName] ASC,
	[ReadingDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Monitoring]
) ON [Monitoring]
GO
/****** Object:  Table [Monitoring].[SQLInstanceInfo]    Script Date: 16/03/2018 12:13:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Monitoring].[SQLInstanceInfo](
	[InstanceID] [smallint] NOT NULL,
	[ReadingDate] [datetime] NOT NULL,
	[VersionString] [varchar](20) NULL,
	[VersionName] [varchar](40) NULL,
	[Edition] [varchar](128) NULL,
	[ServicePack] [varchar](3) NULL,
	[ServerType] [varchar](50) NULL,
	[Collation] [varchar](50) NULL,
	[IsCaseSensitive] [bit] NULL,
	[IsHADREnabled] [bit] NULL,
	[HADREndpointPort] [int] NULL,
	[IsSQLClustered] [bit] NULL,
	[ClusterName] [varchar](30) NULL,
	[ClusterQuorumstate] [varchar](20) NULL,
	[ClusterQuorumType] [varchar](50) NULL,
	[AGs] [varchar](max) NULL,
	[AGListener] [varchar](max) NULL,
	[SQLService] [varchar](50) NULL,
	[SQLServiceAccount] [varchar](128) NULL,
	[SQLServiceStartMode] [varchar](10) NULL,
	[SQLAgentServiceAccount] [varchar](128) NULL,
	[SQLAgentServiceStartMode] [varchar](10) NULL,
	[BrowserAccount] [varchar](128) NULL,
	[BrowserStartMode] [varchar](10) NULL,
	[DefaultFile] [varchar](128) NULL,
	[DefaultLog] [varchar](128) NULL,
	[BackupDirectory] [varchar](128) NULL,
	[InstallDataDirectory] [varchar](128) NULL,
	[InstallSharedDirectory] [varchar](128) NULL,
	[MasterDBPath] [varchar](128) NULL,
	[MasterDBLogPath] [varchar](128) NULL,
	[ErrorLogPath] [varchar](128) NULL,
	[IsFullTextInstalled] [bit] NULL,
	[LinkedServer] [smallint] NULL,
	[LoginMode] [varchar](10) NULL,
	[TcpEnabled] [bit] NULL,
	[NamedPipesEnabled] [bit] NULL,
	[C2AuditMode] [tinyint] NULL,
	[CommonCriteriaComplianceEnabled] [bit] NULL,
	[CostThresholdForParallelism] [smallint] NULL,
	[DBMailEnabled] [bit] NULL,
	[DefaultBackupCompression] [bit] NULL,
	[FillFactor] [tinyint] NULL,
	[MaxDegreeOfParallelism] [smallint] NULL,
	[MaxMem] [int] NULL,
	[MinMem] [int] NULL,
	[OptimizeAdhocWorkloads] [bit] NULL,
	[RemoteDacEnabled] [bit] NULL,
	[XPCmdShellEnabled] [bit] NULL,
 CONSTRAINT [PK_SQLInstanceInfo] PRIMARY KEY CLUSTERED 
(
	[InstanceID] ASC,
	[ReadingDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Monitoring]
) ON [Monitoring] TEXTIMAGE_ON [Monitoring]
GO
/****** Object:  Table [Monitoring].[SqlInstancePropertyInfo]    Script Date: 16/03/2018 12:13:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Monitoring].[SqlInstancePropertyInfo](
	[InstanceID] [smallint] NOT NULL,
	[ReadingDate] [datetime] NOT NULL,
	[PropertyType] [varchar](20) NOT NULL,
	[Name] [varchar](40) NOT NULL,
	[Value] [varchar](128) NULL,
	[Writable] [bit] NULL,
	[Readable] [bit] NULL,
	[Expensive] [bit] NULL,
	[Dirty] [bit] NULL,
	[Retrieved] [bit] NULL,
	[IsNull] [bit] NULL,
	[Enabled] [bit] NULL,
	[Required] [bit] NULL,
	[Attributes] [varchar](128) NULL,
 CONSTRAINT [PK_SqlInstancePropertyInfo] PRIMARY KEY CLUSTERED 
(
	[InstanceID] ASC,
	[ReadingDate] ASC,
	[PropertyType] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Monitoring]
) ON [Monitoring]
GO
/****** Object:  Table [Monitoring].[SqlServiceInfo]    Script Date: 16/03/2018 12:13:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Monitoring].[SqlServiceInfo](
	[ComputerId] [smallint] NOT NULL,
	[DisplayName] [varchar](128) NOT NULL,
	[ReadingDate] [datetime2](7) NOT NULL,
	[StartName] [varchar](128) NULL,
	[ServiceType] [varchar](128) NULL,
	[State] [varchar](20) NULL,
	[StartMode] [varchar](20) NULL,
	[InstanceName] [varchar](128) NULL,
 CONSTRAINT [PK_SQLServiceInfo] PRIMARY KEY CLUSTERED 
(
	[ComputerId] ASC,
	[DisplayName] ASC,
	[ReadingDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Monitoring]
) ON [Monitoring]
GO
/****** Object:  Table [Staging].[DbaAgentAlert]    Script Date: 16/03/2018 12:13:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Staging].[DbaAgentAlert](
	[InstanceId] [smallint] NULL,
	[SqlInstance] [varchar](128) NULL,
	[ReadingDate] [datetime2](7) NULL,
	[ComputerName] [varchar](128) NULL,
	[InstanceName] [varchar](128) NULL,
	[Name] [varchar](128) NULL,
	[CategoryName] [nvarchar](128) NULL,
	[DatabaseName] [varchar](128) NULL,
	[DelayBetweenResponses] [smallint] NULL,
	[EventDescriptionKeyword] [varchar](100) NULL,
	[EventSource] [varchar](100) NULL,
	[HasNotification] [int] NULL,
	[IncludeEventDescription] [varchar](128) NULL,
	[IsEnabled] [bit] NULL,
	[JobID] [uniqueidentifier] NULL,
	[JobName] [varchar](128) NULL,
	[LastOccurrenceDate] [datetime2](7) NULL,
	[LastResponseDate] [datetime2](7) NULL,
	[MessageID] [int] NULL,
	[NotificationMessage] [varchar](512) NULL,
	[OccurrenceCount] [int] NULL,
	[PerformanceCondition] [varchar](512) NULL,
	[Severity] [int] NULL,
	[WmiEventNamespace] [varchar](512) NULL,
	[WmiEventQuery] [varchar](512) NULL
) ON [Staging]
GO
/****** Object:  Table [Staging].[DbaAgentJob]    Script Date: 16/03/2018 12:13:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Staging].[DbaAgentJob](
	[InstanceId] [smallint] NULL,
	[InstanceName] [varchar](128) NULL,
	[ReadingDate] [datetime] NULL,
	[ComputerName] [varchar](128) NULL,
	[SqlInstance] [varchar](128) NULL,
	[Enabled] [bit] NULL,
	[Name] [varchar](128) NULL,
	[JobID] [uniqueidentifier] NULL,
	[Description] [varchar](max) NULL,
	[CategoryID] [int] NULL,
	[Category] [varchar](128) NULL,
	[IsEnabled] [bit] NULL,
	[HasSchedule] [bit] NULL,
	[HasStep] [bit] NULL,
	[StartStepID] [int] NULL,
	[DateCreated] [datetime2](7) NULL,
	[DateLastModified] [datetime2](7) NULL,
	[VersionNumber] [int] NULL,
	[OwnerLoginName] [varchar](128) NULL,
	[DeleteLevel] [varchar](10) NULL,
	[EmailLevel] [varchar](10) NULL,
	[OperatorToEmail] [varchar](128) NULL,
	[EventLogLevel] [varchar](10) NULL,
	[LastRunDate] [datetime2](7) NULL,
	[LastRunOutcome] [varchar](10) NULL,
	[NextRunDate] [datetime2](7) NULL,
	[CurrentRunRetryAttempt] [int] NULL,
	[CurrentRunStatus] [varchar](10) NULL,
	[CurrentRunStep] [varchar](128) NULL,
	[CategoryType] [tinyint] NULL,
	[JobType] [varchar](11) NULL,
	[OriginatingServer] [varchar](128) NULL,
	[HasServer] [bit] NULL
) ON [Staging] TEXTIMAGE_ON [Staging]
GO
/****** Object:  Table [Staging].[DbaComputerSystem]    Script Date: 16/03/2018 12:13:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Staging].[DbaComputerSystem](
	[InputName] [varchar](128) NULL,
	[ComputerName] [varchar](128) NULL,
	[Domain] [varchar](128) NULL,
	[DomainRole] [varchar](128) NULL,
	[Manufacturer] [varchar](128) NULL,
	[Model] [varchar](128) NULL,
	[SystemType] [varchar](128) NULL,
	[NumberLogicalProcessors] [bigint] NULL,
	[NumberProcessors] [bigint] NULL,
	[IsHyperThreading] [bit] NULL,
	[TotalPhysicalMemory] [bigint] NULL,
	[IsDaylightSavingsTime] [bit] NULL,
	[DaylightInEffect] [bit] NULL,
	[DnsHostName] [varchar](128) NULL
) ON [Info]
GO
/****** Object:  Table [Staging].[DbaDatabase]    Script Date: 16/03/2018 12:13:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Staging].[DbaDatabase](
	[ComputerName] [varchar](128) NULL,
	[InstanceName] [varchar](128) NULL,
	[SqlInstance] [varchar](128) NULL,
	[Name] [varchar](128) NULL,
	[CreateDate] [datetime2](7) NULL,
	[Collation] [varchar](40) NULL,
	[CompatibilityLevel] [varchar](30) NULL,
	[Owner] [varchar](128) NULL,
	[AutoClose] [bit] NULL,
	[AutoShrink] [bit] NULL,
	[AutoCreateStatisticsEnabled] [bit] NULL,
	[AutoUpdateStatisticsEnabled] [bit] NULL,
	[AutoUpdateStatisticsAsync] [bit] NULL,
	[CaseSensitive] [bit] NULL,
	[Status] [varchar](50) NULL,
	[LogReuseWaitStatus] [varchar](20) NULL,
	[IsSystemObject] [bit] NULL,
	[IsAccessible] [bit] NULL,
	[IsDatabaseSnapshot] [bit] NULL,
	[DatabaseSnapshotBaseName] [varchar](128) NULL,
	[IsDatabaseSnapshotBase] [bit] NULL,
	[ReadOnly] [bit] NULL,
	[UserAccess] [varchar](30) NULL,
	[Version] [int] NULL,
	[RecoveryModel] [varchar](10) NULL,
	[LastBackupDate] [datetime2](7) NULL,
	[LastDifferentialBackupDate] [datetime2](7) NULL,
	[LastLogBackupDate] [datetime2](7) NULL,
	[TargetRecoveryTime] [int] NULL,
	[PageVerify] [varchar](20) NULL,
	[PrimaryFilePath] [varchar](128) NULL,
	[DefaultFileGroup] [varchar](128) NULL,
	[Size] [float] NULL,
	[SpaceAvailable] [float] NULL,
	[DataSpaceUsage] [float] NULL,
	[IndexSpaceUsage] [float] NULL,
	[EncryptionEnabled] [bit] NULL,
	[IsFullTextEnabled] [bit] NULL,
	[IsMirroringEnabled] [bit] NULL,
	[IsParameterizationForced] [bit] NULL,
	[IsReadCommittedSnapshotOn] [bit] NULL,
	[SnapshotIsolationState] [varchar](10) NULL,
	[ReplicationOptions] [varchar](40) NULL,
	[AvailabilityDatabaseSynchronizationState] [varchar](20) NULL,
	[AvailabilityGroupName] [varchar](128) NULL,
	[IsUpdateable] [bit] NULL,
	[DelayedDurability] [varchar](10) NULL,
	[Trustworthy] [bit] NULL,
	[DatabaseOwnershipChaining] [bit] NULL,
	[TemporalHistoryRetentionEnabled] [varchar](10) NULL,
	[HasMemoryOptimizedObjects] [bit] NULL,
	[DefaultFileStreamFileGroup] [varchar](128) NULL,
	[FilestreamDirectoryName] [varchar](128) NULL,
	[FilestreamNonTransactedAccess] [varchar](10) NULL
) ON [Info]
GO
/****** Object:  Table [Staging].[DbaDatabaseFile]    Script Date: 16/03/2018 12:13:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Staging].[DbaDatabaseFile](
	[ComputerName] [varchar](128) NULL,
	[InstanceName] [varchar](128) NULL,
	[SqlInstance] [varchar](128) NULL,
	[Database] [varchar](128) NULL,
	[FileGroupName] [varchar](128) NULL,
	[ID] [int] NULL,
	[Type] [tinyint] NULL,
	[TypeDescription] [varchar](128) NULL,
	[LogicalName] [varchar](128) NULL,
	[PhysicalName] [varchar](128) NULL,
	[State] [varchar](30) NULL,
	[MaxSize] [bigint] NULL,
	[Growth] [int] NULL,
	[GrowthType] [varchar](10) NULL,
	[NextGrowthEventSize] [bigint] NULL,
	[Size] [bigint] NULL,
	[UsedSpace] [bigint] NULL,
	[AvailableSpace] [bigint] NULL,
	[IsOffline] [bit] NULL,
	[IsReadOnly] [bit] NULL,
	[IsReadOnlyMedia] [bit] NULL,
	[IsSparse] [bit] NULL,
	[NumberOfDiskWrites] [bigint] NULL,
	[NumberOfDiskReads] [bigint] NULL,
	[ReadFromDisk] [bigint] NULL,
	[WrittenToDisk] [bigint] NULL,
	[VolumeFreeSpace] [bigint] NULL,
	[FileGroupDataSpaceId] [int] NULL,
	[FileGroupType] [varchar](10) NULL,
	[FileGroupTypeDescription] [varchar](30) NULL,
	[FileGroupDefault] [bit] NULL,
	[FileGroupReadOnly] [bit] NULL
) ON [Staging]
GO
/****** Object:  Table [Staging].[DbaDiskSpace]    Script Date: 16/03/2018 12:13:58 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Staging].[DbaDiskSpace](
	[ComputerName] [varchar](128) NOT NULL,
	[ReadingDate] [datetime2](7) NOT NULL,
	[Name] [varchar](128) NOT NULL,
	[Label] [varchar](128) NULL,
	[PercentFree] [decimal](10, 2) NULL,
	[BlockSize] [int] NULL,
	[FileSystem] [varchar](15) NULL,
	[IsSqlDisk] [bit] NULL,
	[DriveType] [varchar](30) NULL,
	[SizeInBytes] [bigint] NULL,
	[FreeInBytes] [bigint] NULL
) ON [Info]
GO
/****** Object:  Table [Staging].[DbaLastGoodCheckDb]    Script Date: 16/03/2018 12:13:58 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Staging].[DbaLastGoodCheckDb](
	[InstanceId] [smallint] NULL,
	[SqlInstance] [varchar](128) NULL,
	[ReadingDate] [datetime2](7) NULL,
	[ComputerName] [varchar](128) NULL,
	[InstanceName] [varchar](128) NULL,
	[Database] [varchar](128) NULL,
	[DatabaseCreated] [datetime2](7) NULL,
	[LastGoodCheckDb] [datetime2](7) NULL,
	[DaysSinceLastGoodCheckDb] [int] NULL,
	[DaysSinceDbCreated] [int] NULL,
	[Status] [varchar](30) NULL,
	[DataPurityEnabled] [bit] NULL,
	[CreateVersion] [smallint] NULL
) ON [Staging]
GO
/****** Object:  Table [Staging].[DbaNetworkName]    Script Date: 16/03/2018 12:13:58 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Staging].[DbaNetworkName](
	[InputName] [varchar](128) NULL,
	[ReadingDate] [date] NULL,
	[ComputerName] [varchar](128) NULL,
	[IPAddress] [varchar](39) NULL,
	[FQDN] [varchar](128) NULL,
	[FullComputerName] [varchar](128) NULL
) ON [Info]
GO
/****** Object:  Table [Staging].[DbaOperatingSystem]    Script Date: 16/03/2018 12:13:58 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Staging].[DbaOperatingSystem](
	[InputName] [varchar](128) NULL,
	[ComputerName] [varchar](128) NULL,
	[Manufacturer] [varchar](128) NULL,
	[Architecture] [varchar](128) NULL,
	[Version] [varchar](128) NULL,
	[Build] [varchar](20) NULL,
	[OSVersion] [varchar](128) NULL,
	[SPVersion] [tinyint] NULL,
	[InstallDate] [datetime2](7) NULL,
	[LastBootTime] [datetime2](7) NULL,
	[LocalDateTime] [datetime2](7) NULL,
	[PowerShellVersion] [varchar](10) NULL,
	[TimeZone] [varchar](128) NULL,
	[TimeZoneStandard] [varchar](128) NULL,
	[TimeZoneDaylight] [varchar](128) NULL,
	[BootDevice] [varchar](128) NULL,
	[SystemDevice] [varchar](128) NULL,
	[SystemDrive] [varchar](10) NULL,
	[WindowsDirectory] [varchar](128) NULL,
	[PagingFileSize] [bigint] NULL,
	[TotalVisibleMemory] [bigint] NULL,
	[FreePhysicalMemory] [bigint] NULL,
	[TotalVirtualMemory] [bigint] NULL,
	[FreeVirtualMemory] [bigint] NULL,
	[ActivePowerPlan] [varchar](128) NULL,
	[Status] [varchar](10) NULL,
	[Language] [varchar](128) NULL,
	[LanguageAlias] [varchar](128) NULL,
	[CountryCode] [varchar](10) NULL
) ON [Info]
GO
/****** Object:  Table [Staging].[DbaPageFileSetting]    Script Date: 16/03/2018 12:13:58 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Staging].[DbaPageFileSetting](
	[InputName] [varchar](128) NULL,
	[ComputerName] [varchar](128) NULL,
	[AutoPageFile] [bit] NULL,
	[FileName] [varchar](128) NULL,
	[Status] [varchar](20) NULL,
	[LastModified] [datetime2](7) NULL,
	[LastAccessed] [datetime2](7) NULL,
	[AllocatedBaseSize] [bigint] NULL,
	[InitialSize] [bigint] NULL,
	[MaximumSize] [bigint] NULL,
	[PeakUsage] [bigint] NULL,
	[CurrentUsage] [bigint] NULL
) ON [Info]
GO
/****** Object:  Table [Staging].[DbaSqlInstance]    Script Date: 16/03/2018 12:13:58 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Staging].[DbaSqlInstance](
	[InstanceId] [smallint] NULL,
	[InstanceName] [varchar](128) NULL,
	[ReadingDate] [datetime] NULL,
	[ComputerName] [varchar](128) NULL,
	[VersionString] [varchar](20) NULL,
	[VersionName] [varchar](40) NULL,
	[Edition] [varchar](128) NULL,
	[ServicePack] [varchar](5) NULL,
	[ServerType] [varchar](50) NULL,
	[Collation] [varchar](50) NULL,
	[IsCaseSensitive] [bit] NULL,
	[IsHADREnabled] [bit] NULL,
	[HADREndpointPort] [int] NULL,
	[IsSQLClustered] [bit] NULL,
	[ClusterName] [varchar](128) NULL,
	[ClusterQuorumstate] [varchar](20) NULL,
	[ClusterQuorumType] [varchar](50) NULL,
	[AGs] [varchar](max) NULL,
	[AGListener] [varchar](max) NULL,
	[SQLService] [varchar](50) NULL,
	[SQLServiceAccount] [varchar](128) NULL,
	[SQLServiceStartMode] [varchar](10) NULL,
	[SQLAgentServiceAccount] [varchar](128) NULL,
	[SQLAgentServiceStartMode] [varchar](10) NULL,
	[BrowserAccount] [varchar](128) NULL,
	[BrowserStartMode] [varchar](10) NULL,
	[DefaultFile] [varchar](128) NULL,
	[DefaultLog] [varchar](128) NULL,
	[BackupDirectory] [varchar](128) NULL,
	[InstallDataDirectory] [varchar](128) NULL,
	[InstallSharedDirectory] [varchar](128) NULL,
	[MasterDBPath] [varchar](128) NULL,
	[MasterDBLogPath] [varchar](128) NULL,
	[ErrorLogPath] [varchar](128) NULL,
	[IsFullTextInstalled] [bit] NULL,
	[LinkedServer] [smallint] NULL,
	[LoginMode] [varchar](10) NULL,
	[TcpEnabled] [bit] NULL,
	[NamedPipesEnabled] [bit] NULL,
	[C2AuditMode] [tinyint] NULL,
	[CommonCriteriaComplianceEnabled] [bit] NULL,
	[CostThresholdForParallelism] [smallint] NULL,
	[DBMailEnabled] [bit] NULL,
	[DefaultBackupCompression] [bit] NULL,
	[FillFactor] [tinyint] NULL,
	[MaxDegreeOfParallelism] [smallint] NULL,
	[MaxMem] [int] NULL,
	[MinMem] [int] NULL,
	[OptimizeAdhocWorkloads] [bit] NULL,
	[RemoteDacEnabled] [bit] NULL,
	[XPCmdShellEnabled] [bit] NULL
) ON [Info] TEXTIMAGE_ON [Info]
GO
/****** Object:  Table [Staging].[DbaSqlInstanceProperty]    Script Date: 16/03/2018 12:13:58 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Staging].[DbaSqlInstanceProperty](
	[ComputerName] [varchar](128) NULL,
	[InstanceName] [varchar](128) NULL,
	[SqlInstance] [varchar](128) NULL,
	[PropertyType] [varchar](20) NULL,
	[Name] [varchar](40) NULL,
	[Value] [varchar](128) NULL,
	[Type] [varchar](50) NULL,
	[Writable] [bit] NULL,
	[Readable] [bit] NULL,
	[Expensive] [bit] NULL,
	[Dirty] [bit] NULL,
	[Retrieved] [bit] NULL,
	[IsNull] [bit] NULL,
	[Enabled] [bit] NULL,
	[Required] [bit] NULL,
	[Attributes] [varchar](128) NULL
) ON [Info]
GO
/****** Object:  Table [Staging].[DbaSqlService]    Script Date: 16/03/2018 12:13:58 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Staging].[DbaSqlService](
	[ComputerName] [varchar](128) NOT NULL,
	[ReadingDate] [datetime2](7) NOT NULL,
	[DisplayName] [varchar](128) NULL,
	[StartName] [varchar](128) NULL,
	[ServiceType] [varchar](128) NULL,
	[State] [varchar](20) NULL,
	[StartMode] [varchar](20) NULL,
	[InstanceName] [varchar](128) NULL,
	[ReadingId] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_SQLServiceData] PRIMARY KEY CLUSTERED 
(
	[ReadingId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Info]
) ON [Info]
GO
/****** Object:  Table [Staging].[DbaSuspectPage]    Script Date: 16/03/2018 12:13:58 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Staging].[DbaSuspectPage](
	[InstanceId] [smallint] NULL,
	[SqlInstance] [varchar](128) NULL,
	[ReadingDate] [datetime2](7) NULL,
	[ComputerName] [varchar](128) NULL,
	[InstanceName] [varchar](128) NULL,
	[Database] [varchar](128) NULL,
	[FileId] [smallint] NULL,
	[PageId] [smallint] NULL,
	[EventType] [varchar](30) NULL,
	[ErrorCount] [int] NULL,
	[LastUpdateDate] [datetime2](7) NULL
) ON [Staging]
GO
ALTER TABLE [Config].[Applications] ADD  CONSTRAINT [DF_Applications_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [Config].[NotificationStatus] ADD  CONSTRAINT [DF_NotificationStatus_StartTime]  DEFAULT (getdate()) FOR [StartTime]
GO
ALTER TABLE [Config].[NotificationStatus] ADD  CONSTRAINT [DF_NotificationStatus_EndTime]  DEFAULT ('2199-12-31') FOR [EndTime]
GO
ALTER TABLE [info].[ApplicationDatabaseLookup] ADD  CONSTRAINT [DF_ApplicationDatabaseLookup_LastUpdate]  DEFAULT (getdate()) FOR [LastUpdate]
GO
ALTER TABLE [info].[ComputerList] ADD  CONSTRAINT [DF_ComputerList_MonitorOptions]  DEFAULT ((0)) FOR [MonitorOptions]
GO
ALTER TABLE [info].[ComputerList] ADD  CONSTRAINT [DF_Servers_NotContactable]  DEFAULT ((0)) FOR [NotContactable]
GO
ALTER TABLE [info].[ComputerList] ADD  CONSTRAINT [DF_Servers_createDate]  DEFAULT (getdate()) FOR [createDate]
GO
ALTER TABLE [info].[ComputerList] ADD  CONSTRAINT [DF_Servers_updateDate]  DEFAULT (getdate()) FOR [updateDate]
GO
ALTER TABLE [info].[SQLInstanceList] ADD  CONSTRAINT [DF_SQLInstanceList_IsActive]  DEFAULT ((0)) FOR [IsActive]
GO
ALTER TABLE [info].[ComputerInfo]  WITH CHECK ADD  CONSTRAINT [FK_ComputerInfo_ComputerList] FOREIGN KEY([ComputerID])
REFERENCES [info].[ComputerList] ([ComputerID])
GO
ALTER TABLE [info].[ComputerInfo] CHECK CONSTRAINT [FK_ComputerInfo_ComputerList]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'MonitorOptions' , @level0type=N'SCHEMA',@level0name=N'Config', @level1type=N'TABLE',@level1name=N'MonitorOption'
GO
