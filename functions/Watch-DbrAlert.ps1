Function Watch-DbrAlert
{
<# 
 .SYNOPSIS 
Uses NotifyIcon and a XAML window to display summary of health checks for items collected by dbareports. 
	
.DESCRIPTION 
If any fail, you can then view the SSRS or PowerBi dashboards for more info.

.NOTES 
dbareports PowerShell module (https://dbareports.io, SQLDBAWithABeard.com)
Copyright (C) 2016 Rob Sewell

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

.LINK
https://dbareports.io/Watch-DbrAlert

.EXAMPLE
Watch-DbrAlert
	
Automatically determines dbareport configuration information, and displays information about servers. 
	
Note that the PowerShell window will disappear.


#>	
	[CmdletBinding()]
	Param ()
	
	BEGIN
	{
		try { Add-Type -AssemblyName PresentationFramework, System.Windows.Forms }
		catch { throw "Failed to load Windows Presentation Framework assemblies." }
		
		Get-Config
		$SqlServer = $script:SqlServer
		$InstallDatabase = $script:InstallDatabase
		$SqlCredential = $script:SqlCredential
		
		if ($SqlServer.length -eq 0)
		{
			throw "No config file found. Have you installed dbareports? Please run Install-DbaReports or Install-DbaReportsClient"
		}
		
		$sourceserver = Connect-SqlServer -SqlServer $sqlserver -SqlCredential $SqlCredential
		
		Function Get-Base64Icon
		{
			[CmdletBinding()]
			Param (
				[string]$base64
			)
			# Create a streaming image by streaming the base64 string to a bitmap streamsource
			$bitmap = New-Object System.Windows.Media.Imaging.BitmapImage
			$bitmap.BeginInit()
			$bitmap.StreamSource = [System.IO.MemoryStream][System.Convert]::FromBase64String($base64)
			$bitmap.EndInit()
			$bitmap.Freeze()
			
			# Convert the bitmap into an icon
			$image = [System.Drawing.Bitmap][System.Drawing.Image]::FromStream($bitmap.StreamSource)
			$icon = [System.Drawing.Icon]::FromHandle($image.GetHicon())
			return $icon
		}
		
		Function Get-Base64Image
		{
			[CmdletBinding()]
			Param (
				[string]$base64
			)
			# Create a streaming image by streaming the base64 string to a bitmap streamsource
			$bitmap = New-Object System.Windows.Media.Imaging.BitmapImage
			$bitmap.BeginInit()
			$bitmap.StreamSource = [System.IO.MemoryStream][System.Convert]::FromBase64String($base64)
			$bitmap.EndInit()
			$bitmap.Freeze()
			return $bitmap
		}
		
		function New-ConnectivityRunSpace
		{
			Param (
				[string]$sqlserver
			)
			
			$scriptblock = {
				Param (
					[string]$sqlserver
				)
				
				try
				{
					$testConnect = New-Object Microsoft.SqlServer.Management.Smo.Server $sqlserver
					$testConnect.ConnectionContext.ConnectTimeout = 2
					$testConnect.ConnectionContext.Connect()
					$testConnect.ConnectionContext.Disconnect()
					return "Healthy"
				}
				catch
				{
					$exception = ($_.Exception.InnerException.InnerException).ToString()
					
					if ($exception -like "*A network-related or instance-specific error*")
					{
						return "Alarms"
					}
					elseif ($exception -like "*Login failed*")
					{
						return "Healthy"
					}
					else
					{
						return "Warnings"
					}
				}
			}
			
			$runspace = [PowerShell]::Create()
			$null = $runspace.AddScript($scriptblock)
			$null = $runspace.AddArgument($sqlserver)
			$runspace.RunspacePool = $script:pool
			return $runspace
		}
		
		function New-MonitorRunSpace
		{
			Param (
				[string]$monitor
			)
			
			$scriptblock = {
				Param (
					[object]$server,
					[string]$monitor
				)
				
				$sql = 'Select 25 as Healthy, 0 as Warnings, 0 as Alarms'
				$results = $server.ConnectionContext.ExecuteWithResults($sql).Tables
				
				$healthy = $results.Healthy.ToString()
				
				Add-Content -Value "$monitor $healthy" -Path C:\temp\rs.txt
				$newobject = [PSCustomObject]@{
					'Monitor' = $monitor
					'Healthy' = $results.Healthy.ToString()
					'Warnings' = $results.Warnings.ToString()
					'Alarms' = $results.Alarms.ToString()
				}
				
				return $newobject
			}
			
			$runspace = [PowerShell]::Create()
			$null = $runspace.AddScript($scriptblock)
			$null = $runspace.AddArgument($sourceserver)
			$null = $runspace.AddArgument($monitor)
			$runspace.RunspacePool = $script:pool
			return $runspace
		}
		
		function Update-ListView
		{
			$tempitemsource = @()
			$script:pool = [RunspaceFactory]::CreateRunspacePool(1, [int]($env:NUMBER_OF_PROCESSORS) + 1)
			$pool.ApartmentState = "MTA"
			$pool.Open()
			$connectionrunspaces = $runspaces = @()
			$alertjson = Get-AlertConfig
			$health = $errors = $warnings = 0
			$monitors = 'DiskSpace', 'JobStatus', 'SuspectPage', 'FullBackup', 'LogBackup'
			
			foreach ($monitor in $monitors)
			{
				write-warning $monitor
				$monitorconfig = $alertjson.$monitor
				$runspace = New-MonitorRunSpace -Monitor $monitor
				$runspaces += [PSCustomObject]@{ Pipe = $runspace; Status = $runspace.BeginInvoke() }
			}
			
			# Test if they're online
			foreach ($servername in (Get-Instances))
			{
				$runspace = New-ConnectivityRunSpace -sqlserver $servername.Name
				$connectionrunspaces += [PSCustomObject]@{ Pipe = $runspace; Status = $runspace.BeginInvoke() }
			}
			
			# Finish up T-SQL query-based runspaces
			while ($runspaces.Status.IsCompleted -notcontains $true) { }
			
			foreach ($runspace in $runspaces)
			{
				# EndInvoke method retrieves the results of the asynchronous call
				$tempitemsource += $runspace.Pipe.EndInvoke($runspace.Status)
				$runspace.Pipe.Dispose()
			}
			
			# Finish up connection attempt runspaces
			while ($connectionrunspaces.Status.IsCompleted -notcontains $true) { }
			
			$health = $warnings = $alarms = 0
			foreach ($runspace in $connectionrunspaces)
			{
				switch ($runspace.Pipe.EndInvoke($runspace.Status))
				{
					"Healthy" { $health++ }
					"Warnings" { $warnings++ }
					"Alarms" { $alarms++ }
				}
				
				$runspace.Pipe.Dispose()
			}
			
			$tempitemsource += [PSCustomObject]@{
				'Monitor' = "Online"
				'Healthy' = $health
				'Warnings' = $warnings
				'Alarms' = $alarms
			}
			
			$pool.Close()
			$pool.Dispose()
			
			$script:olditemsource = $script:itemsource
			$script:itemsource = $tempitemsource
		}
		
		Function Update-WindowStatus
		{
			Param (
				[string]$title = "dbareports alert status changed"
			)
			
			if ($script:itemsource.length -eq 0)
			{
				Update-ListView
			}
			
			$listviewJobs.ItemsSource = $script:itemsource
			$timestamp.Content = "Last Updated: $(Get-Date)"
			
			# this is old code to make the notify icon dynamic 
			# and to pop up a Toast that says there has been a failure.
			
			if ($oldjobfailures -ne $script:jobfailures -or $oldbackupfailures -ne $script:backupfailures -or $oldjobfailures -eq $null)
			{
				if ($script:jobfailures -gt 0 -or $script:backupfailures -gt 0)
				{
					if ($script:jobfailures -gt 0)
					{
						$warn += "$($script:jobfailures) jobs have failed"
					}
					if ($script:backupfailures -gt 0)
					{
						$warn += "`n$($script:backupfailures) backups are out of date"
					}
					
					$notifyicon.Icon = $redicon
					$notifyicon.Text = $warn
					$image.source = $redimage
					
					$notifyicon.ShowBalloonTip($null, $title, $warn, [System.Windows.Forms.ToolTipIcon]"Error")
					Remove-Variable -Name warn -ErrorAction SilentlyContinue
				}
				else
				{
					$notifyicon.Icon = $logoicon
					$notifyicon.Text = $warn
					$notifyicon.Visible = $true
					$image.source = $logoimage
				}
			}
		}
	}
	
	PROCESS
	{
		Write-Output "Please wait one moment while we perform the initial population of data :)"
		
		# currently don't have yellow icon
		$base64logo = "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"
		$base64red = "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAFRUlEQVR4Xu3aeWwUVRwH8O+bY4+ekoj+ZYwhMQGUQCptWhttsy1YIx4YTACNRyMpisVgsR5UEWksqFSJogTiQf0DTLQFJcbShQpJjy2IQUVMJMT/aE0bkm6P7c7OmFlT4nTr7sy7iGn7Z/f93u99PzM783ZnCWb4H5nh+TELMHsGXCOBaKhoEYFVbMJSVZCzwXCkhwCW7OVIfwsMVy2Za8X1zxQL9zrDkkgioazN7+z+QyaCVIBoqOhGWIkTIMr86UOa/RbRynM7en6ThSANIHP4ychyEaQAuA8vH0E4gPfwchGEAtCHl4cgDIA9vBwEIQDJ8DCOA+oCPldzcRdG7gD8w4s9E7gCiAsvDoEbgPjwYhC4AMgLzx+BGUB+eL4ITADDy0puIInYCa9Xe1/NRpDr5zpuENbgICY+avZ402C/O1AD0Ia3Ewb3tkCZd6sjrHnpIsaeXuMRwB7OhkAFwBI+CbB7P5QFtzsBfj+PsWefpABgQ/AMwBreXm7gnT1QFxc4wibOncX4phpKAHoETwA8wicBGpuhFpU4AU73YvylWgYAOgTXAP+Et7e3WMi4Svi3NkErLXcCdJ3C+Gt1rFN7via4AuAZ3k7of/kNaKF7HGGNzmOIbd/CAcDbmZARgHf4JMALr0Krut8J0H4UsZ3bOAG4R0gLICK8vTTfhjroD65yAnzbith7TRwB3CH8J4Co8EmAdbXQH1nrCBv/6iDFRsiNV/p9wrQAV0pL52i+iZMguM1NC69jfE+sg/5otRPg4OeY2L/H61Qux5v9hmXded3xMxenFkwLEC0v/AIKnIfIZSs3w/TVj8NX/Yxj6MSBfYgf2O+mnGqMBasnJ9xXMvXhSwpA8sHFuH5ZUaBQdXJRpD+8Gr71zzsB9n2A+KEWF9X0QwiswuxwX9+/Z0gBiFYuDcEkHfRtMldqK1bCv7HeCfDhLsRbD2UuZhhBgJrscGRvWoDhyqV3E5N0MvTJWKotvw/+zQ2OcbHmt2AcbctYyzKAEFKd3dH7SVqAwaqiPH0i0a9ACbA0S1erlVXCv2W7E2DHVhjHvhPVMjmvqSbm57WfuZAWwH4xGircCWCzqNWoJXchsO1tJ8Cbr8D4ISyqpf3YuTU3HFk5tcG0dwFr1UJfdCj7CAGWi1iRekcRAk27HVOPN9Qh0X1KRDv7ofsvJkFZXjgy6ArAHmQVFwej2fE2YinLeK9KXbQEgV0fOwFefA6JHyO8WyXDW5oWym3vGphu8rRbYWEImgaSneNYjzUSBQyDL0CG8HazjB+GhCHwjZo6m4vwrgCEvh10H4iuwRod5cvhMrxrAN4IJBiEr7YeWnkFoOkwz/+M2LuNMP+8xA7hIbwngEmEkSzjMEAqWVbqr38dWqXzJ0LWXwMYfewhtuuAx/CeAXghZLV1gOTkphiObXgK5oVf6WwpwlMB8EAIfvollJtuTgk6uuYBWAOXvQNQhqcGYEWwvxD1NzQCqno1rPHN14i9v0NqeCYAVgTllnnQKqqArCwkTvci0XUSsDz+TpLhyE9KZ9wHZDok9j6Bx4UxU5+U1zmEZz4DJheVRAiYR6BYFZ6D0BRwCs8N4OrbQQYCx/BcAaQgcA7PHUAogoDwQgCEIAgKLwyAK4LA8EIBkggrCrJGotph6ruD4PDCAZgQJISXAkCFICm8NABPCBLDSwVwhSA5vHSAJEJZWWBEHWkyTbJeUeCz/2fCNBRCWuJGfNOczp+u0OyOaWuYPwzRNh6qKMjXibIYlkpMlZzL/757iHYulrprBsCyaJ61swA8Nf+Pc834M+Bv3q/SX94+OnUAAAAASUVORK5CYII="
		$base64green = "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"
		
		$logoicon = Get-Base64Icon $base64logo
		$logoimage = Get-Base64Image $base64logo
		$redicon = Get-Base64Icon $base64red
		$greenicon = Get-Base64Icon $base64green
		
		# Create XAML form in Visual Studio, ensuring the ListView looks chromeless
		[xml]$xaml = '<Window
			xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
			xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
			Name="window" WindowStyle="None" Height="270" Width="475" ResizeMode="NoResize" ShowInTaskbar="False">
		    <Window.Resources>
        <Style TargetType="GridViewColumnHeader">
            <Setter Property="Background" Value="Transparent" />
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="BorderBrush" Value="Transparent"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="GridViewColumnHeader">
                        <Border Background="#555555">
                            <ContentPresenter></ContentPresenter>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>
    <Grid Name="grid" Background="#555555" Width="650">
        <Label x:Name="label" Content="SQL Server Estate Health Summary" Margin="50,10,0,15" Foreground="White" FontSize="18" FontFamily="Segoe WP Semibold"/>
        <Image Name="image" HorizontalAlignment="Left" Height="32" Margin="11,12,0,0" VerticalAlignment="Top" Width="32"/>
        <StackPanel Margin="0,55,0,0">
			<ListView Name="listviewJobs" SelectionMode="Single" Foreground="White"  ScrollViewer.HorizontalScrollBarVisibility="Hidden"
				Background="Transparent" BorderBrush="Transparent" IsHitTestVisible="False">
				<ListView.ItemContainerStyle>
					<Style>
						<Setter Property="Control.HorizontalContentAlignment" Value="Stretch"/>
						<Setter Property="Control.VerticalContentAlignment" Value="Stretch"/>
					</Style>
				</ListView.ItemContainerStyle>
			</ListView>
			<ListView Name="listview1" SelectionMode="Single" Foreground="White"
				Background="Transparent" BorderBrush="Transparent" IsHitTestVisible="False">
				<ListView.ItemContainerStyle>
					<Style>
						<Setter Property="Control.HorizontalContentAlignment" Value="Stretch"/>
						<Setter Property="Control.VerticalContentAlignment" Value="Stretch"/>
					</Style>
				</ListView.ItemContainerStyle>
			</ListView>
			<Label Name="timestamp" HorizontalContentAlignment="Right" Margin="0,15,180,0" Foreground="White"/>
        </StackPanel>
    </Grid>
</Window>'
		
		# Turn XAML into PowerShell objects
		$window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml))
		$xaml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $window.FindName($_.Name) -Scope Script }
		
		$columnorder = 'Monitor', 'Healthy', 'Warnings', 'Alarms'
		
		# Dynamic populator
		# Populate ListView with PS Object data and set width
		$listviewJobs.Width = $grid.width * .95
		
		# Create GridView object to add to ListView
		$gridview = New-Object System.Windows.Controls.GridView
		
		# Dynamically add columns to GridView, then bind data to columns
		foreach ($column in $columnorder)
		{
			$gridcolumn = New-Object System.Windows.Controls.GridViewColumn
			$gridcolumn.Header = $column
			$gridcolumn.Width = $grid.width * .19
			
			$gridbinding = New-Object System.Windows.Data.Binding $column
			$gridcolumn.DisplayMemberBinding = $gridbinding
			$gridview.AddChild($gridcolumn)
		}
		
		# Add GridView to ListView
		$listviewJobs.view = $gridview
		
		# Create notifyicon, and right-click -> Exit menu
		$notifyicon = New-Object System.Windows.Forms.NotifyIcon
		$menuitem = New-Object System.Windows.Forms.MenuItem
		$menuitem.Text = "Exit"
		
		$contextmenu = New-Object System.Windows.Forms.ContextMenu
		$notifyicon.ContextMenu = $contextmenu
		$notifyicon.contextMenu.MenuItems.AddRange($menuitem)
		
		# Close the popup window if it's double clicked
		$window.Add_MouseDoubleClick({
				$window.Hide()
			})
		
		# Close the popup window if any other window is clicked
		$window.Add_Deactivated({
				$window.Hide()
			})
		
		# When Exit is clicked, close everything and kill the PowerShell process
		$menuitem.add_Click({
				$notifyicon.Visible = $false
				$window.Close()
				Stop-Process $pid
			})
		
		# Show window when the notifyicon is clicked with the left mouse button
		# Recall that the right mouse button brings up the contextmenu
		$notifyicon.add_Click({
				if ($_.Button -eq [Windows.Forms.MouseButtons]::Left)
				{
					# reposition each time, in case the resolution changes
					$window.Left = $([System.Windows.SystemParameters]::WorkArea.Width - $window.Width)
					$window.Top = $([System.Windows.SystemParameters]::WorkArea.Height - $window.Height)
					$window.Show()
					$window.Activate()
				}
			})
		
		$notifyicon.add_BalloonTipClicked({
				$window.Show()
			})
		
		$notifyicon.Visible = $true
		
		Update-WindowStatus -Title "Current Status"
		
		$buildlistviewtimer = New-Object System.Windows.Forms.Timer
		$buildlistviewtimer.Interval = 150000
		$buildlistviewtimer.add_Tick({
				# Build script level $listview in runspace?
				Update-ListView
			})
		
		$timer = New-Object System.Windows.Forms.Timer
		$timer.Interval = 200000
		$timer.add_Tick({
				Update-WindowStatus
			})
		
		<# Make PowerShell Disappear
		$windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
		$asyncwindow = Add-Type -MemberDefinition $windowcode -name Win32ShowWindowAsync -namespace Win32Functions -PassThru
		$null = $asyncwindow::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 0)
		#>
		
		# Force garbage collection just to start slightly lower RAM usage.
		[System.GC]::Collect()
		
		$buildlistviewtimer.start()
		$timer.start()
		
		# Create an application context for it to all run within.
		$appContext = New-Object System.Windows.Forms.ApplicationContext
		[void][System.Windows.Forms.Application]::Run($appContext)
	}
}