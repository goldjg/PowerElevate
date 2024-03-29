
function Set-CDotNetConnectionString
{
    <#
    .SYNOPSIS
    Sets a named connection string in the .NET machine.config file

    .DESCRIPTION
    The connection string setting can be set in up to four different machine.config files:
     
     * .NET 2.0 32-bit (switches -Clr2 -Framework)
     * .NET 2.0 64-bit (switches -Clr2 -Framework64)
     * .NET 4.0 32-bit (switches -Clr4 -Framework)
     * .NET 4.0 64-bit (switches -Clr4 -Framework64)
      
    Any combination of Framework and Clr switch can be used, but you MUST supply one of each.

    .LINK
    Set-CDotNetAppSetting

    .LINK
    Remove-CDotNetAppSetting

    .EXAMPLE
    > Set-CDotNetConnectionString -Name DevDB -Value "data source=.\DevDB;Integrated Security=SSPI;" -Framework -Framework64 -Clr2 -Clr4
    
    Sets the DevDB connection string in the following machine.config files:
     
     * `%SYSTEMROOT%\Microsoft.NET\Framework\v2.0.50727\CONFIG\machine.config`
     * `%SYSTEMROOT%\Microsoft.NET\Framework64\v2.0.50727\CONFIG\machine.config`
     * `%SYSTEMROOT%\Microsoft.NET\Framework\v4.0.30319\CONFIG\machine.config`
     * `%SYSTEMROOT%\Microsoft.NET\Framework64\v4.0.30319\CONFIG\machine.config`

    .EXAMPLE
    > Set-CDotNetConnectionString -Name DevDB -Value "data source=.\DevDB;Integrated Security=SSPI;" -Framework64 -Clr4
    
    Sets the DevDB connection string in the `%SYSTEMROOT%\Microsoft.NET\Framework64\v4.0.30319\CONFIG\machine.config` machine.config file to:
     
        <add name="DevDB" connectionString="data source=.\DevDB;Integrated Security=SSPI;" />


    .EXAMPLE
    Set-CDotNetConnectionString -Name Prod -Value "data source=proddb\Prod;Integrated Security=SSPI" -ProviderName 'System.Data.SqlClient' -Framework -Clr2

    Creates the following connection string in the `%SYSTEMROOT%\Microsoft.NET\Framework\v2.0.50727\CONFIG\machine.config` file:

        <add name="Prod" connectionString="data source=proddb\Prod;Integrated Security=SSPI" providerName="System.Data.SqlClient" />

    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the .net connection string to be set
        $Name,

        [Parameter(Mandatory=$true)]
        [string]
        # The connection string to be set.
        $Value,

        [string]
        # The provider name for the connection string.
        $ProviderName,
        
        [Switch]
        # Set the connection string in the 32-bit machine.config.
        $Framework,
        
        [Switch]
        # Set the connection string in the 64-bit machine.config
        $Framework64,
        
        [Switch]
        # Set the app setting in the .NET 2.0 machine.config.  This flag won't work under PowerShell 3.0.
        $Clr2,
        
        [Switch]
        # Set the app setting in the .NET 4.0 machine.config.
        $Clr4
    )
    
    Set-StrictMode -Version 'Latest'

    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    if( -not ($Framework -or $Framework64) )
    {
        Write-Error "You must supply either or both of the Framework and Framework64 switches."
        return
    }
    
    if( -not ($Clr2 -or $Clr4) )
    {
        Write-Error "You must supply either or both of the Clr2 and Clr4 switches."
        return
    }
    
    $runtimes = @()
    if( $Clr2 )
    {
        $runtimes += 'v2.0'
    }
    if( $Clr4 )
    {
        $runtimes += 'v4.0'
    }

    $runtimes | ForEach-Object {
        $params = @{
            FilePath = (Join-Path $CarbonBinDir 'Set-DotNetConnectionString.ps1' -Resolve);
            ArgumentList = @(
                                (ConvertTo-CBase64 -Value $Name -NoWarn),
                                (ConvertTo-CBase64 -Value $Value -NoWarn),
                                (ConvertTo-CBase64 -Value $ProviderName -NoWarn)
                            );
            Runtime = $_;
            ExecutionPolicy = [Microsoft.PowerShell.ExecutionPolicy]::RemoteSigned;
        }

        if( $Framework )
        {    
            Invoke-CPowerShell @params -x86 -NoWarn
        }
        
        if( $Framework64 )
        {
            Invoke-CPowerShell @params -NoWarn
        }
    }
}

