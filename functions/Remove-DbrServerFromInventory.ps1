Function Remove-DbrServerFromInventory
{
<#
	.SYNOPSIS 
		Removes a server from the dbareports inventory of sql servers.

	.DESCRIPTION
		Removes instance/server from the instance list table within the dba reports database. Doing so will mean you are no longer able to report on that server. If you have decommissioned the server but still want to report/hold information on it then use the Set-DbrInstanceInactiveInInventory cmdlet instead.

	.PARAMETER 
	Dynamic parameter returns a list of servers/instances

	.LINK
		https://dbareports.io/functions/Remove-DbrServerFromInventory

	.EXAMPLE
		Remove-DbrServerFromInventory SQLServer01
		Removes the server "SQLServer01" from the instance list table within the dba reports database.


	#>
		[CmdletBinding()]
		Param ()
	
	DynamicParam { return Get-ParamSqlServerInventory }
	
	BEGIN
	{
        $Module = "dbareports"
		
        $SqlInstance = Get-DbrConfigValue -Name app.sqlinstance
        $InstallDatabase = Get-DbrConfigValue -Name app.databasename
        $SqlCredential = Get-DbrConfigValue -Name app.sqlcredential
		
        # Connect to dbareports server
        try {
            Write-PSFMessage -Level Verbose  -Message "Connecting to $SqlInstance" -Tag $Module
            $Server = Connect-DbaInstance -SqlInstance $SqlInstance -SqlCredential $SqlCredential 
        }
        catch {
            Stop-PSFFunction -Message "Failed to connect to $SqlInstance" -ErrorRecord $_ -Tag $Module #-EnableException $EnableException 
            break
        }

		
		# Get columns automatically from the table on the SQL Server
		# and creates the necessary $script:datatable with it
		$table = "dbo.InstanceList"
		$schema = $table.Split(".")[0]
		$tablename = $table.Split(".")[1]
		
		$Instances = $psboundparameters.Instance
		$ServerNames = $psboundparameters.ServerName
		
	}
	
	PROCESS
	{
		
		foreach ($instance in $Instances)
		{
			$sql = "delete from $table where InstanceName = '$instance'"
			
			try
			{
				Write-Output "Removing $instance"
				$null = $sourceserver.Databases[$InstallDatabase].ExecuteNonQuery($sql)
			}
			catch
			{
				Write-Output "Unable to delete $instance using SQL: $sql"
				Write-Exception $_
				Continue
			}
		}
		
		foreach ($server in $ServerNames)
		{
			$sql = "delete from $table where ServerName = '$server'"
			
			try
			{
				Write-Output "Removing $server"
				$null = $sourceserver.Databases[$InstallDatabase].ExecuteNonQuery($sql)
			}
			catch
			{
				Write-Warning "Unable to delete $server"
				Write-Exception $_
				Continue
			}
		}
	}
	
	END
	{
		$sourceserver.ConnectionContext.Disconnect()
		
	}
}