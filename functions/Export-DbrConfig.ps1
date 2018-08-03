function Export-DbrConfig {
    <#
        .SYNOPSIS
            Exports dbareports configs to a json file to make it easier to modify or be used for specific configurations.
        
        .DESCRIPTION
            Exports dbareports configs to a json file to make it easier to modify or be used for specific configurations.
    
        .PARAMETER Path
            The path to export to, by default is "$script:localapp\config.json"
    
        .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.
        
        .EXAMPLE
            Export-DbrConfig
            
            Exports config to "$script:localapp\config.json"
    
        .EXAMPLE
            Export-DbrConfig -Path \\nfs\projects\config.json
            
            Exports config to \\nfs\projects\config.json
    #>
    [CmdletBinding()]
    param (
        [string]$Path = "$script:localapp\config.json",
        [switch]$EnableException
    )
    
    try {
        Get-DbrConfig | Select-Object * | ConvertTo-Json -Depth 10 | Out-File -FilePath $Path -ErrorAction Stop
        Write-PSFMessage -Message "Wrote file to $Path" -Level Output
    }
    catch {
        Stop-PSFFunction -Message $_ -Target $Path
    }
}