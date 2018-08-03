Function Install-DbaReports
{
    <#
    .SYNOPSIS 
        Installs both the server and client components for dbareports. To install only the client component, use Install-DbaReportsClient.

    .DESCRIPTION
        Installs the following on the specified SQL server:
    
        Database with all required tables, stored procedures, extended properties etc.
        Adds the executing account (SQL Agent account if no proxy specified) as dbo to the database
        Proxy/Credential (if required)
        Agent Category ("dbareports collection jobs")
        Agent Jobs
        Job Schedules
        Copies PowerShell files to SQL Server or shared network directory
    
        - If the specified database does not exist, you will be prompted to confirm that the script should create it.
        - If no Proxy Account is specified, you will be prompted to create one automatically or accept that the Agent ServiceAccount has access
        - If no InstallDirectory is specified, the SQL Server's backup directory will be used by default
        - If no LogFileDirectory is specified, InstallDirectory\logs will be used 
        
        Installs the following on the local client
        
        Config file at Documents\WindowsPowerShell\Modules\dbareports\dbareports-config.json
        
        The config file is pretty simple. This is for Windows (Trusted) Authentication
    
        {
        "Username":  null,
        "SqlServer":  "sql2016",
        "InstallDatabase":  "dbareports",
        "SecurePassword":  null
        }
    
        And the following for SQL Login
        {
        "Username":  "sqladmin",
        "SqlServer":  "sql2016",
        "InstallDatabase":  "dbareports",
        "SecurePassword":  "01000000d08c9ddf0115d1118c7a00c04fc297eb010000etcetc"
        }
        
        Or alternative Windows credentials 
        {
        "Username":  "ad\\dataadmin",
        "SqlServer":  "sqlcluster",
        "InstallDatabase":  "dbareports",
        "SecurePassword":  "01000000d08c9ddf0115d1118c7a00c04fc297eb010000etcetc"
        }
        
        Note that only the account that created the config file can decrypt the SecurePassword
    
    .PARAMETER SqlServer
        The SQL Server Instance that will hold the dbareports database and the agent jobs
    
    .PARAMETER SqlCredential
        Allows you to login to servers using SQL Logins as opposed to Windows Auth/Integrated/Trusted.
    
    .PARAMETER InstallDatabase
        The name of the database that will hold all of the information that the agent jobs gather. Defaults to dbareports
    
    .PARAMETER InstallPath
        The folder that will hold the PowerShell scripts that the Agent Jobs call and the logfiles for the agent jobs. The Agent account or Proxy must have access to this folder.
    
        If no InstallPath is specified, the SQL Server's default backup directory is used. 
    
    .PARAMETER LogFileFolder
        The folder where the logs from the Agent Jobs will be written. Defaults to the "logs" folder in the Installpath directory.
    
    .PARAMETER LogFileRetention
        The number of days to keep the Log Files defaults to 30 days
    
    .PARAMETER JobPrefix
        The Prefix that gets added to the Agent Jobs defaults to dbareports
    
    .PARAMETER JobCategory 
        The category for the Agent Jobs. Defaults to "dbareports collection jobs"
    
    .PARAMETER TimeSpan
        By default, the jobs are scheduled to execute daily unless NoJobSchedule is specified. The default time is 04:15. To change the time, pass different timespan.
    
        $customtimespan = New-TimeSpan -hours 22 -minutes 15
    
        This would set the schedule the jobs for 10:15 PM.
    
    .PARAMETER ReportsFolder
        The folder where the report samples will be stored on the client (?)
    
    .PARAMETER NoDatabaseObjects
        A switch which will not update or create the database and its related objects
    
    .PARAMETER NoJobs
        A switch which will not install the Agent Jobs
    
    .PARAMETER NoPsFileCopy
        A switch which will not copy the PowerShell scripts
    
    .PARAMETER NoJobSchedule
        A switch which will not schedule the Agent Jobs
    
    .PARAMETER NoConfig
        A switch which will not create the json config file on the local machine. 
    
    .PARAMETER NoAlias
        A switch which means the script will not create an alias for the dbareports server
    
    .PARAMETER NoShortcut
        A switch which means the script will not create a shortcut on the desktop
    
    .PARAMETER Force
        A switch to force the installation of dbareports. This will drop and recreate everything and all of your data will be lost. "Use the force wisely DBA"
    
    .PARAMETER Confirm
        Prompts you for confirmation before executing the command.
    
    .PARAMETER WhatIf
        This doesnt work as install is too dynamic. Show what would happen if the cmdlet was run.
    
    .NOTES 
        dbareports PowerShell module (https://dbareports.io, SQLDBAWithABeard.com)
        Copyright (C) 2016 Rob Sewell
        
    .LINK
        https://dbareports.io/Install-DbaReports
    
    .EXAMPLE
        Install-DBAreports -SqlServer sql2016
    
    Installs the dbareports database on SQL2016 and uses all defaults. Will not output to screen but will log to a log file in C:\Users\$ENV:USERNAME\Documents\WindowsPowerShell\Modules\dbareports\dbareports_install_DATE.txt
    
    .EXAMPLE
    Install-DBAreports -SqlServer sql2016 -InstallPath \\fileshare\share\sql
    
    Installs the dbareports database on the server sql2016 and the powershell script files at \\fileshare\share\sql Will not output to screen but will log to a log file in C:\Users\$ENV:USERNAME\Documents\WindowsPowerShell\Modules\dbareports\dbareports_install_DATE.txt
    
    .EXAMPLE
    Install-DBAreports -SqlServer sql2016 -InstallPath \\fileshare\share\sql -Verbose
    
    Installs the dbareports database on the server sql2016 and the powershell script files at \\fileshare\share\sql Will output to screen and will log to a log file in C:\Users\$ENV:USERNAME\Documents\WindowsPowerShell\Modules\dbareports\dbareports_install_DATE.txt
    #>
    [CmdletBinding(SupportsShouldProcess = $true)] 
    [OutputType([String])]
    Param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Alias("ServerInstance", "SqlServer")]
        [object]$SqlInstance,
        [PSCredential]$SqlCredential,
        [Alias("Database")]
        [string]$InstallDatabase = "dbareports",
        [string]$InstallPath,
        [string]$JobPrefix = "dbareports",
        [string]$LogFileFolder,
        [int]$LogFileRetention = 30,
        [string]$ReportsFolder,
        [switch]$NoDatabaseObjects,
        [switch]$NoJobs,
        [switch]$NoPsFileCopy,
        [switch]$NoJobSchedule,
        [switch]$NoConfig,
        [switch]$NoShortcut,
        [switch]$NoAlias,
        [string]$JobCategory = "dbareports collection jobs",
        [timespan]$TimeSpan = $(New-TimeSpan -hours 4 -minutes 15),
        [switch]$Force
    )
	
