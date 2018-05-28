Function Install-DbaReportsClient {
    <#
	.SYNOPSIS 
		Installs only the client component configuration entries of DbaReports

	.DESCRIPTION
		Installs the following configuration entries for DbaReports

			app.sqlinstance 
			app.databasename
			app.sqlcredential

		Entries are Created and Persisted using the Configuration framework from PSFramework 

		Note that only the account that created the config entries can decrypt and use the SqlCredential.
	
	.PARAMETER SqlServer
		The SQL Server Instance that holds the dbareports database.
    
    .PARAMETER SqlCredential
        Allows you to login to servers using SQL Logins as opposed to Windows Auth/Integrated/Trusted.
    
    .PARAMETER InstallDatabase
        The name of the database used for dbareports. Defaults to dbareports
 
	
	.NOTES 
		dbareports PowerShell module (https://dbareports.io, SQLDBAWithABeard.com)
		Copyright (C) 2016 Rob Sewell

		This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

		This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

	.LINK
		https://dbareports.io/functions/Install-DbaReportsClient

	.EXAMPLE
		Install-DbaReportsClient -SqlServer SQL2016 

		Registers the database dbareports on SQL Server Instance SQL2016 as Source for dbareports
		Connection via Windows Authentication 
		 
#>
    [CmdletBinding()]
    #SupportsShouldProcess = $true not yet
    Param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Alias("ServerInstance", "SqlInstance")]
        [object]$SqlServer,
        [PSCredential]$SqlCredential,
        [Alias("Database")]
        [string]$InstallDatabase = "dbareports"
    )
	
    DynamicParam { if ($SqlServer) { return (Get-ParamSqlProxyAccount -SqlServer $SqlServer -SqlCredential $SqlCredential) } }
	
    BEGIN {
        $Module = "dbareports"
		
        # Connect to dbareports server
        try {
            Write-PSFMessage -Level Verbose  -Message "Connecting to $SqlInstance" -Tag $Module
            $Server = Connect-DbaInstance -SqlInstance $SqlInstance -SqlCredential $SqlCredential 
        }
        catch {
            Stop-PSFFunction -Message "Failed to connect to $SqlInstance" -ErrorRecord $_ -Tag $Module #-EnableException $EnableException 
            break
        }
		
        # Check suitable version
        if ($Server.VersionMajor -lt 11) {
            Stop-PSFFunction -Message "The dbareports database can only be installed on SQL Server 2012 and above. Invalid server." -Tag $Module
            return
        }
    }
	
    PROCESS {
        $dbexists = $Server.Databases[$InstallDatabase]
        if ($dbexists -eq $null) {
            throw "Database $InstallDatabase not found"
            Stop-PSFFunction -Message "Database $InstallDatabase not found" -Tag $Module
            return
        }
		
        # Record Config Values
        if (-not (Get-DbrConfig -Name app.sqlinstance)) {
            Set-PSFConfig -Module $Module  -Name app.sqlinstance -Value $SqlInstance -Initialize -Description "The SQL Server Instance that will hold the dbareports database and the agent jobs"
            Set-PSFConfig -Module $Module  -Name app.databasename -Value $InstallDatabase -Initialize -Description "The name of the database that will hold all of the information that the agent jobs gather."

            #Set-PSFConfig -Module dbareports -Name app.sqlcredential -Value $null -Initialize -Description "The universal SQL credential if Trusted/Windows Authentication is not used"
            #Set-PSFConfig -Module dbareports -Name app.wincredential -Value $null -Initialize -Description "The universal Windows credential if default Windows Authentication is not used"
        }
        else {
            Set-DbrConfig -Name app.databasename -Value $InstallDatabase
            Set-DbrConfig -Name app.installpath -Value $InstallPath
        }
        
    }
	
    END {
        Write-PSFMessage -Level Verbose  -Message "`nThanks for installing dbareports! You may now run Add-DbrServerToInventory to add a new server to your inventory." -Tag $Module
        $Server.ConnectionContext.Disconnect()
    }
}