#    DynamicParam { if ($SqlInstance) 
#        {
#            return (Get-ParamSqlProxyAccount -SqlServer $SqlInstance -SqlCredential $SqlCredential) 
#        }
#    }
	
    BEGIN {
        Write-PSFMessage -Level Verbose  -Message "Install-DbaReports starting" -Tag "dbareports:install" -Target "dbareports:install" 

        $DBVersion = '0.1.0' # Updates extended property and runs migration scripts for that version
        $parentPath = Split-Path -Parent $PSScriptRoot
        $ProxyAccount = $psboundparameters.ProxyAccount
		
	    # Connect to dbareports server
	    try {
            Write-PSFMessage -Level Verbose  -Message "Connecting to $SqlInstance" -Tag "dbareports"
            $Server = Connect-DbaInstance -SqlInstance $SqlInstance -SqlCredential $SqlCredential 
	    }
	    catch {
            Write-PSFMessage -Level Warning -Message "Failed to connect to $SqlInstance" -ErrorRecord $_ -Tag "dbareports"
            break
	    }

        # Check suitable version
        if ($Server.VersionMajor -lt 10) {
            Write-PSFMessage -Level Warning -Message "The dbareports database must be installed on SQL Server 2008 and above." -ErrorRecord $_ -Tag "dbareports" -Target ""
            break
        }

        # Check if installpath set
        if ($InstallPath.Length -eq 0) {
            Write-PSFMessage -Level Warning -Message "No install path specified" -ErrorRecord $_ -Tag "dbareports" -Target ""
            break
        }

        if ($InstallPath -notlike '*dbareports*') {
            $InstallPath = "$InstallPath\dbareports"
        }

        # Set logging folder if not set
        if ($LogFileFolder.Length -eq 0) {
            $LogFileFolder = "$InstallPath\logs"
            Write-PSFMessage -Level Info  -Message "No log file path specified, using $LogFileFolder" -Tag "dbareports"
        }

        if ($TimeSpan.Days -gt 0) {
            Write-PSFMessage -Level Warning -Message "This is a daily schedule so the days cannot exceed 0" -ErrorRecord $_ -Tag "dbareports" -Target ""
            break
        }

        # ensure agent is running
        try {
            $agent = $Server.EnumProcesses() | Where-Object {
                $_.Program -like '*Agent*' 
            }
        }
        catch {
            Write-PSFMessage -Level Warning -Message "Failed to gather Agent Process on $($Server.name)" -ErrorRecord $_ -Tag "dbareports" -Target ""
            break
        }

        if ($agent.count -eq 0) {
            Write-PSFMessage -Level Warning -Message "SQL Server Agent does not appear to be running." -ErrorRecord $_ -Tag "dbareports" -Target ""
            break
        }
    }

    process {
        
        $InstallDatabaseExists = $Server.Databases[$InstallDatabase].Count
        $source = $Server.DomainInstanceName
        $sqlaccount = $Server.ServiceAccount
        $agentaccount = $Server.JobServer.ServiceAccount

        $InstallDatabaseExists 

        # Uninstall if -Force specified
        if ($Force -eq $true) {
            if ($Server.Databases[$InstallDatabase].Count -ne 0) {
                Write-PSFMessage -Level Warn -Message "Force specified. Removing everything." -Tag "dbareports"
                if ($PSCmdlet.ShouldProcess("Forcing the uninstall of the previous version of dbareports including database")) { 
                    #Uninstall-DbaReports -Force -ErrorAction SilentlyContinue
                }
            }
        }

    }

}

Install-DbaReports -SqlServer LensmanSB
